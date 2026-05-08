import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _navigate();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasLanguage = prefs.getString(AppConstants.keyLanguage) != null;
    final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
    final authUser = ref.read(authStateProvider).valueOrNull;

    if (!hasLanguage) {
      context.go('/language');
    } else if (!onboardingDone) {
      context.go('/onboarding');
    } else if (authUser == null) {
      context.go('/auth/login');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) => Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2 + _glowController.value * 0.4),
                      blurRadius: 40 + _glowController.value * 20,
                      spreadRadius: 5 + _glowController.value * 5,
                    ),
                  ],
                ),
                child: child,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset('assets/images/nikat_logo.png',
                    width: 140, height: 140, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          child: const Center(
                            child: Text('N', style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 72,
                              fontWeight: FontWeight.w800,
                            )),
                          ),
                        )),
              ),
            )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 28),
            const Text('NIKAT',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 6,
                ))
                .animate(delay: 400.ms)
                .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            const Text(AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceMuted,
                  letterSpacing: 0.5,
                ))
                .animate(delay: 600.ms)
                .fadeIn(duration: 500.ms),
            const SizedBox(height: 60),
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 60),
            const Text('by HackifyPro',
                style: TextStyle(fontSize: 11, color: AppColors.onSurfaceDim))
                .animate(delay: 700.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
