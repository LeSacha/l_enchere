import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Nouvelle offre !',
      message: 'Quelqu\'un a surenchéri sur votre annonce "Chaise design"',
      read: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Offre dépassée',
      message: 'Votre offre sur "iPhone 14" a été dépassée',
      read: true,
    ),
  ];

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount =>
      _notifications.where((notif) => notif.read == false).length;

  void markAsRead(String id) {
    final notif = _notifications.firstWhere((n) => n.id == id);
    notif.read = true;
    notifyListeners();
  }

  void markAllAsRead() {
    for (var notif in _notifications) {
      notif.read = true;
    }
    notifyListeners();
  }
}
