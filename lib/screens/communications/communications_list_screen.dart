import 'package:flutter/material.dart';
import '../../models/communication.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/communication_service.dart';
import '../../theme/app_theme.dart';
import 'communication_form_screen.dart';

class CommunicationsListScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const CommunicationsListScreen({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final peutPublier = (profil?.estAdmin ?? false) || (profil?.estChargeCommunication ?? false);

    return Scaffold(
      appBar: AppBar(title: const Text('Communications')),
      body: StreamBuilder<List<Communication>>(
        stream: CommunicationService().streamCommunications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final toutes = snapshot.data!;
          final visibles = profil == null
              ? toutes
              : toutes.where((c) => c.estVisiblePour(profil!)).toList();

          if (visibles.isEmpty) {
            return const Center(child: Text('Aucune communication pour le moment.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: visibles.length,
            itemBuilder: (context, index) {
              final c = visibles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(c.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          if (peutPublier)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.rougeAlerte),
                              onPressed: () => CommunicationService().supprimerCommunication(c.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(c.contenu),
                      const SizedBox(height: 8),
                      if (c.piecesJointes.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(c.piecesJointes.first, height: 150, fit: BoxFit.cover),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatDate(c.datePublication)} • ${_libelleDestinataire(c.destinataire)}',
                        style: const TextStyle(color: AppColors.texteClair, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: peutPublier
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.bleu,
              icon: const Icon(Icons.add, color: AppColors.blanc),
              label: const Text('Publier', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CommunicationFormScreen(profil: profil),
                ));
              },
            )
          : null,
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _libelleDestinataire(String d) {
    const libelles = {
      'tous': 'Tout le monde',
      'moniteurs': 'Moniteurs',
      'responsables': 'Responsables',
      'classe_specifique': 'Une classe',
    };
    return libelles[d] ?? d;
  }
}