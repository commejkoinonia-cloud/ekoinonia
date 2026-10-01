import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/materiel.dart';

class MaterielService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('materiel');

  Stream<List<Materiel>> streamMateriel() {
    return _collection.orderBy('nom').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Materiel.depuisFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> creerMateriel(Materiel materiel) async {
    await _collection.add(materiel.versFirestore());
  }

  Future<void> modifierMateriel(String id, Materiel materiel) async {
    await _collection.doc(id).update(materiel.versFirestore());
  }

  Future<void> supprimerMateriel(String id) async {
    await _collection.doc(id).delete();
  }
}