// MODIFIÉ : l'import cloud_firestore n'est plus nécessaire ici, depuis que
// `dateDerniereConsultationNotifications` est converti par
// LecteurFirestore.dateOuNull (ce modèle n'écrit jamais de Timestamp lui-même).
import 'lecteur_firestore.dart';
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

  /// MODIFIÉ : `(donnees['dateDerniereConsultationNotifications] as
  /// Timestamp?)` levait "String is not a subtype of type Timestamp? in type
  /// cast" si ce champ avait été écrit en texte. Comme il pilote le badge de
  /// notifications, l'erreur remontait sur l'écran principal à chaque
  /// ouverture. `dateOuNull` accepte Timestamp, DateTime, millisecondes et
  /// texte ISO.
  factory UtilisateurProfil.depuisFirestore(String uid, Map<String, dynamic> donnees) {
    return UtilisateurProfil(
      uid: uid,
      nom: donnees['nom'] ?? '',
      prenom: donnees['prenom'] ?? '',
      classeId: donnees['classeId'] ?? '',
      // MODIFIÉ : `List<String>.from(donnees['fonctions'] ?? [])` levait
      // "type 'String' is not a subtype of type 'Iterable<dynamic>'" quand le
      // champ `fonctions` avait été rempli avec un texte unique
      // ("charge_materiel") au lieu d'une liste. Or ce champ pilote TOUS les
      // droits de l'app : une seule exception faisait planter l'écran
      // principal et le menu tiroir. `listeDeTextes` accepte les trois cas.
      fonctions: LecteurFirestore.listeDeTextes(donnees['fonctions']),
      imageUrl: donnees['imageUrl'],
      actif: donnees['actif'] ?? true,
      dateDerniereConsultationNotifications:
          LecteurFirestore.dateOuNull(donnees['dateDerniereConsultationNotifications']),
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