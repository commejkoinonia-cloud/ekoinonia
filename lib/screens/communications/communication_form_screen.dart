import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/classe.dart';
import '../../models/communication.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/classe_service.dart';
import '../../services/communication_service.dart';
import '../../services/image_upload_service.dart';
import '../../theme/app_theme.dart';

class CommunicationFormScreen extends StatefulWidget {
  final UtilisateurProfil? profil;
  const CommunicationFormScreen({super.key, required this.profil});

  @override
  State<CommunicationFormScreen> createState() => _CommunicationFormScreenState();
}

class _CommunicationFormScreenState extends State<CommunicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _contenuController = TextEditingController();

  String _destinataire = 'tous';
  String? _classeSelectionnee;
  File? _imageChoisie;
  bool _enregistrementEnCours = false;

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Future<void> _choisirImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => _imageChoisie = File(image.path));
  }

  Future<void> _publier() async {
    if (!_formKey.currentState!.validate()) return;
    if (_destinataire == 'classe_specifique' && _classeSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis une classe.'), backgroundColor: AppColors.rougeAlerte),
      );
      return;
    }

    setState(() => _enregistrementEnCours = true);

    try {
      final piecesJointes = <String>[];
      if (_imageChoisie != null) {
        final lien = await ImageUploadService().televerserImage(_imageChoisie!);
        piecesJointes.add(lien);
      }

      final communication = Communication(
        id: '',
        titre: _titreController.text.trim(),
        contenu: _contenuController.text.trim(),
        datePublication: DateTime.now(),
        destinataire: _destinataire,
        classeId: _destinataire == 'classe_specifique' ? _classeSelectionnee : null,
        auteurId: widget.profil?.uid ?? '',
        piecesJointes: piecesJointes,
      );

      await CommunicationService().publierCommunication(communication);
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
      appBar: AppBar(title: const Text('Nouvelle communication')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contenuController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Contenu'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _destinataire,
              decoration: const InputDecoration(labelText: 'Destinataire'),
              items: const [
                DropdownMenuItem(value: 'tous', child: Text('Tout le monde')),
                DropdownMenuItem(value: 'moniteurs', child: Text('Moniteurs')),
                DropdownMenuItem(value: 'responsables', child: Text('Responsables')),
                DropdownMenuItem(value: 'classe_specifique', child: Text('Une classe précise')),
              ],
              onChanged: (v) => setState(() => _destinataire = v!),
            ),

            if (_destinataire == 'classe_specifique') ...[
              const SizedBox(height: 12),
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

            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.image_outlined),
              label: Text(_imageChoisie == null ? 'Ajouter une image (optionnel)' : 'Image sélectionnée ✓'),
              onPressed: _choisirImage,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enregistrementEnCours ? null : _publier,
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                    )
                  : const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }
}