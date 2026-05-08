import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/locale_provider.dart';

class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  ConsumerState<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  String? _selected;

  void _confirm() async {
    if (_selected == null) return;
    await ref.read(localeProvider.notifier).setLocale(_selected!);
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
    if (mounted) context.go(onboardingDone ? '/auth/login' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('🌐', style: TextStyle(fontSize: 40))
                  .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              const Text('Choose Language', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onSurface))
                  .animate(delay: 100.ms).slideX(begin: -0.2, duration: 400.ms).fadeIn(),
              const SizedBox(height: 4),
              const Text('भाषा चुनें • ভাষা বাছুন', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted))
                  .animate(delay: 150.ms).fadeIn(),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: AppConstants.supportedLanguages.length,
                  itemBuilder: (context, i) {
                    final lang = AppConstants.supportedLanguages[i];
                    final isSelected = _selected == lang['code'];
                    return _LanguageCard(
                      language: lang,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selected = lang['code']),
                    ).animate(delay: Duration(milliseconds: 200 + i * 50))
                        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut)
                        .fadeIn(duration: 300.ms);
                  },
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _selected != null ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _selected != null ? _confirm : null,
                  child: const Text('Continue →'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.language, required this.isSelected, required this.onTap});

  final Map<String, String> language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGlow : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(language['flag'] ?? '🌐', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                if (isSelected)
                  Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: Colors.black),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(language['nativeName'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                )),
            Text(language['name'] ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
          ],
        ),
      ),
    );
  }
}
