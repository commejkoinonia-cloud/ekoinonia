import 'package:flutter/material.dart';
import '../../models/notification_app.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../enfants/enfants_list_screen.dart';
import '../classes/classes_list_screen.dart';
import '../materiel/materiel_list_screen.dart';
import '../moniteurs/moniteurs_list_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profil/profil_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import 'accueil_screen.dart';

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
              _clocheNotifications(profil),
              _avatarUtilisateur(profil),
              const SizedBox(width: 8),
            ],
          ),
          drawer: _MenuTiroir(profil: profil),
          body: _indexActif == 0
              ? AccueilScreen(profil: profil)
              : _indexActif == 1
                  ? EnfantsListScreen(profil: profil)
                  : _indexActif == 3
                      ? ProfilScreen(profil: profil)
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

  /// Cloche de notifications avec un badge rouge indiquant le nombre de
  /// notifications plus récentes que la dernière consultation de la
  /// personne connectée (voir NotificationService).
  Widget _clocheNotifications(UtilisateurProfil? profil) {
    return StreamBuilder<List<AppNotification>>(
      stream: NotificationService().streamNotifications(profil?.classeId),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final derniereConsultation = profil?.dateDerniereConsultationNotifications;
        final nombreNonLues = notifications
            .where((n) => derniereConsultation == null || n.dateCreation.isAfter(derniereConsultation))
            .length;

        return IconButton(
          tooltip: 'Notifications',
          icon: Badge(
            label: Text('$nombreNonLues'),
            isLabelVisible: nombreNonLues > 0,
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => NotificationsScreen(profil: profil),
            ));
          },
        );
      },
    );
  }

  /// Avatar de la personne connectée : sa photo si elle en a une, sinon
  /// simplement l'initiale de son prénom. Un appui amène directement sur
  /// l'onglet "Profil".
  Widget _avatarUtilisateur(UtilisateurProfil? profil) {
    final initiale = (profil?.prenom.isNotEmpty ?? false) ? profil!.prenom[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => setState(() => _indexActif = 3),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.violetBleute,
          backgroundImage: (profil?.imageUrl != null && profil!.imageUrl!.isNotEmpty)
              ? NetworkImage(profil.imageUrl!)
              : null,
          child: (profil?.imageUrl == null || profil!.imageUrl!.isEmpty)
              ? Text(initiale, style: const TextStyle(color: AppColors.blanc, fontSize: 13, fontWeight: FontWeight.bold))
              : null,
        ),
      ),
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
            _itemMenu(
              context,
              Icons.groups_outlined,
              'Moniteurs',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const MoniteursListScreen(),
                ));
              },
            ),
            _itemMenu(
              context,
              Icons.class_outlined,
              'Classes',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ClassesListScreen(profil: p),
                ));
              },
            ),
            _itemMenu(context, Icons.assignment_outlined, 'Devoirs'),
            _itemMenu(context, Icons.event_outlined, 'Activités'),
            _itemMenu(context, Icons.card_giftcard_outlined, 'Opération Enfant Noël'),
            _itemMenu(
              context,
              Icons.inventory_2_outlined,
              'Matériel',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MaterielListScreen(profil: p),
                ));
              },
            ),
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

  ListTile _itemMenu(BuildContext context, IconData icone, String titre, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icone, color: AppColors.bleu),
      title: Text(titre),
      onTap: () {
        Navigator.of(context).pop();
        if (onTap != null) {
          onTap();
        }
        // Les sections sans action pour l'instant : TODO, branchées au
        // fur et à mesure qu'on construit chaque écran.
      },
    );
  }
}