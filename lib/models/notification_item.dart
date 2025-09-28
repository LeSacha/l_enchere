class NotificationItem {
  final String id;
  final String title;
  final String message;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.read = false,
  });
}
