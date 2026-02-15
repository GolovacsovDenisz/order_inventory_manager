import 'package:riverpod/legacy.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

sealed class AuthState {
  const AuthState();
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthLoggedIn extends AuthState {
  const AuthLoggedIn();
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthLoggedOut());

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AuthLoggedIn();
  }

  void logout() => state = const AuthLoggedOut();
}