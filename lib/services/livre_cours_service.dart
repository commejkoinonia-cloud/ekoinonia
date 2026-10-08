import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chapitre.dart';
import '../models/livre_cours.dart';

class LivreCoursService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<LivreCours>> streamLivres() {
    return _db.collection('livresCours').orderBy('titre').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => LivreCours.depuisFirestore(doc.id, doc.data())).toList(),
        );
  }

  Future<void> creerLivre(LivreCours livre) async {
    await _db.collection('livresCours').add(livre.versFirestore());
  }

  Stream<List<Chapitre>> streamChapitres(String livreId) {
    return _db
        .collection('livresCours')
        .doc(livreId)
        .collection('chapitres')
        .orderBy('numero')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Chapitre.depuisFirestore(doc.id, doc.data())).toList());
  }

  Future<void> ajouterChapitre(String livreId, Chapitre chapitre) async {
    await _db.collection('livresCours').doc(livreId).collection('chapitres').add(chapitre.versFirestore());
  }
}