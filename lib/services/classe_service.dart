import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classe.dart';

class ClasseService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('classes');

  Stream<List<Classe>> streamClasses() {
    return _collection.orderBy('nom').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Classe.depuisFirestore(doc.id, doc.data()))
              .toList(),
        );
  }
}