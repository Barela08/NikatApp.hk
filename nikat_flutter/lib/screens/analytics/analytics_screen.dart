import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    final providerAsync = ref.watch(myProviderProfileProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analytics')),
      body: providerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (provider) {
          if (provider == null) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('📊', style: TextStyle(fontSize: 64)),
                SizedBox(height: 16),
                Text('Set up your shop to view analytics', style: TextStyle(fontSize: 16)),
              ]),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Stats
                _SectionTitle(title: 'Overview'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Total Views', value: '${provider.totalViews}', icon: '👁️', color: AppColors.info, change: '+12%')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatTile(label: 'Bookings', value: '${provider.totalBookings}', icon: '📦', color: AppColors.success, change: '+8%')),
                  ],
                ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Rating', value: provider.ratingDisplay, icon: '⭐', color: AppColors.gold, change: '+0.2')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatTile(label: 'Reviews', value: '${provider.reviewCount}', icon: '💬', color: AppColors.primary, change: '+3')),
                  ],
                ).animate(delay: 60.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 28),

                // Views Chart
                _SectionTitle(title: 'Views This Week').animate(delay: 120.ms).fadeIn(),
                const SizedBox(height: 12),
                _ViewsChart().animate(delay: 160.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 28),

                // Revenue Chart
                _SectionTitle(title: 'Revenue (Last 7 Days)').animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 12),
                _RevenueChart(providerId: provider.id).animate(delay: 240.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 28),

                // Order Status breakdown
                _SectionTitle(title: 'Order Status Breakdown').animate(delay: 280.ms).fadeIn(),
                const SizedBox(height: 12),
                _OrderStatusChart(providerId: provider.id).animate(delay: 320.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 28),

                // Recent Reviews
                _SectionTitle(title: 'Recent Reviews').animate(delay: 360.ms).fadeIn(),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(AppConstants.reviewsCollection)
                      .where('providerId', isEqualTo: provider.id)
                      .orderBy('createdAt', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator(color: AppColors.primary);
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No reviews yet', style: TextStyle(color: AppColors.onSurfaceMuted)));
                    }
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('👤', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(d['userName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        const Spacer(),
                                        Row(
                                          children: List.generate(5, (i) => Icon(
                                            i < (d['rating'] ?? 5) ? Icons.star : Icons.star_border,
                                            size: 13,
                                            color: AppColors.gold,
                                          )),
                                        ),
                                      ],
                                    ),
                                    if (d['comment'] != null && d['comment'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(d['comment'], style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13)),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon, required this.color, required this.change});
  final String label, value, icon, change;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(change, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
        ],
      ),
    );
  }
}

class _ViewsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock data - replace with Firestore data in production
    final spots = [
      const FlSpot(0, 3), const FlSpot(1, 7), const FlSpot(2, 5),
      const FlSpot(3, 12), const FlSpot(4, 8), const FlSpot(5, 15), const FlSpot(6, 11),
    ];
    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(days[v.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceDim));
              },
              reservedSize: 24,
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context) {
    final barGroups = List.generate(7, (i) => BarChartGroupData(
      x: i,
      barRods: [BarChartRodData(
        toY: [1200, 2400, 800, 3600, 1800, 4200, 2800][i].toDouble(),
        color: i == 5 ? AppColors.primary : AppColors.primary.withOpacity(0.5),
        width: 20,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      )],
    ));

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5000,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Text(days[v.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceDim));
              },
              reservedSize: 20,
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}

class _OrderStatusChart extends StatelessWidget {
  const _OrderStatusChart({required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.ordersCollection)
          .where('providerId', isEqualTo: providerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));

        final orders = snapshot.data!.docs;
        final delivered = orders.where((d) => (d.data() as Map)['status'] == 'delivered').length;
        final cancelled = orders.where((d) => (d.data() as Map)['status'] == 'cancelled').length;
        final active = orders.length - delivered - cancelled;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: orders.isEmpty
                      ? const Center(child: Text('No data', style: TextStyle(color: AppColors.onSurfaceMuted)))
                      : PieChart(PieChartData(
                          sections: [
                            PieChartSectionData(value: delivered.toDouble(), color: AppColors.success, title: '', radius: 48),
                            PieChartSectionData(value: active.toDouble(), color: AppColors.info, title: '', radius: 48),
                            PieChartSectionData(value: cancelled.toDouble(), color: AppColors.error, title: '', radius: 48),
                          ],
                          centerSpaceRadius: 24,
                          sectionsSpace: 2,
                        )),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(color: AppColors.success, label: 'Delivered', count: delivered),
                  const SizedBox(height: 8),
                  _LegendItem(color: AppColors.info, label: 'Active', count: active),
                  const SizedBox(height: 8),
                  _LegendItem(color: AppColors.error, label: 'Cancelled', count: cancelled),
                  const SizedBox(height: 8),
                  _LegendItem(color: AppColors.onSurfaceDim, label: 'Total', count: orders.length),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.count});
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: $count', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
      ],
    );
  }
}
