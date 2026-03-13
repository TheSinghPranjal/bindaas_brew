import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Initiates Google sign-in and returns the account on success or null.
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final acct = await _googleSignIn.signIn();
      return acct;
    } catch (e) {
      // In the starter app we don't crash - just return null
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
