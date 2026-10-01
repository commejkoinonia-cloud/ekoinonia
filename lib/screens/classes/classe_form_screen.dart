import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../services/classe_service.dart';
import '../../theme/app_theme.dart';

class ClasseFormScreen extends StatefulWidget {
  final Classe? classeExistante;
  const ClasseFormScreen({super.key, this.classeExistante});

  @override
  State<ClasseFormScreen> createState() => _ClasseFormScreenState();
}

class _ClasseFormScreenState extends State<ClasseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ageMinController;
  late final TextEditingController _ageMaxController;
  bool _actif = true;
  bool _enregistrementEnCours = false;

  bool get _modeEdition => widget.classeExistante != null;

  @override
  void initState() {
    super.initState();
    final c = widget.classeExistante;
    _nomController = TextEditingController(text: c?.nom ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _ageMinController = TextEditingController(text: c?.ageMin?.toString() ?? '');
    _ageMaxController = TextEditingController(text: c?.ageMax?.toString() ?? '');
    _actif = c?.actif ?? true;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enregistrementEnCours = true);

    try {
      final classe = Classe(
        id: widget.classeExistante?.id ?? '',
        nom: _nomController.text.trim(),
        description: _descriptionController.text.trim(),
        ageMin: int.tryParse(_ageMinController.text.trim()),
        ageMax: int.tryParse(_ageMaxController.text.trim()),
        moniteurIds: widget.classeExistante?.moniteurIds ?? const [],
        actif: _actif,
      );

      if (_modeEdition) {
        await ClasseService().modifierClasse(widget.classeExistante!.id, classe);
      } else {
        await ClasseService().creerClasse(classe);
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

  Future<void> _supprimer() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette classe ?'),
        content: const Text('Cette action est irréversible.'),
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
      await ClasseService().supprimerClasse(widget.classeExistante!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdition ? 'Modifier la classe' : 'Nouvelle classe'),
        actions: [
          if (_modeEdition)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _supprimer),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom de la classe'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description (optionnel)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Âge min'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _ageMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Âge max'),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Classe active'),
              value: _actif,
              onChanged: (v) => setState(() => _actif = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enregistrementEnCours ? null : _enregistrer,
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : Text(_modeEdition ? 'Enregistrer' : 'Créer la classe'),
            ),
          ],
        ),
      ),
    );
  }
}