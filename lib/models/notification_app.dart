import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory AppNotification.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return AppNotification(
      id: id,
      titre: donnees['titre'] ?? '',
      message: donnees['message'] ?? '',
      type: donnees['type'] ?? 'systeme',
      creePar: donnees['creePar'] ?? '',
      dateCreation: (donnees['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      referenceCollection: donnees['referenceCollection'],
      referenceId: donnees['referenceId'],
      classeId: donnees['classeId'],
    );
  }
}