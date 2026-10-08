import 'package:cloud_firestore/cloud_firestore.dart';

/// Petits convertisseurs tolérants aux erreurs de saisie manuelle dans la
/// console Firebase : un champ censé être une date peut arriver comme un
/// Timestamp (normal, depuis l'app), un texte, un nombre de millisecondes,
/// ou être absent. Pareil pour les listes de texte, parfois saisies comme
/// une simple chaîne au lieu d'un tableau. Plutôt que de faire planter
/// l'app avec un cast direct, on fait de son mieux et on retombe sur une
/// valeur neutre si on ne reconnaît rien.
class LecteurFirestore {
  static DateTime? dateOuNull(dynamic valeur) {
    if (valeur == null) return null;
    if (valeur is Timestamp) return valeur.toDate();
    if (valeur is DateTime) return valeur;
    if (valeur is int) return DateTime.fromMillisecondsSinceEpoch(valeur);
    if (valeur is String) return DateTime.tryParse(valeur);
    return null;
  }

  static List<String> listeDeTextes(dynamic valeur) {
    if (valeur == null) return [];
    if (valeur is List) {
      return valeur.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (valeur is String && valeur.isNotEmpty) return [valeur];
    return [];
  }
}