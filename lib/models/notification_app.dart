// MODIFIÉ : l'import cloud_firestore n'est plus nécessaire ici, depuis que
// `dateCreation` est converti par LecteurFirestore.dateOuNull (ce modèle
// n'écrit jamais de Timestamp lui-même).
import 'lecteur_firestore.dart';

class AppNotification {
  final String id;
  final String titre;
  final String message;
  final String type;
  final String? referenceCollection;
  final String? referenceId;
  final String? classeId;
  final String creePar;
  final DateTime dateCreation;

  AppNotification({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.creePar,
    required this.dateCreation,
    this.referenceCollection,
    this.referenceId,
    this.classeId,
  });

  /// MODIFIÉ : `(donnees['dateCreation'] as Timestamp?)` levait
  /// "String is not a subtype of type Timestamp? in type cast" sur une
  /// notification dont la date avait été saisie en texte, ce qui faisait
  /// planter tout l'écran des notifications. `dateOuNull` accepte Timestamp,
  /// DateTime, millisecondes et texte ISO.
  factory AppNotification.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return AppNotification(
      id: id,
      titre: donnees['titre'] ?? '',
      message: donnees['message'] ?? '',
      type: donnees['type'] ?? 'systeme',
      creePar: donnees['creePar'] ?? '',
      dateCreation: LecteurFirestore.dateOuNull(donnees['dateCreation']) ?? DateTime.now(),
      referenceCollection: donnees['referenceCollection'],
      referenceId: donnees['referenceId'],
      classeId: donnees['classeId'],
    );
  }
}