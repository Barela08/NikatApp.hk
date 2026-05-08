import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20)],
                  ),
                  child: const Center(child: Text('👤', style: TextStyle(fontSize: 40))),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
                    .animate(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 4),
                Text(user.phone, style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14))
                    .animate(delay: 150.ms).fadeIn(),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGlow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                  ),
                  child: Text(user.role.toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 28),
                // Subscription card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: user.hasActiveSubscription
                        ? LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.primaryDark.withOpacity(0.1)])
                        : null,
                    color: user.hasActiveSubscription ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: user.hasActiveSubscription ? AppColors.primary.withOpacity(0.5) : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text(user.hasActiveSubscription ? '💎' : '🔒', style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.hasActiveSubscription ? 'Premium Active' : 'Free Plan',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(user.hasActiveSubscription
                                ? 'Expires ${user.subscriptionEnd?.day}/${user.subscriptionEnd?.month}/${user.subscriptionEnd?.year}'
                                : 'Upgrade for unlimited access',
                                style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted)),
                          ],
                        ),
                      ),
                      if (!user.hasActiveSubscription)
                        ElevatedButton(
                          onPressed: () => context.push('/subscribe'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
                          child: const Text('Upgrade', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                const SizedBox(height: 20),
                // Menu items
                ...[
                  _MenuItem(icon: Icons.receipt_long_outlined, label: 'My Orders', onTap: () => context.go('/orders')),
                  if (user.isProvider)
                    _MenuItem(icon: Icons.store_outlined, label: 'My Shop Dashboard', onTap: () => context.go('/provider-dashboard')),
                  if (user.isAdmin)
                    _MenuItem(icon: Icons.admin_panel_settings_outlined, label: 'Admin Panel', onTap: () => context.go('/admin')),
                  _MenuItem(icon: Icons.language_outlined, label: 'Change Language', onTap: () => context.go('/language')),
                  _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
                  _MenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
                  _MenuItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    color: AppColors.error,
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.go('/auth/login');
                    },
                  ),
                ].asMap().entries.map((e) => e.value
                    .animate(delay: Duration(milliseconds: 400 + e.key * 60))
                    .slideY(begin: 0.2, duration: 400.ms).fadeIn()),
                const SizedBox(height: 40),
                const Text('NIKAT v1.0.0\nby HackifyPro',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceDim))
                    .animate(delay: 800.ms).fadeIn(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
        tileColor: AppColors.surface,
        leading: Icon(icon, color: color ?? AppColors.onSurfaceMuted, size: 22),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? AppColors.onSurface)),
        trailing: Icon(Icons.chevron_right, color: color ?? AppColors.onSurfaceDim, size: 20),
      ),
    );
  }
}
