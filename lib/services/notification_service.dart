import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_app.dart';

/// Le volume de notifications d'une école du dimanche reste modeste : on
/// récupère les 100 plus récentes et on filtre par classe côté app,
/// plutôt que de complexifier les règles Firestore avec des requêtes OR.
class NotificationService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('notifications');

  /// [classeId] = la classe de la personne connectée, pour ne garder que
  /// les notifications globales (classeId absent) ou celles de sa classe.
  Stream<List<AppNotification>> streamNotifications(String? classeId) {
    return _collection
        .orderBy('dateCreation', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.depuisFirestore(doc.id, doc.data()))
            .where((n) => n.classeId == null || n.classeId == classeId)
            .toList());
  }

  /// Crée une notification. Appelée par les autres services (communications,
  /// activités...) juste après une création/modification pertinente —
  /// jamais déclenchée automatiquement en coulisses.
  Future<void> creerNotification({
    required String titre,
    required String message,
    required String type,
    required String creePar,
    String? referenceCollection,
    String? referenceId,
    String? classeId,
  }) async {
    await _collection.add({
      'titre': titre,
      'message': message,
      'type': type,
      'creePar': creePar,
      'dateCreation': Timestamp.now(),
      if (referenceCollection != null) 'referenceCollection': referenceCollection,
      if (referenceId != null) 'referenceId': referenceId,
      if (classeId != null) 'classeId': classeId,
    });
  }

  /// Marque tout comme lu pour cette personne, en avançant sa date de
  /// dernière consultation à maintenant.
  Future<void> marquerCommeLues(String uid) async {
    await FirebaseFirestore.instance.collection('utilisateurs').doc(uid).update({
      'dateDerniereConsultationNotifications': Timestamp.now(),
    });
  }
}