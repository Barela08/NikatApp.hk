import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_model.dart';
import '../services/provider_service.dart';

final providerServiceProvider = Provider<ProviderService>((ref) => ProviderService());

final nearbyProvidersProvider = FutureProvider.family<List<ProviderModel>, NearbyQuery>((ref, query) async {
  return ref.watch(providerServiceProvider).getNearbyProviders(
    lat: query.lat,
    lng: query.lng,
    radiusKm: query.radiusKm,
    categoryId: query.categoryId,
  );
});

final providerDetailProvider = FutureProvider.family<ProviderModel?, String>((ref, id) async {
  return ref.watch(providerServiceProvider).getProvider(id);
});

final myProviderProfileProvider = FutureProvider.family<ProviderModel?, String>((ref, userId) async {
  return ref.watch(providerServiceProvider).getProviderByUserId(userId);
});

final searchProvidersProvider = FutureProvider.family<List<ProviderModel>, SearchQuery>((ref, query) async {
  return ref.watch(providerServiceProvider).searchProviders(
    query.text,
    lat: query.lat,
    lng: query.lng,
  );
});

class NearbyQuery {
  final double lat;
  final double lng;
  final double radiusKm;
  final String? categoryId;

  const NearbyQuery({
    required this.lat,
    required this.lng,
    this.radiusKm = 10,
    this.categoryId,
  });

  @override
  bool operator ==(Object other) =>
      other is NearbyQuery &&
      other.lat == lat &&
      other.lng == lng &&
      other.radiusKm == radiusKm &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(lat, lng, radiusKm, categoryId);
}

class SearchQuery {
  final String text;
  final double? lat;
  final double? lng;

  const SearchQuery({required this.text, this.lat, this.lng});

  @override
  bool operator ==(Object other) =>
      other is SearchQuery && other.text == text && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(text, lat, lng);
}
