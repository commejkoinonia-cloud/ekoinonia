import 'package:flutter/material.dart';
import '../../models/livre_cours.dart';
import '../../services/livre_cours_service.dart';
import '../../theme/app_theme.dart';

class LivreFormScreen extends StatefulWidget {
  const LivreFormScreen({super.key});

  @override
  State<LivreFormScreen> createState() => _LivreFormScreenState();
}

class _LivreFormScreenState extends State<LivreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _enregistrementEnCours = false;

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enregistrementEnCours = true);
    try {
      await LivreCoursService().creerLivre(LivreCours(
        id: '',
        titre: _titreController.text.trim(),
        description: _descriptionController.text.trim(),
      ));
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
      appBar: AppBar(title: const Text('Nouveau livre')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Titre du livre'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description (optionnel)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enregistrementEnCours ? null : _enregistrer,
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : const Text('Ajouter le livre'),
            ),
          ],
        ),
      ),
    );
  }
}