import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/classe.dart';
import '../../models/enfant.dart';
import '../../services/classe_service.dart';
import '../../services/enfant_service.dart';
import '../../theme/app_theme.dart';

/// Le QR code encode uniquement l'identifiant de l'enfant, jamais ses
/// informations directement : au scan, l'app va chercher les données à
/// jour dans Firestore plutôt que d'afficher des infos qui pourraient être
/// obsolètes si l'enfant a changé de classe entre-temps, par exemple.
class EnfantQrScreen extends StatelessWidget {
  final String enfantId;
  const EnfantQrScreen({super.key, required this.enfantId});

  @override
  Widget build(BuildContext context) {
    final contenuQr = 'enfant:$enfantId';

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code de l\'enfant')),
      body: StreamBuilder<List<Classe>>(
        stream: ClasseService().streamClasses(),
        builder: (context, snapshotClasses) {
          final nomsClasses = <String, String>{
            for (final c in snapshotClasses.data ?? <Classe>[]) c.id: c.nom,
          };

          return FutureBuilder<Enfant?>(
            future: EnfantService().obtenirEnfant(enfantId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final enfant = snapshot.data!;
              final nomClasse = nomsClasses[enfant.classeId] ?? '—';

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
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12),
                          ],
                        ),
                        child: QrImageView(
                          data: contenuQr,
                          size: 220,
                          backgroundColor: AppColors.blanc,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        enfant.nomComplet,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('$nomClasse${enfant.age != null ? ' • ${enfant.age} ans' : ''}',
                          style: const TextStyle(color: AppColors.texteClair)),
                      const SizedBox(height: 4),
                      Text('Réf : $enfantId',
                          style: const TextStyle(color: AppColors.texteClair, fontSize: 12)),
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