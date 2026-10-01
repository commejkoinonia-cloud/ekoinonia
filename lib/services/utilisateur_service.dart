import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utilisateur_profil.dart';

class UtilisateurService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('utilisateurs');

  Stream<List<UtilisateurProfil>> streamUtilisateurs() {
    return _collection.orderBy('nom').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => UtilisateurProfil.depuisFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<UtilisateurProfil?> obtenirUtilisateur(String uid) async {
    final doc = await _collection.doc(uid).get();
    if (!doc.exists) return null;
    return UtilisateurProfil.depuisFirestore(doc.id, doc.data()!);
  }
}