import 'package:flutter/material.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../enfants/enfants_list_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import '../';

/// Écran principal après connexion : contient la barre de navigation basse
/// (les sections les plus utilisées) et le menu tiroir (tout le reste,
/// affiché ou masqué selon les fonctions de la personne connectée).
///
/// Pour l'instant les pages sont des espaces réservés (placeholders) :
/// on branchera le vrai contenu (liste des enfants, des cours...) à
/// mesure qu'on construira chaque écran.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _indexActif = 0;

  // Les 4 sections principales, accessibles directement depuis la barre basse.
  final List<_PageBarreBasse> _pages = const [
    _PageBarreBasse(titre: 'Accueil', icone: Icons.home_outlined),
    _PageBarreBasse(titre: 'Enfants', icone: Icons.child_care_outlined),
    _PageBarreBasse(titre: 'Cours', icone: Icons.menu_book_outlined),
    _PageBarreBasse(titre: 'Profil', icone: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshotProfil>(
      // On utilise un petit adaptateur ci-dessous pour rester simple ;
      // en pratique ce stream vient de AuthService().monProfilStream.
      stream: _ecouterProfil(),
      builder: (context, snapshot) {
        final profil = snapshot.data?.profil;

        return Scaffold(
          appBar: AppBar(
            title: const Text('ECODIM'),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Scanner un QR code',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => QrScannerScreen(profil: profil),
                  ));
                },
              ),
            ],
          ),
          drawer: _MenuTiroir(profil: profil),
          body: _indexActif == 0
              ? AccueilScreen(profil: profil)
              : _indexActif == 1
                  ? EnfantsListScreen(profil: profil)
                  : Center(
                      child: Text(
                        _pages[_indexActif].titre,
                        style: const TextStyle(fontSize: 20, color: AppColors.texte),
                      ),
                    ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _indexActif,
            onTap: (index) => setState(() => _indexActif = index),
            items: _pages
                .map((page) => BottomNavigationBarItem(
                      icon: Icon(page.icone),
                      label: page.titre,
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Stream<DocumentSnapshotProfil> _ecouterProfil() async* {
    final stream = AuthService().monProfilStream;
    if (stream == null) return;
    await for (final doc in stream) {
      if (doc.exists) {
        yield DocumentSnapshotProfil(
          UtilisateurProfil.depuisFirestore(doc.id, doc.data()!),
        );
      }
    }
  }
}

/// Petit conteneur pour transporter le profil dans le StreamBuilder ci-dessus.
class DocumentSnapshotProfil {
  final UtilisateurProfil profil;
  DocumentSnapshotProfil(this.profil);
}

class _PageBarreBasse {
  final String titre;
  final IconData icone;
  const _PageBarreBasse({required this.titre, required this.icone});
}

/// Menu tiroir (accessible via l'icône ☰ en haut à gauche) : regroupe toutes
/// les sections secondaires. Chaque item n'apparaît que si la personne
/// connectée y a droit, en miroir des règles de sécurité Firestore.
class _MenuTiroir extends StatelessWidget {
  final UtilisateurProfil? profil;
  const _MenuTiroir({required this.profil});

  @override
  Widget build(BuildContext context) {
    final p = profil;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.bleu),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    p?.nomComplet ?? '...',
                    style: const TextStyle(color: AppColors.blanc, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (p != null && p.badges.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 6,
                        children: p.badges
                            .map((b) => Chip(
                                  label: Text(b, style: const TextStyle(fontSize: 11, color: AppColors.blanc)),
                                  backgroundColor: AppColors.violetBleute,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Sections visibles par tout le monde (lecture ouverte à tous
            // dans les règles de sécurité).
            _itemMenu(context, Icons.groups_outlined, 'Moniteurs'),
            _itemMenu(context, Icons.class_outlined, 'Classes'),
            _itemMenu(context, Icons.assignment_outlined, 'Devoirs'),
            _itemMenu(context, Icons.event_outlined, 'Activités'),
            _itemMenu(context, Icons.card_giftcard_outlined, 'Opération Enfant Noël'),
            _itemMenu(context, Icons.inventory_2_outlined, 'Matériel'),
            _itemMenu(context, Icons.campaign_outlined, 'Communications'),
            _itemMenu(context, Icons.shield_outlined, 'Discipline'),

            // Sections sensibles : uniquement admin ou caissière/adjoint.
            if (p != null && (p.estAdmin || p.estCaissiere)) ...[
              const Divider(),
              _itemMenu(context, Icons.savings_outlined, 'Finances'),
              _itemMenu(context, Icons.handshake_outlined, 'Partenaires'),
            ],

            const Divider(),
            _itemMenu(context, Icons.settings_outlined, 'Paramètres'),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.rougeAlerte),
              title: const Text('Déconnexion', style: TextStyle(color: AppColors.rougeAlerte)),
              onTap: () => AuthService().deconnexion(),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _itemMenu(BuildContext context, IconData icone, String titre) {
    return ListTile(
      leading: Icon(icone, color: AppColors.bleu),
      title: Text(titre),
      onTap: () {
        Navigator.of(context).pop();
        // TODO : brancher la navigation vers l'écran correspondant
        // au fur et à mesure qu'on construit chaque section.
      },
    );
  }
}