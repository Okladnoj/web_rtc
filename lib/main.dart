import 'package:flutter/material.dart';

import 'firebase/firebase_config.dart';
import 'pages/rooms/rooms_core.dart';
import 'pages/rooms/rooms_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initFirebase();
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: RoomsListScreen(roomsCore: RoomsCore()),
    );
  }
}
