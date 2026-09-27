import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente un document de la collection `enfants`.
class Enfant {
  final String id;
  final String nom;
  final String prenom;
  final DateTime? dateNaissance;
  final String sexe;
  final String classeId;
  final String nomTuteur;
  final String telephoneTuteur;
  final String adresse;
  final String? imageUrl;
  final DateTime? dateInscription;
  final bool actif;
  final bool aDejaParticipeOEN;
  final int? anneeParticipationOEN;
  final double? moyenneDevoirs;
  final int? nombreDevoirsNotes;

  Enfant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.sexe,
    required this.classeId,
    required this.nomTuteur,
    required this.telephoneTuteur,
    required this.adresse,
    required this.actif,
    this.dateNaissance,
    this.imageUrl,
    this.dateInscription,
    this.aDejaParticipeOEN = false,
    this.anneeParticipationOEN,
    this.moyenneDevoirs,
    this.nombreDevoirsNotes,
  });

  String get nomComplet => '$prenom $nom';

  /// Âge calculé à partir de la date de naissance. Retourne null si la
  /// date de naissance n'est pas renseignée, pour ne jamais afficher un
  /// faux âge.
  int? get age {
    if (dateNaissance == null) return null;
    final aujourdHui = DateTime.now();
    int age = aujourdHui.year - dateNaissance!.year;
    // Si l'anniversaire n'est pas encore passé cette année, on retire 1 an.
    final anniversaireDejaPasse = aujourdHui.month > dateNaissance!.month ||
        (aujourdHui.month == dateNaissance!.month && aujourdHui.day >= dateNaissance!.day);
    if (!anniversaireDejaPasse) age--;
    return age;
  }

  factory Enfant.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Enfant(
      id: id,
      nom: _texte(donnees['nom']),
      prenom: _texte(donnees['prenom']),
      sexe: _texte(donnees['sexe']),
      classeId: _texte(donnees['classeId']),
      nomTuteur: _texte(donnees['nomTuteur']),
      telephoneTuteur: _texte(donnees['telephoneTuteur']),
      adresse: _texte(donnees['adresse']),
      actif: _bool(donnees['actif'], true),
      imageUrl: _texteOuNull(donnees['imageUrl']),
      dateNaissance: _dateOuNull(donnees['dateNaissance']),
      dateInscription: _dateOuNull(donnees['dateInscription']),
      aDejaParticipeOEN: _bool(donnees['aDejaParticipeOEN'], false),
      anneeParticipationOEN: _intOuNull(donnees['anneeParticipationOEN']),
      moyenneDevoirs: _doubleOuNull(donnees['moyenneDevoirs']),
      nombreDevoirsNotes: _intOuNull(donnees['nombreDevoirsNotes']),
    );
  }

  /// Les données Firestore arrivent en `dynamic` : sans ces conversions, une
  /// valeur du mauvais type (par exemple un Timestamp dans un champ numérique)
  /// ferait planter toute la liste des enfants.
  static String _texte(dynamic valeur) => valeur is String ? valeur : '';

  static String? _texteOuNull(dynamic valeur) => valeur is String ? valeur : null;

  static bool _bool(dynamic valeur, bool defaut) => valeur is bool ? valeur : defaut;

  static int? _intOuNull(dynamic valeur) {
    if (valeur is int) return valeur;
    if (valeur is num) return valeur.toInt();
    if (valeur is String) return int.tryParse(valeur.trim());
    return null;
  }

  static double? _doubleOuNull(dynamic valeur) {
    if (valeur is num) return valeur.toDouble();
    if (valeur is String) return double.tryParse(valeur.trim().replaceAll(',', '.'));
    return null;
  }

  static DateTime? _dateOuNull(dynamic valeur) {
    if (valeur is Timestamp) return valeur.toDate();
    if (valeur is DateTime) return valeur;
    if (valeur is int) return DateTime.fromMillisecondsSinceEpoch(valeur);
    if (valeur is String) return DateTime.tryParse(valeur.trim());
    return null;
  }

  /// Convertit l'objet en Map pour l'écrire dans Firestore.
  /// N'inclut jamais de champ optionnel resté vide, pour garder des
  /// documents propres (voir règle "champ optionnel = absent si vide").
  Map<String, dynamic> versFirestore() {
    final donnees = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
      'sexe': sexe,
      'classeId': classeId,
      'nomTuteur': nomTuteur,
      'telephoneTuteur': telephoneTuteur,
      'adresse': adresse,
      'actif': actif,
      'aDejaParticipeOEN': aDejaParticipeOEN,
    };
    if (dateNaissance != null) donnees['dateNaissance'] = Timestamp.fromDate(dateNaissance!);
    if (dateInscription != null) donnees['dateInscription'] = Timestamp.fromDate(dateInscription!);
    if (imageUrl != null && imageUrl!.isNotEmpty) donnees['imageUrl'] = imageUrl;
    if (anneeParticipationOEN != null) donnees['anneeParticipationOEN'] = anneeParticipationOEN;
    return donnees;
  }
}