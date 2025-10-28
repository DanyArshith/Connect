import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/business_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  auth.User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  auth.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    FirebaseService.authStateChanges.listen((auth.User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'customer',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await FirebaseService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      if (userCredential != null) {
        _user = userCredential.user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await FirebaseService.signIn(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        _user = userCredential.user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await FirebaseService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      await FirebaseService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}

class BusinessProvider extends ChangeNotifier {
  List<Business> _businesses = [];
  List<Business> _favoriteBusinesses = [];
  List<Business> _userBusinesses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = '';
  String _selectedLocation = '';
  String _searchQuery = '';
  StreamSubscription<List<Business>>? _businessesSubscription;
  StreamSubscription<List<Business>>? _favoritesSubscription;
  StreamSubscription<List<Business>>? _userBusinessesSubscription;

  List<Business> get businesses => _businesses;
  List<Business> get favoriteBusinesses => _favoriteBusinesses;
  List<Business> get userBusinesses => _userBusinesses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get selectedLocation => _selectedLocation;
  String get searchQuery => _searchQuery;

  Future<void> loadBusinesses() async {
    _setLoading(true);
    _clearError();

    // Cancel previous listener if any
    await _businessesSubscription?.cancel();

    _businessesSubscription =
        FirebaseService.businessesStreamFiltered(
          category: _selectedCategory.isEmpty ? null : _selectedCategory,
          location: _selectedLocation.isEmpty ? null : _selectedLocation,
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        ).listen(
          (data) {
            _businesses = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _isLoading = false;
            _setError(e.toString());
          },
        );
  }

  Future<void> loadFavoriteBusinesses(List<String> favoriteIds) async {
    try {
      _setLoading(true);
      _clearError();

      _favoriteBusinesses = await FirebaseService.getFavoriteBusinesses(
        favoriteIds,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserFavorites(String userId) async {
    _setLoading(true);
    _clearError();

    await _favoritesSubscription?.cancel();
    _favoritesSubscription = FirebaseService.userFavoritesStream(userId).listen(
      (data) {
        _favoriteBusinesses = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _setError(e.toString());
      },
    );
  }

  Future<void> loadUserBusinesses(String userId) async {
    _setLoading(true);
    _clearError();

    await _userBusinessesSubscription?.cancel();
    _userBusinessesSubscription = FirebaseService.userBusinessesStream(userId)
        .listen(
          (data) {
            _userBusinesses = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _isLoading = false;
            _setError(e.toString());
          },
        );
  }

  Future<Business?> getBusinessById(String businessId) async {
    try {
      return await FirebaseService.getBusinessById(businessId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> addBusiness(Business business) async {
    try {
      _setLoading(true);
      _clearError();

      final businessId = await FirebaseService.addBusiness(business);
      if (businessId.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBusiness(String businessId, Business business) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.updateBusiness(businessId, business);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteBusiness(String businessId) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.deleteBusiness(businessId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addFeedback(
    String businessId,
    String userId,
    String userName,
    String comment,
    double rating,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.addFeedback(
        businessId,
        userId,
        userName,
        comment,
        rating,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> getBusinessFeedbacks(
    String businessId,
  ) async {
    try {
      return await FirebaseService.getBusinessFeedbacks(businessId);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    loadBusinesses();
  }

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
    loadBusinesses();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    loadBusinesses();
  }

  void clearFilters() {
    _selectedCategory = '';
    _selectedLocation = '';
    _searchQuery = '';
    notifyListeners();
    loadBusinesses();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _businessesSubscription?.cancel();
    _favoritesSubscription?.cancel();
    _userBusinessesSubscription?.cancel();
    super.dispose();
  }
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  List<String> _favorites = [];
  Map<String, int> _businessOwnerStats = {};
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  List<String> get favorites => _favorites;
  Map<String, int> get businessOwnerStats => _businessOwnerStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBusinessOwner => _currentUser?.role == 'business_owner';
  bool get isCustomer => _currentUser?.role == 'customer';

  Future<void> loadUserData(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _currentUser = await FirebaseService.getUserData(userId);
      if (_currentUser != null) {
        _favorites = _currentUser!.favorites;

        // Load business owner stats if user is a business owner
        if (isBusinessOwner) {
          await loadBusinessOwnerStats(userId);
        }
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBusinessOwnerStats(String userId) async {
    try {
      _businessOwnerStats = await FirebaseService.getBusinessOwnerStats(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> updateUserData(User user) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.updateUserData(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserRole(String newRole) async {
    try {
      if (_currentUser == null) return false;

      _setLoading(true);
      _clearError();

      await FirebaseService.updateUserRole(_currentUser!.id, newRole);
      _currentUser = _currentUser!.copyWith(role: newRole);

      // Load stats if switching to business owner
      if (newRole == 'business_owner') {
        await loadBusinessOwnerStats(_currentUser!.id);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleFavorite(String businessId) async {
    try {
      if (_currentUser == null) return false;

      _setLoading(true);
      _clearError();

      final isNowFavorite = await FirebaseService.toggleFavorite(
        _currentUser!.id,
        businessId,
      );

      if (isNowFavorite) {
        _favorites.add(businessId);
      } else {
        _favorites.remove(businessId);
      }

      _currentUser = _currentUser!.copyWith(favorites: _favorites);
      notifyListeners();
      return isNowFavorite;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isFavorite(String businessId) async {
    if (_currentUser == null) return false;
    try {
      return await FirebaseService.isBusinessFavorite(
        _currentUser!.id,
        businessId,
      );
    } catch (e) {
      return _favorites.contains(businessId); // Fallback to local list
    }
  }

  bool isFavoriteLocal(String businessId) {
    return _favorites.contains(businessId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
