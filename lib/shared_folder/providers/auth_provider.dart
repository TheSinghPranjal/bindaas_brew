import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../features/auth/google_auth.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

/// AuthNotifier holds a lightweight `AuthUser` instead of a plugin type.
/// This allows tests and dev environments to mock or fallback when
/// Google sign-in is not available.
class AuthNotifier extends StateNotifier<AuthUser?> {
  AuthNotifier() : super(null);

  /// Attempt real Google sign-in. If it fails or returns null, fallback
  /// to a local mocked user so the app flow can continue in dev.
  Future<void> signIn() async {
    try {
      // Use Firebase-based sign-in helper
      final fb_auth.User? user = await AuthService.signInWithGoogle();
      if (user != null) {
        state = AuthUser(displayName: user.displayName ?? user.email ?? 'User', email: user.email ?? '');
        return;
      }
    } catch (_) {
      // ignore and fallback to mock below
    }

    // Fallback mock user for environments where Google sign-in can't run
    state = AuthUser(displayName: 'Dev User', email: 'dev@example.com');
  }

  /// Directly set a mocked authenticated user without invoking Google SDK.
  /// Useful for local development when native Google setup is not available.
  Future<void> signInMock({String? name, String? email}) async {
    state = AuthUser(displayName: name ?? 'Dev User', email: email ?? 'dev@example.com');
  }

  Future<void> signOut() async {
    try {
      // Sign out Firebase + Google plugin if present
      try {
        await fb_auth.FirebaseAuth.instance.signOut();
      } catch (_) {}
      try {
        await GoogleAuth.signOut();
      } catch (_) {}
    } catch (_) {}
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthUser?>((ref) {
  return AuthNotifier();
});
