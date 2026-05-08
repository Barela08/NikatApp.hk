import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';

class ProviderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ProviderModel>> getNearbyProviders({
    required double lat,
    required double lng,
    double radiusKm = 10,
    String? categoryId,
    int limit = 20,
  }) async {
    Query query = _db
        .collection(AppConstants.providersCollection)
        .where('status', isEqualTo: 'active')
        .where('isVerified', isEqualTo: true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await query.limit(100).get();

    List<ProviderModel> providers = snapshot.docs
        .map((doc) => ProviderModel.fromFirestore(doc))
        .toList();

    // Client-side distance calculation and filtering
    providers = providers
        .map((p) => p.copyWith(distance: _haversineDistance(lat, lng, p.latitude, p.longitude)))
        .where((p) => p.distance! <= radiusKm)
        .toList();

    // Sort: premium first, then by distance, then by rating
    providers.sort((a, b) {
      if (a.isPremium && !b.isPremium) return -1;
      if (!a.isPremium && b.isPremium) return 1;
      return (a.distance ?? 0).compareTo(b.distance ?? 0);
    });

    return providers.take(limit).toList();
  }

  Future<ProviderModel?> getProvider(String providerId) async {
    final doc = await _db.collection(AppConstants.providersCollection).doc(providerId).get();
    if (!doc.exists) return null;
    return ProviderModel.fromFirestore(doc);
  }

  Future<ProviderModel?> getProviderByUserId(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.providersCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return ProviderModel.fromFirestore(snapshot.docs.first);
  }

  Future<List<ProviderModel>> searchProviders(String query, {double? lat, double? lng}) async {
    final snapshot = await _db
        .collection(AppConstants.providersCollection)
        .where('status', isEqualTo: 'active')
        .where('isVerified', isEqualTo: true)
        .limit(50)
        .get();

    final lowerQuery = query.toLowerCase();
    List<ProviderModel> results = snapshot.docs
        .map((doc) => ProviderModel.fromFirestore(doc))
        .where((p) =>
            p.shopName.toLowerCase().contains(lowerQuery) ||
            (p.categoryName?.toLowerCase().contains(lowerQuery) ?? false) ||
            p.city.toLowerCase().contains(lowerQuery) ||
            (p.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();

    if (lat != null && lng != null) {
      results = results
          .map((p) => p.copyWith(distance: _haversineDistance(lat, lng, p.latitude, p.longitude)))
          .toList();
      results.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    }

    return results;
  }

  Future<String> createProvider(ProviderModel provider) async {
    final doc = await _db.collection(AppConstants.providersCollection).add(provider.toFirestore());
    return doc.id;
  }

  Future<void> updateProvider(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.providersCollection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementViews(String providerId) async {
    await _db.collection(AppConstants.providersCollection).doc(providerId).update({
      'totalViews': FieldValue.increment(1),
    });
  }

  Future<List<ReviewModel>> getReviews(String providerId) async {
    final snapshot = await _db
        .collection(AppConstants.reviewsCollection)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }

  Future<void> addReview(ReviewModel review) async {
    await _db.collection(AppConstants.reviewsCollection).add(review.toFirestore());
    // Recalculate average
    final reviews = await getReviews(review.providerId);
    final avg = reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    await updateProvider(review.providerId, {
      'rating': avg,
      'reviewCount': reviews.length,
    });
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}
