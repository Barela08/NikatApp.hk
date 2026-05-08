import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String providerId;
  final String shopName;
  final String? serviceId;
  final String? serviceName;
  final double price;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? address;
  final String? notes;
  final double? userLatitude;
  final double? userLongitude;
  final double? providerLatitude;
  final double? providerLongitude;
  final DateTime? scheduledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.providerId,
    required this.shopName,
    this.serviceId,
    this.serviceName,
    required this.price,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.address,
    this.notes,
    this.userLatitude,
    this.userLongitude,
    this.providerLatitude,
    this.providerLongitude,
    this.scheduledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? '',
      userPhone: d['userPhone'] ?? '',
      providerId: d['providerId'] ?? '',
      shopName: d['shopName'] ?? '',
      serviceId: d['serviceId'],
      serviceName: d['serviceName'],
      price: (d['price'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: d['paymentMethod'] ?? 'cash',
      paymentStatus: d['paymentStatus'] ?? 'pending',
      status: d['status'] ?? 'pending',
      address: d['address'],
      notes: d['notes'],
      userLatitude: (d['userLatitude'] as num?)?.toDouble(),
      userLongitude: (d['userLongitude'] as num?)?.toDouble(),
      providerLatitude: (d['providerLatitude'] as num?)?.toDouble(),
      providerLongitude: (d['providerLongitude'] as num?)?.toDouble(),
      scheduledAt: (d['scheduledAt'] as Timestamp?)?.toDate(),
      cancellationReason: d['cancellationReason'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId, 'userName': userName, 'userPhone': userPhone,
        'providerId': providerId, 'shopName': shopName,
        'serviceId': serviceId, 'serviceName': serviceName,
        'price': price, 'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus, 'status': status,
        'address': address, 'notes': notes,
        'userLatitude': userLatitude, 'userLongitude': userLongitude,
        'providerLatitude': providerLatitude, 'providerLongitude': providerLongitude,
        'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
        'cancellationReason': cancellationReason,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isOnTheWay => status == 'on_the_way';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => ['pending', 'confirmed', 'on_the_way'].contains(status);

  int get statusStep {
    switch (status) {
      case 'pending': return 0;
      case 'confirmed': return 1;
      case 'on_the_way': return 2;
      case 'delivered': return 3;
      default: return -1;
    }
  }
}
