import 'package:cloud_firestore/cloud_firestore.dart';

class Finance {
  final String id;
  final String type; // "offrande","contribution_activite","don_partenaire","depense","autre_recette"
  final double montant;
  final DateTime date;
  final String? classeId;
  final String? enfantId;
  final String? activiteId;
  final String? partenaireId;
  final String motif;
  final String enregistrePar;
  final String? justificatifUrl;

  Finance({
    required this.id,
    required this.type,
    required this.montant,
    required this.date,
    required this.enregistrePar,
    this.classeId,
    this.enfantId,
    this.activiteId,
    this.partenaireId,
    this.motif = '',
    this.justificatifUrl,
  });

  /// Les dépenses retirent de la caisse, tout le reste l'alimente.
  bool get estDepense => type == 'depense';
  double get montantSigne => estDepense ? -montant : montant;

  static const Map<String, String> libellesType = {
    'offrande': 'Offrande',
    'contribution_activite': 'Contribution activité',
    'don_partenaire': 'Don de partenaire',
    'depense': 'Dépense',
    'autre_recette': 'Autre recette',
  };

  factory Finance.depuisFirestore(String id, Map<String, dynamic> donnees) {
    return Finance(
      id: id,
      type: donnees['type'] ?? 'autre_recette',
      montant: (donnees['montant'] as num?)?.toDouble() ?? 0,
      date: (donnees['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enregistrePar: donnees['enregistrePar'] ?? '',
      classeId: donnees['classeId'],
      enfantId: donnees['enfantId'],
      activiteId: donnees['activiteId'],
      partenaireId: donnees['partenaireId'],
      motif: donnees['motif'] ?? '',
      justificatifUrl: donnees['justificatifUrl'],
    );
  }

  Map<String, dynamic> versFirestore() {
    final donnees = <String, dynamic>{
      'type': type,
      'montant': montant,
      'date': Timestamp.fromDate(date),
      'enregistrePar': enregistrePar,
      'motif': motif,
    };
    if (classeId != null) donnees['classeId'] = classeId;
    if (enfantId != null) donnees['enfantId'] = enfantId;
    if (activiteId != null) donnees['activiteId'] = activiteId;
    if (partenaireId != null) donnees['partenaireId'] = partenaireId;
    if (justificatifUrl != null) donnees['justificatifUrl'] = justificatifUrl;
    return donnees;
  }
}