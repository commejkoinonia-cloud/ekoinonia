import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/finance.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/finance_service.dart';
import '../../theme/app_theme.dart';

class FinanceFormScreen extends StatefulWidget {
  final UtilisateurProfil? profil;
  const FinanceFormScreen({super.key, required this.profil});

  @override
  State<FinanceFormScreen> createState() => _FinanceFormScreenState();
}

class _FinanceFormScreenState extends State<FinanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _motifController = TextEditingController();

  String _type = 'offrande';
  String? _classeSelectionnee;
  DateTime _date = DateTime.now();
  bool _enregistrementEnCours = false;

  @override
  void dispose() {
    _montantController.dispose();
    _motifController.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enregistrementEnCours = true);
    try {
      final finance = Finance(
        id: '',
        type: _type,
        montant: double.tryParse(_montantController.text.trim()) ?? 0,
        date: _date,
        enregistrePar: widget.profil?.uid ?? '',
        classeId: _type == 'offrande' ? _classeSelectionnee : null,
        motif: _motifController.text.trim(),
      );
      await FinanceService().enregistrerMouvement(finance);
      if (mounted) Navigator.of(context).pop();
    } catch (erreur) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $erreur'), backgroundColor: AppColors.rougeAlerte),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mouvement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: Finance.libellesType.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
              validator: (v) {
                final valeur = double.tryParse(v ?? '');
                if (valeur == null || valeur <= 0) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date : ${_date.day}/${_date.month}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _choisirDate,
            ),
            if (_type == 'offrande') ...[
              const SizedBox(height: 8),
              StreamBuilder<List<Classe>>(
                stream: ClasseService().streamClasses(),
                builder: (context, snapshot) {
                  final classes = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    initialValue: _classeSelectionnee,
                    decoration: const InputDecoration(labelText: 'Classe concernée'),
                    items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nom))).toList(),
                    onChanged: (v) => setState(() => _classeSelectionnee = v),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _motifController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Motif (optionnel)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enregistrementEnCours ? null : _enregistrer,
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}