import 'package:cloud_firestore/cloud_firestore.dart';

class Materiel {
  final String id;
  final String nom;
  final String categorie;
  final String typeMateriel; // "durable" ou "consommable"
  final int quantite;
  final int? quantiteMinimale;
  final String? etat; // "bon","use","hors_service" — surtout pour le durable
  final DateTime? dateAcquisition;
  final String? responsableId;
  final String remarque;

  Materiel({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.typeMateriel,
    required this.quantite,
    this.quantiteMinimale,
    this.etat,
    this.dateAcquisition,
    this.responsableId,
    this.remarque = '',
  });

  /// Vrai quand le stock est descendu sous le seuil d'alerte défini.
  bool get stockBas => quantiteMinimale != null && quantite < quantiteMinimale!;

  factory Materiel.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Materiel(
      id: id,
      nom: donnees['nom'] ?? '',
      categorie: donnees['categorie'] ?? '',
      typeMateriel: donnees['typeMateriel'] ?? 'durable',
      quantite: donnees['quantite'] ?? 0,
      quantiteMinimale: donnees['quantiteMinimale'],
      etat: donnees['etat'],
      dateAcquisition: (donnees['dateAcquisition'] as Timestamp?)?.toDate(),
      responsableId: donnees['responsableId'],
      remarque: donnees['remarque'] ?? '',
    );
  }

  Map<String, dynamic> versFirestore() {
    final donnees = <String, dynamic>{
      'nom': nom,
      'categorie': categorie,
      'typeMateriel': typeMateriel,
      'quantite': quantite,
      'remarque': remarque,
    };
    if (quantiteMinimale != null) donnees['quantiteMinimale'] = quantiteMinimale;
    if (etat != null) donnees['etat'] = etat;
    if (dateAcquisition != null) donnees['dateAcquisition'] = Timestamp.fromDate(dateAcquisition!);
    if (responsableId != null) donnees['responsableId'] = responsableId;
    return donnees;
  }
}