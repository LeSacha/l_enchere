import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification_item.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({Key? key}) : super(key: key);

  void _showNotifications(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final notifications = notifProvider.notifications;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  // --- GRIP + HEADER ---
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (notifications.any((n) => !n.read))
                              TextButton(
                                onPressed: () => notifProvider.markAllAsRead(),
                                child: const Text("Tout marquer comme lu"),
                              ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // --- LISTE DES NOTIFS ---
                  Expanded(
                    child: notifications.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucune notification pour le moment",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              final isUnread = !notif.read;

                              return InkWell(
                                onTap: () => notifProvider.markAsRead(notif.id),
                                child: Container(
                                  color: isUnread
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.transparent,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.notifications_active,
                                      color: isUnread
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                    title: Text(
                                      notif.title,
                                      style: TextStyle(
                                        fontWeight: isUnread
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      notif.message,
                                      style: TextStyle(
                                        color: isUnread
                                            ? Colors.black87
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    trailing: isUnread
                                        ? const Icon(
                                            Icons.circle,
                                            size: 10,
                                            color: Colors.red,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final count = notifProvider.unreadCount;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _showNotifications(context),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
