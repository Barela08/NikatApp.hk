import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String id;
  final String userId;
  final String shopName;
  final String ownerName;
  final String? description;
  final String categoryId;
  final String? categoryName;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String phone;
  final String? whatsapp;
  final List<String> images;
  final String? profileImage;
  final String kycStatus;
  final bool isVerified;
  final bool isPremium;
  final bool isOnline;
  final String status;
  final double rating;
  final int reviewCount;
  final int totalViews;
  final int totalBookings;
  final List<ServiceItem> services;
  final double? distance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProviderModel({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.ownerName,
    this.description,
    required this.categoryId,
    this.categoryName,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.whatsapp,
    this.images = const [],
    this.profileImage,
    this.kycStatus = 'pending',
    this.isVerified = false,
    this.isPremium = false,
    this.isOnline = false,
    this.status = 'active',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.totalViews = 0,
    this.totalBookings = 0,
    this.services = const [],
    this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProviderModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      shopName: d['shopName'] ?? '',
      ownerName: d['ownerName'] ?? '',
      description: d['description'],
      categoryId: d['categoryId'] ?? '',
      categoryName: d['categoryName'],
      address: d['address'] ?? '',
      city: d['city'] ?? '',
      latitude: (d['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (d['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: d['phone'] ?? '',
      whatsapp: d['whatsapp'],
      images: List<String>.from(d['images'] ?? []),
      profileImage: d['profileImage'],
      kycStatus: d['kycStatus'] ?? 'pending',
      isVerified: d['isVerified'] ?? false,
      isPremium: d['isPremium'] ?? false,
      isOnline: d['isOnline'] ?? false,
      status: d['status'] ?? 'active',
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: d['reviewCount'] ?? 0,
      totalViews: d['totalViews'] ?? 0,
      totalBookings: d['totalBookings'] ?? 0,
      services: (d['services'] as List<dynamic>?)
              ?.map((s) => ServiceItem.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'shopName': shopName,
        'ownerName': ownerName,
        'description': description,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'whatsapp': whatsapp,
        'images': images,
        'profileImage': profileImage,
        'kycStatus': kycStatus,
        'isVerified': isVerified,
        'isPremium': isPremium,
        'isOnline': isOnline,
        'status': status,
        'rating': rating,
        'reviewCount': reviewCount,
        'totalViews': totalViews,
        'totalBookings': totalBookings,
        'services': services.map((s) => s.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  ProviderModel copyWith({double? distance}) => ProviderModel(
        id: id, userId: userId, shopName: shopName, ownerName: ownerName,
        description: description, categoryId: categoryId, categoryName: categoryName,
        address: address, city: city, latitude: latitude, longitude: longitude,
        phone: phone, whatsapp: whatsapp, images: images, profileImage: profileImage,
        kycStatus: kycStatus, isVerified: isVerified, isPremium: isPremium,
        isOnline: isOnline, status: status, rating: rating, reviewCount: reviewCount,
        totalViews: totalViews, totalBookings: totalBookings, services: services,
        distance: distance ?? this.distance,
        createdAt: createdAt, updatedAt: updatedAt,
      );

  String get ratingDisplay => rating.toStringAsFixed(1);
  String get distanceDisplay => distance != null
      ? distance! < 1 ? '${(distance! * 1000).toInt()}m' : '${distance!.toStringAsFixed(1)}km'
      : '';
}

class ServiceItem {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String priceType;
  final int? durationMinutes;
  final bool isActive;

  const ServiceItem({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.priceType = 'fixed',
    this.durationMinutes,
    this.isActive = true,
  });

  factory ServiceItem.fromMap(Map<String, dynamic> m) => ServiceItem(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        description: m['description'],
        price: (m['price'] as num?)?.toDouble(),
        priceType: m['priceType'] ?? 'fixed',
        durationMinutes: m['durationMinutes'],
        isActive: m['isActive'] ?? true,
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'name': name, 'description': description,
        'price': price, 'priceType': priceType,
        'durationMinutes': durationMinutes, 'isActive': isActive,
      };

  String get priceDisplay {
    if (price == null) return 'Call for price';
    return priceType == 'starting' ? 'Starting ₹${price!.toInt()}' : '₹${price!.toInt()}';
  }
}
