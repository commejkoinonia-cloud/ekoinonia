import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/enfant.dart';

/// Toute la logique Firestore liée aux enfants passe par ce service.
/// Les écrans ne parlent jamais directement à Firestore.
class EnfantService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('enfants');

  /// Flux en temps réel de tous les enfants, triés par nom.
  /// Le tri et le filtrage par texte de recherche se font ensuite côté
  /// écran (la liste d'enfants reste petite, pas besoin d'index complexe).
  Stream<List<Enfant>> streamEnfants() {
    return _collection.orderBy('nom').snapshots().map((snapshot) {
      final enfants = <Enfant>[];
      for (final doc in snapshot.docs) {
        try {
          enfants.add(Enfant.depuisFirestore(doc.id, doc.data()));
        } catch (erreur) {
          debugPrint('Document enfants/${doc.id} ignoré : $erreur');
        }
      }
      return enfants;
    });
  }

  Future<Enfant?> obtenirEnfant(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Enfant.depuisFirestore(doc.id, doc.data()!);
  }

  /// Crée un nouvel enfant. `dateInscription` est fixée à aujourd'hui
  /// automatiquement si elle n'est pas déjà renseignée.
  Future<void> creerEnfant(Enfant enfant) async {
    final donnees = enfant.versFirestore();
    donnees['dateInscription'] ??= Timestamp.now();
    await _collection.add(donnees);
  }

  Future<void> modifierEnfant(String id, Enfant enfant) async {
    await _collection.doc(id).update(enfant.versFirestore());
  }

  Future<void> supprimerEnfant(String id) async {
    await _collection.doc(id).delete();
  }
}