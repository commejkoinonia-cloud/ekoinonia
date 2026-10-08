import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/seance.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/seance_service.dart';
import '../../theme/app_theme.dart';
import 'seance_form_screen.dart';
import 'seance_presence_screen.dart';

class SeancesTab extends StatelessWidget {
  final UtilisateurProfil? profil;
  const SeancesTab({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final filtrerParClasse = (profil != null && !profil!.estAdmin) ? profil!.classeId : null;
    final peutCreer = profil != null && (profil!.estAdmin || profil!.classeId.isNotEmpty);

    return Scaffold(
      body: StreamBuilder<List<Classe>>(
        stream: ClasseService().streamClasses(),
        builder: (context, snapshotClasses) {
          final nomsClasses = <String, String>{
            for (final c in snapshotClasses.data ?? <Classe>[]) c.id: c.nom,
          };

          return StreamBuilder<List<Seance>>(
            stream: SeanceService().streamSeances(classeId: filtrerParClasse),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final seances = snapshot.data!;
              if (seances.isEmpty) {
                return const Center(child: Text('Aucune séance enregistrée.'));
              }

              return ListView.builder(
                itemCount: seances.length,
                itemBuilder: (context, index) {
                  final s = seances[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.grisClair,
                      child: Icon(Icons.event_note_outlined, color: AppColors.bleu),
                    ),
                    title: Text(s.titre?.isNotEmpty == true ? s.titre! : 'Séance du ${_formatDate(s.date)}'),
                    subtitle: Text(
                      '${nomsClasses[s.classeId] ?? '—'} • ${s.nombrePresents} présent(s) / ${s.nombreAbsents} absent(s)',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SeancePresenceScreen(seance: s),
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
              label: const Text('Nouvelle séance', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SeanceFormScreen(profil: profil),
                ));
              },
            )
          : null,
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}