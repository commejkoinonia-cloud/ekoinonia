import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../theme/app_theme.dart';
import 'classe_form_screen.dart';

class ClassesListScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const ClassesListScreen({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final peutGerer = profil?.estAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      body: StreamBuilder<List<Classe>>(
        stream: ClasseService().streamClasses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final classes = snapshot.data!;
          if (classes.isEmpty) {
            return const Center(child: Text('Aucune classe pour le moment.'));
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classe = classes[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.grisClair,
                  child: Icon(Icons.class_, color: AppColors.bleu),
                ),
                title: Text(classe.nom),
                subtitle: Text(
                  [
                    if (classe.trancheAge.isNotEmpty) classe.trancheAge,
                    '${classe.moniteurIds.length} moniteur(s)',
                  ].join(' • '),
                ),
                trailing: peutGerer ? const Icon(Icons.edit_outlined, color: AppColors.texteClair) : null,
                onTap: peutGerer
                    ? () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ClasseFormScreen(classeExistante: classe),
                        ));
                      }
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: peutGerer
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.bleu,
              icon: const Icon(Icons.add, color: AppColors.blanc),
              label: const Text('Nouvelle classe', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ClasseFormScreen(),
                ));
              },
            )
          : null,
    );
  }
}