import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({super.key, required this.provider, this.compact = false});

  final ProviderModel provider;
  final bool compact;

  Future<void> _call(BuildContext context) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(provider.phone);
    } catch (_) {
      final uri = Uri(scheme: 'tel', path: provider.phone);
      if (await canLaunchUrl(uri)) launchUrl(uri);
    }
  }

  Future<void> _whatsapp() async {
    final msg = Uri.encodeComponent(AppConstants.whatsappDefaultMessage);
    final phone = provider.whatsapp ?? provider.phone;
    final uri = Uri.parse('${AppConstants.whatsappUrl}$phone?text=$msg');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/provider/${provider.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: provider.isPremium ? AppColors.primary.withOpacity(0.4) : AppColors.border),
          boxShadow: provider.isPremium
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 12)]
              : [],
        ),
        child: Row(
          children: [
            // Shop image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: provider.profileImage ?? '',
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 76, height: 76,
                  color: AppColors.surfaceVariant,
                  child: const Center(child: Text('🏪', style: TextStyle(fontSize: 32))),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 76, height: 76,
                  color: AppColors.surfaceVariant,
                  child: const Center(child: Text('🏪', style: TextStyle(fontSize: 32))),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(provider.shopName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (provider.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                          child: const Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                        ),
                      const SizedBox(width: 4),
                      if (provider.isVerified)
                        const Text('✓', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (provider.categoryName != null)
                    Text(provider.categoryName!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: AppColors.gold),
                      const SizedBox(width: 3),
                      Text(provider.ratingDisplay, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(' (${provider.reviewCount})', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on, size: 12, color: AppColors.onSurfaceMuted),
                      const SizedBox(width: 2),
                      Text(provider.distanceDisplay, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: provider.isOnline ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 5, height: 5,
                                decoration: BoxDecoration(
                                  color: provider.isOnline ? AppColors.primary : AppColors.onSurfaceDim,
                                  shape: BoxShape.circle,
                                )),
                            const SizedBox(width: 4),
                            Text(provider.isOnline ? 'Open' : 'Closed',
                                style: TextStyle(fontSize: 10, color: provider.isOnline ? AppColors.primary : AppColors.onSurfaceDim, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ActionButton(icon: Icons.phone, label: 'Call', color: AppColors.primary, onTap: () => _call(context)),
                      const SizedBox(width: 8),
                      _ActionButton(icon: Icons.chat, label: 'WhatsApp', color: const Color(0xFF25D366), onTap: _whatsapp),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
