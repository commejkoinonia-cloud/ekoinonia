import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/auth_service.dart';
import '../../services/classe_service.dart';
import '../../theme/app_theme.dart';

class ProfilScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const ProfilScreen({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final p = profil;
    if (p == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Classe>>(
      stream: ClasseService().streamClasses(),
      builder: (context, snapshotClasses) {
        final nomsClasses = <String, String>{
          for (final c in snapshotClasses.data ?? <Classe>[]) c.id: c.nom,
        };
        final nomClasse = nomsClasses[p.classeId] ?? '—';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.violetBleute,
                backgroundImage: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                    ? NetworkImage(p.imageUrl!)
                    : null,
                child: (p.imageUrl == null || p.imageUrl!.isEmpty)
                    ? Text(
                        p.prenom.isNotEmpty ? p.prenom[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.blanc, fontSize: 32, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(p.nomComplet, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            if (p.badges.isNotEmpty) ...[
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: p.badges
                      .map((b) => Chip(
                            label: Text(b, style: const TextStyle(color: AppColors.blanc, fontSize: 12)),
                            backgroundColor: AppColors.bleu,
                          ))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ligneInfo('Classe encadrée', nomClasse),
                    _ligneInfo('Statut', p.actif ? 'Actif' : 'Inactif'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            OutlinedButton.icon(
              icon: const Icon(Icons.lock_outline),
              label: const Text('Changer mon mot de passe'),
              onPressed: () => _ouvrirDialogueMotDePasse(context),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.rougeAlerte),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              onPressed: () => AuthService().deconnexion(),
            ),
          ],
        );
      },
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

  Future<void> _ouvrirDialogueMotDePasse(BuildContext context) async {
    final controleur = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool enCours = false;
    String? erreur;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialogue) => AlertDialog(
          title: const Text('Nouveau mot de passe'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controleur,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Au moins 6 caractères' : null,
                ),
                if (erreur != null) ...[
                  const SizedBox(height: 8),
                  Text(erreur!, style: const TextStyle(color: AppColors.rougeAlerte, fontSize: 12)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            TextButton(
              onPressed: enCours
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setStateDialogue(() => enCours = true);
                      try {
                        await AuthService().changerMotDePasse(controleur.text);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        setStateDialogue(() {
                          enCours = false;
                          // Firebase exige parfois une reconnexion récente
                          // pour ce type d'opération sensible.
                          erreur = "Échec. Déconnecte-toi puis reconnecte-toi avant de réessayer.";
                        });
                      }
                    },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}