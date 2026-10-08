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

  Set<String> _utilisateursSelectionnes = {};
  String _statut = 'ouvert';
  bool _concerneToutLeMonde = false;
  bool _enregistrementEnCours = false;

  bool get _modeEdition => widget.entreeExistante != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entreeExistante;
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _mesurePriseController = TextEditingController(text: e?.mesurePrise ?? '');
    _utilisateursSelectionnes = (e?.utilisateurIds ?? []).toSet();
    _statut = e?.statut ?? 'ouvert';
    _concerneToutLeMonde = e?.concerneToutLeMonde ?? false;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _mesurePriseController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_concerneToutLeMonde && _utilisateursSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis au moins une personne.'), backgroundColor: AppColors.rougeAlerte),
      );
      return;
    }

    setState(() => _enregistrementEnCours = true);
    try {
      final entree = EntreeDiscipline(
        id: widget.entreeExistante?.id ?? '',
        utilisateurIds: _concerneToutLeMonde ? const [] : _utilisateursSelectionnes.toList(),
        date: widget.entreeExistante?.date ?? DateTime.now(),
        description: _descriptionController.text.trim(),
        mesurePrise: _mesurePriseController.text.trim(),
        signalePar: widget.entreeExistante?.signalePar ?? widget.profil?.uid ?? '',
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Règle générale pour tous les moniteurs'),
              subtitle: const Text("Désactive pour cibler une ou plusieurs personnes précises"),
              value: _concerneToutLeMonde,
              onChanged: (v) => setState(() {
                _concerneToutLeMonde = v;
                if (v) _utilisateursSelectionnes.clear();
              }),
            ),
            if (!_concerneToutLeMonde) ...[
              const SizedBox(height: 8),
              const Text('Personne(s) concernée(s)', style: TextStyle(color: AppColors.texteClair)),
              StreamBuilder<List<UtilisateurProfil>>(
                stream: UtilisateurService().streamUtilisateurs(),
                builder: (context, snapshot) {
                  final utilisateurs = snapshot.data ?? [];
                  if (utilisateurs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  // Sélection multiple : une case à cocher par moniteur, pour
                  // pouvoir cibler une seule personne OU plusieurs à la fois.
                  return Column(
                    children: utilisateurs.map((u) {
                      final coche = _utilisateursSelectionnes.contains(u.uid);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(u.nomComplet),
                        value: coche,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _utilisateursSelectionnes.add(u.uid);
                          } else {
                            _utilisateursSelectionnes.remove(u.uid);
                          }
                        }),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
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