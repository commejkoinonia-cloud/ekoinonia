import 'package:cloud_firestore/cloud_firestore.dart';
import 'lecteur_firestore.dart';

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

  /// Les données Firestore arrivent en `dynamic` : sans ces conversions, une
  /// valeur du mauvais type (par exemple un Timestamp dans un champ numérique)
  /// ferait planter toute la liste des enfants.
  ///
  /// MODIFIÉ : ces conversions étaient des méthodes privées (_texte, _bool,
  /// _intOuNull...) définies dans cette classe. Elles sont maintenant
  /// partagées dans LecteurFirestore, pour que Classe et Materiel profitent
  /// de la même protection. Comportement strictement identique, seul
  /// l'endroit où elles sont définies a changé.
  factory Enfant.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Enfant(
      id: id,
      nom: LecteurFirestore.texte(donnees['nom']),
      prenom: LecteurFirestore.texte(donnees['prenom']),
      sexe: LecteurFirestore.texte(donnees['sexe']),
      classeId: LecteurFirestore.texte(donnees['classeId']),
      nomTuteur: LecteurFirestore.texte(donnees['nomTuteur']),
      telephoneTuteur: LecteurFirestore.texte(donnees['telephoneTuteur']),
      adresse: LecteurFirestore.texte(donnees['adresse']),
      actif: LecteurFirestore.boolOuDefaut(donnees['actif'], true),
      imageUrl: LecteurFirestore.texteOuNull(donnees['imageUrl']),
      dateNaissance: LecteurFirestore.dateOuNull(donnees['dateNaissance']),
      dateInscription: LecteurFirestore.dateOuNull(donnees['dateInscription']),
      aDejaParticipeOEN: LecteurFirestore.boolOuDefaut(donnees['aDejaParticipeOEN'], false),
      anneeParticipationOEN: LecteurFirestore.intOuNull(donnees['anneeParticipationOEN']),
      moyenneDevoirs: LecteurFirestore.doubleOuNull(donnees['moyenneDevoirs']),
      nombreDevoirsNotes: LecteurFirestore.intOuNull(donnees['nombreDevoirsNotes']),
    );
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