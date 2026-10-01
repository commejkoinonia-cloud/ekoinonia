import 'package:flutter/material.dart';
import '../../models/materiel.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/materiel_service.dart';
import '../../theme/app_theme.dart';
import 'materiel_form_screen.dart';

class MaterielListScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const MaterielListScreen({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final peutGerer = (profil?.estAdmin ?? false) || (profil?.estChargeMateriel ?? false);

    return Scaffold(
      appBar: AppBar(title: const Text('Matériel')),
      body: StreamBuilder<List<Materiel>>(
        stream: MaterielService().streamMateriel(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final articles = snapshot.data!;
          if (articles.isEmpty) {
            return const Center(child: Text('Aucun matériel enregistré.'));
          }

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final m = articles[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: m.stockBas ? AppColors.rougeAlerte.withValues(alpha: 0.15) : AppColors.grisClair,
                  child: Icon(
                    m.typeMateriel == 'consommable' ? Icons.inventory_2_outlined : Icons.chair_outlined,
                    color: m.stockBas ? AppColors.rougeAlerte : AppColors.bleu,
                  ),
                ),
                title: Text(m.nom),
                subtitle: Text('${m.categorie} • Quantité : ${m.quantite}'),
                trailing: m.stockBas
                    ? const Tooltip(
                        message: 'Stock bas, pense à racheter',
                        child: Icon(Icons.warning_amber_rounded, color: AppColors.rougeAlerte),
                      )
                    : null,
                onTap: peutGerer
                    ? () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MaterielFormScreen(materielExistant: m),
                        ));
                      }
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: peutGerer
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.bleu,
              icon: const Icon(Icons.add, color: AppColors.blanc),
              label: const Text('Ajouter', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const MaterielFormScreen(),
                ));
              },
            )
          : null,
    );
  }
}