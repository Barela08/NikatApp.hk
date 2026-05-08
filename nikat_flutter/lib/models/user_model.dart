import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role;
  final String? email;
  final String? profileImage;
  final String? city;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final bool isVerified;
  final String? fcmToken;
  final String? languageCode;
  final int freeViewsUsed;
  final int freeViewsLimit;
  final bool hasActiveSubscription;
  final DateTime? subscriptionEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.profileImage,
    this.city,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.isVerified = false,
    this.fcmToken,
    this.languageCode,
    this.freeViewsUsed = 0,
    this.freeViewsLimit = 3,
    this.hasActiveSubscription = false,
    this.subscriptionEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? 'User',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      email: data['email'],
      profileImage: data['profileImage'],
      city: data['city'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      fcmToken: data['fcmToken'],
      languageCode: data['languageCode'],
      freeViewsUsed: data['freeViewsUsed'] ?? 0,
      freeViewsLimit: data['freeViewsLimit'] ?? 3,
      hasActiveSubscription: data['hasActiveSubscription'] ?? false,
      subscriptionEnd: (data['subscriptionEnd'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'phone': phone,
        'role': role,
        'email': email,
        'profileImage': profileImage,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'isActive': isActive,
        'isVerified': isVerified,
        'fcmToken': fcmToken,
        'languageCode': languageCode,
        'freeViewsUsed': freeViewsUsed,
        'freeViewsLimit': freeViewsLimit,
        'hasActiveSubscription': hasActiveSubscription,
        'subscriptionEnd': subscriptionEnd != null ? Timestamp.fromDate(subscriptionEnd!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  UserModel copyWith({
    String? name, String? phone, String? role, String? email,
    String? profileImage, String? city, double? latitude, double? longitude,
    bool? isActive, bool? isVerified, String? fcmToken, String? languageCode,
    int? freeViewsUsed, int? freeViewsLimit, bool? hasActiveSubscription,
    DateTime? subscriptionEnd,
  }) => UserModel(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        email: email ?? this.email,
        profileImage: profileImage ?? this.profileImage,
        city: city ?? this.city,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isActive: isActive ?? this.isActive,
        isVerified: isVerified ?? this.isVerified,
        fcmToken: fcmToken ?? this.fcmToken,
        languageCode: languageCode ?? this.languageCode,
        freeViewsUsed: freeViewsUsed ?? this.freeViewsUsed,
        freeViewsLimit: freeViewsLimit ?? this.freeViewsLimit,
        hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
        subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  bool get isCustomer => role == 'customer';
  bool get isProvider => role == 'provider';
  bool get isAdmin => role == 'admin';
  bool get canViewContacts => hasActiveSubscription || freeViewsUsed < freeViewsLimit;
}
