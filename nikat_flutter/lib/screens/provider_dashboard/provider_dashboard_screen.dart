import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers_provider.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    final providerAsync = ref.watch(myProviderProfileProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => context.push('/add-store')),
        ],
      ),
      body: providerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (provider) {
          if (provider == null) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🏪', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text("You haven't set up your shop yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => context.go('/add-store'), child: const Text('Set Up My Shop')),
              ]),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop info header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.primaryDark.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('🏪', style: TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                            Text(provider.categoryName ?? '', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: provider.isOnline ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(provider.isOnline ? 'Open' : 'Closed',
                                      style: TextStyle(color: provider.isOnline ? AppColors.primary : AppColors.onSurfaceMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 8),
                                if (provider.isVerified) const Text('✓ Verified', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 20),
                // Stats grid
                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Total Views', value: '${provider.totalViews}', icon: '👁️', color: AppColors.info)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Rating', value: provider.ratingDisplay, icon: '⭐', color: AppColors.gold)),
                  ],
                ).animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Total Bookings', value: '${provider.totalBookings}', icon: '📦', color: AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Reviews', value: '${provider.reviewCount}', icon: '💬', color: AppColors.warning)),
                  ],
                ).animate(delay: 150.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 24),
                // Toggle online status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      Text(provider.isOnline ? '🟢' : '🔴', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Shop Status', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(provider.isOnline ? 'Customers can find you' : 'You are offline',
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                        ],
                      )),
                      Switch(
                        value: provider.isOnline,
                        onChanged: (val) {
                          FirebaseFirestore.instance
                              .collection(AppConstants.providersCollection)
                              .doc(provider.id)
                              .update({'isOnline': val, 'updatedAt': FieldValue.serverTimestamp()});
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 20),
                const Text('Recent Orders', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(AppConstants.ordersCollection)
                      .where('providerId', isEqualTo: provider.id)
                      .orderBy('createdAt', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text('No orders yet', style: TextStyle(color: AppColors.onSurfaceMuted))),
                      );
                    }
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                          child: Row(
                            children: [
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['userName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(data['serviceName'] ?? 'General service', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                                ],
                              )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${(data['price'] as num?)?.toInt() ?? 0}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                                  Text(data['status'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ).animate(delay: 300.ms).fadeIn(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
        ],
      ),
    );
  }
}
