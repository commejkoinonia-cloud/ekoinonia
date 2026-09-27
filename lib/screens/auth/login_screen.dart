import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  bool _chargementEnCours = false;
  String? _messageErreur;
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    // Ne tente la connexion que si le formulaire est valide
    // (champs non vides, email au bon format).
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _chargementEnCours = true;
      _messageErreur = null;
    });

    try {
      await AuthService().connexion(
        email: _emailController.text.trim(),
        motDePasse: _motDePasseController.text,
      );
      // Pas besoin de naviguer manuellement vers le tableau de bord :
      // l'AuthGate écoute authStateChanges et redirige tout seul dès que
      // la connexion réussit.
    } on FirebaseAuthException {
      // On reste volontairement vague sur la raison exacte (mauvais email
      // ou mauvais mot de passe) : c'est une bonne pratique de sécurité,
      // ça évite de révéler si un compte existe ou non.
      setState(() {
        _messageErreur = "Email ou mot de passe incorrect.";
      });
    } finally {
      if (mounted) setState(() => _chargementEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo_mej.png', width: 90, height: 90),
                  const SizedBox(height: 12),
                  const Text(
                    'ECODIM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bleu,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Connectez-vous pour continuer',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.texteClair),
                  ),
                  const SizedBox(height: 28),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (valeur) {
                      if (valeur == null || valeur.trim().isEmpty) {
                        return 'Merci de saisir votre email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _motDePasseController,
                    obscureText: !_motDePasseVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_motDePasseVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
                      ),
                    ),
                    validator: (valeur) {
                      if (valeur == null || valeur.isEmpty) {
                        return 'Merci de saisir votre mot de passe';
                      }
                      return null;
                    },
                  ),

                  if (_messageErreur != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _messageErreur!,
                      style: const TextStyle(color: AppColors.rougeAlerte),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 22),

                  ElevatedButton(
                    onPressed: _chargementEnCours ? null : _seConnecter,
                    child: _chargementEnCours
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blanc),
                          )
                        : const Text('Se connecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}