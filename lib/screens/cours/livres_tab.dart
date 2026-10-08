import 'package:flutter/material.dart';
import '../../models/livre_cours.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/livre_cours_service.dart';
import '../../theme/app_theme.dart';
import 'livre_chapitres_screen.dart';
import 'livre_form_screen.dart';

class LivresTab extends StatelessWidget {
  final UtilisateurProfil? profil;
  const LivresTab({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final peutGerer = profil?.estAdmin ?? false;

    return Scaffold(
      body: StreamBuilder<List<LivreCours>>(
        stream: LivreCoursService().streamLivres(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final livres = snapshot.data!;
          if (livres.isEmpty) {
            return const Center(child: Text('Aucun livre pour le moment.'));
          }

          return ListView.builder(
            itemCount: livres.length,
            itemBuilder: (context, index) {
              final livre = livres[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.grisClair,
                  child: Icon(Icons.menu_book_outlined, color: AppColors.bleu),
                ),
                title: Text(livre.titre),
                subtitle: livre.description.isNotEmpty ? Text(livre.description) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => LivreChapitresScreen(livre: livre, profil: profil),
                  ));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: peutGerer
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.bleu,
              icon: const Icon(Icons.add, color: AppColors.blanc),
              label: const Text('Nouveau livre', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const LivreFormScreen(),
                ));
              },
            )
          : null,
    );
  }
}