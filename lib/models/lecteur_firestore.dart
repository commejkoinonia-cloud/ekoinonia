import 'package:cloud_firestore/cloud_firestore.dart';

/// Conversions tolérantes pour les données brutes de Firestore.
///
/// Un document Firestore est une `Map<String, dynamic>` : rien ne garantit
/// qu'un champ numérique soit bien un `int`, ni qu'un champ texte soit bien
/// une `String` (un import CSV/Excel laisse souvent `"quantite": "5"`).
///
/// Sans conversion, une seule valeur du mauvais type fait planter toute la
/// liste qui la contient ("type 'String' is not a subtype of type 'int'"),
/// parce que le `Stream.map()` s'interrompt sur le document fautif.
///
/// Ces helpers isolent cette défense : chaque modèle les appelle dans son
/// `depuisFirestore()` et se met ainsi à l'abri des données sales.
class LecteurFirestore {
  /// Un champ texte : tout ce qui n'est pas une `String` devient vide.
  static String texte(dynamic valeur) => valeur is String ? valeur : '';

  /// Un champ texte facultatif : tout ce qui n'est pas une `String` devient null.
  static String? texteOuNull(dynamic valeur) => valeur is String ? valeur : null;

  /// Un champ texte obligatoire, avec une valeur de repli. Si le champ est
  /// absent, vide ou du mauvais type, [defaut] est renvoyé.
  static String texteOuDefaut(dynamic valeur, String defaut) {
    final texte = valeur is String ? valeur.trim() : '';
    return texte.isEmpty ? defaut : texte;
  }

  /// Un champ booléen. Si la valeur est absente ou du mauvais type,
  /// [defaut] est renvoyé (ex: un champ "actif" stocké en "true" reste vrai).
  static bool boolOuDefaut(dynamic valeur, bool defaut) => valeur is bool ? valeur : defaut;

  /// Un nombre entier facultatif. Accepte un vrai `int`, un `double`
  /// (12.0 -> 12) ou un texte numérique ("12" -> 12). Sinon null.
  static int? intOuNull(dynamic valeur) {
    if (valeur is int) return valeur;
    if (valeur is num) return valeur.toInt();
    if (valeur is String) return int.tryParse(valeur.trim());
    return null;
  }

  /// Un décimal facultatif. Accepte un nombre ou un texte, virgule comprise
  /// ("12,5" -> 12.5, car la France écrit les décimaux avec une virgule).
  static double? doubleOuNull(dynamic valeur) {
    if (valeur is num) return valeur.toDouble();
    if (valeur is String) return double.tryParse(valeur.trim().replaceAll(',', '.'));
    return null;
  }

  /// Une date facultative. Firestore stocke normalement un `Timestamp`, mais
  /// on tolère aussi une `DateTime` déjà convertible, un nombre de
  /// millisecondes, ou un texte ISO ("2026-01-31").
  static DateTime? dateOuNull(dynamic valeur) {
    if (valeur is Timestamp) return valeur.toDate();
    if (valeur is DateTime) return valeur;
    if (valeur is int) return DateTime.fromMillisecondsSinceEpoch(valeur);
    if (valeur is String) return DateTime.tryParse(valeur.trim());
    return null;
  }

  /// Une liste de textes. Tolère l'absence (liste vide) et le cas d'un seul
  /// texte à la place d'une liste (["x"]), au lieu de laisser
  /// `List.from` planter sur le mauvais type.
  static List<String> listeDeTextes(dynamic valeur) {
    if (valeur is List) return valeur.map(texte).toList();
    if (valeur is String) return [valeur];
    return <String>[];
  }
}