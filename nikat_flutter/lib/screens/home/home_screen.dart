import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/providers_provider.dart';
import '../../widgets/provider_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/banner_slider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).detectLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final locationState = ref.watch(locationProvider);
    final user = userAsync.valueOrNull;

    final nearbyQuery = NearbyQuery(
      lat: locationState.latitude ?? AppConstants.defaultLat,
      lng: locationState.longitude ?? AppConstants.defaultLng,
      categoryId: _selectedCategory,
    );
    final providersAsync = ref.watch(nearbyProvidersProvider(nearbyQuery));

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.background, AppColors.background],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$greeting 👋',
                              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
                          Text(user?.name.split(' ').first ?? 'User',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(child: Text('👤', style: TextStyle(fontSize: 20))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Location bar
                  GestureDetector(
                    onTap: () => ref.read(locationProvider.notifier).detectLocation(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              locationState.isLoading
                                  ? 'Detecting location...'
                                  : locationState.city ?? locationState.address ?? 'Tap to detect location',
                              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (locationState.isLoading)
                            const SizedBox(width: 14, height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                          else
                            const Icon(Icons.navigation, color: AppColors.primary, size: 14),
                        ],
                      ),
                    ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  GestureDetector(
                    onTap: () => context.go('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppColors.onSurfaceMuted, size: 20),
                          SizedBox(width: 10),
                          Text('Search shops, services...', style: TextStyle(color: AppColors.onSurfaceDim, fontSize: 15)),
                        ],
                      ),
                    ).animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                  ),
                  const SizedBox(height: 20),
                  // Banner
                  const BannerSlider().animate(delay: 150.ms).fadeIn(),
                  const SizedBox(height: 24),
                  // Categories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categories', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => setState(() => _selectedCategory = null),
                        child: Text('All', style: TextStyle(color: _selectedCategory == null ? AppColors.primary : AppColors.onSurfaceMuted, fontSize: 13)),
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn(),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.categories.length,
                      itemBuilder: (context, i) {
                        final cat = AppConstants.categories[i];
                        return CategoryChip(
                          icon: cat['icon'] as String,
                          label: cat['name'] as String,
                          color: Color(cat['color'] as int),
                          isSelected: _selectedCategory == cat['id'],
                          onTap: () => setState(() {
                            _selectedCategory = _selectedCategory == cat['id'] ? null : cat['id'] as String;
                          }),
                        ).animate(delay: Duration(milliseconds: 200 + i * 30)).slideX(begin: 0.2, duration: 300.ms).fadeIn();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nearby Services', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      providersAsync.when(
                        data: (p) => Text('${p.length} found', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ).animate(delay: 300.ms).fadeIn(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          providersAsync.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (c, i) => Container(margin: const EdgeInsets.only(bottom: 12), height: 100,
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16))),
                  childCount: 5,
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(children: [
                  const Text('📡', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Could not load providers', style: const TextStyle(color: AppColors.onSurfaceMuted)),
                ]),
              ),
            ),
            data: (providers) => providers.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text('No shops nearby yet', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Try expanding the area or change category', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
                      ]),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProviderCard(provider: providers[i])
                              .animate(delay: Duration(milliseconds: i * 60))
                              .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut)
                              .fadeIn(),
                        ),
                        childCount: providers.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
