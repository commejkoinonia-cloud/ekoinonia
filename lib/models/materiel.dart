import 'package:cloud_firestore/cloud_firestore.dart';
import 'lecteur_firestore.dart';

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

  /// Les données Firestore arrivent en `dynamic` : chaque champ passe par
  /// LecteurFirestore pour qu'une valeur du mauvais type stockée en base ne
  /// fasse pas planter toute la liste du matériel. Avant,
  /// `quantite: donnees['quantite'] ?? 0` levait
  /// "type 'String' is not a subtype of type 'int'" dès qu'un article avait
  /// sa quantité en texte ("5" au lieu de 5).
  factory Materiel.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Materiel(
      id: id,
      nom: LecteurFirestore.texte(donnees['nom']),
      categorie: LecteurFirestore.texte(donnees['categorie']),
      typeMateriel: LecteurFirestore.texteOuDefaut(donnees['typeMateriel'], 'durable'),
      // quantite est obligatoire : une valeur illisible ou absente devient 0
      // plutôt que de faire planter la liste entière.
      quantite: LecteurFirestore.intOuNull(donnees['quantite']) ?? 0,
      // Seuil d'alerte facultatif : reste null si absent ou illisible, ce qui
      // désactive simplement l'alerte de stock bas (getter stockBas).
      quantiteMinimale: LecteurFirestore.intOuNull(donnees['quantiteMinimale']),
      etat: LecteurFirestore.texteOuNull(donnees['etat']),
      dateAcquisition: LecteurFirestore.dateOuNull(donnees['dateAcquisition']),
      responsableId: LecteurFirestore.texteOuNull(donnees['responsableId']),
      remarque: LecteurFirestore.texte(donnees['remarque']),
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