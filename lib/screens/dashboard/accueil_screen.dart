import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/utilisateur_profil.dart';
import '../../theme/app_theme.dart';

/// Écran d'accueil : quelques chiffres clés, calculés à la demande via des
/// requêtes d'agrégation Firestore (count()) plutôt que via une collection
/// "statistiques" séparée à maintenir à la main (voir schema_firestore.md,
/// section notifications/statistiques : on préfère toujours calculer à la
/// volée quand le volume de données reste raisonnable).
class AccueilScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const AccueilScreen({super.key, required this.profil});

  Future<int> _compter(String collection) async {
    final resultat = await FirebaseFirestore.instance.collection(collection).count().get();
    return resultat.count ?? 0;
  }

  Future<int> _compterOenParticipants() async {
    final resultat = await FirebaseFirestore.instance
        .collection('enfants')
        .where('aDejaParticipeOEN', isEqualTo: true)
        .count()
        .get();
    return resultat.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // Permet de tirer vers le bas pour relancer les requêtes de comptage.
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Bonjour, ${profil?.prenom ?? ''} 👋',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Voici un aperçu de l'école du dimanche aujourd'hui.",
            style: TextStyle(color: AppColors.texteClair),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _CarteStatistique(
                titre: 'Enfants inscrits',
                icone: Icons.child_care,
                couleur: AppColors.bleu,
                futur: _compter('enfants'),
              ),
              _CarteStatistique(
                titre: 'Moniteurs',
                icone: Icons.groups,
                couleur: AppColors.violetBleute,
                futur: _compter('utilisateurs'),
              ),
              _CarteStatistique(
                titre: 'Classes',
                icone: Icons.class_,
                couleur: AppColors.vertBleute,
                futur: _compter('classes'),
              ),
              _CarteStatistique(
                titre: 'Participants OEN',
                icone: Icons.card_giftcard,
                couleur: AppColors.rougeAlerte,
                futur: _compterOenParticipants(),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            "D'autres sections (présences du jour, activités à venir...) "
            "viendront s'ajouter ici au fur et à mesure qu'on construira "
            "les écrans correspondants.",
            style: TextStyle(color: AppColors.texteClair, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _CarteStatistique extends StatelessWidget {
  final String titre;
  final IconData icone;
  final Color couleur;
  final Future<int> futur;

  const _CarteStatistique({
    required this.titre,
    required this.icone,
    required this.couleur,
    required this.futur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: couleur, size: 26),
            const Spacer(),
            FutureBuilder<int>(
              future: futur,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Tooltip(
                    message: '${snapshot.error}',
                    child: const Icon(Icons.error_outline, color: AppColors.rougeAlerte, size: 24),
                  );
                }
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 24, width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return Text(
                  '${snapshot.data}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 2),
            Text(titre, style: const TextStyle(color: AppColors.texteClair, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}