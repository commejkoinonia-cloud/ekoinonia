import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/discipline_entree.dart';

class DisciplineService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('discipline');

  Stream<List<EntreeDiscipline>> streamEntrees() {
    return _collection.orderBy('date', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => EntreeDiscipline.depuisFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Crée l'entrée de discipline ET la notification correspondante.
  ///
  /// Les deux écritures passent par un seul `batch()` : soit les deux
  /// réussissent, soit aucune. Avec deux appels séparés, une entrée pouvait
  /// être enregistrée alors que la notification avait échoué (on perdait
  /// silencieusement l'information pour les autres utilisateurs).
  /// Même approche que `CommunicationService.publierCommunication`.
  Future<void> creerEntree(EntreeDiscipline entree) async {
    final batch = FirebaseFirestore.instance.batch();

    // 1. L'entrée elle-même, avec une référence générée pour pouvoir l'ouvrir
    //    plus tard depuis la notification.
    final refEntree = _collection.doc();
    batch.set(refEntree, entree.versFirestore());

    // 2. La notification, dans la collection globale `notifications`.
    //    `creePar` reprend l'uid de la personne qui a fait le signalement
    //    (champ `signalPar` de l'entrée), et non l'auteur du document.
    final refNotification = FirebaseFirestore.instance.collection('notifications').doc();
    batch.set(refNotification, <String, dynamic>{
      'titre': 'Nouvelle entrée de discipline',
      // Le message est tronqué : une notification doit tenir sur une ligne.
      'message': _accroche(entree.description),
      // `type` et `referenceCollection`/`referenceId` permettent à
      // l'écran des notifications de reconnaître l'événement et de
      // remonter jusqu'à l'entrée concernée.
      'type': 'discipline',
      'referenceCollection': 'discipline',
      'referenceId': refEntree.id,
      'creePar': entree.signalPar,
      'dateCreation': Timestamp.now(),
    });

    await batch.commit();
  }

  /// Modification d'une entrée existante.
  ///
  /// Aucune notification n'est envoyée ici, volontairement : une mise à jour
  /// (changer le statut, compléter la mesure) n'est pas un événement que tout
  /// le monde doit voir, contrairement à la création. Même choix que
  /// `CommunicationService`, qui ne notifie que la publication.
  Future<void> modifierEntree(String id, EntreeDiscipline entree) async {
    await _collection.doc(id).update(entree.versFirestore());
  }

  Future<void> supprimerEntree(String id) async {
    await _collection.doc(id).delete();
  }

  /// Réduit une description à une phrase courte pour la notification.
  String _accroche(String description, {int maxCaracteres = 120}) {
    final texte = description.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (texte.length <= maxCaracteres) return texte;
    return '${texte.substring(0, maxCaracteres)}…';
  }
}