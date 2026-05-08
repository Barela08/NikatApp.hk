import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/constants/app_colors.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final _controller = PageController();
  Timer? _timer;
  int _current = 0;

  static const _banners = [
    _BannerData(emoji: '⚡', title: 'Instant Services', subtitle: 'Book in 30 seconds', gradient: [Color(0xFF00FF88), Color(0xFF00AA55)]),
    _BannerData(emoji: '🎯', title: 'Verified Providers', subtitle: 'KYC-checked professionals', gradient: [Color(0xFF4FC3F7), Color(0xFF0288D1)]),
    _BannerData(emoji: '💎', title: 'Go Premium', subtitle: 'Unlock unlimited contacts', gradient: [Color(0xFFFFB800), Color(0xFFE65100)]),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _current = (_current + 1) % _banners.length;
      _controller.animateToPage(_current, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (_, i) => _BannerWidget(banner: _banners[i]),
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _controller,
          count: _banners.length,
          effect: ExpandingDotsEffect(
            activeDotColor: AppColors.primary,
            dotColor: AppColors.surfaceVariant,
            dotHeight: 4,
            dotWidth: 4,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  const _BannerData({required this.emoji, required this.title, required this.subtitle, required this.gradient});
}

class _BannerWidget extends StatelessWidget {
  const _BannerWidget({required this.banner});
  final _BannerData banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: banner.gradient.map((c) => c.withOpacity(0.15)).toList()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: banner.gradient.first.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(banner.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(banner.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: banner.gradient.first)),
              Text(banner.subtitle, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
