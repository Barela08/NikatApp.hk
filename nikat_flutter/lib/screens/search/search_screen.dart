import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/location_provider.dart';
import '../../providers/providers_provider.dart';
import '../../widgets/provider_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final searchQuery = SearchQuery(
      text: _query,
      lat: locationState.latitude,
      lng: locationState.longitude,
    );
    final resultsAsync = _query.length >= 2 ? ref.watch(searchProvidersProvider(searchQuery)) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontSize: 16, color: AppColors.onSurface),
          decoration: const InputDecoration(
            hintText: 'Search shops, services, areas...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.onSurfaceDim),
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () { _controller.clear(); setState(() => _query = ''); },
            ),
        ],
      ),
      body: _query.length < 2
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔍', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text('Search for anything nearby', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Electrician, Plumber, Salon...', style: TextStyle(color: AppColors.onSurfaceDim, fontSize: 13)),
                ],
              ),
            )
          : resultsAsync!.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (providers) => providers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('😔', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 16),
                          Text('No results for "$_query"', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text('Try different keywords', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13)),
                        ],
                      ),
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
