import 'package:flutter/material.dart';
import '../../models/classe.dart';
import '../../models/devoir.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/devoir_service.dart';
import '../../theme/app_theme.dart';

class DevoirFormScreen extends StatefulWidget {
  final UtilisateurProfil? profil;
  const DevoirFormScreen({super.key, required this.profil});

  @override
  State<DevoirFormScreen> createState() => _DevoirFormScreenState();
}

class _DevoirFormScreenState extends State<DevoirFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _classeSelectionnee;
  bool _enregistrementEnCours = false;

  @override
  void initState() {
    super.initState();
    // Un simple moniteur ne peut créer un devoir que pour sa propre classe :
    // on la pré-sélectionne et on ne lui laisse pas le choix.
    if (widget.profil != null && !widget.profil!.estAdmin) {
      _classeSelectionnee = widget.profil!.classeId;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classeSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis une classe.'), backgroundColor: AppColors.rougeAlerte),
      );
      return;
    }

    setState(() => _enregistrementEnCours = true);
    try {
      final devoir = Devoir(
        id: '',
        classeId: _classeSelectionnee!,
        titre: _titreController.text.trim(),
        date: _date,
        creePar: widget.profil?.uid ?? '',
      );
      await DevoirService().creerDevoir(devoir);
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
      appBar: AppBar(title: const Text('Nouveau devoir')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Titre du devoir'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date : ${_date.day}/${_date.month}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _choisirDate,
            ),
            const SizedBox(height: 8),
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
              )
            else
              const Text('Ce devoir sera créé pour ta propre classe.',
                  style: TextStyle(color: AppColors.texteClair)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enregistrementEnCours ? null : _enregistrer,
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : const Text('Créer le devoir'),
            ),
          ],
        ),
      ),
    );
  }
}