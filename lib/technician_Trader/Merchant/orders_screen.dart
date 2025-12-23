// orders_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'Order_Tracking.screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  bool _isLoading = true;

  List<Map<String, dynamic>> currentOrders = [];
  List<Map<String, dynamic>> previousOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      print('--- fetching Orders ---');
      print('URL: ${ApiConstants.shopOrders}');
      print('Token: $token'); // Printing full token as requested for debugging

      if (token == null) {
        print('Error: Token is null');
        setState(() => _isLoading = false);
        return;
      }

      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.shopOrders, token: token);

      print('--- Orders API Response ---');
      print('Response Type: ${response.runtimeType}');
      print('Response Data: $response');

      if (response != null) {
        // Handle potential Map wrapper (e.g. { "data": [...] })
        dynamic ordersData = response;
        if (response is Map<String, dynamic> && response.containsKey('data')) {
           ordersData = response['data'];
           print('Extracted Data from "data" key: $ordersData');
        }

        if (ordersData is List) {
          List<Map<String, dynamic>> active = [];
          List<Map<String, dynamic>> history = [];

          for (var order in ordersData) {
            final mappedOrder = _mapOrderToUI(order);
            
            // Filter based on Date as requested
            // Previous Orders = Old Dates Only
            // Current Orders = Today's Orders
            
            bool isToday = true;
            try {
              final dateStr = order['orderDate'] ?? order['createdAt'];
              if (dateStr != null) {
                final date = DateTime.parse(dateStr);
                final now = DateTime.now();
                
                // Compare Year, Month, Day
                if (date.year != now.year || date.month != now.month || date.day != now.day) {
                  // If not same day, check if before
                  // Actually, just "not today" implies old (assuming no future orders created)
                  isToday = false;
                }
              }
            } catch (e) {
              print('Error parsing date: $e');
              // Fallback to status logic if date parse fails
              isToday = true; 
            }

            if (isToday) {
               active.add(mappedOrder);
            } else {
               history.add(mappedOrder);
            }
          }

          if (mounted) {
            setState(() {
              currentOrders = active;
              previousOrders = history;
              _isLoading = false;
            });
          }
          print('Orders Parsed Successfully. Active: ${active.length}, History: ${history.length}');
        } else {
          print('Error: Expected List but got ${ordersData.runtimeType}');
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        print('Error: Response is null');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      print('Error fetching orders: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل الطلبات: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, dynamic> _mapOrderToUI(dynamic apiOrder) {
    // Helper to safely get nested values
    final id = apiOrder['id']?.toString() ?? apiOrder['orderId']?.toString() ?? '#000';
    
    // Requested Fields
    final customerName = apiOrder['customerName'] ?? apiOrder['user']?['fullName'] ?? 'عميل';
    final customerPhone = apiOrder['customerPhoneNumber'] ?? apiOrder['customerPhone'] ?? '--';
    final address = apiOrder['address'] ?? apiOrder['shippingAddress'] ?? '';
    final price = apiOrder['price']?.toString() ?? apiOrder['totalAmount']?.toString() ?? '0';
    final title = apiOrder['title'] ?? ''; 
    final date = apiOrder['orderDate'] ?? apiOrder['createdAt'] ?? '';

    final rawStatus = apiOrder['orderStatus'] ?? apiOrder['status'];

    // Robust Status Mapping
    int statusId = -1;
    if (rawStatus is int) {
      statusId = rawStatus;
    } else if (rawStatus is String) {
      // Try parsing as int first
      if (int.tryParse(rawStatus) != null) {
        statusId = int.parse(rawStatus);
      } else {
        // Handle Enum Strings
        switch (rawStatus.toLowerCase()) {
          case 'pending': statusId = 0; break;
          case 'assigned': statusId = 1; break;
          case 'accepted': statusId = 2; break;
          case 'inprogress': statusId = 3; break;
          case 'completed': statusId = 4; break;
          case 'cancelled': statusId = 5; break;
          case 'rejected': statusId = 6; break;
          default: statusId = -1;
        }
      }
    }
    
    // Status Color & Text Mapping
    Color statusColor = Colors.grey;
    String statusText = 'غير معروف';
    
    switch (statusId) {
      case 0: // Pending
        statusColor = Color(0xFFFFD700);
        statusText = 'قيد الانتظار';
        break;
      case 1: // Assigned
        statusColor = Colors.blue;
        statusText = 'تم التعيين';
        break;
      case 2: // Accepted
        statusColor = Colors.teal;
        statusText = 'تم القبول';
        break;
      case 3: // InProgress
        statusColor = Colors.orange;
        statusText = 'قيد التنفيذ';
        break;
      case 4: // Completed
        statusColor = Colors.green;
        statusText = 'مكتمل';
        break;
      case 5: // Cancelled
        statusColor = Colors.red;
        statusText = 'ملغي';
        break;
      case 6: // Rejected
        statusColor = Colors.red[900]!;
        statusText = 'مرفوض';
        break;
      default:
        statusText = 'غير معروف';
    }

    // Items Mapping
    List<Map<String, dynamic>> items = [];
    if (apiOrder['items'] != null && apiOrder['items'] is List) {
      items = (apiOrder['items'] as List).map((item) {
        return {
          'name': item['productName'] ?? 'منتج',
          'quantity': item['quantity'] ?? 1,
          'price': '${item['unitPrice'] ?? 0} ج.م',
          'available': true,
          'id': item['productId']
        };
      }).toList();
    }

    // Customer Info
    final customerInfo = {
      'name': customerName,
      'phone': customerPhone,
      'address': address,
    };
    
    // Delivery Agent Info
    final deliveryAgent = {
      'name': apiOrder['deliveryAgent']?['name'] ?? 'غير متوفر',
      'phone': apiOrder['deliveryAgent']?['phone'] ?? '--',
    };

    return {
      'id': '#$id',
      'rawId': apiOrder['id'] ?? apiOrder['orderId'], // Store raw ID for API calls
      'title': title, // Added Title
      'customer': customerName,
      'amount': '$price ج.م', // Used 'price' field with EGP
      'status': statusText,
      'statusColor': statusColor,
      'time': date,
      'items': items,
      'customerInfo': customerInfo,
      'deliveryAgent': deliveryAgent,
      'notes': apiOrder['notes'] ?? '',
      'preparationTime': apiOrder['preparationTime'] ?? '',
      'rejectionReason': apiOrder['rejectionReason'] ?? '',
      'rawStatus': statusId, 
    };
  }

  // --- Helper Methods (Calculations, etc) ---
  double _calculateTotal(List<Map<String, dynamic>> orders) {
    double total = 0;
    for (var order in orders) {
      String amountStr = order['amount'].toString().replaceAll('ج.م', '').trim();
      total += double.tryParse(amountStr) ?? 0;
    }
    return total;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'الطلبات',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // الرجوع للشاشة السابقة
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenSize.height * 0.15), // Increased height slightly
          child: Container(
            color: Color(0xFFFFD700),
            child: Column(
              children: [
                // إحصائيات سريعة
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          currentOrders.length.toString(), 'طلبات حالية'),
                      _buildStatItem(
                          '${_calculateTotal(currentOrders)} ج.م', 'إجمالي اليوم'),
                      _buildStatItem(
                          previousOrders.length.toString(), 'طلبات سابقة'),
                    ],
                  ),
                ),
                // Tabs
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'الطلبات الحالية (${currentOrders.length})'),
                      Tab(text: 'الطلبات السابقة (${previousOrders.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))))
          : TabBarView(
              controller: _tabController,
              children: [
                // الطلبات الحالية
                _buildCurrentOrdersList(),
                // الطلبات السابقة
                _buildPreviousOrdersList(),
              ],
            ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Container(
          width: 50, // Added fixed width for larger circle
          height: 50, // Added fixed height for larger circle
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Increased font size
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 12, // Slightly larger font
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentOrdersList() {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: Color(0xFFFFD700),
      child: currentOrders.isEmpty
          ? SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(child: Text('لا توجد طلبات حالية')),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: currentOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(currentOrders[index], true);
              },
            ),
    );
  }

  Widget _buildPreviousOrdersList() {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: Color(0xFFFFD700),
      child: previousOrders.isEmpty
          ? SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(child: Text('لا توجد طلبات سابقة')),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: previousOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(previousOrders[index], false);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isCurrent) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: order['statusColor'].withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Order Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Display (Above as requested)
                      if (order['title'] != null && order['title'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            order['title'],
                            style: TextStyle(
                              fontSize: 16, // Slightly larger/bold for title
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Text(
                        order['customer'],
                        style: TextStyle(
                          fontSize: 14, // Adjusted size since title is above
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        order['id'],
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status & Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order['amount'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: order['statusColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // المنتجات
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنتجات:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                ...order['items'].map<Widget>((item) {
                  return _buildProductItem(item, isCurrent);
                }).toList(),
              ],
            ),
          ),

          // معلومات العميل
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xffffffff)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header مع زر الرجوع
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'معلومات العميل:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.black, size: 20),
                      onPressed: () {
                        Navigator.pop(context); // الرجوع للشاشة السابقة
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _buildCustomerInfoItem('الاسم', order['customerInfo']['name']),
                _buildCustomerInfoItem(
                    'رقم التليفون', order['customerInfo']['phone']),
                _buildCustomerInfoItem(
                    'العنوان', order['customerInfo']['address']),
                if (order['notes'].isNotEmpty)
                  _buildCustomerInfoItem('ملاحظات', order['notes']),
              ],
            ),
          ),

          // أسباب الرفض للطلبات المرفوضة
          if (!isCurrent && order.containsKey('rejectionReason'))
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xffffafaf)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سبب الرفض: ${order['rejectionReason']}',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // أزرار التحكم للطلبات الحالية
          // تظهر فقط للطلبات بحالة (0) "قيد الانتظار" أو (1) "تم التعيين"
          if (isCurrent && (order['rawStatus'].toString() == '0' || order['rawStatus'].toString() == '1'))
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _showRejectionDialog(context, order);
                      },
                      child: Text('رفض الطلب'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _showAcceptConfirmationDialog(context, order);
                      },
                      child: Text('قبول الطلب'),
                    ),
                  ),
                ],
              ),
            ),

          // زر تتبع الطلب (عام لكل الطلبات)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _navigateToTrackingScreen(context, order);
              },
              icon: Icon(Icons.track_changes, size: 20),
              label: Text('متابعة الطلب'),
            ),
          ),

          // Rating for completed orders
          if (!isCurrent && order.containsKey('rating'))
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xffbff2c1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'التقييم: ${order['rating']}/5',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  Spacer(),
                  Text(
                    'تم التقييم',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, bool isCurrent) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: product['available'] ? Color(0xfffefdfd) : Color(0xffffafaf),
        ),
      ),
      child: Row(
        children: [
          // Product availability indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: product['available'] ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: product['available'] ? Colors.black : Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${product['quantity']} × ${product['price']}',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Remove button for unavailable products in current orders
          if (isCurrent && !product['available'])
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 18),
              onPressed: () {
                _removeProductFromOrder(product);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

    void _showRejectionDialog(BuildContext context, Map<String, dynamic> order) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              SizedBox(width: 8),
              Text('رفض الطلب ${order['id']}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('يرجى كتابة سبب الرفض:'),
              SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'اكتب هنا...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى كتابة سبب الرفض')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _updateOrderStatus(order, newStatus: 6, reason: reason);
              },
              child: Text('تأكيد الرفض'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 8),
            Text('تم الإرسال بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('تم إرسال سبب الرفض للطلب $orderId بنجاح'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم إعلام العميل برفض الطلب',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('تم'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // تحديث حالة الطلب عبر API المتخصص (Accept/Reject)
  Future<void> _updateOrderStatus(Map<String, dynamic> order, {int? newStatus, String? reason}) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)))),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        Navigator.pop(context); // Hide loading
        return;
      }

      final orderId = order['rawId'];
      final apiClient = ApiClient();
      dynamic response;

      if (newStatus == 2) {
        // متطلب جديد: Accept Order API
        // curl -X 'POST' '.../api/Merchants/accept-order/{id}'
        print('Accepting Order $orderId');
        response = await apiClient.post(
          "${ApiConstants.merchantAcceptOrder}/$orderId",
          {},
          token: token,
        );
      } else if (newStatus == 6) {
        // متطلب جديد: Reject Order API
        // curl -X 'POST' '.../api/Merchants/reject-order' with body
        print('Rejecting Order $orderId for reason: $reason');
        response = await apiClient.post(
          ApiConstants.merchantRejectOrder,
          {
            "orderId": orderId.toString(),
            "rejectionReason": reason ?? "لا يوجد سبب محدد"
          },
          token: token,
        );
      } else if (newStatus == 4) {
        // حالة إتمام الطلب (Complete Order)
        // نستخدم الـ API العام لتحديث الحالة
        print('Completing Order $orderId');
        response = await apiClient.post(
          ApiConstants.merchantUpdateOrderStatus,
          {
            "orderId": orderId.toString(),
            "status": 4,
            "price": 0
          },
          token: token,
        );
      } else {
        // fallback to old generic update if needed
        return;
      }

      Navigator.pop(context); // Hide loading

      if (response != null) {
         // تحديث القائمة
         await _fetchOrders();
         
         String message = 'تم تحديث حالة الطلب';
         if (newStatus == 2) message = 'تم قبول الطلب بنجاح';
         if (newStatus == 6) message = 'تم رفض الطلب بنجاح';
         if (newStatus == 4) message = 'تم إتمام الطلب بنجاح';

         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(message), 
             backgroundColor: (newStatus == 2 || newStatus == 4) ? Colors.green : Colors.red
           ),
         );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('فشل تحديث حالة الطلب'), backgroundColor: Colors.red),
         );
      }
    } catch (e) {
      Navigator.pop(context); // Hide loading
      print('Error updating order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // دالة إظهار ديلوج تأكيد القبول
  void _showAcceptConfirmationDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('تأكيد القبول'),
          ],
        ),
        content: Text('هل أنت متأكد من قبول الطلب رقم ${order['id']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order, newStatus: 2); // 2 = Accepted
            },
            child: Text('نعم، قبول'),
          ),
        ],
      ),
    );
  }

  // تم تحديث دالة الرفض لاستخدام API
  void _rejectOrder(Map<String, dynamic> order, String reason) {
    // استدعاء API الرفضالمتخصص
    _updateOrderStatus(order, newStatus: 6, reason: reason);
  }

  // Navigate to order tracking screen
  void _navigateToTrackingScreen(BuildContext context, Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(order: order),
      ),
    );
  }

  // Remove product from order
  void _removeProductFromOrder(Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف المنتج: ${product['name']}'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
