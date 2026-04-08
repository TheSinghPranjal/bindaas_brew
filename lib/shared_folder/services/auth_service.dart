import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../features/auth/google_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  /// Sign in using Google and save a basic user doc to Firestore.
  static Future<fb_auth.User?> signInWithGoogle() async {
    try {
      // Use the central GoogleAuth wrapper. Some google_sign_in versions
      // no longer expose an `accessToken` getter on the auth object; using
      // `dynamic` here makes the code tolerant to those API differences.
      final googleUser = await GoogleAuth.signIn();
      if (googleUser == null) return null;

      // Some google_sign_in implementations expose `authentication` as a
      // synchronous getter, others as a Future. Normalize both cases here.
      final dynamic authMaybe = googleUser.authentication;
      final dynamic googleAuth = authMaybe is Future ? await authMaybe : authMaybe;

      final credential = fb_auth.GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken,
      );

      final userCredential = await fb_auth.FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Save minimal user info to Firestore (merge to avoid overwriting other fields)
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          // Firestore save failed — ignore for now but log in debug
          // print('Failed to save user to Firestore: $e');
        }
      }

      return user;
    } catch (e) {
      // print("Login Error: $e");
      return null;
    }
  }
}
