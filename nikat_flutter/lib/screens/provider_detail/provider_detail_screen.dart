import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/provider_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers_provider.dart';
import '../../services/provider_service.dart';

class ProviderDetailScreen extends ConsumerStatefulWidget {
  const ProviderDetailScreen({super.key, required this.providerId});
  final String providerId;

  @override
  ConsumerState<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends ConsumerState<ProviderDetailScreen> {
  bool _contactRevealed = false;

  Future<void> _revealContact() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    if (!user.canViewContacts) {
      context.push('/subscribe');
      return;
    }
    await ref.read(providerServiceProvider).incrementViews(widget.providerId);
    setState(() => _contactRevealed = true);
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _whatsapp(String phone) async {
    final msg = Uri.encodeComponent(AppConstants.whatsappDefaultMessage);
    final uri = Uri.parse('${AppConstants.whatsappUrl}$phone?text=$msg');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMaps(ProviderModel provider) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${provider.latitude},${provider.longitude}');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final providerAsync = ref.watch(providerDetailProvider(widget.providerId));
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: providerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (provider) {
          if (provider == null) return const Center(child: Text('Provider not found'));
          final contactVisible = _contactRevealed || (user?.hasActiveSubscription ?? false);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      provider.images.isNotEmpty
                          ? CachedNetworkImage(imageUrl: provider.images.first, fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(color: AppColors.surfaceVariant,
                                  child: const Center(child: Text('🏪', style: TextStyle(fontSize: 80)))))
                          : Container(color: AppColors.surfaceVariant,
                              child: const Center(child: Text('🏪', style: TextStyle(fontSize: 80)))),
                      Container(decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.background],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(provider.shopName,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
                                  if (provider.isPremium)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                                      child: const Text('PRO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (provider.categoryName != null)
                                Text(provider.categoryName!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: AppColors.gold),
                                  const SizedBox(width: 4),
                                  Text(provider.ratingDisplay, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                  Text(' (${provider.reviewCount} reviews)', style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 20),
                    // Status & Distance
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: provider.isOnline ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(
                              color: provider.isOnline ? AppColors.primary : AppColors.onSurfaceDim,
                              shape: BoxShape.circle,
                            )),
                            const SizedBox(width: 6),
                            Text(provider.isOnline ? 'Open Now' : 'Closed',
                                style: TextStyle(color: provider.isOnline ? AppColors.primary : AppColors.onSurfaceDim, fontSize: 12, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        const SizedBox(width: 10),
                        if (provider.distanceDisplay.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.location_on, size: 13, color: AppColors.onSurfaceMuted),
                              const SizedBox(width: 4),
                              Text(provider.distanceDisplay, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
                            ]),
                          ),
                      ],
                    ).animate(delay: 100.ms).fadeIn(),
                    const SizedBox(height: 20),
                    // Contact section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: contactVisible ? AppColors.primary.withOpacity(0.4) : AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          if (contactVisible) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _call(provider.phone),
                                    icon: const Icon(Icons.phone, size: 18),
                                    label: Text(provider.phone),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (provider.whatsapp != null)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _whatsapp(provider.whatsapp!),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                                      icon: const Icon(Icons.chat, size: 18),
                                      label: const Text('WhatsApp'),
                                    ),
                                  ),
                              ],
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  const Text('🔒', style: TextStyle(fontSize: 32)),
                                  const SizedBox(height: 8),
                                  const Text('Contact info is locked', fontWeight: FontWeight.w600, textAlign: TextAlign.center),
                                  const SizedBox(height: 4),
                                  const Text('Subscribe to reveal phone & WhatsApp',
                                      style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13), textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  ElevatedButton(onPressed: _revealContact, child: const Text('Unlock Contact')),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate(delay: 150.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 16),
                    // Quick actions
                    Row(
                      children: [
                        Expanded(child: _QuickAction(icon: Icons.map_outlined, label: 'Directions', onTap: () => _openMaps(provider))),
                        const SizedBox(width: 10),
                        Expanded(child: _QuickAction(icon: Icons.chat_outlined, label: 'Chat', onTap: () => context.push('/chat/${provider.id}'))),
                        const SizedBox(width: 10),
                        Expanded(child: _QuickAction(icon: Icons.shopping_bag_outlined, label: 'Order', onTap: () => context.push('/orders'))),
                      ],
                    ).animate(delay: 200.ms).fadeIn(),
                    const SizedBox(height: 24),
                    if (provider.description != null) ...[
                      const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(provider.description!, style: const TextStyle(color: AppColors.onSurfaceMuted, height: 1.5)),
                      const SizedBox(height: 20),
                    ],
                    if (provider.services.isNotEmpty) ...[
                      const Text('Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ...provider.services.map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (s.description != null)
                                  Text(s.description!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                              ],
                            )),
                            Text(s.priceDisplay, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      )).toList(),
                    ],
                    const SizedBox(height: 24),
                    const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _openMaps(provider),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(provider.address, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text(provider.city, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                              ],
                            )),
                            const Icon(Icons.open_in_new, size: 16, color: AppColors.onSurfaceMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted)),
          ],
        ),
      ),
    );
  }
}
