import 'package:flutter/material.dart';
import '../../models/notification_app.dart';
import '../../models/utilisateur_profil.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  final UtilisateurProfil? profil;
  const NotificationsScreen({super.key, required this.profil});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Dès l'ouverture de l'écran, on marque tout comme lu : le badge
    // repassera à zéro au retour sur le tableau de bord.
    final uid = widget.profil?.uid;
    if (uid != null) {
      NotificationService().marquerCommeLues(uid);
    }
  }

  IconData _iconePourType(String type) {
    switch (type) {
      case 'communication':
        return Icons.campaign_outlined;
      case 'activite':
        return Icons.event_outlined;
      case 'seance':
        return Icons.menu_book_outlined;
      case 'devoir':
        return Icons.assignment_outlined;
      case 'oen':
        return Icons.card_giftcard_outlined;
      case 'materiel':
        return Icons.inventory_2_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationService().streamNotifications(widget.profil?.classeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('Aucune notification pour le moment.'));
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.grisClair,
                  child: Icon(_iconePourType(n.type), color: AppColors.bleu, size: 20),
                ),
                title: Text(n.titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(n.message),
                trailing: Text(
                  '${n.dateCreation.day}/${n.dateCreation.month}',
                  style: const TextStyle(color: AppColors.texteClair, fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}