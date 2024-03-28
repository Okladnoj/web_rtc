import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

class AuthAnonymous {
  Future<String> get uID async {
    final user = await FirebaseAuth.instance.signInAnonymously();
    return user.user?.uid ?? Random().nextDouble().toStringAsFixed(10);
  }
}
