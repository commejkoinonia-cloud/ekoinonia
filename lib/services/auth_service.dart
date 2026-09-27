import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Toute la logique liée à l'authentification et au profil de la personne
/// connectée passe par ce service. Les écrans ne parlent jamais directement
/// à Firebase : ils passent toujours par ici.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Flux qui "prévient" l'app à chaque fois que l'état de connexion change
  /// (connexion, déconnexion, session restaurée au démarrage...).
  /// C'est ce flux que l'AuthGate écoute pour savoir quel écran afficher.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get utilisateurActuel => _auth.currentUser;

  /// Connexion avec email + mot de passe.
  /// Lance une FirebaseAuthException si les identifiants sont invalides ;
  /// c'est à l'écran de connexion de l'attraper et d'afficher un message clair.
  Future<UserCredential> connexion({
    required String email,
    required String motDePasse,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: motDePasse);
  }

  Future<void> deconnexion() => _auth.signOut();

  /// Change le mot de passe de la personne actuellement connectée.
  /// Chaque utilisateur ne peut changer que le SIEN, jamais celui d'un autre
  /// (c'est une règle imposée par Firebase Authentication lui-même, pas
  /// besoin de la reprogrammer).
  Future<void> changerMotDePasse(String nouveauMotDePasse) async {
    await _auth.currentUser?.updatePassword(nouveauMotDePasse);
  }

  /// Récupère en temps réel le document `utilisateurs/{uid}` de la personne
  /// connectée : c'est ce document qui contient `classeId` et `fonctions`,
  /// utilisés partout dans l'app pour savoir ce que cette personne a le
  /// droit de voir/faire.
  Stream<DocumentSnapshot<Map<String, dynamic>>>? get monProfilStream {
    final uid = utilisateurActuel?.uid;
    if (uid == null) return null;
    return _db.collection('utilisateurs').doc(uid).snapshots();
  }
}