import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/features/auth/data/firebase_auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: FilledButton.tonal(
          onPressed: () => ref.read(firebaseAuthProvider).signOut(),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}