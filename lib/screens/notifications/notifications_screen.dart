import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/models/notification_model.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/services/firebase_messaging_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final notifications = await _dbService.getUserNotifications(
        authProvider.currentUser!.id,
      );

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الإشعارات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: _markAllAsRead,
              tooltip: 'تحديد الكل كمقروء',
            ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllNotifications,
            tooltip: 'مسح جميع الإشعارات',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إشعارات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر الإشعارات الجديدة هنا',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _getNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('تحديد كمقروء'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleNotificationAction(value, notification),
        ),
        onTap: () => _handleNotificationTap(notification),
        tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      ),
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case NotificationType.newCar:
        iconData = Icons.directions_car;
        color = Colors.blue;
        break;
      case NotificationType.carSold:
        iconData = Icons.sell;
        color = Colors.green;
        break;
      case NotificationType.newMessage:
        iconData = Icons.message;
        color = Colors.orange;
        break;
      case NotificationType.newRating:
        iconData = Icons.star;
        color = Colors.amber;
        break;
      case NotificationType.accountApproved:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.accountRejected:
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      case NotificationType.systemUpdate:
        iconData = Icons.system_update;
        color = Colors.purple;
        break;
      case NotificationType.priceChange:
        iconData = Icons.price_change;
        color = Colors.teal;
        break;
      case NotificationType.carExpired:
        iconData = Icons.schedule;
        color = Colors.grey;
        break;
      case NotificationType.reminder:
        iconData = Icons.notification_important;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Future<void> _handleNotificationAction(
      String action, NotificationModel notification) async {
    switch (action) {
      case 'mark_read':
        await _dbService.markNotificationAsRead(notification.id);
        _loadNotifications();
        break;
      case 'delete':
        await _dbService.deleteNotification(notification.id);
        _loadNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الإشعار')),
          );
        }
        break;
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    // تحديد الإشعار كمقروء
    if (!notification.isRead) {
      await _dbService.markNotificationAsRead(notification.id);
      _loadNotifications();
    }

    // التنقل حسب نوع الإشعار
    switch (notification.type) {
      case NotificationType.newCar:
        if (notification.relatedId != null) {
          // التنقل إلى تفاصيل السيارة
          // Navigator.push(context, MaterialPageRoute(...));
        }
        break;
      case NotificationType.newMessage:
        if (notification.relatedId != null) {
          // التنقل إلى المحادثة
          // Navigator.push(context, MaterialPageRoute(...));
        }
        break;
      default:
        // عدم فعل شيء للأنواع الأخرى
        break;
    }
  }

  Future<void> _markAllAsRead() async {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    try {
      for (final notification in _notifications.where((n) => !n.isRead)) {
        await _dbService.markNotificationAsRead(notification.id);
      }
      _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد المسح'),
        content: const Text('هل تريد مسح جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbService.clearAllNotifications(
          authProvider.currentUser!.id,
        );
        _loadNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم مسح جميع الإشعارات')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e')),
          );
        }
      }
    }
  }
}
