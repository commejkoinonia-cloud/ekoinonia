import 'package:flutter/material.dart';
import '../../models/discipline_entree.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/discipline_service.dart';
import '../../services/utilisateur_service.dart';
import '../../theme/app_theme.dart';

class DisciplineFormScreen extends StatefulWidget {
  final EntreeDiscipline? entreeExistante;
  final UtilisateurProfil? profil;
  const DisciplineFormScreen({super.key, this.entreeExistante, required this.profil});

  @override
  State<DisciplineFormScreen> createState() => _DisciplineFormScreenState();
}

class _DisciplineFormScreenState extends State<DisciplineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _mesurePriseController;

  String? _utilisateurSelectionne;
  String _statut = 'ouvert';
  bool _enregistrementEnCours = false;

  bool get _modeEdition => widget.entreeExistante != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entreeExistante;
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _mesurePriseController = TextEditingController(text: e?.mesurePrise ?? '');
    _utilisateurSelectionne = e?.utilisateurId;
    _statut = e?.statut ?? 'ouvert';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _mesurePriseController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_utilisateurSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis la personne concernée.'), backgroundColor: AppColors.rougeAlerte),
      );
      return;
    }

    setState(() => _enregistrementEnCours = true);
    try {
      final entree = EntreeDiscipline(
        id: widget.entreeExistante?.id ?? '',
        utilisateurId: _utilisateurSelectionne!,
        date: widget.entreeExistante?.date ?? DateTime.now(),
        description: _descriptionController.text.trim(),
        mesurePrise: _mesurePriseController.text.trim(),
        signalPar: widget.entreeExistante?.signalPar ?? widget.profil?.uid ?? '',
        statut: _statut,
        dateResolution: _statut == 'resolu' ? DateTime.now() : null,
      );

      if (_modeEdition) {
        await DisciplineService().modifierEntree(widget.entreeExistante!.id, entree);
      } else {
        await DisciplineService().creerEntree(entree);
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
      appBar: AppBar(title: Text(_modeEdition ? "Modifier l'entrée" : 'Nouvelle entrée')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StreamBuilder<List<UtilisateurProfil>>(
              stream: UtilisateurService().streamUtilisateurs(),
              builder: (context, snapshot) {
                final utilisateurs = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: _utilisateurSelectionne,
                  decoration: const InputDecoration(labelText: 'Personne concernée'),
                  items: utilisateurs
                      .map((u) => DropdownMenuItem(value: u.uid, child: Text(u.nomComplet)))
                      .toList(),
                  onChanged: _modeEdition ? null : (v) => setState(() => _utilisateurSelectionne = v),
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mesurePriseController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Mesure prise (optionnel)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _statut,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: const [
                DropdownMenuItem(value: 'ouvert', child: Text('Ouvert')),
                DropdownMenuItem(value: 'resolu', child: Text('Résolu')),
              ],
              onChanged: (v) => setState(() => _statut = v!),
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