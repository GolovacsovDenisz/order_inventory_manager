import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Call at request time to get the current Firebase ID token (or null if not signed in).
final getAuthTokenProvider = Provider<Future<String?> Function()>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  return () => auth.currentUser?.getIdToken() ?? Future.value(null);
});