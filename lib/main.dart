import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  // Obligatoire avant d'utiliser tout plugin natif (dont Firebase)
  // quand on fait des appels asynchrones avant runApp().
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const EcodimApp());
}

class EcodimApp extends StatelessWidget {
  const EcodimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECODIM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // le thème centralisé, appliqué globalement
      home: const SplashScreen(),
    );
  }
}