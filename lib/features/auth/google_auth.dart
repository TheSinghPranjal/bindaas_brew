import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  // Lazily initialize the plugin using the common constructor.
  // Keep this simple to avoid referencing plugin constructors that
  // may not exist on every version and cause compile-time errors.
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Initiates Google sign-in and returns the account on success or null.
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      // Some plugin versions expose signIn() while others use signInSilently/
      // signInWithNewAccount; try the common method first.
      return await _googleSignIn.signIn();
          return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
