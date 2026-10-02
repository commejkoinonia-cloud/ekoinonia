import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/communication.dart';

class CommunicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Communication>> streamCommunications() {
    return _db
        .collection('communications')
        .orderBy('datePublication', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Communication.depuisFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Publie la communication ET crée la notification correspondante,
  /// dans un seul batch (les deux réussissent, ou aucune des deux).
  Future<void> publierCommunication(Communication communication) async {
    final batch = _db.batch();

    final refCommunication = _db.collection('communications').doc();
    batch.set(refCommunication, communication.versFirestore());

    final refNotification = _db.collection('notifications').doc();
    final donneesNotification = <String, dynamic>{
      'titre': 'Nouvelle communication',
      'message': communication.titre,
      'type': 'communication',
      'referenceCollection': 'communications',
      'referenceId': refCommunication.id,
      'creePar': communication.auteurId,
      'dateCreation': Timestamp.now(),
    };
    if (communication.classeId != null) {
      donneesNotification['classeId'] = communication.classeId;
    }
    batch.set(refNotification, donneesNotification);

    await batch.commit();
  }

  Future<void> supprimerCommunication(String id) async {
    await _db.collection('communications').doc(id).delete();
  }
}