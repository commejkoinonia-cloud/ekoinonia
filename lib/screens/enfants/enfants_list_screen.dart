import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/enfant.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/enfant_service.dart';
import '../../theme/app_theme.dart';
import 'enfant_detail_screen.dart';
import 'enfant_form_screen.dart';

class EnfantsListScreen extends StatefulWidget {
  final UtilisateurProfil? profil;
  const EnfantsListScreen({super.key, required this.profil});

  @override
  State<EnfantsListScreen> createState() => _EnfantsListScreenState();
}

class _EnfantsListScreenState extends State<EnfantsListScreen> {
  final TextEditingController _rechercheController = TextEditingController();
  String _texteRecherche = '';

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peutAjouter = widget.profil?.estAdmin ?? false;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _rechercheController,
              onChanged: (valeur) => setState(() => _texteRecherche = valeur.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Rechercher un enfant...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Classe>>(
              stream: ClasseService().streamClasses(),
              builder: (context, snapshotClasses) {
                // On construit une correspondance classeId -> nom de classe,
                // pour afficher le nom plutôt que l'identifiant technique.
                final nomsClasses = <String, String>{
                  for (final c in snapshotClasses.data ?? <Classe>[]) c.id: c.nom,
                };

                return StreamBuilder<List<Enfant>>(
                  stream: EnfantService().streamEnfants(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur : ${snapshot.error}'));
                    }

                    var enfants = snapshot.data ?? [];

                    if (_texteRecherche.isNotEmpty) {
                      enfants = enfants
                          .where((e) => e.nomComplet.toLowerCase().contains(_texteRecherche))
                          .toList();
                    }

                    if (enfants.isEmpty) {
                      return const Center(child: Text('Aucun enfant trouvé.'));
                    }

                    return ListView.builder(
                      itemCount: enfants.length,
                      itemBuilder: (context, index) {
                        final enfant = enfants[index];
                        final nomClasse = nomsClasses[enfant.classeId] ?? '—';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.grisClair,
                            backgroundImage: (enfant.imageUrl != null && enfant.imageUrl!.isNotEmpty)
                                ? NetworkImage(enfant.imageUrl!)
                                : null,
                            child: (enfant.imageUrl == null || enfant.imageUrl!.isEmpty)
                                ? const Icon(Icons.child_care, color: AppColors.bleu)
                                : null,
                          ),
                          title: Text(enfant.nomComplet),
                          subtitle: Text('$nomClasse${enfant.age != null ? ' • ${enfant.age} ans' : ''}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => EnfantDetailScreen(
                                enfantId: enfant.id,
                                profil: widget.profil,
                              ),
                            ));
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: peutAjouter
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.bleu,
              icon: const Icon(Icons.add, color: AppColors.blanc),
              label: const Text('Nouvel enfant', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const EnfantFormScreen(),
                ));
              },
            )
          : null,
    );
  }
}