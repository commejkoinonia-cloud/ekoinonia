/// Représente un document de la collection `classes`.
/// Modèle volontairement minimal : on ajoutera les autres champs
/// (ageMin, ageMax, moniteurIds...) quand on construira l'écran "Classes".
class Classe {
  final String id;
  final String nom;
  final bool actif;

  Classe({required this.id, required this.nom, required this.actif});

  factory Classe.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Classe(
      id: id,
      nom: donnees['nom'] ?? '',
      actif: donnees['actif'] ?? true,
    );
  }
}