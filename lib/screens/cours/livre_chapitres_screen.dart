import 'package:flutter/material.dart';
import '../../models/chapitre.dart';
import '../../models/livre_cours.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/livre_cours_service.dart';
import '../../theme/app_theme.dart';

class LivreChapitresScreen extends StatelessWidget {
  final LivreCours livre;
  final UtilisateurProfil? profil;
  const LivreChapitresScreen({super.key, required this.livre, required this.profil});

  Future<void> _ouvrirDialogueAjoutChapitre(BuildContext context, int prochainNumero) async {
    final titreController = TextEditingController();
    final contenuController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chapitre $prochainNumero'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titreController,
              decoration: const InputDecoration(labelText: 'Titre du chapitre'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contenuController,
              decoration: const InputDecoration(labelText: 'Contenu (optionnel)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (titreController.text.trim().isEmpty) return;
              await LivreCoursService().ajouterChapitre(
                livre.id,
                Chapitre(id: '', numero: prochainNumero, titre: titreController.text.trim(), contenu: contenuController.text.trim()),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final peutGerer = profil?.estAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(livre.titre)),
      body: StreamBuilder<List<Chapitre>>(
        stream: LivreCoursService().streamChapitres(livre.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chapitres = snapshot.data!;
          if (chapitres.isEmpty) {
            return const Center(child: Text('Aucun chapitre pour le moment.'));
          }

          return ListView.builder(
            itemCount: chapitres.length,
            itemBuilder: (context, index) {
              final c = chapitres[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.grisClair, child: Text('${c.numero}')),
                title: Text(c.titre),
                subtitle: c.contenu.isNotEmpty ? Text(c.contenu, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
              );
            },
          );
        },
      ),
      floatingActionButton: peutGerer
          ? StreamBuilder<List<Chapitre>>(
              stream: LivreCoursService().streamChapitres(livre.id),
              builder: (context, snapshot) {
                final prochainNumero = (snapshot.data?.length ?? 0) + 1;
                return FloatingActionButton.extended(
                  backgroundColor: AppColors.bleu,
                  icon: const Icon(Icons.add, color: AppColors.blanc),
                  label: const Text('Chapitre', style: TextStyle(color: AppColors.blanc)),
                  onPressed: () => _ouvrirDialogueAjoutChapitre(context, prochainNumero),
                );
              },
            )
          : null,
    );
  }
}