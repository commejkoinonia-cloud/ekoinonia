import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/classe.dart';
import '../../services/classe_service.dart';
import '../../services/utilisateur_service.dart';
import '../../theme/app_theme.dart';

class MoniteurQrScreen extends StatelessWidget {
  final String uid;
  const MoniteurQrScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final contenuQr = 'moniteur:$uid';

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code du moniteur')),
      body: StreamBuilder<List<Classe>>(
        stream: ClasseService().streamClasses(),
        builder: (context, snapshotClasses) {
          final nomsClasses = <String, String>{
            for (final c in snapshotClasses.data ?? <Classe>[]) c.id: c.nom,
          };

          return FutureBuilder(
            future: UtilisateurService().obtenirUtilisateur(uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final moniteur = snapshot.data!;
              final nomClasse = nomsClasses[moniteur.classeId] ?? '—';

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.blanc,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)],
                        ),
                        child: QrImageView(data: contenuQr, size: 220, backgroundColor: AppColors.blanc),
                      ),
                      const SizedBox(height: 24),
                      Text(moniteur.nomComplet, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(nomClasse, style: const TextStyle(color: AppColors.texteClair)),
                      if (moniteur.badges.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          alignment: WrapAlignment.center,
                          children: moniteur.badges
                              .map((b) => Chip(
                                    label: Text(b, style: const TextStyle(color: AppColors.blanc, fontSize: 11)),
                                    backgroundColor: AppColors.violetBleute,
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}