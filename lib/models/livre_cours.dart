import 'package:cloud_firestore/cloud_firestore.dart';

class LivreCours {
  final String id;
  final String titre;
  final String description;
  final DateTime? dateAjout;

  LivreCours({required this.id, required this.titre, this.description = '', this.dateAjout});

  factory LivreCours.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return LivreCours(
      id: id,
      titre: donnees['titre'] ?? '',
      description: donnees['description'] ?? '',
      dateAjout: (donnees['dateAjout'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> versFirestore() {
    return {
      'titre': titre,
      'description': description,
      'dateAjout': Timestamp.now(),
    };
  }
}