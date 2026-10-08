import 'package:flutter/material.dart';
import '../../models/enfant.dart';
import '../../models/presence.dart';
import '../../models/seance.dart';
import '../../services/enfant_service.dart';
import '../../services/seance_service.dart';
import '../../theme/app_theme.dart';

class SeancePresenceScreen extends StatefulWidget {
  final Seance seance;
  const SeancePresenceScreen({super.key, required this.seance});

  @override
  State<SeancePresenceScreen> createState() => _SeancePresenceScreenState();
}

class _SeancePresenceScreenState extends State<SeancePresenceScreen> {
  // enfantId -> présent (true/false). Rempli au chargement, modifié par les
  // interrupteurs, puis envoyé d'un coup à l'enregistrement.
  final Map<String, bool> _presenceParEnfant = {};
  bool _enregistrementEnCours = false;
  bool _dejaInitialise = false;

  Future<void> _enregistrer(List<Enfant> enfants) async {
    setState(() => _enregistrementEnCours = true);
    try {
      final presences = enfants
          .map((e) => Presence(enfantId: e.id, present: _presenceParEnfant[e.id] ?? false))
          .toList();
      await SeanceService().enregistrerPresences(widget.seance.id, presences);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Présences enregistrées.'), backgroundColor: AppColors.vertBleute),
        );
      }
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
      appBar: AppBar(title: const Text('Présences')),
      body: StreamBuilder<List<Presence>>(
        stream: SeanceService().streamPresences(widget.seance.id),
        builder: (context, snapshotPresences) {
          // On ne pré-remplit qu'une seule fois, pour ne pas écraser les
          // interrupteurs que la personne est en train de modifier.
          if (!_dejaInitialise && snapshotPresences.hasData) {
            for (final p in snapshotPresences.data!) {
              _presenceParEnfant[p.enfantId] = p.present;
            }
            _dejaInitialise = true;
          }

          return StreamBuilder<List<Enfant>>(
            stream: EnfantService().streamEnfantsParClasse(widget.seance.classeId),
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

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: enfants.length,
                      itemBuilder: (context, index) {
                        final enfant = enfants[index];
                        final present = _presenceParEnfant[enfant.id] ?? false;
                        return SwitchListTile(
                          title: Text(enfant.nomComplet),
                          value: present,
                          activeThumbColor: AppColors.vertBleute,
                          onChanged: (v) => setState(() => _presenceParEnfant[enfant.id] = v),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _enregistrementEnCours ? null : () => _enregistrer(enfants),
                      child: _enregistrementEnCours
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                            )
                          : const Text('Enregistrer les présences'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}