import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/order_model.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Details')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection(AppConstants.ordersCollection).doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          final order = OrderModel.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Column(
                    children: [
                      Text(order.shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount'),
                          Text('₹${order.price.toInt()}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Method', style: TextStyle(color: AppColors.onSurfaceMuted)),
                          Text(order.paymentMethod.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Placed On', style: TextStyle(color: AppColors.onSurfaceMuted)),
                          Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Order Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                ...['Placed', 'Confirmed', 'On The Way', 'Delivered'].asMap().entries.map((e) {
                  final isDone = e.key <= order.statusStep;
                  final isCurrent = e.key == order.statusStep;
                  return Row(
                    children: [
                      Column(children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.primary : AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                            boxShadow: isCurrent ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8)] : [],
                          ),
                          child: Icon(isDone ? Icons.check : Icons.circle, size: 16, color: isDone ? Colors.black : AppColors.onSurfaceDim),
                        ),
                        if (e.key < 3) Container(width: 2, height: 32, color: isDone ? AppColors.primary : AppColors.surfaceVariant),
                      ]),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Text(e.value, style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.primary : (isDone ? AppColors.onSurface : AppColors.onSurfaceDim),
                        )),
                      ),
                    ],
                  );
                }).toList(),
                if (order.isCancelled) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withOpacity(0.3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Cancelled', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                        if (order.cancellationReason != null)
                          Text(order.cancellationReason!, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
