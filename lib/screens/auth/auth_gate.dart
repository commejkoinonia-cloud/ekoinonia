import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';

/// Décide quel écran afficher selon l'état de connexion de la personne.
/// Écoute authStateChanges : tant que l'état est inconnu, on montre un
/// simple écran de chargement ; ensuite on bascule automatiquement entre
/// l'écran de connexion et le tableau de bord, sans navigation manuelle.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.bleu),
            ),
          );
        }

        final utilisateur = snapshot.data;
        return utilisateur != null
            ? const DashboardScreen()
            : const LoginScreen();
      },
    );
  }
}