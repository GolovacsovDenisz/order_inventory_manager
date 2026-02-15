import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';
    case 'user-not-found':
      return 'No account found for this email. Try creating one.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'invalid-credential':
      return 'Invalid email or password. Please try again.';
    case 'email-already-in-use':
      return 'This email is already in use. Try signing in instead.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a bit and try again.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled for this project.';
    case 'requires-recent-login':
      return 'Please sign in again to continue.';
    default:
      return error.message ?? 'Authentication failed. Please try again.';
  }
}