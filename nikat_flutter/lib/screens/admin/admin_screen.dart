import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceMuted,
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Users'),
            Tab(text: 'Providers'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StatsTab(),
          _UsersTab(),
          _ProvidersTab(),
          _OrdersTab(),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _StreamStat(
            label: 'Total Users',
            icon: '👥',
            color: AppColors.info,
            stream: FirebaseFirestore.instance.collection(AppConstants.usersCollection).snapshots(),
            getValue: (s) => '${s.size}',
          ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 12),
          _StreamStat(
            label: 'Total Providers',
            icon: '🏪',
            color: AppColors.success,
            stream: FirebaseFirestore.instance.collection(AppConstants.providersCollection).snapshots(),
            getValue: (s) => '${s.size}',
          ).animate(delay: 80.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 12),
          _StreamStat(
            label: 'Total Orders',
            icon: '📦',
            color: AppColors.warning,
            stream: FirebaseFirestore.instance.collection(AppConstants.ordersCollection).snapshots(),
            getValue: (s) => '${s.size}',
          ).animate(delay: 160.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 12),
          _StreamStat(
            label: 'Active Subscriptions',
            icon: '💎',
            color: AppColors.primary,
            stream: FirebaseFirestore.instance.collection(AppConstants.subscriptionsCollection)
                .where('isActive', isEqualTo: true).snapshots(),
            getValue: (s) => '${s.size}',
          ).animate(delay: 240.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _StreamStat extends StatelessWidget {
  const _StreamStat({required this.label, required this.icon, required this.color, required this.stream, required this.getValue});
  final String label;
  final String icon;
  final Color color;
  final Stream<QuerySnapshot> stream;
  final String Function(QuerySnapshot) getValue;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final value = snapshot.hasData ? getValue(snapshot.data!) : '...';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color)),
                  Text(label, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(AppConstants.usersCollection).orderBy('createdAt', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  const Text('👤', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(data['phone'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(data['role'] ?? 'customer', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProvidersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(AppConstants.providersCollection).orderBy('createdAt', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final doc = snapshot.data!.docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(data['shopName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis)),
                      Switch(
                        value: data['isVerified'] ?? false,
                        onChanged: (val) => doc.reference.update({'isVerified': val, 'status': val ? 'active' : 'pending'}),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  Text(data['city'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                  const SizedBox(height: 4),
                  Text('KYC: ${data['kycStatus'] ?? 'pending'} • Status: ${data['status'] ?? 'pending'}',
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceDim)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(AppConstants.ordersCollection).orderBy('createdAt', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['shopName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('by ${data['userName'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                    ],
                  )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${(data['price'] as num?)?.toInt() ?? 0}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      Text(data['status'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
