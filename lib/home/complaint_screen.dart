import 'package:flutter/material.dart';

// تعريف الـ Enum (بدون تغيير)
enum NotificationType {
  success,
  error,
  warning,
  info,
  promotion,
}

// تعريف موديل بيانات الإشعار (بدون تغيير)
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime time;
  final IconData icon;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
    required this.icon,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // بيانات الإشعارات (بدون تغيير)
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'تم تأكيد طلبك',
      message:
          'تم تأكيد طلبك من الفني محمد أحمد. سيتم البدء في العمل خلال ساعة.',
      type: NotificationType.success,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      icon: Icons.assignment_turned_in_rounded,
    ),
    NotificationItem(
      id: '2',
      title: 'بدء تنفيذ الطلب',
      message: 'الفني بدأ تنفيذ طلبك رقم #12345.',
      type: NotificationType.info,
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      icon: Icons.build_rounded,
    ),
    NotificationItem(
      id: '3',
      title: 'الفني في الطريق',
      message: 'الفني محمد في الطريق إليك. سيصل خلال 15 دقيقة.',
      type: NotificationType.warning,
      time: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      icon: Icons.directions_car_rounded,
    ),
    NotificationItem(
      id: '4',
      title: 'تم إلغاء الطلب',
      message: 'تم إلغاء طلبك رقم #12346 من قبل الفني.',
      type: NotificationType.error,
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.cancel_rounded,
    ),
    NotificationItem(
      id: '5',
      title: 'تم إنهاء الطلب',
      message: 'تم إنهاء طلبك رقم #12345 بنجاح. شكراً لثقتك بنا.',
      type: NotificationType.success,
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.verified_rounded,
    ),
    NotificationItem(
      id: '6',
      title: 'تقييم الخدمة',
      message: 'كيف كانت تجربتك مع الفني محمد؟ ساعدنا في تحسين خدماتنا.',
      type: NotificationType.promotion,
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      icon: Icons.star_rate_rounded,
    ),
    NotificationItem(
      id: '7',
      title: 'عرض خاص',
      message: 'احصل على خصم 20% على طلبك القادم!',
      type: NotificationType.promotion,
      time: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
      icon: Icons.local_offer_rounded,
    ),
    NotificationItem(
      id: '8',
      title: 'تذكير بالموعد',
      message: 'لديك موعد غداً مع الفني أحمد الساعة 10:00 صباحاً',
      type: NotificationType.info,
      time: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
      icon: Icons.access_time_rounded,
    ),
  ];

  // الدوال المساعدة الأخرى (بدون تغيير)
  int get _unreadCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم تحديد جميع الإشعارات كمقروءة'),
        backgroundColor: Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _toggleReadStatus(String id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n.id == id);
      notification.isRead = !notification.isRead;
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حذف الإشعار'),
        backgroundColor: Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} يوم';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.promotion:
        return Colors.purple;
    }
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return 'نجاح';
      case NotificationType.error:
        return 'خطأ';
      case NotificationType.warning:
        return 'تنبيه';
      case NotificationType.info:
        return 'معلومات';
      case NotificationType.promotion:
        return 'عرض';
    }
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_rounded,
          color: Colors.red[400],
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'حذف الإشعار',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text('هل أنت متأكد من حذف هذا الإشعار؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteNotification(notification.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                notification.isRead ? Colors.grey[200]! : Colors.yellow[100]!,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _toggleReadStatus(notification.id),
            splashColor: Colors.yellow[100],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.yellow[50]!,
                          Colors.yellow[100]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.yellow[200]!,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      notification.icon,
                      color: _getNotificationColor(notification.type),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Notification Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.yellow[700],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.yellow[700]!.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgo(notification.time),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getNotificationColor(notification.type)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getTypeText(notification.type),
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      _getNotificationColor(notification.type),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.yellow[200]!,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 50,
                color: Colors.yellow[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'سيظهر هنا جميع الإشعارات الخاصة بطلباتك وتحديثات الخدمة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // إعادة تحميل الإشعارات
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        elevation: 2,
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[500],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            onPressed: _markAllAsRead,
            tooltip: 'تحديد الكل كمقروء',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.yellow[50]!,
                  Colors.yellow[100]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'غير مقروء',
                  _unreadCount.toString(),
                  Icons.notifications_active_rounded,
                  Colors.yellow[700]!,
                ),
                _buildStatItem(
                  'الإجمالي',
                  _notifications.length.toString(),
                  Icons.list_alt_rounded,
                  Colors.orange[600]!,
                ),
                _buildStatItem(
                  'هذا الأسبوع',
                  '8',
                  Icons.calendar_today_rounded,
                  Colors.amber[700]!,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Notifications list
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
