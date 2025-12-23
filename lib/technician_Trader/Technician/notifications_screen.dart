import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'طلب جديد',
      'message': 'لديك طلب جديد من العميل أحمد محمد',
      'time': 'منذ 5 دقائق',
      'type': 'new_request',
      'read': false,
      'requestId': '12345',
    },
    {
      'id': '2',
      'title': 'تذكير موعد',
      'message': 'موعدك مع العميل سارة خالد بعد ساعة',
      'time': 'منذ ساعة',
      'type': 'reminder',
      'read': true,
      'requestId': '12346',
    },
    {
      'id': '3',
      'title': 'تقييم جديد',
      'message': 'حصلت على تقييم 5 نجوم من العميل علي محمود',
      'time': 'منذ يوم',
      'type': 'rating',
      'read': true,
      'requestId': '12344',
    },
    {
      'id': '4',
      'title': 'دفع مكتمل',
      'message': 'تم استلام دفعة بقيمة 250 جنية من العميل فاطمة أحمد',
      'time': 'منذ يومين',
      'type': 'payment',
      'read': true,
      'requestId': '12343',
    },
    {
      'id': '5',
      'title': 'طلب ملغي',
      'message': 'تم إلغاء الطلب #12342 من قبل العميل خالد سعيد',
      'time': 'منذ 3 أيام',
      'type': 'cancelled',
      'read': true,
      'requestId': '12342',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: Colors.amber[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: _markAllAsRead,
            tooltip: 'تعليم الكل كمقروء',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAllNotifications,
            tooltip: 'حذف الكل',
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات سريعة
          _buildStatsHeader(),

          // قائمة الإشعارات
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الإشعارات غير المقروءة: $unreadCount',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('تعليم الكل كمقروء'),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: notification['read'] ? Colors.white : Colors.blue[50],
        elevation: 1,
        child: ListTile(
          leading: _buildNotificationIcon(notification['type']),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontWeight:
                  notification['read'] ? FontWeight.normal : FontWeight.bold,
              color: notification['read'] ? Colors.grey[600] : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification['message']),
              const SizedBox(height: 4),
              Text(
                notification['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: notification['read']
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () {
            _handleNotificationTap(notification);
          },
          onLongPress: () {
            _showNotificationOptions(notification);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'new_request':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'reminder':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case 'rating':
        icon = Icons.star;
        color = Colors.amber;
        break;
      case 'payment':
        icon = Icons.attach_money;
        color = Colors.green;
        break;
      case 'cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'سيظهر هنا جميع الإشعارات الخاصة بك',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // تعليم الإشعار كمقروء
    setState(() {
      notification['read'] = true;
    });

    // التنقل حسب نوع الإشعار
    switch (notification['type']) {
      case 'new_request':
        // الانتقال لشاشة تفاصيل الطلب
        _showSnackBar('سيتم الانتقال لتفاصيل الطلب');
        break;
      case 'reminder':
        _showSnackBar('تذكير بالموعد');
        break;
      case 'rating':
        // الانتقال لشاشة التقييمات
        _showSnackBar('سيتم الانتقال للتقييمات');
        break;
      default:
        _showSnackBar('تم فتح الإشعار');
    }
  }

  void _showNotificationOptions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text('تعليم كمقروء'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    notification['read'] = true;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('حذف الإشعار'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteNotification(notification['id']);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('نسخ النص'),
                onTap: () {
                  Navigator.pop(context);
                  _copyNotificationText(notification);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    _showSnackBar('تم تعليم جميع الإشعارات كمقروءة');
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع الإشعارات'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              _showSnackBar('تم حذف جميع الإشعارات');
            },
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
    _showSnackBar('تم حذف الإشعار');
  }

  void _copyNotificationText(Map<String, dynamic> notification) {
    // محاكاة نسخ النص
    _showSnackBar('تم نسخ نص الإشعار');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
