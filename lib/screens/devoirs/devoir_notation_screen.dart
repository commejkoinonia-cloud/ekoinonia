import 'package:flutter/material.dart';
import '../../models/devoir.dart';
import '../../models/enfant.dart';
import '../../models/note_devoir.dart';
import '../../services/devoir_service.dart';
import '../../services/enfant_service.dart';
import '../../theme/app_theme.dart';

class DevoirNotationScreen extends StatelessWidget {
  final Devoir devoir;
  const DevoirNotationScreen({super.key, required this.devoir});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(devoir.titre)),
      body: StreamBuilder<List<NoteDevoir>>(
        stream: DevoirService().streamNotes(devoir.id),
        builder: (context, snapshotNotes) {
          final notesExistantes = <String, double>{
            for (final n in snapshotNotes.data ?? <NoteDevoir>[]) n.enfantId: n.note,
          };

          return StreamBuilder<List<Enfant>>(
            stream: EnfantService().streamEnfantsParClasse(devoir.classeId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final enfants = snapshot.data!;
              if (enfants.isEmpty) {
                return const Center(child: Text('Aucun enfant dans cette classe.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: enfants.length,
                itemBuilder: (context, index) {
                  final enfant = enfants[index];
                  return _LigneNotation(
                    enfant: enfant,
                    devoirId: devoir.id,
                    noteActuelle: notesExistantes[enfant.id],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LigneNotation extends StatefulWidget {
  final Enfant enfant;
  final String devoirId;
  final double? noteActuelle;

  const _LigneNotation({required this.enfant, required this.devoirId, required this.noteActuelle});

  @override
  State<_LigneNotation> createState() => _LigneNotationState();
}

class _LigneNotationState extends State<_LigneNotation> {
  late final TextEditingController _controleur;
  bool _enregistrementEnCours = false;

  @override
  void initState() {
    super.initState();
    _controleur = TextEditingController(text: widget.noteActuelle?.toStringAsFixed(1) ?? '');
  }

  @override
  void didUpdateWidget(covariant _LigneNotation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ne resynchronise que si le champ est encore vide (pas de saisie en
    // cours), pour ne jamais écraser ce que la personne est en train de taper.
    if (oldWidget.noteActuelle != widget.noteActuelle && _controleur.text.isEmpty) {
      _controleur.text = widget.noteActuelle?.toStringAsFixed(1) ?? '';
    }
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  Future<void> _enregistrerNote() async {
    final valeur = double.tryParse(_controleur.text.replaceAll(',', '.'));
    if (valeur == null || valeur < 0 || valeur > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note invalide (0 à 20).'), backgroundColor: AppColors.rougeAlerte),
      );
      return;
    }

    setState(() => _enregistrementEnCours = true);
    try {
      await DevoirService().enregistrerNote(
        devoirId: widget.devoirId,
        enfantId: widget.enfant.id,
        note: valeur,
      );
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(widget.enfant.nomComplet),
        trailing: SizedBox(
          width: 110,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controleur,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: '/20', isDense: true),
                  onSubmitted: (_) => _enregistrerNote(),
                ),
              ),
              const SizedBox(width: 4),
              _enregistrementEnCours
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(icon: const Icon(Icons.check, color: AppColors.vertBleute), onPressed: _enregistrerNote),
            ],
          ),
        ),
      ),
    );
  }
}