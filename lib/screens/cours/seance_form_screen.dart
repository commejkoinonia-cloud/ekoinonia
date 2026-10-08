import 'package:flutter/material.dart';
import '../../models/chapitre.dart';
import '../../models/classe.dart';
import '../../models/livre_cours.dart';
import '../../models/seance.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/livre_cours_service.dart';
import '../../services/seance_service.dart';
import '../../theme/app_theme.dart';

class SeanceFormScreen extends StatefulWidget {
  final UtilisateurProfil? profil;
  const SeanceFormScreen({super.key, required this.profil});

  @override
  State<SeanceFormScreen> createState() => _SeanceFormScreenState();
}

class _SeanceFormScreenState extends State<SeanceFormScreen> {
  final _titreController = TextEditingController();
  final _versetController = TextEditingController();
  final _resumeController = TextEditingController();

  DateTime _date = DateTime.now();
  String? _classeSelectionnee;
  String? _livreSelectionne;
  String? _chapitreSelectionne;
  bool _utiliserUnLivre = false;
  bool _enregistrementEnCours = false;

  @override
  void initState() {
    super.initState();
    if (widget.profil != null && !widget.profil!.estAdmin) {
      _classeSelectionnee = widget.profil!.classeId;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _versetController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _enregistrer() async {
    if (_classeSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis une classe.'), backgroundColor: AppColors.rougeAlerte),
      );
      return;
    }

    setState(() => _enregistrementEnCours = true);
    try {
      final seance = Seance(
        id: '',
        classeId: _classeSelectionnee!,
        date: _date,
        moniteurId: widget.profil?.uid ?? '',
        creePar: widget.profil?.uid ?? '',
        livreId: _utiliserUnLivre ? _livreSelectionne : null,
        chapitreId: _utiliserUnLivre ? _chapitreSelectionne : null,
        titre: _titreController.text.trim(),
        versetCle: _versetController.text.trim(),
        contenuResume: _resumeController.text.trim(),
      );
      await SeanceService().creerSeance(seance);
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
    final peutChoisirClasse = widget.profil?.estAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle séance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Date : ${_date.day}/${_date.month}/${_date.year}'),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _choisirDate,
          ),
          if (peutChoisirClasse)
            StreamBuilder<List<Classe>>(
              stream: ClasseService().streamClasses(),
              builder: (context, snapshot) {
                final classes = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: _classeSelectionnee,
                  decoration: const InputDecoration(labelText: 'Classe'),
                  items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nom))).toList(),
                  onChanged: (v) => setState(() => _classeSelectionnee = v),
                );
              },
            ),
          const SizedBox(height: 12),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cette séance utilise un livre de cours'),
            value: _utiliserUnLivre,
            onChanged: (v) => setState(() => _utiliserUnLivre = v),
          ),

          if (_utiliserUnLivre) ...[
            StreamBuilder<List<LivreCours>>(
              stream: LivreCoursService().streamLivres(),
              builder: (context, snapshot) {
                final livres = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: _livreSelectionne,
                  decoration: const InputDecoration(labelText: 'Livre'),
                  items: livres.map((l) => DropdownMenuItem(value: l.id, child: Text(l.titre))).toList(),
                  onChanged: (v) => setState(() {
                    _livreSelectionne = v;
                    _chapitreSelectionne = null;
                  }),
                );
              },
            ),
            if (_livreSelectionne != null)
              StreamBuilder<List<Chapitre>>(
                stream: LivreCoursService().streamChapitres(_livreSelectionne!),
                builder: (context, snapshot) {
                  final chapitres = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    initialValue: _chapitreSelectionne,
                    decoration: const InputDecoration(labelText: 'Chapitre'),
                    items: chapitres
                        .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.numero}. ${c.titre}')))
                        .toList(),
                    onChanged: (v) => setState(() => _chapitreSelectionne = v),
                  );
                },
              ),
          ] else
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Titre libre (optionnel)'),
            ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _versetController,
            decoration: const InputDecoration(labelText: 'Verset clé (optionnel)'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _resumeController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Résumé (optionnel)'),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _enregistrementEnCours ? null : _enregistrer,
            child: _enregistrementEnCours
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                  )
                : const Text('Créer la séance'),
          ),
        ],
      ),
    );
  }
}