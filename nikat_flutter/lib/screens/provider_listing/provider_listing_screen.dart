import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/location_provider.dart';
import '../../providers/providers_provider.dart';
import '../../widgets/provider_card.dart';

class ProviderListingScreen extends ConsumerWidget {
  const ProviderListingScreen({super.key, required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final category = AppConstants.categories.firstWhere((c) => c['id'] == categoryId, orElse: () => {});
    final query = NearbyQuery(
      lat: locationState.latitude ?? AppConstants.defaultLat,
      lng: locationState.longitude ?? AppConstants.defaultLng,
      categoryId: categoryId,
    );
    final providersAsync = ref.watch(nearbyProvidersProvider(query));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            if (category.isNotEmpty) Text('${category['icon']} ', style: const TextStyle(fontSize: 20)),
            Text(category.isNotEmpty ? category['name'] as String : 'Providers'),
          ],
        ),
      ),
      body: providersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (providers) => providers.isEmpty
            ? const Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('🔍', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('No providers found nearby', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Try expanding the search area', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14)),
                ]),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: providers.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProviderCard(provider: providers[i]),
                ),
              ),
      ),
    );
  }
}
