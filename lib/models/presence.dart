class Presence {
  final String enfantId;
  final bool present;
  final String remarque;

  Presence({required this.enfantId, required this.present, this.remarque = ''});

  factory Presence.depuisFirestore(String enfantId, Map<String, dynamic> donnees) {
    return Presence(
      enfantId: enfantId,
      present: donnees['present'] ?? false,
      remarque: donnees['remarque'] ?? '',
    );
  }

  Map<String, dynamic> versFirestore() {
    return {'present': present, 'remarque': remarque};
  }
}