import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:order_inventory_manager/features/auth/data/firebase_auth_provider.dart';
import 'package:order_inventory_manager/features/screens/clients_screen.dart';
import 'package:order_inventory_manager/features/screens/login_screen.dart';
import 'package:order_inventory_manager/features/screens/orders_screen.dart';
import 'package:order_inventory_manager/features/screens/products_screen.dart';
import 'package:order_inventory_manager/features/screens/settings_screen.dart';

import '../features/screens/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/orders',
    redirect: (context, state) {
      final goingToLogin = state.matchedLocation == '/login';

      if (authAsync.isLoading) return null;

      final loggedIn = authAsync.asData?.value != null;

      if (!loggedIn && !goingToLogin) return '/login';
      if (loggedIn && goingToLogin) return '/orders';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/orders',
            builder: (BuildContext context, GoRouterState state) =>
                const OrdersScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (BuildContext context, GoRouterState state) =>
                const ProductsScreen(),
          ),
          GoRoute(
            path: '/clients',
            builder: (BuildContext context, GoRouterState state) =>
                const ClientsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
