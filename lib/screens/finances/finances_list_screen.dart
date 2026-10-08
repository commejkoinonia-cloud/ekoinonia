import 'package:flutter/material.dart';
import '../../models/finance.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/finance_service.dart';
import '../../theme/app_theme.dart';
import 'finance_form_screen.dart';

class FinancesListScreen extends StatelessWidget {
  final UtilisateurProfil? profil;
  const FinancesListScreen({super.key, required this.profil});

  @override
  Widget build(BuildContext context) {
    final peutGerer = (profil?.estAdmin ?? false) || (profil?.estCaissiere ?? false);

    return Scaffold(
      appBar: AppBar(title: const Text('Finances')),
      body: StreamBuilder<List<Finance>>(
        stream: FinanceService().streamMouvements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final mouvements = snapshot.data!;
          final solde = mouvements.fold<double>(0, (total, m) => total + m.montantSigne);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.bleu,
                child: Column(
                  children: [
                    const Text('Solde actuel', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '${solde.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(color: AppColors.blanc, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: mouvements.isEmpty
                    ? const Center(child: Text('Aucun mouvement enregistré.'))
                    : ListView.builder(
                        itemCount: mouvements.length,
                        itemBuilder: (context, index) {
                          final m = mouvements[index];
                          return ListTile(
                            leading: Icon(
                              m.estDepense ? Icons.arrow_upward : Icons.arrow_downward,
                              color: m.estDepense ? AppColors.rougeAlerte : AppColors.vertBleute,
                            ),
                            title: Text(Finance.libellesType[m.type] ?? m.type),
                            subtitle: Text(
                              [
                                if (m.motif.isNotEmpty) m.motif,
                                '${m.date.day}/${m.date.month}/${m.date.year}',
                              ].join(' • '),
                            ),
                            trailing: Text(
                              '${m.estDepense ? '-' : '+'}${m.montant.toStringAsFixed(0)} FCFA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: m.estDepense ? AppColors.rougeAlerte : AppColors.vertBleute,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: peutGerer
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.bleu,
              icon: const Icon(Icons.add, color: AppColors.blanc),
              label: const Text('Nouveau mouvement', style: TextStyle(color: AppColors.blanc)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FinanceFormScreen(profil: profil),
                ));
              },
            )
          : null,
    );
  }
}