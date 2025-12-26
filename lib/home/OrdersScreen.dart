import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import 'dart:convert';
import '../sections/GeneralRatingScreen.dart';
import '../sections/maintenance/OrderTrackingScreen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTab = 0; // 0: Current, 1: History, 2: Purchases
  
  List<dynamic> _currentOrders = [];
  List<dynamic> _completedOrders = [];
  List<dynamic> _purchaseOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllOrders();
  }

  Future<void> _fetchAllOrders() async {
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
      final response = await client.get(ApiConstants.myOrders, token: token);
      
      List<dynamic> allOrders = [];
      if (response != null) {
        if (response is List) {
           allOrders = response;
        } else if (response is Map && response.containsKey('data')) {
           allOrders = response['data'] ?? [];
        }
      }

      List<dynamic> active = [];
      List<dynamic> history = [];
      List<dynamic> purchases = [];

      for (var order in allOrders) {
        // Check for products first
        if (order['orderedProducts'] != null && (order['orderedProducts'] as List).isNotEmpty) {
          purchases.add(order);
        } else {
          // Service Orders
          int status = order['orderStatus'] ?? 0;
          if (status <= 3) {
            active.add(order);
          } else {
            history.add(order);
          }
        }
      }

      if (mounted) {
        setState(() {
          _currentOrders = active;
          _completedOrders = history;
          _purchaseOrders = purchases;
        });
      }

    } catch (e) {
      print("Error fetching orders: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
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
      backgroundColor: Colors.grey[50], 
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

          // Tabs
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
                _buildTabItem("الطلبات الحالية", 0),
                _buildTabItem("الطلبات المنتهية", 1),
                _buildTabItem("طلبات الشراء", 2),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchAllOrders,
                  child: _getChildForTab(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _getChildForTab() {
    switch (_selectedTab) {
      case 0: return _buildCurrentOrders();
      case 1: return _buildCompletedOrders();
      case 2: return _buildPurchaseOrders();
      default: return const SizedBox();
    }
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow[700] : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentOrders() {
    if (_currentOrders.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
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
    
    // Status Logic
    String statusText = 'غير معروف';
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey[100]!;

    switch (status) {
      case 0:
        statusText = 'قيد المراجعة';
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange[50]!;
        break;
      case 1:
        statusText = 'تم التعيين';
        statusColor = Colors.blue[800]!;
        statusBgColor = Colors.blue[50]!;
        break;
      case 2:
        statusText = 'تم القبول';
        statusColor = Colors.blue[800]!;
        statusBgColor = Colors.blue[50]!;
        break;
      case 3:
        statusText = 'قيد التنفيذ';
        statusColor = Colors.indigo[800]!;
        statusBgColor = Colors.indigo[50]!;
        break;
      case 4:
        statusText = 'مكتمل';
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green[50]!;
        break;
      case 5:
        statusText = 'ملغي';
        statusColor = Colors.red[800]!;
        statusBgColor = Colors.red[50]!;
        break;
      case 6:
        statusText = 'مرفوض';
        statusColor = Colors.red[800]!;
        statusBgColor = Colors.red[50]!;
        break;
      default:
        statusText = 'غير محدد';
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.grey[300], height: 1),
                const SizedBox(height: 16),
                
                _buildDetailRow(Icons.tag, 'رقم الطلب', id.toString()),
                const SizedBox(height: 12),

                _buildDetailRow(Icons.build, 'الخدمة المطلوبة', serviceSubCategoryName),
                const SizedBox(height: 12),
                
                if (problemDescription.isNotEmpty && problemDescription != 'none' && problemDescription != 'لا يوجد وصف') ...[
                  _buildDetailRow(Icons.description, 'وصف المشكلة', problemDescription),
                  const SizedBox(height: 12),
                ],
                
                if (address.isNotEmpty && address != 'none' && address != 'لا يوجد عنوان') ...[
                  _buildDetailRow(Icons.location_on, 'العنوان', address),
                  const SizedBox(height: 12),
                ],
                
                _buildDetailRow(Icons.calendar_today, 'تاريخ الإنشاء', date),
                
                // Display technician name if available
                if (order['techniciaName'] != null || order['technicianName'] != null || order['merchantName'] != null) ...[ 
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.person, 
                    'الفني/التاجر', 
                    order['techniciaName'] ?? order['technicianName'] ?? order['merchantName'] ?? 'غير محدد'
                  ),
                ],
                
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                ],

                // Track Order Button
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingScreen(
                            orderId: id.toString(),
                            customerName: order['customerName'] ?? order['customer'] ?? order['customerInfo']?['name'] ?? 'العميل',
                            totalAmount: (num.tryParse(price.toString()) ?? 0).toDouble(),
                            specialization: order['serviceCategoryName'] ?? order['serviceName'] ?? serviceSubCategoryName,
                            orderStatus: status,
                            technicianName: order['techniciaName'] ?? order['technicianName'] ?? order['merchantName'] ?? 'لم يتم التعيين بعد',
                            technicianPhone: order['techniciaPhoneNumber'] ?? order['technicianPhone'] ?? order['merchantPhoneNumber'],
                            merchantPhone: order['merchantPhoneNumber'],
                            address: order['address'] ?? order['customerInfo']?['address'],
                            customerPhone: order['customerPhoneNumber'] ?? order['phoneNumber'] ?? order['customerPhone'] ?? order['customerInfo']?['phone'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.track_changes, color: Colors.blue),
                    label: const Text(
                      'متابعة الطلب',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                // Rating Button if completed
                if (status == 4) ...[
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
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPurchaseOrders() {
    if (_purchaseOrders.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد طلبات شراء',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _purchaseOrders.length,
      itemBuilder: (context, index) {
        return _buildPurchaseOrderCard(_purchaseOrders[index]);
      },
    );
  }

  Widget _buildPurchaseOrderCard(dynamic order) {
    final id = order['id'] ?? 'N/A';
    final title = order['title'] ?? 'طلب شراء';
    final date = order['createdAt'] != null 
        ? order['createdAt'].toString().split('T')[0] 
        : '---';
    final price = order['price'] ?? 0;
    final status = order['orderStatus'] ?? 0;
    final products = order['orderedProducts'] as List? ?? [];
    
    // Convert payWay to Arabic text
    final payWayValue = order['payWay'];
    String payWay = 'غير محدد';
    if (payWayValue == 0) {
      payWay = 'كاش';
    } else if (payWayValue == 1) {
      payWay = 'اونلاين';
    }
    
    final merchantName = order['merchantName'] ?? 'غير محدد';
    final serviceSubCategoryName = order['serviceSubCategoryName'] ?? 'غير محدد';
    
    // Status Logic
    String statusText = 'غير معروف';
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey[100]!;
    
    switch (status) {
      case 0:
        statusText = 'قيد المراجعة';
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange[50]!;
        break;
      case 1:
        statusText = 'تم التعيين';
        statusColor = Colors.blue[800]!;
        statusBgColor = Colors.blue[50]!;
        break;
      case 2:
        statusText = 'تم القبول';
        statusColor = Colors.blue[800]!;
        statusBgColor = Colors.blue[50]!;
        break;
      case 3:
        statusText = 'قيد التنفيذ';
        statusColor = Colors.indigo[800]!;
        statusBgColor = Colors.indigo[50]!;
        break;
      case 4:
        statusText = 'مكتمل';
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green[50]!;
        break;
      case 5:
        statusText = 'ملغي';
        statusColor = Colors.red[800]!;
        statusBgColor = Colors.red[50]!;
        break;
      case 6:
        statusText = 'مرفوض';
        statusColor = Colors.red[800]!;
        statusBgColor = Colors.red[50]!;
        break;
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
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag, color: Colors.blue[800], size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'رقم الطلب: #${id.toString().substring(0, 8)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              Text(
                'طريقة الدفع: $payWay',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              Text(
                'التاجر: $merchantName',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              Text(
                'الخدمة: $serviceSubCategoryName',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.grey[300], height: 1),
                const SizedBox(height: 16),
                
                // Products Loop
                ...products.map((p) {
                   final pName = p['productName'] ?? 'منتج';
                   final pQty = p['quantity'] ?? 0;
                   final pImg = p['productImageUrl'];
                   
                   String finalImg = '';
                   if (pImg != null && pImg.isNotEmpty) {
                      if (pImg.startsWith('http')) {
                        finalImg = pImg;
                      } else {
                         finalImg = "${ApiConstants.baseUrl}${pImg.startsWith('/') ? '' : '/'}$pImg";
                      }
                   }

                   return Padding(
                     padding: const EdgeInsets.only(bottom: 12.0),
                     child: Row(
                       children: [
                         Container(
                           width: 50,
                           height: 50,
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(8),
                             color: Colors.grey[200],
                           ),
                           child: finalImg.isNotEmpty 
                             ? ClipRRect(
                                 borderRadius: BorderRadius.circular(8),
                                 child: Image.network(
                                   finalImg,
                                   fit: BoxFit.cover,
                                   errorBuilder: (_,__,___) => const Icon(Icons.image, color: Colors.grey),
                                 ),
                               ) 
                             : const Icon(Icons.shopping_bag, color: Colors.grey),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 pName,
                                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                               ),
                               Text(
                                 'الكمية: $pQty',
                                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   );
                }).toList(),

                const SizedBox(height: 12),
                Divider(color: Colors.grey[200]),
                Row(
                  children: [
                     const Text('الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold)),
                     const Spacer(),
                     Text('$price جنيه', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 16)),
                  ],
                ),
                
                // Track Order Button
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingScreen(
                            orderId: id.toString(),
                            customerName: order['customerName'] ?? 'العميل',
                            totalAmount: (num.tryParse(price.toString()) ?? 0).toDouble(),
                            specialization: 'طلب شراء',
                            orderStatus: status,
                            technicianName: merchantName,
                            technicianPhone: order['merchantPhoneNumber'] ?? order['technicianPhone'],
                            merchantPhone: order['merchantPhoneNumber'],
                            address: order['address'],
                            customerPhone: order['customerPhoneNumber'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.track_changes, color: Colors.blue),
                    label: const Text(
                      'متابعة الطلب',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                // Rating Button (only for status 4 - completed)
                if (status == 4) ...[
                  const SizedBox(height: 12),
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
                        'تقييم الطلب',
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
}
