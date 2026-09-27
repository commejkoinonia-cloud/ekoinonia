import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../auth/auth_gate.dart';

/// Premier écran affiché au lancement de l'app : le logo de MEJ, avec le
/// nom "ECODIM" en dessous, pendant 3 secondes. Passé ce délai, on ne
/// revient jamais sur cet écran (pushReplacement) : on part directement
/// vers l'AuthGate, qui décide ensuite lui-même connexion ou tableau de bord.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _demarrerCompteAReboursPuisRediriger();
  }

  Future<void> _demarrerCompteAReboursPuisRediriger() async {
    await Future.delayed(const Duration(seconds: 3));

    // "mounted" vérifie que l'écran est toujours affiché avant de naviguer
    // (au cas où l'utilisateur aurait déjà quitté l'app entre-temps).
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bleu,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Le logo doit être ajouté aux assets du projet (voir instructions).
            Image.asset(
              'assets/images/logo_mej.png',
              width: 140,
              height: 140,
            ),
            const SizedBox(height: 16),
            const Text(
              'ECODIM',
              style: TextStyle(
                color: AppColors.blanc,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}