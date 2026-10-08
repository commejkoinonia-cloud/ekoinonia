import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/presence.dart';
import '../models/seance.dart';

class SeanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Seance>> streamSeances({String? classeId}) {
    Query<Map<String, dynamic>> requete = _db.collection('seances').orderBy('date', descending: true);
    if (classeId != null) {
      requete = _db.collection('seances').where('classeId', isEqualTo: classeId).orderBy('date', descending: true);
    }
    return requete.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Seance.depuisFirestore(doc.id, doc.data())).toList(),
        );
  }

  Future<void> creerSeance(Seance seance) async {
    await _db.collection('seances').add(seance.versFirestore());
  }

  Stream<List<Presence>> streamPresences(String seanceId) {
    return _db.collection('seances').doc(seanceId).collection('presences').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Presence.depuisFirestore(doc.id, doc.data())).toList(),
        );
  }

  /// Enregistre toutes les présences d'un coup (un document par enfant dans
  /// la sous-collection `presences`), PUIS met à jour les compteurs
  /// `nombrePresents`/`nombreAbsents` directement sur le document de la
  /// séance, pour un affichage rapide sans tout recompter à chaque fois.
  Future<void> enregistrerPresences(String seanceId, List<Presence> presences) async {
    final batch = _db.batch();
    final refSeance = _db.collection('seances').doc(seanceId);

    for (final p in presences) {
      batch.set(refSeance.collection('presences').doc(p.enfantId), p.versFirestore());
    }

    final nombrePresents = presences.where((p) => p.present).length;
    final nombreAbsents = presences.length - nombrePresents;
    batch.update(refSeance, {'nombrePresents': nombrePresents, 'nombreAbsents': nombreAbsents});

    await batch.commit();
  }
}