// ===== lib/providers/notification_provider.dart =====
import 'package:flutter/foundation.dart';

enum NotificationType { announcement, transaction, priceAlert, system, kyc }

class NotificationMessage {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationMessage> _notifications = [];
  bool _isLoading = false;

  List<NotificationMessage> get notifications => List.unmodifiable(_notifications);
  List<NotificationMessage> get unreadNotifications => 
    _notifications.where((n) => !n.isRead).toList();
  bool get isLoading => _isLoading;
  int get unreadCount => unreadNotifications.length;

  NotificationProvider() {
    _initializeDemoNotifications();
  }

  void _initializeDemoNotifications() {
    _notifications = [
      NotificationMessage(
        id: 'notif-001',
        title: 'Welcome to RMS Gold',
        message: 'Your account has been successfully created. Start investing in gold today!',
        type: NotificationType.announcement,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationMessage(
        id: 'notif-002',
        title: 'Gold Price Alert',
        message: 'Gold price has increased by 2.5% today. Current price: RM 475.50/g',
        type: NotificationType.priceAlert,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationMessage(
        id: 'notif-003',
        title: 'Transaction Completed',
        message: 'Your purchase of 2.10g gold has been completed successfully.',
        type: NotificationType.transaction,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationMessage(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        data: _notifications[index].data,
      );
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => NotificationMessage(
      id: n.id,
      title: n.title,
      message: n.message,
      type: n.type,
      timestamp: n.timestamp,
      isRead: true,
      data: n.data,
    )).toList();
    notifyListeners();
  }

  void addNotification(NotificationMessage notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }
}
