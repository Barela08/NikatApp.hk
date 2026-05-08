import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  int _currentIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/orders')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);
    final userAsync = ref.watch(currentUserProvider);
    final isProvider = userAsync.valueOrNull?.isProvider ?? false;
    final isAdmin = userAsync.valueOrNull?.isAdmin ?? false;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', isActive: currentIndex == 0, onTap: () => context.go('/')),
                _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Search', isActive: currentIndex == 1, onTap: () => context.go('/search')),
                _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Orders', isActive: currentIndex == 2, onTap: () => context.go('/orders')),
                if (isProvider || isAdmin)
                  _NavItem(icon: Icons.store_outlined, activeIcon: Icons.store, label: 'Dashboard', isActive: location.startsWith('/provider-dashboard'), onTap: () => context.go('/provider-dashboard')),
                if (isAdmin)
                  _NavItem(icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings, label: 'Admin', isActive: location.startsWith('/admin'), onTap: () => context.go('/admin')),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', isActive: currentIndex == 3, onTap: () => context.go('/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.isActive, required this.onTap});
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.primary : AppColors.onSurfaceMuted, size: 22),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.onSurfaceMuted,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
