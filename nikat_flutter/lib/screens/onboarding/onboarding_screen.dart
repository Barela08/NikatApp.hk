import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '🔍',
      title: 'Discover Nearby Shops',
      subtitle: 'Find electricians, plumbers, salons, and 100+ services near you in seconds',
      gradient: [Color(0xFF00FF88), Color(0xFF00CC6A)],
    ),
    _OnboardingPage(
      emoji: '📱',
      title: 'One Tap Connect',
      subtitle: 'Call or WhatsApp service providers directly. No middlemen, no hassle',
      gradient: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
    ),
    _OnboardingPage(
      emoji: '⭐',
      title: 'Trusted & Verified',
      subtitle: 'All providers are KYC-verified and rated by real customers like you',
      gradient: [Color(0xFFFFB800), Color(0xFFE65100)],
    ),
    _OnboardingPage(
      emoji: '📦',
      title: 'Book & Track Orders',
      subtitle: 'Place orders, pay online, and track delivery in real-time from your home',
      gradient: [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (mounted) context.go('/auth/role');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _OnboardingPageWidget(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.surfaceVariant,
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next →'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.emoji, required this.title,
    required this.subtitle, required this.gradient,
  });
}

class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient.map((c) => c.withOpacity(0.2)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: page.gradient.first.withOpacity(0.4), width: 2),
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 72)),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.onSurface))
              .animate(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
          const SizedBox(height: 16),
          Text(page.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppColors.onSurfaceMuted, height: 1.5))
              .animate(delay: 350.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
        ],
      ),
    );
  }
}
