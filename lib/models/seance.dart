import 'package:cloud_firestore/cloud_firestore.dart';

class Seance {
  final String id;
  final String classeId;
  final DateTime date;
  final String? livreId;
  final String? chapitreId;
  final String? titre;
  final String? versetCle;
  final String moniteurId;
  final String? contenuResume;
  final String creePar;
  final int nombrePresents;
  final int nombreAbsents;

  Seance({
    required this.id,
    required this.classeId,
    required this.date,
    required this.moniteurId,
    required this.creePar,
    this.livreId,
    this.chapitreId,
    this.titre,
    this.versetCle,
    this.contenuResume,
    this.nombrePresents = 0,
    this.nombreAbsents = 0,
  });

  factory Seance.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Seance(
      id: id,
      classeId: donnees['classeId'] ?? '',
      date: (donnees['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      moniteurId: donnees['moniteurId'] ?? '',
      creePar: donnees['creePar'] ?? '',
      livreId: donnees['livreId'],
      chapitreId: donnees['chapitreId'],
      titre: donnees['titre'],
      versetCle: donnees['versetCle'],
      contenuResume: donnees['contenuResume'],
      nombrePresents: donnees['nombrePresents'] ?? 0,
      nombreAbsents: donnees['nombreAbsents'] ?? 0,
    );
  }

  Map<String, dynamic> versFirestore() {
    final donnees = <String, dynamic>{
      'classeId': classeId,
      'date': Timestamp.fromDate(date),
      'moniteurId': moniteurId,
      'creePar': creePar,
      'dateCreation': Timestamp.now(),
      'nombrePresents': nombrePresents,
      'nombreAbsents': nombreAbsents,
    };
    if (livreId != null) donnees['livreId'] = livreId;
    if (chapitreId != null) donnees['chapitreId'] = chapitreId;
    if (titre != null && titre!.isNotEmpty) donnees['titre'] = titre;
    if (versetCle != null && versetCle!.isNotEmpty) donnees['versetCle'] = versetCle;
    if (contenuResume != null && contenuResume!.isNotEmpty) donnees['contenuResume'] = contenuResume;
    return donnees;
  }
}