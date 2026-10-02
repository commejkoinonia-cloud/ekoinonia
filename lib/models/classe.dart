import 'lecteur_firestore.dart';

/// Représente un document de la collection `classes`.
class Classe {
  final String id;
  final String nom;
  final String description;
  final int? ageMin;
  final int? ageMax;
  final List<String> moniteurIds;
  final bool actif;

  Classe({
    required this.id,
    required this.nom,
    required this.actif,
    this.description = '',
    this.ageMin,
    this.ageMax,
    this.moniteurIds = const [],
  });

  /// Les données Firestore arrivent en `dynamic` : chaque champ passe par
  /// LecteurFirestore pour qu'une valeur du mauvais type stockée en base
  /// (ex: `ageMin` en texte "6") ne fasse pas planter toute la liste des
  /// classes. Avant, `ageMin: donnees['ageMin']` levait
  /// "type 'String' is not a subtype of type 'int'".
  factory Classe.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Classe(
      id: id,
      nom: LecteurFirestore.texte(donnees['nom']),
      description: LecteurFirestore.texte(donnees['description']),
      // ageMin/ageMax : un nombre, mais tolère "6" ou 6.0 stockés en base.
      ageMin: LecteurFirestore.intOuNull(donnees['ageMin']),
      ageMax: LecteurFirestore.intOuNull(donnees['ageMax']),
      // moniteurIds : tolère un champ absent, ou un seul uid écrit sans liste.
      moniteurIds: LecteurFirestore.listeDeTextes(donnees['moniteurIds']),
      // actif : tolère un "true" écrit en texte.
      actif: LecteurFirestore.boolOuDefaut(donnees['actif'], true),
    );
  }

  /// Texte d'affichage pratique, ex: "6 - 8 ans"
  String get trancheAge {
    if (ageMin == null && ageMax == null) return '';
    return '${ageMin ?? '?'} - ${ageMax ?? '?'} ans';
  }

  Map<String, dynamic> versFirestore() {
    return {
      'nom': nom,
      'description': description,
      if (ageMin != null) 'ageMin': ageMin,
      if (ageMax != null) 'ageMax': ageMax,
      'moniteurIds': moniteurIds,
      'actif': actif,
    };
  }
}