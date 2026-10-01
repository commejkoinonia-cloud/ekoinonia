import 'package:cloud_firestore/cloud_firestore.dart';
/// Représente le document `utilisateurs/{uid}` de la personne connectée.
///
/// Toute la logique "qui a le droit de voir/faire quoi" dans l'interface
/// (afficher ou masquer un item de menu, par exemple) passe par les
/// méthodes de cette classe, plutôt que de relire des chaînes de texte
/// un peu partout dans les écrans.
class UtilisateurProfil {
  final String uid;
  final String nom;
  final String prenom;
  final String classeId;
  final List<String> fonctions;
  final String? imageUrl;
  final bool actif;
  final DateTime? dateDerniereConsultationNotifications;

  UtilisateurProfil({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.classeId,
    required this.fonctions,
    required this.actif,
    this.imageUrl,
    this.dateDerniereConsultationNotifications
  });

  factory UtilisateurProfil.depuisFirestore(String uid, Map<String, dynamic> donnees) {
    return UtilisateurProfil(
      uid: uid,
      nom: donnees['nom'] ?? '',
      prenom: donnees['prenom'] ?? '',
      classeId: donnees['classeId'] ?? '',
      fonctions: List<String>.from(donnees['fonctions'] ?? []),
      imageUrl: donnees['imageUrl'],
      actif: donnees['actif'] ?? true,
      dateDerniereConsultationNotifications: (donnees['dateDerniereConsultationNotifications'] as Timestamp?)?.toDate(),
    );
  }

  String get nomComplet => '$prenom $nom';

  bool aFonction(String fonction) => fonctions.contains(fonction);

  bool get estAdmin => aFonction('responsable') || aFonction('responsable_adjoint');
  bool get estCaissiere => aFonction('caissiere') || aFonction('caissiere_adjoint');
  bool get estChargeMateriel => aFonction('charge_materiel') || aFonction('charge_materiel_adjoint');
  bool get estChargeCommunication => aFonction('charge_communication') || aFonction('charge_communication_adjoint');
  bool get estChargeDiscipline => aFonction('charge_discipline') || aFonction('charge_discipline_adjoint');

  /// Un badge par fonction supplémentaire, à afficher sur les cartes/QR code.
  /// Ex: ["Responsable", "Adjoint Matériel"]
  List<String> get badges {
    const libelles = {
      'responsable': 'Responsable',
      'responsable_adjoint': 'Adjoint Responsable',
      'caissiere': 'Caissière',
      'caissiere_adjoint': 'Adjointe Caissière',
      'charge_materiel': 'Chargé Matériel',
      'charge_materiel_adjoint': 'Adjoint Matériel',
      'charge_communication': 'Chargé Communication',
      'charge_communication_adjoint': 'Adjoint Communication',
      'charge_discipline': 'Chargé Discipline',
      'charge_discipline_adjoint': 'Adjoint Discipline',
    };
    return fonctions.map((f) => libelles[f] ?? f).toList();
  }
}