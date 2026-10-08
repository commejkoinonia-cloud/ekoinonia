import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente un document de la sous-collection `devoirs/{id}/notes/{enfantId}`.
class NoteDevoir {
  final String enfantId;
  final double note; // sur 20
  final DateTime dateEvaluation;
  final String remarque;

  NoteDevoir({
    required this.enfantId,
    required this.note,
    required this.dateEvaluation,
    this.remarque = '',
  });

  factory NoteDevoir.depuisFirestore(Map<String, dynamic> donnees) {
    return NoteDevoir(
      enfantId: donnees['enfantId'] ?? '',
      note: (donnees['note'] as num?)?.toDouble() ?? 0,
      dateEvaluation: (donnees['dateEvaluation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      remarque: donnees['remarque'] ?? '',
    );
  }

  Map<String, dynamic> versFirestore() {
    return {
      'enfantId': enfantId,
      'note': note,
      'dateEvaluation': Timestamp.fromDate(dateEvaluation),
      'remarque': remarque,
    };
  }
}