import 'package:flutter/material.dart';
import '../../models/materiel.dart';
import '../../services/materiel_service.dart';
import '../../theme/app_theme.dart';

class MaterielFormScreen extends StatefulWidget {
  final Materiel? materielExistant;
  const MaterielFormScreen({super.key, this.materielExistant});

  @override
  State<MaterielFormScreen> createState() => _MaterielFormScreenState();
}

class _MaterielFormScreenState extends State<MaterielFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _categorieController;
  late final TextEditingController _quantiteController;
  late final TextEditingController _quantiteMinController;
  late final TextEditingController _remarqueController;

  String _typeMateriel = 'durable';
  String? _etat;
  bool _enregistrementEnCours = false;

  bool get _modeEdition => widget.materielExistant != null;

  @override
  void initState() {
    super.initState();
    final m = widget.materielExistant;
    _nomController = TextEditingController(text: m?.nom ?? '');
    _categorieController = TextEditingController(text: m?.categorie ?? '');
    _quantiteController = TextEditingController(text: m?.quantite.toString() ?? '0');
    _quantiteMinController = TextEditingController(text: m?.quantiteMinimale?.toString() ?? '');
    _remarqueController = TextEditingController(text: m?.remarque ?? '');
    _typeMateriel = m?.typeMateriel ?? 'durable';
    _etat = m?.etat;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _categorieController.dispose();
    _quantiteController.dispose();
    _quantiteMinController.dispose();
    _remarqueController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enregistrementEnCours = true);

    try {
      final materiel = Materiel(
        id: widget.materielExistant?.id ?? '',
        nom: _nomController.text.trim(),
        categorie: _categorieController.text.trim(),
        typeMateriel: _typeMateriel,
        quantite: int.tryParse(_quantiteController.text.trim()) ?? 0,
        quantiteMinimale: int.tryParse(_quantiteMinController.text.trim()),
        etat: _etat,
        remarque: _remarqueController.text.trim(),
      );

      if (_modeEdition) {
        await MaterielService().modifierMateriel(widget.materielExistant!.id, materiel);
      } else {
        await MaterielService().creerMateriel(materiel);
      }
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
      appBar: AppBar(title: Text(_modeEdition ? 'Modifier l\'article' : 'Nouvel article')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categorieController,
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _typeMateriel,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'durable', child: Text('Durable (chaises, tables...)')),
                DropdownMenuItem(value: 'consommable', child: Text('Consommable (craies, feuilles...)')),
              ],
              onChanged: (v) => setState(() => _typeMateriel = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantiteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantité actuelle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _quantiteMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Seuil d\'alerte'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_typeMateriel == 'durable')
              DropdownButtonFormField<String>(
                initialValue: _etat,
                decoration: const InputDecoration(labelText: 'État'),
                items: const [
                  DropdownMenuItem(value: 'bon', child: Text('Bon état')),
                  DropdownMenuItem(value: 'use', child: Text('Usé')),
                  DropdownMenuItem(value: 'hors_service', child: Text('Hors service')),
                ],
                onChanged: (v) => setState(() => _etat = v),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarqueController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Remarque (optionnel)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enregistrementEnCours ? null : _enregistrer,
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : Text(_modeEdition ? 'Enregistrer' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}