import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/utilisateur_service.dart';
import '../../theme/app_theme.dart';
import 'moniteur_detail_screen.dart';

class MoniteursListScreen extends StatelessWidget {
  const MoniteursListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moniteurs')),
      body: StreamBuilder<List<Classe>>(
        stream: ClasseService().streamClasses(),
        builder: (context, snapshotClasses) {
          final nomsClasses = <String, String>{
            for (final c in snapshotClasses.data ?? <Classe>[]) c.id: c.nom,
          };

          return StreamBuilder<List<UtilisateurProfil>>(
            stream: UtilisateurService().streamUtilisateurs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final moniteurs = snapshot.data ?? [];
              if (moniteurs.isEmpty) {
                return const Center(child: Text('Aucun moniteur trouvé.'));
              }

              return ListView.builder(
                itemCount: moniteurs.length,
                itemBuilder: (context, index) {
                  final m = moniteurs[index];
                  final nomClasse = nomsClasses[m.classeId] ?? '—';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.violetBleute,
                      backgroundImage: (m.imageUrl != null && m.imageUrl!.isNotEmpty)
                          ? NetworkImage(m.imageUrl!)
                          : null,
                      child: (m.imageUrl == null || m.imageUrl!.isEmpty)
                          ? Text(
                              m.prenom.isNotEmpty ? m.prenom[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.blanc, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    title: Text(m.nomComplet),
                    subtitle: Text('Moniteur • $nomClasse'),
                    trailing: m.badges.isNotEmpty
                        ? Chip(
                            label: Text(m.badges.first, style: const TextStyle(fontSize: 11, color: AppColors.blanc)),
                            backgroundColor: AppColors.bleu,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MoniteurDetailScreen(uid: m.uid),
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}