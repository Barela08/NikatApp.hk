import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  late Razorpay _razorpay;
  int _selectedPlan = 1;
  bool _isLoading = false;

  static const _plans = [
    _Plan(id: 'free', name: 'Free', price: 0, period: 'Forever', features: ['3 contact views', 'Browse all listings', 'Basic search'], highlight: false),
    _Plan(id: 'basic', name: 'Basic', price: 49, period: 'per month', features: ['Unlimited contacts', 'Direct calls', 'WhatsApp connect'], highlight: false),
    _Plan(id: 'pro', name: 'Pro', price: 99, period: 'per month', features: ['Everything in Basic', 'Priority support', 'Exclusive offers', 'Early access'], highlight: true),
    _Plan(id: 'premium', name: 'Premium', price: 199, period: 'per month', features: ['Everything in Pro', 'Business tools', 'Analytics', 'Ad-free experience'], highlight: false),
    _Plan(id: 'annual', name: 'Annual', price: 399, period: 'per year', features: ['Everything in Premium', '3 months free', 'Premium badge', 'VIP support'], highlight: false),
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  void _onSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful! Subscription activated.'), backgroundColor: AppColors.success),
    );
    if (mounted) Navigator.pop(context);
  }

  void _onError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: AppColors.error),
    );
  }

  void _onWallet(ExternalWalletResponse response) {}

  void _subscribe() {
    final plan = _plans[_selectedPlan];
    if (plan.price == 0) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final options = {
      'key': AppConstants.razorpayKey,
      'amount': plan.price * 100,
      'name': 'NIKAT',
      'description': '${plan.name} Subscription',
      'prefill': {'contact': user.phone, 'name': user.name},
      'theme': {'color': '#00FF88'},
    };
    _razorpay.open(options);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Choose a Plan')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Unlock Full Access', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)).animate().fadeIn(),
                  const SizedBox(height: 6),
                  const Text('Get unlimited contact access & more', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14)).animate(delay: 100.ms).fadeIn(),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _plans.length,
                itemBuilder: (context, i) {
                  final plan = _plans[i];
                  final isSelected = _selectedPlan == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPlan = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGlow : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppColors.primary : (plan.highlight ? AppColors.primary.withOpacity(0.4) : AppColors.border), width: isSelected ? 2 : 1),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 16)] : [],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(plan.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isSelected ? AppColors.primary : AppColors.onSurface)),
                                    if (plan.highlight) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                                        child: const Text('POPULAR', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ...plan.features.map((f) => Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Row(children: [
                                    Icon(Icons.check_circle, size: 14, color: isSelected ? AppColors.primary : AppColors.onSurfaceMuted),
                                    const SizedBox(width: 6),
                                    Text(f, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                                  ]),
                                )),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(plan.price == 0 ? 'FREE' : '₹${plan.price}',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isSelected ? AppColors.primary : AppColors.onSurface)),
                              Text(plan.period, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                            ],
                          ),
                        ],
                      ),
                    ).animate(delay: Duration(milliseconds: i * 80)).slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut).fadeIn(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _plans[_selectedPlan].price == 0 ? null : _subscribe,
                child: Text(_plans[_selectedPlan].price == 0 ? 'Current Plan' : 'Subscribe for ₹${_plans[_selectedPlan].price}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Plan {
  final String id;
  final String name;
  final int price;
  final String period;
  final List<String> features;
  final bool highlight;

  const _Plan({required this.id, required this.name, required this.price, required this.period, required this.features, required this.highlight});
}
