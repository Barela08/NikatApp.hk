import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/nikat_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _countryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final phone = '$_countryCode${_phoneController.text.trim()}';
    context.push('/auth/login/otp', extra: phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const NikatLogo(size: 100)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                const Text('NIKAT',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 4))
                    .animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 4),
                const Text(AppConstants.appTagline,
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted))
                    .animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 56),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Enter your phone number',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface))
                      .animate(delay: 400.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('We\'ll send you a 6-digit OTP',
                      style: TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted)),
                ).animate(delay: 450.ms).fadeIn(),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButton<String>(
                        value: _countryCode,
                        underline: const SizedBox(),
                        dropdownColor: AppColors.surfaceVariant,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 16),
                        items: const [
                          DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                          DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                          DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                        ],
                        onChanged: (v) => setState(() => _countryCode = v ?? '+91'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 2),
                        decoration: const InputDecoration(hintText: 'XXXXX XXXXX'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter phone number';
                          if (v.length < 10) return 'Enter 10-digit number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ).animate(delay: 500.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _sendOtp,
                  child: const Text('Send OTP'),
                ).animate(delay: 600.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.go('/language'),
                  child: const Text('🌐 Change Language', style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13)),
                ).animate(delay: 700.ms).fadeIn(),
                const SizedBox(height: 40),
                const Text('By continuing, you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceDim))
                    .animate(delay: 800.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
