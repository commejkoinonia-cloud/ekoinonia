import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente un document `discipline/{id}` : un fait disciplinaire
/// concernant un utilisateur, signalé par un autre, avec la mesure prise
/// et le statut de traitement.
///
/// Les champs correspondent exactement au document Firestore :
/// date, dateResolution, description, mesurePrise, signalPar, statut,
/// utilisateurId.
class EntreeDiscipline {
  final String id;
  final String utilisateurId; // la personne concernée
  final String description;
  final String mesurePrise;
  final String signalPar; // uid de la personne qui a fait le signalement
  final String statut; // "ouvert" ou "resolu"
  final DateTime date; // date du fait
  final DateTime? dateResolution;

  EntreeDiscipline({
    required this.id,
    required this.utilisateurId,
    required this.description,
    required this.mesurePrise,
    required this.signalPar,
    required this.statut,
    required this.date,
    this.dateResolution,
  });

  /// Vrai une fois que la mesure a été appliquée et l'entrée clôturée.
  bool get estResolu => statut == 'resolu';

  factory EntreeDiscipline.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return EntreeDiscipline(
      id: id,
      utilisateurId: donnees['utilisateurId'] ?? '',
      description: donnees['description'] ?? '',
      mesurePrise: donnees['mesurePrise'] ?? '',
      signalPar: donnees['signalPar'] ?? '',
      statut: donnees['statut'] ?? 'ouvert',
      date: (donnees['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateResolution: (donnees['dateResolution'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> versFirestore() {
    final donnees = <String, dynamic>{
      'utilisateurId': utilisateurId,
      'description': description,
      'mesurePrise': mesurePrise,
      'signalPar': signalPar,
      'statut': statut,
      'date': Timestamp.fromDate(date),
    };
    if (dateResolution != null) {
      donnees['dateResolution'] = Timestamp.fromDate(dateResolution!);
    }
    return donnees;
  }
}