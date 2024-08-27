import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on User


  // Sign in anonymously
  Future<User?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;

      if (user != null) {
        print("Signed in Temporarily: ${user.uid}");
        return user;
      } else {
        print("Failed to sign in anonymously");
        return null;
      }
    } catch (e) {
      print("Error Signing in anonymously: $e");
      return null;
    }
  }

  // Add methods for sign in with email and password, and register with email and password
}
