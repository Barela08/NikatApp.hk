import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/language_select/language_select_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/role_select_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/main_shell.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/provider_listing/provider_listing_screen.dart';
import '../../screens/provider_detail/provider_detail_screen.dart';
import '../../screens/subscription/subscription_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/orders/order_detail_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/provider_dashboard/provider_dashboard_screen.dart';
import '../../screens/provider_dashboard/add_store_screen.dart';
import '../../screens/admin/admin_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/language' ||
          state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/language', builder: (c, s) => const LanguageSelectScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/auth/role', builder: (c, s) => const RoleSelectScreen()),
      GoRoute(
        path: '/auth/login',
        builder: (c, s) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (c, s) => OtpScreen(phone: s.extra as String? ?? ''),
          ),
          GoRoute(path: 'register', builder: (c, s) => const RegisterScreen()),
        ],
      ),
      ShellRoute(
        builder: (c, s, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
          GoRoute(
            path: '/category/:id',
            builder: (c, s) => ProviderListingScreen(categoryId: s.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: '/provider/:id',
            builder: (c, s) => ProviderDetailScreen(providerId: s.pathParameters['id'] ?? ''),
          ),
          GoRoute(path: '/subscribe', builder: (c, s) => const SubscriptionScreen()),
          GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen()),
          GoRoute(
            path: '/orders/:id',
            builder: (c, s) => OrderDetailScreen(orderId: s.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: '/chat/:providerId',
            builder: (c, s) => ChatScreen(providerId: s.pathParameters['providerId'] ?? ''),
          ),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
          GoRoute(path: '/provider-dashboard', builder: (c, s) => const ProviderDashboardScreen()),
          GoRoute(path: '/add-store', builder: (c, s) => const AddStoreScreen()),
          GoRoute(path: '/admin', builder: (c, s) => const AdminScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 64, color: Color(0xFF00FF88), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Page not found', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/'), child: const Text('Go Home')),
          ],
        ),
      ),
    ),
  );
});
