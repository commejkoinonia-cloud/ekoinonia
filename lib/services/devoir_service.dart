import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/devoir.dart';
import '../models/note_devoir.dart';
import 'enfant_service.dart';

class DevoirService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Devoir>> streamDevoirs({String? classeId}) {
    Query<Map<String, dynamic>> requete = _db.collection('devoirs').orderBy('date', descending: true);
    if (classeId != null) {
      requete = _db.collection('devoirs').where('classeId', isEqualTo: classeId).orderBy('date', descending: true);
    }
    return requete.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Devoir.depuisFirestore(doc.id, doc.data())).toList(),
        );
  }

  Future<void> creerDevoir(Devoir devoir) async {
    await _db.collection('devoirs').add(devoir.versFirestore());
  }

  Stream<List<NoteDevoir>> streamNotes(String devoirId) {
    return _db.collection('devoirs').doc(devoirId).collection('notes').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => NoteDevoir.depuisFirestore(doc.data())).toList(),
        );
  }

  /// Enregistre (ou modifie) la note d'un enfant pour ce devoir, PUIS
  /// recalcule sa moyenne générale en interrogeant TOUTES ses notes à
  /// travers tous les devoirs (requête "collection group" sur `notes`).
  Future<void> enregistrerNote({
    required String devoirId,
    required String enfantId,
    required double note,
    String remarque = '',
  }) async {
    final noteDevoir = NoteDevoir(enfantId: enfantId, note: note, dateEvaluation: DateTime.now(), remarque: remarque);

    await _db
        .collection('devoirs')
        .doc(devoirId)
        .collection('notes')
        .doc(enfantId)
        .set(noteDevoir.versFirestore());

    await _recalculerMoyenne(enfantId);
  }

  Future<void> _recalculerMoyenne(String enfantId) async {
    // Requête "collection group" : cherche dans TOUTES les sous-collections
    // `notes` (quel que soit le devoir parent) celles qui concernent cet enfant.
    final snapshot = await _db.collectionGroup('notes').where('enfantId', isEqualTo: enfantId).get();

    if (snapshot.docs.isEmpty) return;

    final notes = snapshot.docs.map((d) => (d.data()['note'] as num?)?.toDouble() ?? 0).toList();
    final moyenne = notes.reduce((a, b) => a + b) / notes.length;

    await EnfantService().metAJourMoyenneDevoirs(enfantId, moyenne, notes.length);
  }
}