import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.provider,
    this.index = 0,
    this.onTap,
  });

  final ProviderModel provider;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/provider/${provider.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: provider.coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: provider.coverImageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _PlaceholderImage(category: provider.category),
                    )
                  : _PlaceholderImage(category: provider.category),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.shopName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (provider.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text('✅', style: TextStyle(fontSize: 14)),
                        ),
                      if (provider.isOpen)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Open', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Closed', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.description ?? provider.categoryLabel,
                    style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 15, color: AppColors.gold),
                      const SizedBox(width: 3),
                      Text(
                        provider.ratingDisplay,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(' (${provider.reviewCount})',
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                      const Spacer(),
                      if (provider.distanceKm != null) ...[
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.onSurfaceMuted),
                        const SizedBox(width: 2),
                        Text(
                          AppHelpers.formatDistance(provider.distanceKm!),
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: (index * 60).ms).slideY(begin: 0.15, duration: 350.ms).fadeIn(),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.category});
  final String category;

  String get _emoji {
    const map = {
      'grocery': '🛒', 'restaurant': '🍽️', 'pharmacy': '💊', 'salon': '💇',
      'electronics': '📱', 'clothing': '👗', 'gym': '💪', 'doctor': '🏥',
      'hardware': '🔧', 'tutor': '📚', 'laundry': '👕', 'auto': '🔩',
      'bakery': '🍞', 'dairy': '🥛', 'vegetable': '🥦', 'plumber': '🪠',
    };
    return map[category] ?? '🏪';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: Center(child: Text(_emoji, style: const TextStyle(fontSize: 56))),
    );
  }
}

class ProviderListTile extends StatelessWidget {
  const ProviderListTile({super.key, required this.provider, this.index = 0});
  final ProviderModel provider;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/provider/${provider.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: provider.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: provider.imageUrl!,
                      width: 60, height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _TileEmoji(category: provider.category),
                    )
                  : _TileEmoji(category: provider.category),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.shopName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(provider.categoryLabel, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.star, size: 13, color: AppColors.gold),
                    const SizedBox(width: 3),
                    Text(provider.ratingDisplay, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    if (provider.distanceKm != null) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.onSurfaceMuted),
                      Text(AppHelpers.formatDistance(provider.distanceKm!), style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                    ],
                  ]),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.onSurfaceDim),
          ],
        ),
      ).animate(delay: (index * 50).ms).slideX(begin: 0.1, duration: 300.ms).fadeIn(),
    );
  }
}

class _TileEmoji extends StatelessWidget {
  const _TileEmoji({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60, height: 60,
      color: AppColors.surfaceVariant,
      child: const Center(child: Text('🏪', style: TextStyle(fontSize: 28))),
    );
  }
}
