import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String providerId;
  final String? orderId;
  final int rating;
  final String? comment;
  final String? userImage;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.providerId,
    this.orderId,
    required this.rating,
    this.comment,
    this.userImage,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? 'Anonymous',
      providerId: d['providerId'] ?? '',
      orderId: d['orderId'],
      rating: d['rating'] ?? 5,
      comment: d['comment'],
      userImage: d['userImage'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userName': userName,
        'providerId': providerId,
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
        'userImage': userImage,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
