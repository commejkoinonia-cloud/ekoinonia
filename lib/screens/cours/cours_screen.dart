import 'package:flutter/material.dart';
import '../../models/utilisateur_profil.dart';
import '../../theme/app_theme.dart';
import 'livres_tab.dart';
import 'seances_tab.dart';

/// Contenu réel de l'onglet "Cours" de la barre basse : regroupe les
/// séances (calendrier des dimanches) et le catalogue des livres, dans
/// deux sous-onglets.
class CoursScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const CoursScreen({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    // Pas de Scaffold/AppBar ici : cet écran est déjà affiché à l'intérieur
    // du Dashboard, qui a sa propre barre du haut (cloche, avatar...).
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: AppColors.bleu,
            child: const TabBar(
              indicatorColor: AppColors.blanc,
              labelColor: AppColors.blanc,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Séances'),
                Tab(text: 'Livres'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SeancesTab(profil: profil),
                LivresTab(profil: profil),
              ],
            ),
          ),
        ],
      ),
    );
  }
}