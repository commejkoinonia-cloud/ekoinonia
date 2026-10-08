import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/devoir.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/devoir_service.dart';
import '../../theme/app_theme.dart';
import 'devoir_form_screen.dart';
import 'devoir_notation_screen.dart';

class DevoirsListScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const DevoirsListScreen({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    // Un simple moniteur ne voit (et ne crée) que les devoirs de SA classe.
    // Un admin voit tout.
    final filtrerParClasse = (profil != null && !profil!.estAdmin) ? profil!.classeId : null;
    final peutCreer = profil != null && (profil!.estAdmin || profil!.classeId.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('Devoirs')),
      body: StreamBuilder<List<Classe>>(
        stream: ClasseService().streamClasses(),
        builder: (context, snapshotClasses) {
          final nomsClasses = <String, String>{
            for (final c in snapshotClasses.data ?? <Classe>[]) c.id: c.nom,
          };

          return StreamBuilder<List<Devoir>>(
            stream: DevoirService().streamDevoirs(classeId: filtrerParClasse),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final devoirs = snapshot.data!;
              if (devoirs.isEmpty) {
                return const Center(child: Text('Aucun devoir pour le moment.'));
              }

              return ListView.builder(
                itemCount: devoirs.length,
                itemBuilder: (context, index) {
                  final d = devoirs[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.grisClair,
                      child: Icon(Icons.assignment_outlined, color: AppColors.bleu),
                    ),
                    title: Text(d.titre),
                    subtitle: Text('${nomsClasses[d.classeId] ?? '—'} • ${_formatDate(d.date)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DevoirNotationScreen(devoir: d),
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: peutCreer
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.bleu,
              icon: const Icon(Icons.add, color: AppColors.blanc),
              label: const Text('Nouveau devoir', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => DevoirFormScreen(profil: profil),
                ));
              },
            )
          : null,
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}