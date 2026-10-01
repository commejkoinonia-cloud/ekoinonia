import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../services/classe_service.dart';
import '../../services/utilisateur_service.dart';
import '../../theme/app_theme.dart';
import 'moniteur_qr_screen.dart';

class MoniteurDetailScreen extends StatelessWidget {
  final String uid;
  const MoniteurDetailScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche moniteur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Voir le QR code',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MoniteurQrScreen(uid: uid),
              ));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Classe>>(
        stream: ClasseService().streamClasses(),
        builder: (context, snapshotClasses) {
          final nomsClasses = <String, String>{
            for (final c in snapshotClasses.data ?? <Classe>[]) c.id: c.nom,
          };

          return FutureBuilder(
            future: UtilisateurService().obtenirUtilisateur(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final moniteur = snapshot.data;
              if (moniteur == null) {
                return const Center(child: Text("Ce moniteur n'existe plus."));
              }

              final nomClasse = nomsClasses[moniteur.classeId] ?? '—';

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.violetBleute,
                      backgroundImage: (moniteur.imageUrl != null && moniteur.imageUrl!.isNotEmpty)
                          ? NetworkImage(moniteur.imageUrl!)
                          : null,
                      child: (moniteur.imageUrl == null || moniteur.imageUrl!.isEmpty)
                          ? Text(
                              moniteur.prenom.isNotEmpty ? moniteur.prenom[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.blanc, fontSize: 32, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(moniteur.nomComplet,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  if (moniteur.badges.isNotEmpty)
                    Center(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: moniteur.badges
                            .map((b) => Chip(
                                  label: Text(b, style: const TextStyle(color: AppColors.blanc, fontSize: 12)),
                                  backgroundColor: AppColors.bleu,
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ligneInfo('Classe encadrée', nomClasse),
                          _ligneInfo('Statut', moniteur.actif ? 'Actif' : 'Inactif'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _ligneInfo(String libelle, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(libelle, style: const TextStyle(color: AppColors.texteClair))),
          Expanded(child: Text(valeur, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}