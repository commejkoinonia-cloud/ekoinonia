import 'package:cloud_firestore/cloud_firestore.dart';
import 'utilisateur_profil.dart';

class Communication {
  final String id;
  final String titre;
  final String contenu;
  final DateTime datePublication;
  final String destinataire; // "tous","moniteurs","responsables","classe_specifique"
  final String? classeId;
  final String auteurId;
  final List<String> piecesJointes;

  Communication({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.datePublication,
    required this.destinataire,
    required this.auteurId,
    this.classeId,
    this.piecesJointes = const [],
  });

  factory Communication.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Communication(
      id: id,
      titre: donnees['titre'] ?? '',
      contenu: donnees['contenu'] ?? '',
      datePublication: (donnees['datePublication'] as Timestamp?)?.toDate() ?? DateTime.now(),
      destinataire: donnees['destinataire'] ?? 'tous',
      classeId: donnees['classeId'],
      auteurId: donnees['auteurId'] ?? '',
      piecesJointes: List<String>.from(donnees['piecesJointes'] ?? []),
    );
  }

  Map<String, dynamic> versFirestore() {
    final donnees = <String, dynamic>{
      'titre': titre,
      'contenu': contenu,
      'datePublication': Timestamp.fromDate(datePublication),
      'destinataire': destinataire,
      'auteurId': auteurId,
      'piecesJointes': piecesJointes,
    };
    if (classeId != null) donnees['classeId'] = classeId;
    return donnees;
  }

  /// Une communication "classe_specifique" n'est pertinente que pour
  /// l'admin et le moniteur de cette classe précise. "responsables" ne
  /// concerne que les admins. Le reste ("tous","moniteurs") est visible
  /// par tout le monde, puisque tout le monde est au moins moniteur.
  bool estVisiblePour(UtilisateurProfil profil) {
    switch (destinataire) {
      case 'classe_specifique':
        return profil.estAdmin || profil.classeId == classeId;
      case 'responsables':
        return profil.estAdmin;
      default:
        return true;
    }
  }
}