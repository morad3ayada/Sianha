import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'شهري';
  final List<String> _periods = ['يومي', 'أسبوعي', 'شهري', 'سنوي'];
  bool _isLoading = false;

  Map<String, dynamic> _statsData = {
    'totalEarnings': 0.0,
    'totalDiscounts': 0.0,
    'completedOrders': 0,
    'cancelledOrders': 0,
    'averageRating': 0.0,
    'totalCustomers': 0,
    'responseRate': 0,
    'completionRate': 0,
    'monthlyGrowth': 0.0,
    'topService': 'لا يوجد بيانات',
  };

  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final apiClient = ApiClient();
      // Fetch from my-jobs instead of my-stats
      final response = await apiClient.get(ApiConstants.technicianMyJobs, token: token);
      print("📊 Jobs for Stats Response: $response");

      if (mounted && response is List) {
        // Calculate Stats locally
        final allJobs = response;
        
        // Filter Completed Jobs (Status == 4)
        final completedJobs = allJobs.where((job) {
          final status = job['orderStatus'] ?? job['status'];
          return status == 4 || status == '4';
        }).toList();

        // Filter Cancelled Jobs (Status == 5 || 6)
        final cancelledJobs = allJobs.where((job) {
          final status = job['orderStatus'] ?? job['status'];
          return status == 5 || status == 6 || status == '5' || status == '6';
        }).toList();

        // Calculate Totals
        double totalRevenue = 0.0;
        for (var job in completedJobs) {
          final price = _parseUrl(job['totalPrice'] ?? job['price'] ?? job['amount']);
          totalRevenue += price;
        }

        // Logic: 40% Deductions
        final double totalDiscounts = totalRevenue * 0.40;
        final double netEarnings = totalRevenue - totalDiscounts;

        // Calculate Ratings (if available)
        double totalRating = 0.0;
        int ratingCount = 0;
        for (var job in completedJobs) {
          if (job['rating'] != null || job['previousRating'] != null) {
            final r = _parseUrl(job['rating'] ?? job['previousRating']);
            if (r > 0) {
              totalRating += r;
              ratingCount++;
            }
          }
        }
        final double averageRating = ratingCount > 0 ? totalRating / ratingCount : 5.0; // Default to 5 if no ratings

        // Unique Customers
        final uniqueCustomers = allJobs.map((j) => j['customerName'] ?? j['customer']).toSet().length;

        setState(() {
          _statsData = {
            'totalEarnings': netEarnings, // Show Net Earnings as main figure? Or Total? User said "Net is Total - Discount"
            'totalRevenue': totalRevenue, // Keeping track of gross
            'totalDiscounts': totalDiscounts,
            'completedOrders': completedJobs.length,
            'cancelledOrders': cancelledJobs.length,
            'averageRating': averageRating,
            'totalCustomers': uniqueCustomers,
            'responseRate': 100, // Placeholder
            'completionRate': allJobs.isNotEmpty ? ((completedJobs.length / allJobs.length) * 100).toInt() : 0,
            'monthlyGrowth': 0.0, // Placeholder
            'topService': _calculateTopService(completedJobs),
          };

          // Recent Transactions (Take last 5)
          _recentTransactions = allJobs.take(5).map((t) {
             final status = t['orderStatus'] ?? t['status'];
             // Determine type based on status, or just show completed as earnings
             final isCompleted = status == 4 || status == '4';
             final amount = _parseUrl(t['totalPrice'] ?? t['price'] ?? t['amount']);
             
              return {
              'customer': t['customerName'] ?? 'عميل',
              'service': t['serviceSubCategoryName'] ?? t['serviceName'] ?? 'خدمة',
              'amount': amount,
              'date': _formatDate(t['createdAt'] ?? t['date']),
              'type': isCompleted ? 'earning' : 'pending', 
            };
          }).toList().cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("❌ Error fetching jobs stats: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _calculateTopService(List<dynamic> jobs) {
    if (jobs.isEmpty) return 'لا يوجد بيانات';
    final Map<String, int> counts = {};
    for (var job in jobs) {
      final service = job['serviceSubCategoryName'] ?? job['serviceName'] ?? 'خدمة';
      counts[service] = (counts[service] ?? 0) + 1;
    }
    var topService = jobs.first['serviceSubCategoryName'] ?? 'خدمة';
    var maxCount = 0;
    counts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        topService = key;
      }
    });
    return topService;
  }

  double _parseUrl(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Media Query (تم إضافة متغير للوصول إليه إذا لزم الأمر في تصميمات أخرى)
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('الإحصائيات'),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20
        ),
        actions: [
          // PopupMenuButton<String>(
          //   onSelected: (value) {
          //     setState(() {
          //       _selectedPeriod = value;
          //       // Here you would typically re-fetch stats based on period
          //     });
          //   },
          //   // itemBuilder: (context) => _periods.map((period) {
          //   //   return PopupMenuItem(
          //   //     value: period,
          //   //     child: Text(period),
          //   //   );
          //   // }).toList(),
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     child: Row(
          //       children: [
          //         Text(_selectedPeriod),
          //         const Icon(Icons.arrow_drop_down),
          //       ],
          //     ),
          //   ),
          // ),
       
        ],
      ),
      // تأكد من استخدام SingleChildScrollView لتغليف الـ body
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة الإيرادات الرئيسية
            _buildEarningsCard(),

            const SizedBox(height: 16),

            // شبكة الإحصائيات (GridView) - مصدر المشكلة
            _buildStatsGrid(),

            const SizedBox(height: 16),

            // معدلات الأداء
            _buildPerformanceRates(),

            const SizedBox(height: 16),

            // آخر المعاملات
            _buildRecentTransactions(),

            // مسافة سفلية إضافية للتأكد من عدم وجود تجاوز عند الحافة
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // دوال البناء الفرعية
  // -------------------------

  Widget _buildEarningsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإيرادات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '+${_statsData['monthlyGrowth']}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${(_statsData['totalEarnings'] as double).toStringAsFixed(2)} ر.س',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'صافي الأرباح (بعد خصم 40%)',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEarningItem('الإجمالي',
                    '${(_statsData['totalRevenue'] ?? 0.0).toStringAsFixed(2)} ر.س'),
                _buildEarningItem(
                    'الخصومات (40%)', '${(_statsData['totalDiscounts'] as double).toStringAsFixed(2)} ر.س'),
                _buildEarningItem(
                    'الطلبات', _statsData['completedOrders'].toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      // 🎯 التعديل الأخير: تم تقليل childAspectRatio إلى 0.90 لتوفير مساحة عمودية أكبر
      // هذا هو الحل النهائي لمشكلة التجاوز في GridView
      childAspectRatio: 0.90,
      children: [
        _buildStatCard(
          '✅ الطلبات المكتملة',
          _statsData['completedOrders'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          '❌ الطلبات الملغاة',
          _statsData['cancelledOrders'].toString(),
          Icons.cancel,
          Colors.red,
        ),
        _buildStatCard(
          '⭐ التقييم العام',
          _statsData['averageRating'].toString(),
          Icons.star,
          Colors.amber,
        ),
        _buildStatCard(
          '👥 العملاء',
          _statsData['totalCustomers'].toString(),
          Icons.people,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معدلات الأداء',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceRow(
              'معدل الاستجابة',
              (_statsData['responseRate'] as num).toInt(),
              Colors.blue,
            ),
            _buildPerformanceRow(
              'معدل الإنجاز',
              (_statsData['completionRate'] as num).toInt(),
              Colors.green,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الخدمة الأكثر طلباً',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _statsData['topService'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
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

  Widget _buildPerformanceRow(String label, int rate, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$rate%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: rate / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'آخر المعاملات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._recentTransactions
                .map((transaction) => _buildTransactionItem(transaction)),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // عرض كل المعاملات
                },
                child: const Text('عرض كل المعاملات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // الأيقونة (ثابتة العرض)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction['type'] == 'earning'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction['type'] == 'earning'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: transaction['type'] == 'earning'
                  ? Colors.green
                  : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Expanded لعمود النصوص (العميل والخدمة)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['customer'],
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  transaction['service'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // المبلغ والتاريخ (ثابت العرض)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction['amount']} ر.س',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction['type'] == 'earning'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              Text(
                transaction['date'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
