import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selected;

  void _continue() async {
    if (_selected == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, _selected!);
    if (mounted) context.go('/auth/login');
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
              const SizedBox(height: 40),
              const Text('I am a...', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.onSurface))
                  .animate().slideX(begin: -0.2, duration: 500.ms).fadeIn(),
              const SizedBox(height: 8),
              const Text('Select your role to get started', style: TextStyle(fontSize: 15, color: AppColors.onSurfaceMuted))
                  .animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 48),
              _RoleCard(
                icon: '👤',
                title: 'Customer',
                subtitle: 'Find nearby shops & services',
                color: AppColors.primary,
                isSelected: _selected == AppConstants.roleCustomer,
                onTap: () => setState(() => _selected = AppConstants.roleCustomer),
              ).animate(delay: 200.ms).slideY(begin: 0.3, duration: 400.ms).fadeIn(),
              const SizedBox(height: 16),
              _RoleCard(
                icon: '🏪',
                title: 'Shop Owner',
                subtitle: 'List your shop & grow your business',
                color: const Color(0xFFFFB800),
                isSelected: _selected == AppConstants.roleProvider,
                onTap: () => setState(() => _selected = AppConstants.roleProvider),
              ).animate(delay: 300.ms).slideY(begin: 0.3, duration: 400.ms).fadeIn(),
              const Spacer(),
              AnimatedOpacity(
                opacity: _selected != null ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _selected != null ? _continue : null,
                  child: const Text('Continue'),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.isSelected, required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 16)] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isSelected ? color : AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 16, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}
