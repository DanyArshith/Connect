class Business {
  final String id;
  final String ownerId;
  final String name;
  final String category;
  final String location;
  final String description;
  final String contact;
  final String? imageUrl;
  final DateTime createdAt;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final List<Map<String, dynamic>> feedbacks;

  Business({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    required this.contact,
    this.imageUrl,
    required this.createdAt,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    this.feedbacks = const [],
  });

  factory Business.fromMap(Map<String, dynamic> map, String id) {
    return Business(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      contact: map['contact'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      feedbacks: List<Map<String, dynamic>>.from(map['feedbacks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'category': category,
      'location': location,
      'description': description,
      'contact': contact,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'feedbacks': feedbacks,
    };
  }

  Business copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? category,
    String? location,
    String? description,
    String? contact,
    String? imageUrl,
    DateTime? createdAt,
    double? rating,
    int? reviewCount,
    bool? isActive,
    List<Map<String, dynamic>>? feedbacks,
  }) {
    return Business(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      feedbacks: feedbacks ?? this.feedbacks,
    );
  }

  @override
  String toString() {
    return 'Business(id: $id, name: $name, category: $category, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Business && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'customer' or 'business_owner'
  final List<String> favorites;
  final List<String> businesses; // business IDs owned by this user
  final DateTime createdAt;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'customer',
    this.favorites = const [],
    this.businesses = const [],
    required this.createdAt,
    this.profileImageUrl,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      favorites: List<String>.from(map['favorites'] ?? []),
      businesses: List<String>.from(map['businesses'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      profileImageUrl: map['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'favorites': favorites,
      'businesses': businesses,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'profileImageUrl': profileImageUrl,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    List<String>? favorites,
    List<String>? businesses,
    DateTime? createdAt,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      favorites: favorites ?? this.favorites,
      businesses: businesses ?? this.businesses,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Feedback model
class Feedback {
  final String id;
  final String businessId;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime createdAt;

  Feedback({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Feedback.fromMap(Map<String, dynamic> map, String id) {
    return Feedback(
      id: id,
      businessId: map['businessId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'Feedback(id: $id, userName: $userName, rating: $rating)';
  }
}

// Business categories
class BusinessCategory {
  static const List<String> categories = [
    'Tailor',
    'Tutor',
    'Food & Catering',
    'Local Shop',
    'Repair Services',
    'Beauty & Wellness',
    'Home Services',
    'Transportation',
    'Photography',
    'Other',
  ];

  static const Map<String, String> categoryIcons = {
    'Tailor': '✂️',
    'Tutor': '📚',
    'Food & Catering': '🍽️',
    'Local Shop': '🏪',
    'Repair Services': '🔧',
    'Beauty & Wellness': '💄',
    'Home Services': '🏠',
    'Transportation': '🚗',
    'Photography': '📸',
    'Other': '🏢',
  };
}
