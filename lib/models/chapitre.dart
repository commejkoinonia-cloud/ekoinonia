class Chapitre {
  final String id;
  final int numero;
  final String titre;
  final String contenu;

  Chapitre({required this.id, required this.numero, required this.titre, this.contenu = ''});

  factory Chapitre.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Chapitre(
      id: id,
      numero: donnees['numero'] ?? 0,
      titre: donnees['titre'] ?? '',
      contenu: donnees['contenu'] ?? '',
    );
  }

  Map<String, dynamic> versFirestore() {
    return {'numero': numero, 'titre': titre, 'contenu': contenu};
  }
}