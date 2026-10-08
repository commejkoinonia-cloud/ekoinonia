import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/finance.dart';

class FinanceService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('finances');

  Stream<List<Finance>> streamMouvements() {
    return _collection.orderBy('date', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Finance.depuisFirestore(doc.id, doc.data())).toList(),
        );
  }

  Future<void> enregistrerMouvement(Finance finance) async {
    await _collection.add(finance.versFirestore());
  }

  Future<void> supprimerMouvement(String id) async {
    await _collection.doc(id).delete();
  }
}