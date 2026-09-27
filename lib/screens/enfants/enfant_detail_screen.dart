import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/enfant.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/enfant_service.dart';
import '../../theme/app_theme.dart';
import 'enfant_form_screen.dart';
import 'enfant_qr_screen.dart';

class EnfantDetailScreen extends StatelessWidget {
  final String enfantId;
  final UtilisateurProfil? profil;
  const EnfantDetailScreen({super.key, required this.enfantId, required this.profil});

  @override
  Widget build(BuildContext context) {
    final peutModifier = profil?.estAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche enfant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Voir le QR code',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EnfantQrScreen(enfantId: enfantId),
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

          return FutureBuilder<Enfant?>(
            future: EnfantService().obtenirEnfant(enfantId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final enfant = snapshot.data;
              if (enfant == null) {
                return const Center(child: Text("Cet enfant n'existe plus."));
              }

              final nomClasse = nomsClasses[enfant.classeId] ?? '—';

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.grisClair,
                      backgroundImage: (enfant.imageUrl != null && enfant.imageUrl!.isNotEmpty)
                          ? NetworkImage(enfant.imageUrl!)
                          : null,
                      child: (enfant.imageUrl == null || enfant.imageUrl!.isEmpty)
                          ? const Icon(Icons.child_care, size: 48, color: AppColors.bleu)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      enfant.nomComplet,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Chip(
                      label: Text(nomClasse),
                      backgroundColor: AppColors.violetBleute,
                      labelStyle: const TextStyle(color: AppColors.blanc),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ligneInfo('Âge', enfant.age != null ? '${enfant.age} ans' : '—'),
                          _ligneInfo('Sexe', enfant.sexe.isNotEmpty ? enfant.sexe : '—'),
                          _ligneInfo('Tuteur', enfant.nomTuteur.isNotEmpty ? enfant.nomTuteur : '—'),
                          _ligneInfo('Téléphone tuteur', enfant.telephoneTuteur.isNotEmpty ? enfant.telephoneTuteur : '—'),
                          _ligneInfo('Adresse', enfant.adresse.isNotEmpty ? enfant.adresse : '—'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ligneInfo(
                            'Opération Enfant Noël',
                            enfant.aDejaParticipeOEN
                                ? 'Déjà participé${enfant.anneeParticipationOEN != null ? ' (${enfant.anneeParticipationOEN})' : ''}'
                                : "N'a pas encore participé",
                          ),
                          _ligneInfo(
                            'Moyenne des devoirs',
                            (enfant.nombreDevoirsNotes ?? 0) > 0
                                ? '${enfant.moyenneDevoirs?.toStringAsFixed(1)}/20 (${enfant.nombreDevoirsNotes} devoir(s))'
                                : 'Aucun devoir noté pour le moment',
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (peutModifier) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Modifier'),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => EnfantFormScreen(enfantExistant: enfant),
                              ));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.rougeAlerte),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Supprimer'),
                            onPressed: () => _confirmerSuppression(context, enfant),
                          ),
                        ),
                      ],
                    ),
                  ],
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
          SizedBox(
            width: 150,
            child: Text(libelle, style: const TextStyle(color: AppColors.texteClair)),
          ),
          Expanded(child: Text(valeur, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _confirmerSuppression(BuildContext context, Enfant enfant) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet enfant ?'),
        content: Text('Cette action est irréversible pour ${enfant.nomComplet}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.rougeAlerte)),
          ),
        ],
      ),
    );

    if (confirme == true) {
      await EnfantService().supprimerEnfant(enfant.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}