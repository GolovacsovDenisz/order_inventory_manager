import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  int _indexFromLocation(String location) {
    if (location.startsWith('/products')) return 1;
    if (location.startsWith('/clients')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // orders
  }

  void _go(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/orders'); break;
      case 1: context.go('/products'); break;
      case 2: context.go('/clients'); break;
      case 3: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _go(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.people_alt), label: 'Clients'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}