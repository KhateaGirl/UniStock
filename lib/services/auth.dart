import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;

      if (user != null) {
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

}
