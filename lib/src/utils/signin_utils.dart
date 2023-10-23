import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<User?> signInWithGoogle() async {
  try {
    // Trigger the Google Sign In process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // If the process was cancelled, return null
    if (googleUser == null) {
      return null;
    }

    // Obtain the GoogleSignInAuthentication object
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new Google credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credentials
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Return the signed in user
    return userCredential.user;
  } catch (e) {
    print('Failed to sign in with Google: $e');
    return null;
  }
}
