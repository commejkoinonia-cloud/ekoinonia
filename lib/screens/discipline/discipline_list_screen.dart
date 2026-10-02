import 'package:flutter/material.dart';
import '../../models/discipline_entree.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/discipline_service.dart';
import '../../services/utilisateur_service.dart';
import '../../theme/app_theme.dart';
import 'discipline_form_screen.dart';

class DisciplineListScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const DisciplineListScreen({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final peutGerer = (profil?.estAdmin ?? false) || (profil?.estChargeDiscipline ?? false);

    return Scaffold(
      appBar: AppBar(title: const Text('Discipline')),
      body: StreamBuilder<List<UtilisateurProfil>>(
        stream: UtilisateurService().streamUtilisateurs(),
        builder: (context, snapshotUtilisateurs) {
          final noms = <String, String>{
            for (final u in snapshotUtilisateurs.data ?? <UtilisateurProfil>[]) u.uid: u.nomComplet,
          };

          return StreamBuilder<List<EntreeDiscipline>>(
            stream: DisciplineService().streamEntrees(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final entrees = snapshot.data!;
              if (entrees.isEmpty) {
                return const Center(child: Text('Aucune entrée pour le moment.'));
              }

              return ListView.builder(
                itemCount: entrees.length,
                itemBuilder: (context, index) {
                  final e = entrees[index];
                  final nomConcerne = noms[e.utilisateurId] ?? 'Inconnu';
                  final estResolu = e.statut == 'resolu';

                  return ListTile(
                    leading: Icon(
                      estResolu ? Icons.check_circle_outline : Icons.error_outline,
                      color: estResolu ? AppColors.vertBleute : AppColors.rougeAlerte,
                    ),
                    title: Text(nomConcerne),
                    subtitle: Text(e.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      estResolu ? 'Résolu' : 'Ouvert',
                      style: TextStyle(
                        color: estResolu ? AppColors.vertBleute : AppColors.rougeAlerte,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    onTap: peutGerer
                        ? () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => DisciplineFormScreen(entreeExistante: e, profil: profil),
                            ));
                          }
                        : null,
                  );
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
              label: const Text('Nouvelle entrée', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => DisciplineFormScreen(profil: profil),
                ));
              },
            )
          : null,
    );
  }
}