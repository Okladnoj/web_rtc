import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

abstract class FirebaseConfig {
  static Future<void> initFirebase() async {
    final options = DefaultFirebaseOptions.currentPlatform;
    try {
      await Firebase.initializeApp(
        // name: Platform.isAndroid ? null : options.projectId,
        options: options,
      );
    } catch (e) {
      log('Error during Firebase initialization: $e');
      rethrow;
    }
  }
}
