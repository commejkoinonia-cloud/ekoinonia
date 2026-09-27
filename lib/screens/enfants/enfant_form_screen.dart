import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/classe.dart';
import '../../models/enfant.dart';
import '../../services/classe_service.dart';
import '../../services/enfant_service.dart';
import '../../services/image_upload_service.dart';
import '../../theme/app_theme.dart';

/// Un seul écran pour AJOUTER (enfantExistant == null) et MODIFIER
/// (enfantExistant renseigné) : ça évite de dupliquer tout le formulaire.
class EnfantFormScreen extends StatefulWidget {
  final Enfant? enfantExistant;
  const EnfantFormScreen({super.key, this.enfantExistant});

  @override
  State<EnfantFormScreen> createState() => _EnfantFormScreenState();
}

class _EnfantFormScreenState extends State<EnfantFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _nomTuteurController;
  late final TextEditingController _telephoneTuteurController;
  late final TextEditingController _adresseController;

  String? _sexeSelectionne;
  String? _classeSelectionnee;
  DateTime? _dateNaissance;

  File? _nouvelleImage;
  String? _imageUrlExistante;

  bool _enregistrementEnCours = false;

  bool get _modeEdition => widget.enfantExistant != null;

  @override
  void initState() {
    super.initState();
    final e = widget.enfantExistant;
    _nomController = TextEditingController(text: e?.nom ?? '');
    _prenomController = TextEditingController(text: e?.prenom ?? '');
    _nomTuteurController = TextEditingController(text: e?.nomTuteur ?? '');
    _telephoneTuteurController = TextEditingController(text: e?.telephoneTuteur ?? '');
    _adresseController = TextEditingController(text: e?.adresse ?? '');
    _sexeSelectionne = e?.sexe.isNotEmpty == true ? e?.sexe : null;
    _classeSelectionnee = e?.classeId.isNotEmpty == true ? e?.classeId : null;
    _dateNaissance = e?.dateNaissance;
    _imageUrlExistante = e?.imageUrl;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _nomTuteurController.dispose();
    _telephoneTuteurController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    // Propose caméra ou galerie, comme dans la maquette de référence.
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final image = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (image == null) return;

    setState(() => _nouvelleImage = File(image.path));
  }

  Future<void> _choisirDateNaissance() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime(DateTime.now().year - 8),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _dateNaissance = date);
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classeSelectionnee == null) {
      _afficherErreur('Merci de choisir une classe.');
      return;
    }

    setState(() => _enregistrementEnCours = true);

    try {
      String? imageUrl = _imageUrlExistante;

      // On n'envoie une nouvelle image à ImgBB que si l'utilisateur en a
      // choisi une ; sinon on garde l'ancien lien tel quel.
      if (_nouvelleImage != null) {
        imageUrl = await ImageUploadService().televerserImage(_nouvelleImage!);
      }

      final enfant = Enfant(
        id: widget.enfantExistant?.id ?? '',
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        sexe: _sexeSelectionne!,
        classeId: _classeSelectionnee!,
        nomTuteur: _nomTuteurController.text.trim(),
        telephoneTuteur: _telephoneTuteurController.text.trim(),
        adresse: _adresseController.text.trim(),
        actif: true,
        dateNaissance: _dateNaissance,
        imageUrl: imageUrl,
        aDejaParticipeOEN: widget.enfantExistant?.aDejaParticipeOEN ?? false,
        anneeParticipationOEN: widget.enfantExistant?.anneeParticipationOEN,
      );

      if (_modeEdition) {
        await EnfantService().modifierEnfant(widget.enfantExistant!.id, enfant);
      } else {
        await EnfantService().creerEnfant(enfant);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (erreur) {
      _afficherErreur("Une erreur est survenue : $erreur");
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.rougeAlerte),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_modeEdition ? 'Modifier l\'enfant' : 'Nouvel enfant')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _choisirPhoto,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.grisClair,
                  backgroundImage: _nouvelleImage != null
                      ? FileImage(_nouvelleImage!)
                      : (_imageUrlExistante != null && _imageUrlExistante!.isNotEmpty)
                          ? NetworkImage(_imageUrlExistante!) as ImageProvider
                          : null,
                  child: (_nouvelleImage == null &&
                          (_imageUrlExistante == null || _imageUrlExistante!.isEmpty))
                      ? const Icon(Icons.camera_alt, size: 32, color: AppColors.bleu)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_dateNaissance == null
                  ? 'Choisir la date de naissance'
                  : 'Né(e) le ${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _choisirDateNaissance,
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _sexeSelectionne,
              decoration: const InputDecoration(labelText: 'Sexe'),
              items: const [
                DropdownMenuItem(value: 'Masculin', child: Text('Masculin')),
                DropdownMenuItem(value: 'Féminin', child: Text('Féminin')),
              ],
              onChanged: (v) => setState(() => _sexeSelectionne = v),
              validator: (v) => v == null ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<Classe>>(
              stream: ClasseService().streamClasses(),
              builder: (context, snapshot) {
                final classes = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: _classeSelectionnee,
                  decoration: const InputDecoration(labelText: 'Classe'),
                  items: classes
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nom)))
                      .toList(),
                  onChanged: (v) => setState(() => _classeSelectionnee = v),
                );
              },
            ),
            const SizedBox(height: 20),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Tuteur / Parent', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.texteClair)),
            ),

            TextFormField(
              controller: _nomTuteurController,
              decoration: const InputDecoration(labelText: 'Nom du tuteur'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telephoneTuteurController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone du tuteur'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _adresseController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Adresse'),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _enregistrementEnCours ? null : _enregistrer,
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : Text(_modeEdition ? 'Enregistrer les modifications' : 'Ajouter l\'enfant'),
            ),
          ],
        ),
      ),
    );
  }
}