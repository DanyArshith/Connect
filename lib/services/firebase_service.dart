import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/business_model.dart';

class FirebaseService {
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth methods
  static auth.User? get currentUser => _auth.currentUser;
  static Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  static Future<auth.UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'customer',
  }) async {
    try {
      final auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'favorites': [],
        'businesses': [],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      return userCredential;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  static Future<auth.UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // User methods
  static Future<User?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  static Future<void> updateUserData(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  static Future<void> addToFavorites(String userId, String businessId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([businessId]),
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  static Future<void> removeFromFavorites(
    String userId,
    String businessId,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([businessId]),
      });
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  static Future<bool> toggleFavorite(String userId, String businessId) async {
    try {
      final favoriteRef = _firestore
          .collection('favorites')
          .doc('${userId}_$businessId');

      final favoriteDoc = await favoriteRef.get();
      final isFavorite = favoriteDoc.exists;

      if (isFavorite) {
        // Remove from favorites
        await favoriteRef.delete();

        // Also remove from user's favorites array for backward compatibility
        await _firestore.collection('users').doc(userId).update({
          'favorites': FieldValue.arrayRemove([businessId]),
        });

        return false;
      } else {
        // Add to favorites
        await favoriteRef.set({
          'userId': userId,
          'businessId': businessId,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });

        // Also add to user's favorites array for backward compatibility
        await _firestore.collection('users').doc(userId).update({
          'favorites': FieldValue.arrayUnion([businessId]),
        });

        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Business methods - Get stream for real-time updates
  static Stream<List<Business>> businessesStream() {
    return _firestore
        .collection('businesses')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Business.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Business methods - Get stream with filters for real-time updates
  static Stream<List<Business>> businessesStreamFiltered({
    String? category,
    String? location,
    String? searchQuery,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('businesses')
        .where('isActive', isEqualTo: true);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    return query.snapshots().map((snapshot) {
      List<Business> businesses = snapshot.docs
          .map((doc) => Business.fromMap(doc.data(), doc.id))
          .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lower = searchQuery.toLowerCase();
        businesses = businesses.where((b) {
          return b.name.toLowerCase().contains(lower) ||
              b.description.toLowerCase().contains(lower) ||
              b.category.toLowerCase().contains(lower);
        }).toList();
      }

      businesses.sort((a, b) {
        if (a.rating != b.rating) return b.rating.compareTo(a.rating);
        return b.createdAt.compareTo(a.createdAt);
      });

      return businesses;
    });
  }

  // Business methods
  static Future<List<Business>> getBusinesses({
    String? category,
    String? location,
    String? searchQuery,
  }) async {
    try {
      Query query = _firestore
          .collection('businesses')
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }

      final QuerySnapshot snapshot = await query.get();
      List<Business> businesses = snapshot.docs
          .map(
            (doc) =>
                Business.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      // Filter by search query if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        businesses = businesses.where((business) {
          return business.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              business.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              business.category.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
        }).toList();
      }

      // Sort by rating and creation date
      businesses.sort((a, b) {
        if (a.rating != b.rating) {
          return b.rating.compareTo(a.rating);
        }
        return b.createdAt.compareTo(a.createdAt);
      });

      return businesses;
    } catch (e) {
      throw Exception('Failed to get businesses: $e');
    }
  }

  static Future<Business?> getBusinessById(String businessId) async {
    try {
      final doc = await _firestore
          .collection('businesses')
          .doc(businessId)
          .get();
      if (doc.exists) {
        return Business.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get business: $e');
    }
  }

  // Business by id stream (real-time)
  static Stream<Business?> businessByIdStream(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .snapshots()
        .map(
          (doc) => doc.exists ? Business.fromMap(doc.data()!, doc.id) : null,
        );
  }

  static Future<String> addBusiness(Business business) async {
    try {
      final docRef = await _firestore
          .collection('businesses')
          .add(business.toMap());

      // Update user's businesses list
      await _firestore.collection('users').doc(business.ownerId).update({
        'businesses': FieldValue.arrayUnion([docRef.id]),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add business: $e');
    }
  }

  static Future<void> updateBusiness(
    String businessId,
    Business business,
  ) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(businessId)
          .update(business.toMap());
    } catch (e) {
      throw Exception('Failed to update business: $e');
    }
  }

  static Future<void> deleteBusiness(String businessId) async {
    try {
      // Get business to find owner
      final businessDoc = await _firestore
          .collection('businesses')
          .doc(businessId)
          .get();
      if (businessDoc.exists) {
        final businessData = businessDoc.data()!;
        final ownerId = businessData['ownerId'];

        // Update user's businesses list
        await _firestore.collection('users').doc(ownerId).update({
          'businesses': FieldValue.arrayRemove([businessId]),
        });
      }

      // Soft delete the business
      await _firestore.collection('businesses').doc(businessId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to delete business: $e');
    }
  }

  static Future<List<Business>> getUserBusinesses(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('businesses')
          .where('ownerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                Business.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get user businesses: $e');
    }
  }

  // User businesses stream (real-time)
  static Stream<List<Business>> userBusinessesStream(String userId) {
    return _firestore
        .collection('businesses')
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Business.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  static Future<List<Business>> getFavoriteBusinesses(
    List<String> businessIds,
  ) async {
    try {
      if (businessIds.isEmpty) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('businesses')
          .where(FieldPath.documentId, whereIn: businessIds)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                Business.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get favorite businesses: $e');
    }
  }

  // Get user favorites stream for real-time updates
  static Stream<List<Business>> userFavoritesStream(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return <Business>[];

          final businessIds = <String>[];
          for (final doc in snapshot.docs) {
            final businessId = doc.data()['businessId'];
            if (businessId is String) {
              businessIds.add(businessId);
            }
          }

          if (businessIds.isEmpty) return <Business>[];

          final businessesSnapshot = await _firestore
              .collection('businesses')
              .where(FieldPath.documentId, whereIn: businessIds)
              .where('isActive', isEqualTo: true)
              .get();

          return businessesSnapshot.docs
              .map((doc) => Business.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  static Future<List<Business>> getUserFavorites(String userId) async {
    try {
      // Get favorite business IDs from the separate favorites collection
      final favoritesSnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      if (favoritesSnapshot.docs.isEmpty) return [];

      final businessIds = <String>[];
      for (final doc in favoritesSnapshot.docs) {
        final businessId = doc.data()['businessId'];
        if (businessId is String) {
          businessIds.add(businessId);
        }
      }

      if (businessIds.isEmpty) return [];

      // Get the actual business documents
      final businessesSnapshot = await _firestore
          .collection('businesses')
          .where(FieldPath.documentId, whereIn: businessIds)
          .where('isActive', isEqualTo: true)
          .get();

      return businessesSnapshot.docs
          .map((doc) => Business.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user favorites: $e');
    }
  }

  static Future<bool> isBusinessFavorite(
    String userId,
    String businessId,
  ) async {
    try {
      final favoriteDoc = await _firestore
          .collection('favorites')
          .doc('${userId}_$businessId')
          .get();
      return favoriteDoc.exists;
    } catch (e) {
      throw Exception('Failed to check if business is favorite: $e');
    }
  }

  // User data stream (real-time)
  static Stream<User?> userDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromMap(doc.data()!, doc.id) : null);
  }

  // Storage methods
  static Future<String> uploadImage(File imageFile, String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Categories and locations
  static Future<List<String>> getCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('businesses')
          .get();
      final Set<String> categories = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['category'] != null) {
          categories.add(data['category']);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Feedback methods
  static Future<void> addFeedback(
    String businessId,
    String userId,
    String userName,
    String comment,
    double rating,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Add feedback to business document
        final businessRef = _firestore.collection('businesses').doc(businessId);
        final businessDoc = await transaction.get(businessRef);

        if (!businessDoc.exists) {
          throw Exception('Business not found');
        }

        final businessData = businessDoc.data()!;
        final feedbacks = List<Map<String, dynamic>>.from(
          businessData['feedbacks'] ?? [],
        );

        // Add new feedback
        final newFeedback = {
          'userId': userId,
          'userName': userName,
          'comment': comment,
          'rating': rating,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        };

        feedbacks.add(newFeedback);

        // Calculate new average rating
        final totalRating = feedbacks.fold<double>(
          0.0,
          (sum, feedback) => sum + (feedback['rating'] as double),
        );
        final averageRating = totalRating / feedbacks.length;

        // Update business document
        transaction.update(businessRef, {
          'feedbacks': feedbacks,
          'rating': averageRating,
          'reviewCount': feedbacks.length,
        });
      });
    } catch (e) {
      throw Exception('Failed to add feedback: $e');
    }
  }

  // Get feedbacks stream for real-time updates
  static Stream<List<Map<String, dynamic>>> businessFeedbacksStream(
    String businessId,
  ) {
    return _firestore.collection('businesses').doc(businessId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        final data = doc.data()!;
        return List<Map<String, dynamic>>.from(data['feedbacks'] ?? []);
      }
      return <Map<String, dynamic>>[];
    });
  }

  static Future<List<Map<String, dynamic>>> getBusinessFeedbacks(
    String businessId,
  ) async {
    try {
      final doc = await _firestore
          .collection('businesses')
          .doc(businessId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        return List<Map<String, dynamic>>.from(data['feedbacks'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get feedbacks: $e');
    }
  }

  static Future<int> getUniqueCustomersCount(String businessId) async {
    try {
      final doc = await _firestore
          .collection('businesses')
          .doc(businessId)
          .get();
      if (!doc.exists) return 0;

      final feedbacks = List<Map<String, dynamic>>.from(
        doc.data()!['feedbacks'] ?? [],
      );
      final uniqueUserIds = feedbacks
          .map((feedback) => feedback['userId'])
          .toSet();

      return uniqueUserIds.length;
    } catch (e) {
      throw Exception('Failed to get unique customers count: $e');
    }
  }

  static Future<Map<String, int>> getBusinessOwnerStats(String userId) async {
    try {
      final businessesSnapshot = await _firestore
          .collection('businesses')
          .where('ownerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      int totalBusinesses = businessesSnapshot.docs.length;
      int totalFeedbacks = 0;
      int uniqueCustomers = 0;
      final Set<String> uniqueCustomerIds = {};

      for (final doc in businessesSnapshot.docs) {
        final feedbacks = List<Map<String, dynamic>>.from(
          doc.data()['feedbacks'] ?? [],
        );
        totalFeedbacks += feedbacks.length;

        for (final feedback in feedbacks) {
          uniqueCustomerIds.add(feedback['userId']);
        }
      }

      uniqueCustomers = uniqueCustomerIds.length;

      return {
        'totalBusinesses': totalBusinesses,
        'totalFeedbacks': totalFeedbacks,
        'uniqueCustomers': uniqueCustomers,
      };
    } catch (e) {
      throw Exception('Failed to get business owner stats: $e');
    }
  }

  static Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  static Future<List<String>> getLocations() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('businesses')
          .get();
      final Set<String> locations = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['location'] != null) {
          locations.add(data['location']);
        }
      }

      return locations.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get locations: $e');
    }
  }
}
