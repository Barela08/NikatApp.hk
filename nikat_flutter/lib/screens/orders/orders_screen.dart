import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.ordersCollection)
            .where('userId', isEqualTo: user.id)
            .orderBy('createdAt', descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('📦', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Start exploring nearby services', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => context.go('/'), child: const Text('Explore Services')),
              ]),
            );
          }

          final orders = snapshot.data!.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OrderCard(order: orders[i])
                  .animate(delay: Duration(milliseconds: i * 60))
                  .slideY(begin: 0.2, duration: 400.ms).fadeIn(),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderModel order;

  Color get _statusColor {
    switch (order.status) {
      case 'confirmed': return AppColors.info;
      case 'on_the_way': return AppColors.warning;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.onSurfaceMuted;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case 'pending': return '⏳ Pending';
      case 'confirmed': return '✅ Confirmed';
      case 'on_the_way': return '🚗 On the way';
      case 'delivered': return '🎉 Delivered';
      case 'cancelled': return '❌ Cancelled';
      default: return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.shopName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_statusLabel, style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.serviceName != null)
              Text(order.serviceName!, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${order.price.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                Text(DateFormat('dd MMM, hh:mm a').format(order.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
              ],
            ),
            if (order.isActive) ...[
              const SizedBox(height: 12),
              _OrderProgressBar(step: order.statusStep),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderProgressBar extends StatelessWidget {
  const _OrderProgressBar({required this.step});
  final int step;

  static const _steps = ['Placed', 'Confirmed', 'On Way', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final lineIndex = i ~/ 2;
          return Expanded(child: Container(height: 2, color: lineIndex < step ? AppColors.primary : AppColors.surfaceVariant));
        }
        final dotIndex = i ~/ 2;
        final isActive = dotIndex <= step;
        return Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: isActive ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
        );
      }),
    );
  }
}
