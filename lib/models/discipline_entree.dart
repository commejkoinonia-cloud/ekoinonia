import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente un document de la collection `discipline`.
/// `utilisateurIds` vide = règle générale qui concerne tous les moniteurs
/// (ex: "tout moniteur doit être présent avant culte"). Non vide = concerne
/// une ou plusieurs personnes précises (une seule, deux, ou plus).
class EntreeDiscipline {
  final String id;
  final List<String> utilisateurIds;
  final DateTime date;
  final String description;
  final String mesurePrise;
  final String signalePar;
  final String statut; // "ouvert" ou "resolu"
  final DateTime? dateResolution;

  EntreeDiscipline({
    required this.id,
    required this.date,
    required this.description,
    required this.signalePar,
    required this.statut,
    this.utilisateurIds = const [],
    this.mesurePrise = '',
    this.dateResolution,
  });

  bool get concerneToutLeMonde => utilisateurIds.isEmpty;

  factory EntreeDiscipline.depuisFirestore(String id, Map<String, dynamic> donnees) {
    // Compatibilité avec d'anciennes entrées créées avant ce changement,
    // qui stockaient un seul `utilisateurId` (texte) au lieu d'une liste.
    List<String> ids;
    if (donnees['utilisateurIds'] is List) {
      ids = List<String>.from(donnees['utilisateurIds']);
    } else if (donnees['utilisateurId'] is String && (donnees['utilisateurId'] as String).isNotEmpty) {
      ids = [donnees['utilisateurId']];
    } else {
      ids = [];
    }

    return EntreeDiscipline(
      id: id,
      utilisateurIds: ids,
      date: (donnees['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: donnees['description'] ?? '',
      mesurePrise: donnees['mesurePrise'] ?? '',
      signalePar: donnees['signalePar'] ?? '',
      statut: donnees['statut'] ?? 'ouvert',
      dateResolution: (donnees['dateResolution'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> versFirestore() {
    final donnees = <String, dynamic>{
      'utilisateurIds': utilisateurIds,
      'date': Timestamp.fromDate(date),
      'description': description,
      'mesurePrise': mesurePrise,
      'signalePar': signalePar,
      'statut': statut,
    };
    if (dateResolution != null) donnees['dateResolution'] = Timestamp.fromDate(dateResolution!);
    return donnees;
  }
}