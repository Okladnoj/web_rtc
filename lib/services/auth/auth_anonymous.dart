import 'package:firebase_auth/firebase_auth.dart';

class AuthAnonymous {
  Future<String?> get uID async {
    final user = await FirebaseAuth.instance.signInAnonymously();
    return user.user?.uid;
  }
}
