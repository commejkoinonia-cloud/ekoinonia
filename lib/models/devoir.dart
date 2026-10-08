import 'package:cloud_firestore/cloud_firestore.dart';

class Devoir {
  final String id;
  final String classeId;
  final String? seanceId;
  final String titre;
  final DateTime date;
  final String creePar;

  Devoir({
    required this.id,
    required this.classeId,
    required this.titre,
    required this.date,
    required this.creePar,
    this.seanceId,
  });

  factory Devoir.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Devoir(
      id: id,
      classeId: donnees['classeId'] ?? '',
      titre: donnees['titre'] ?? '',
      date: (donnees['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      creePar: donnees['creePar'] ?? '',
      seanceId: donnees['seanceId'],
    );
  }

  Map<String, dynamic> versFirestore() {
    final donnees = <String, dynamic>{
      'classeId': classeId,
      'titre': titre,
      'date': Timestamp.fromDate(date),
      'creePar': creePar,
      'dateCreation': Timestamp.now(),
    };
    if (seanceId != null) donnees['seanceId'] = seanceId;
    return donnees;
  }
}