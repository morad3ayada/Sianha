import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'RatingsScreen.dart';
import 'ProfileScreen.dart';
import 'StatisticsScreen.dart';
import 'request_details_screen.dart';
import 'location_screen.dart';
import 'notifications_screen.dart';
import 'my_jobs_screen.dart';
import 'TechnicianReportScreen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  List<dynamic> _myOrders = [];
  bool _isLoading = false;
  int _currentIndex = 0;

  // Stats Data
  Map<String, dynamic> _todayStats = {
    'totalRevenue': 0.0,
    'todayRequests': 0,
    'todayCompleted': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchMyOrders();
    _fetchTodayStats();
  }

  Future<void> _fetchTodayStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.technicianMyJobs, token: token);
      print("📊 Today Stats Response: $response");

      if (mounted && response is List) {
        final now = DateTime.now();
        final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

        final todayJobs = response.where((job) {
          final dateStr = job['createdAt'] ?? job['time'] ?? job['date'];
          if (dateStr == null) return false;
          try {
            // Check if date string starts with YYYY-MM-DD or parse it
            if (dateStr.toString().startsWith(todayStr)) return true;
             final date = DateTime.parse(dateStr);
             final jobDateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
             return jobDateStr == todayStr;
          } catch (e) {
            return false;
          }
        }).toList();

        final completedToday = todayJobs.where((job) {
           final status = job['orderStatus'] ?? job['status'];
           return status == 4 || status == '4';
        }).toList();

        double revenue = 0.0;
        for (var job in completedToday) {
           final price = double.tryParse((job['totalPrice'] ?? job['price'] ?? job['amount']).toString()) ?? 0.0;
           revenue += price;
        }

        setState(() {
          _todayStats = {
            'totalRevenue': revenue,
            'todayRequests': todayJobs.length,
            'todayCompleted': completedToday.length,
          };
        });
      }
    } catch (e) {
      print("❌ Error fetching today stats: $e");
    }
  }


  Future<void> _fetchMyOrders() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.technicianAssignedOrders, token: token);
      print("📦 Assigned Orders Response: $response");

      if (mounted) {
        setState(() {
          if (response is List) {
            _myOrders = response.map<Map<String, dynamic>>((item) {
              final data = item as Map<String, dynamic>;
              return {
                // Preserve original data
                ...data,
                // Normalize keys for UI
                'id': data['id'] ?? data['Id'],
                'customer': data['customerName'] ?? data['CustomerName'] ?? data['customer'] ?? data['clientName'],
                'service': data['serviceSubCategoryName'] ?? data['serviceName'] ?? data['ServiceName'] ?? data['service'],
                'address': data['address'] ?? data['Address'] ?? data['location'],
                'time': _formatTimeOnly(data['createdAt'] ?? data['time']),
                'date': data['date'] ?? data['Date'] ?? data['orderDate'] ?? '',
                'payment': (data['isPaid'] == true || data['paymentStatus'] == 'paid') ? 'paid' : 'unpaid',
                'payWay': data['payWay'] ?? data['PayWay'] ?? 0, // 0: Cash, 1: Online
                'amount': data['totalPrice'] ?? data['price'] ?? '0',
                'status': data['status'] ?? data['Status'] ?? 'pending',
              };
            }).toList();
          }
        });
      }
    } catch (e) {
      print("❌ Error fetching orders: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTimeOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--:--';
    try {
      final date = DateTime.parse(dateStr);
      int hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '$hour:$minute $period';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'طلباتي',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    _fetchMyOrders();
                    _fetchTodayStats();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.report_problem_outlined, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TechnicianReportScreen(),
                      ),
                    );
                  },
                ),
                // Notification Icon Removed
              ],
            )
          : null,
      body: _currentIndex == 0
          ? Column(
              children: [
                _buildStatsBar(),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : _buildOrdersList(),
                ),
              ],
            )
          : _buildOtherScreens(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildOrdersList() {
    if (_myOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد طلبات خاصة بك حالياً',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myOrders.length,
      itemBuilder: (context, index) {
        final request = _myOrders[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب #${(request['id']?.toString().length ?? 0) > 6 ? request['id'].toString().substring(0, 6) : request['id'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (request['payWay'] == 0 || request['payWay'] == '0')
                        ? Colors.orange[100] // Cash
                        : Colors.blue[100],  // Online
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (request['payWay'] == 0 || request['payWay'] == '0') ? 'كاش' : 'اونلاين',
                    style: TextStyle(
                      color: (request['payWay'] == 0 || request['payWay'] == '0')
                          ? Colors.orange[800]
                          : Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, request['customer'] ?? 'عميل غير محدد'),
            _buildInfoRow(Icons.home_repair_service, request['service'] ?? 'خدمة غير محددة'),
            _buildInfoRow(Icons.location_on, request['address'] ?? 'عنوان غير محدد'),
            _buildInfoRow(
                Icons.access_time,
                ' ${request['time'] ?? '--:--'}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showRequestDetails(request),
                    child: const Text('عرض التفاصيل'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildOtherScreens() {
    switch (_currentIndex) {
      case 1:
        return const StatisticsScreen();
      case 2:
        return const ProfileScreen();
      case 3:
        return const MyJobsScreen();
      default:
        return Container();
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.amber[700],
      unselectedItemColor: Colors.grey[600],
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), label: 'الإحصائيات'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'الملف الشخصي'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'طلباتي'),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('الحصيلة (اليوم)', '${(_todayStats['totalRevenue'] as double).toStringAsFixed(2)} جنية', Icons.account_balance_wallet),
          _buildStatItem('طلبات اليوم', '${_todayStats['todayRequests']}', Icons.today),
          _buildStatItem('مكتمل (اليوم)', '${_todayStats['todayCompleted']}', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  void _showRequestDetails(Map<String, dynamic> apiRequest) {
    // Normalize API data to match RequestDetailsScreen expectations
    final normalizedRequest = {
      'id': apiRequest['id'] ?? apiRequest['Id'],
      'service': apiRequest['serviceName'] ?? apiRequest['ServiceName'] ?? 'خدمة',
      'date': apiRequest['orderDate'] ?? apiRequest['OrderDate'] ?? '',
      'time': '', // Extract time if strictly needed, or leave empty
      'payment': (apiRequest['isPaid'] == true) ? 'paid' : 'unpaid',
      'priority': 'عادية', // Default
      'status': apiRequest['status'] ?? apiRequest['Status'] ?? 'pending',
      'customer': apiRequest['customerName'] ?? apiRequest['CustomerName'] ?? 'عميل',
      'phone': apiRequest['phoneNumber'] ?? apiRequest['PhoneNumber'] ?? 'غير متوفر',
      'governorate': apiRequest['governorateName'] ?? apiRequest['GovernorateName'] ?? '',
      'address': apiRequest['address'] ?? apiRequest['Address'] ?? '',
      'notes': apiRequest['notes'] ?? apiRequest['Notes'] ?? '',
      'previousRating': '0.0',
      'amount': apiRequest['totalPrice'] ?? apiRequest['TotalPrice'] ?? '0',
      ...apiRequest, // Pass all other raw data
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailsScreen(request: normalizedRequest),
      ),
    ).then((_) {
      // Refresh orders when returning from details screen
      _fetchMyOrders();
      _fetchTodayStats();
    });
  }
}
