import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import 'dart:convert';
import '../sections/GeneralRatingScreen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTab = 0; // 0 للطلبات الحالية, 1 للطلبات المنتهية
  int _currentIndex = 3; // مؤشر الطلبات في البوتوم نافيغيشن

  // بيانات وهمية للطلبات
  List<dynamic> _currentOrders = [];
  List<dynamic> _completedOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchActiveOrders();
  }

  Future<void> _fetchActiveOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      final client = ApiClient();
      final response = await client.get(ApiConstants.activeOrders, token: token);
      
      print("Active Orders Response: $response");

      // assuming response is a List or a Map containing a list
      if (response != null) {
        if (response is List) {
           setState(() {
            _currentOrders = response;
          });
        } else if (response is Map && response.containsKey('data')) {
          // Adjust based on actual API structure
           setState(() {
            _currentOrders = response['data'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching orders: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchHistoryOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }

      final client = ApiClient();
      final response = await client.get(ApiConstants.orderHistory, token: token);
      
      print("Order History Response: $response");

      if (response != null) {
        if (response is List) {
           setState(() {
            _completedOrders = response;
          });
        } else if (response is Map && response.containsKey('data')) {
           setState(() {
            _completedOrders = response['data'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching history: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      // No AppBar, using custom header
      body: Column(
        children: [
          // Custom Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.yellow[600]!,
                  Colors.yellow[700]!,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            width: double.infinity,
            child: const Text(
              "الطلبات",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // تبويبات الطلبات الحالية والمنتهية
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // تبويب الطلبات الحالية
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                      if (_currentOrders.isEmpty) _fetchActiveOrders();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? Colors.yellow[700]
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'الطلبات الحالية',
                          style: TextStyle(
                            color: _selectedTab == 0
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // تبويب الطلبات المنتهية
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                      if (_completedOrders.isEmpty) _fetchHistoryOrders();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? Colors.yellow[700]
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'الطلبات المنتهية',
                          style: TextStyle(
                            color: _selectedTab == 1
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // محتوى الطلبات
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _selectedTab == 0
                  ? _buildCurrentOrders()
                  : _buildCompletedOrders(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOrders() {
    if (_currentOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: Colors.yellow[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد طلبات حالية',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _currentOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_currentOrders[index]);
      },
    );
  }

  Widget _buildCompletedOrders() {
    if (_completedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50], // Green/Yellow depending on preference, sticking to green for "check"
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد طلبات منتهية',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _completedOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_completedOrders[index]);
      },
    );
  }

  Widget _buildOrderCard(dynamic order) {
    // Map API fields safely
    final id = order['id'] ?? 'N/A';
    final serviceName = order['problemDescription'] ?? order['serviceSubCategoryName'] ?? 'طلب خدمة';

    final serviceSubCategoryName = order['serviceSubCategoryName'] ?? 'غير محدد';
    final problemDescription = order['problemDescription'] ?? 'لا يوجد وصف';
    final date = order['createdAt'] != null 
        ? order['createdAt'].toString().split('T')[0] 
        : '---';
    final price = order['price'] ?? 0;
    final address = order['address'] ?? 'لا يوجد عنوان';
    final problemImageUrl = order['problemImageUrl'];
    final status = order['orderStatus'] ?? 0;
    
    // Status text based on orderStatus value
    String statusText = 'قيد المعالجة';
    Color statusColor = Colors.orange;
    if (status == 1) {
      statusText = 'مكتمل';
      statusColor = Colors.green;
    } else if (status == 2) {
      statusText = 'ملغي';
      statusColor = Colors.red;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_long, color: Colors.yellow[800], size: 24),
          ),
          title: Text(
            serviceName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            'طلب #${id.toString().substring(0, 8)}...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Divider
                Divider(color: Colors.grey[300], height: 1),
                const SizedBox(height: 16),
                
                // Order ID
                // Order ID
                _buildDetailRow(Icons.tag, 'رقم الطلب', id.toString()),
                const SizedBox(height: 12),



                // Service Subcategory
                _buildDetailRow(Icons.build, 'الخدمة المطلوبة', serviceSubCategoryName),
                const SizedBox(height: 12),
                
                // Problem Description
                _buildDetailRow(Icons.description, 'وصف المشكلة', problemDescription),
                const SizedBox(height: 12),
                
                // Address
                _buildDetailRow(Icons.location_on, 'العنوان', address),
                const SizedBox(height: 12),
                
                // Date
                _buildDetailRow(Icons.calendar_today, 'تاريخ الإنشاء', date),
                if ((num.tryParse(price.toString()) ?? 0) > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 20, color: Colors.yellow[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'السعر:',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '$price جنيه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.yellow[800],
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Problem Image (if available)
                if (problemImageUrl != null && problemImageUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[300], height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'صورة المشكلة:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      problemImageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'فشل تحميل الصورة',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                  // Rating Button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeneralRatingScreen(orderId: id.toString()),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star_rate, color: Colors.white, size: 20),
                      label: const Text(
                        'تقييم الخدمة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToScreen(int index) {
      // Navigation logic managed by home_sections now
  }
}
