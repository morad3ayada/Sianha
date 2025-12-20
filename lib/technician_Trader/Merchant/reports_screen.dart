// 📊 شاشة التقارير الشخصية للفني
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _TechnicianReportsScreenState();
}

class _TechnicianReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'اليوم';
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  bool _isLoading = false;
  List<dynamic> _allOrders = [];
  List<dynamic> _filteredOrders = [];
  double _totalSales = 0.0;
  int _ordersCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _fetchOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
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

        setState(() {
          _allOrders = orders;
        });
        _filterOrders();
      }
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _appFee = 0.0;
  double _netProfit = 0.0;

  void _filterOrders() {
    final now = DateTime.now();
    _filteredOrders = _allOrders.where((order) {
      // Keys from OrdersScreen: orderDate, createdAt
      final dateStr = order['createdOn'] ?? order['orderDate'] ?? order['createdAt'];
      
      if (dateStr == null) return true; // Default include if no date to allow seeing something
      
      final orderDate = DateTime.tryParse(dateStr);
      if (orderDate == null) return true; // Include if parse fails to allow debug

      if (_selectedPeriod == 'اليوم') {
        return orderDate.year == now.year && 
               orderDate.month == now.month && 
               orderDate.day == now.day;
      } else if (_selectedPeriod == 'الأسبوع') {
        final difference = now.difference(orderDate).inDays;
        return difference <= 7;
      } else if (_selectedPeriod == 'الشهر') {
        return orderDate.year == now.year && orderDate.month == now.month;
      }
      return true;
    }).toList();

    // Calculate Stats
    _totalSales = 0.0;
    _ordersCount = _filteredOrders.length;
    
    for (var order in _filteredOrders) {
      // Keys from OrdersScreen: price, totalAmount
      final priceVal = order['totalPrice'] ?? order['price'] ?? order['totalAmount'] ?? 0;
      _totalSales += double.tryParse(priceVal.toString()) ?? 0.0;
    }

    // Logic: Discounts = 30% of Sales (App Fee), Profit = Sales - Discounts
    _appFee = _totalSales * 0.30;
    _netProfit = _totalSales - _appFee;
    
    // Trigger animation re-run for effect
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
        : AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _animation.value) * 50),
            child: Opacity(
              opacity: _animation.value,
              child: Column(
                children: [
                  // الهيدر مع زر الرجوع
                  _buildHeader(),

                  // الفلترة
                  _buildPeriodFilter(),

                  // الإحصائيات الشخصية
                  _buildPersonalStats(),

                  // التفاصيل
                  _buildTransactionsList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // الهيدر مع زر الرجوع
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFD700), Color(0xFFFFC400)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تقريري المالي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عرض المبيعات والخصومات والمكافآت والأرباح',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // فلترة الفترات
  Widget _buildPeriodFilter() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['اليوم', 'الأسبوع', 'الشهر'].map((period) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = period;
                _filterOrders();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: _selectedPeriod == period
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFC400)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                color: _selectedPeriod == period ? null : Colors.transparent,
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: _selectedPeriod == period
                      ? Colors.white
                      : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // الإحصائيات الشخصية
  Widget _buildPersonalStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView( // Added scroll just in case of overflow on small screens
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                'المبيعات', '${_totalSales.toStringAsFixed(1)}', Icons.shopping_cart, Colors.purple),
            const SizedBox(width: 15),
            _buildStatItem(
                'الربح', '${_netProfit.toStringAsFixed(1)}', Icons.attach_money, Colors.green),
            const SizedBox(width: 15),
            _buildStatItem('العمولة', '${_appFee.toStringAsFixed(1)}', Icons.discount, Colors.orange),
            const SizedBox(width: 15),
            _buildStatItem(
                'الطلبات', '$_ordersCount', Icons.list_alt, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 80, // Fixed width for alignment in row
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
             maxLines: 1,
          ),
        ],
      ),
    );
  }

  // قائمة المعاملات
  Widget _buildTransactionsList() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // عنوان القسم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[100]!),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'سجل المعاملات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_filteredOrders.length} معاملة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // القائمة
            Expanded(
              child: _filteredOrders.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد معاملات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
                            child: const Icon(Icons.shopping_bag, color: Color(0xFFFF8C00)),
                          ),
                          title: Text(order['customerName'] ?? 'عميل', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(order['createdOn'] != null 
                              ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(order['createdOn']))
                              : 'بدون تاريخ'),
                          trailing: Text(
                            '${order['totalPrice'] ?? order['price'] ?? 0} ر.س',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
