import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _pinController = TextEditingController();
  Timer? _timer;
  int _seconds = 60;
  bool _resendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  void _startTimer() {
    _seconds = 60;
    _resendEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _resendEnabled = true;
          t.cancel();
        }
      });
    });
  }

  void _sendOtp() {
    ref.read(otpProvider.notifier).sendOtp(widget.phone);
  }

  void _resend() {
    _sendOtp();
    _startTimer();
  }

  Future<void> _verify() async {
    if (_pinController.text.length != 6) return;
    final success = await ref.read(otpProvider.notifier).verifyOtp(_pinController.text);
    if (!success || !mounted) return;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final existingProfile = await ref.read(authServiceProvider).getUserProfile(user.uid);
    if (existingProfile == null) {
      if (mounted) context.go('/auth/register');
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserId, user.uid);
      await prefs.setString(AppConstants.keyUserRole, existingProfile.role);
      if (mounted) context.go('/');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('📱', style: TextStyle(fontSize: 48))
                  .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              const Text('Enter OTP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onSurface))
                  .animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted),
                  children: [
                    const TextSpan(text: 'Sent to '),
                    TextSpan(text: widget.phone, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration?.copyWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onCompleted: (_) => _verify(),
                  autofocus: true,
                ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              ),
              const SizedBox(height: 32),
              if (otpState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Text(otpState.error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              ElevatedButton(
                onPressed: otpState.isLoading ? null : _verify,
                child: otpState.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Verify & Login'),
              ).animate(delay: 400.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 20),
              Center(
                child: _resendEnabled
                    ? TextButton(onPressed: _resend, child: const Text('Resend OTP'))
                    : Text('Resend in ${_seconds}s',
                        style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13)),
              ).animate(delay: 500.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
