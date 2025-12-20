// trader_home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'orders_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'add_product_screen.dart';
import 'complaints_and_ratings_screen.dart';
import 'borrows_screen.dart';
import 'products_screen.dart';
import 'merchant_shop_screen.dart';
import 'ComplaintScreen.dart'; // تأكد من استيراد شاشة الشكاوى

class TraderHomeScreen extends StatefulWidget {
  const TraderHomeScreen({super.key});

  @override
  State<TraderHomeScreen> createState() => _TraderHomeScreenState();
}

class _TraderHomeScreenState extends State<TraderHomeScreen> {
  final String storeType = "متجرك";
  final int newNotifications = 0;
  
  bool _isLoading = true;
  int _newOrdersCount = 0;
  int _shippingOrdersCount = 0;
  int _completedOrdersCount = 0;
  int _totalOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrderStats();
  }

  Future<void> _fetchOrderStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.shopOrders, token: token);

      if (response != null) {
        List<dynamic> orders = [];
        if (response is List) {
          orders = response;
        } else if (response is Map && response.containsKey('data') && response['data'] is List) {
          orders = response['data'];
        }

        int newCount = 0;
        int shippingCount = 0;
        int completedCount = 0;

        for (var order in orders) {
          final status = order['orderStatus'] ?? order['status'];
          if (status != null) {
            final statusInt = int.tryParse(status.toString()) ?? -1;
            if (statusInt == 2) {
              newCount++;
            } else if (statusInt == 3) {
              shippingCount++;
            } else if (statusInt == 4) {
              completedCount++;
            }
          }
        }

        if (mounted) {
          setState(() {
            _newOrdersCount = newCount;
            _shippingOrdersCount = shippingCount;
            _completedOrdersCount = completedCount;
            _totalOrdersCount = orders.length;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching order stats: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get stats => [
    {
      'title': 'الطلبات',
      'count': '$_totalOrdersCount',
      'icon': Icons.shopping_cart_outlined,
      'color': const Color(0xFFFFD700),
      'screen':  OrdersScreen(),
    },
    {
      'title': 'التقارير',
      'count': 'عرض',
      'icon': Icons.analytics_outlined,
      'color': const Color(0xFFFFD700),
      'screen': const ReportsScreen(),
    },
    {
      'title': 'المنتجات',
      'count': 'إدارة',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFFFFD700),
      'screen': const ProductsScreen(),
    },
    {
      'title': 'متجري',
      'count': 'عرض',
      'icon': Icons.store,
      'color': const Color(0xFFFFD700),
      'screen': const MerchantShopScreen(),
    },
  ];

  List<Map<String, dynamic>> get orderStats => [
    {
      'status': 'جديد',
      'count': '$_newOrdersCount',
      'icon': Icons.pending_actions,
      'color': const Color(0xFFFFD700),
      'statusColor': const Color(0xFFFFD700),
    },
    {
      'status': 'مكتمل',
      'count': '$_completedOrdersCount',
      'icon': Icons.task_alt,
      'color': const Color(0xFF4CAF50),
      'statusColor': const Color(0xFF4CAF50),
    },
    {
      'status': 'شحن',
      'count': '$_shippingOrdersCount',
      'icon': Icons.local_shipping,
      'color': const Color(0xFF2196F3),
      'statusColor': const Color(0xFF2196F3),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الترحيب المحسنة
            _buildWelcomeCard(context),

            SizedBox(height: 20),

            // الإحصائيات السريعة
            _buildSectionHeader('نظرة سريعة'),
            SizedBox(height: 12),

            // GridView محسّن مع بطاقات أكبر - 2 في كل صف
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                return _buildStatCard(context, stats[index]);
              },
            ),

            SizedBox(height: 20),

            // حالة الطلبات
            _buildOrdersStatusSection(context),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // تصميم AppBar محسن مع زر الإسعاف
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('لوحة التحكم',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),
          Text(
            'تخصص: $storeType',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFFFD700),
      elevation: 4,
      centerTitle: false,
      shadowColor: Colors.black.withOpacity(0.3),
      actions: [
        // زر الإسعاف/الشكاوى
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: Icon(Icons.medical_services_outlined,
                color: Colors.red, size: 22),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ComplaintScreen()),
            );
          },
        ),
        SizedBox(width: 8),

        // زر الإشعارات
        Stack(
          children: [
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26, width: 1),
                ),
                child: Icon(Icons.notifications_none,
                    color: Colors.black, size: 22),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BorrowsScreen()),
                );
              },
            ),
            if (newNotifications > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    newNotifications > 9 ? '9+' : newNotifications.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 8),
      ],
    );
  }

  // بطاقة ترحيب محسنة
  Widget _buildWelcomeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 100,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFFC400),
              Color(0xFFFFB300),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // الصورة
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 24,
                color: Color(0xFFFFD700),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'مرحباً بك! 👋',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 10, color: Colors.black87),
                        SizedBox(width: 4),
                        Text(
                          'عرض الملف الشخصي',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // التقييم
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
                  SizedBox(width: 4),
                  Text(
                    '0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة إحصائية محسنة
  Widget _buildStatCard(BuildContext context, Map<String, dynamic> stat) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: stat['color'],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => stat['screen']),
              );
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      stat['icon'],
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    stat['count'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    stat['title'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // قسم حالة الطلبات
  Widget _buildOrdersStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('حالة الطلبات'),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersScreen()),
                );
              },
              child: Row(
                children: [
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      size: 12, color: Color(0xFFFFD700)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: orderStats.map((stat) {
              return _buildOrderStatusItem(stat);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // قسم الاستعارات والإشعارات
  Widget _buildBorrowsNotificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('الاستعارات والإشعارات'),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BorrowsScreen()),
                );
              },
              child: Row(
                children: [
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      size: 12, color: Color(0xFFFFD700)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildBorrowsItem(
                'الاستعارات النشطة',
                Icons.receipt_long,
                Colors.blue,
                'لا توجد استعارات نشطة',
              ),
              SizedBox(height: 12),
              _buildBorrowsItem(
                'الإشعارات',
                Icons.notifications_none,
                Colors.orange,
                'لا توجد إشعارات جديدة',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // عنصر الاستعارات والإشعارات
  Widget _buildBorrowsItem(
      String title, IconData icon, Color color, String status) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '0',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // عنصر حالة الطلب
  Widget _buildOrderStatusItem(Map<String, dynamic> stat) {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: stat['statusColor'].withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: stat['statusColor'].withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            stat['icon'],
            color: stat['statusColor'],
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          stat['count'],
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 2),
        Text(
          stat['status'],
          style: TextStyle(
            color: Colors.black54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.build_circle_outlined,
                    size: 50, color: Color(0xFFFFD700)),
                SizedBox(height: 16),
                Text(
                  'قيد التطوير',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$feature - هذه الميزة قيد التطوير',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('موافق'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
