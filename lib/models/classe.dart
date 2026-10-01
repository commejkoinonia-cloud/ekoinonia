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

  factory Classe.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Classe(
      id: id,
      nom: donnees['nom'] ?? '',
      description: donnees['description'] ?? '',
      ageMin: donnees['ageMin'],
      ageMax: donnees['ageMax'],
      moniteurIds: List<String>.from(donnees['moniteurIds'] ?? []),
      actif: donnees['actif'] ?? true,
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