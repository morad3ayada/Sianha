import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'TechnicianOrderTrackingScreen.dart';
import 'lib/sections/maintenance/OrderTrackingScreen.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  List<dynamic> _myJobs = [];
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMyJobs();
    // Auto-refresh every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchMyJobs(showLoading: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMyJobs({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.technicianMyJobs, token: token);
      print("📦 My Jobs Response: $response");

      if (mounted) {
        setState(() {
          if (response is List) {
            _myJobs = response.map<Map<String, dynamic>>((item) {
              final data = item as Map<String, dynamic>;
              return {
                ...data,
                'id': data['id'] ?? data['Id'],
                'customer': data['customerName'] ?? data['CustomerName'] ?? data['customer'] ?? data['customerInfo']?['name'] ?? 'عميل',
                'service': data['serviceSubCategoryName'] ?? data['serviceName'] ?? data['serviceCategoryName'] ?? 'خدمة',
                'problemDescription': data['problemDescription'] ?? data['notes'] ?? 'لا يوجد وصف',
                'address': data['address'] ?? data['Address'] ?? data['customerInfo']?['address'] ?? 'غير محدد',
                'dateTime': _formatDateTime(data['createdAt'] ?? data['time'] ?? data['date']),
                'payWay': data['payWay'] ?? data['PayWay'] ?? 0,
                'amount': data['totalPrice'] ?? data['price'] ?? '0',
                'status': data['orderStatus'] ?? data['status'] ?? 0,
                'customerPhoneNumber': data['customerPhoneNumber'] ?? data['phoneNumber'] ?? data['customerPhone'] ?? data['customerInfo']?['phone'],
              };
            }).toList();

            // Custom Sorting: InProgress (3) -> Pending (0) -> Completed (4) -> Rejected (6) -> Others
            _myJobs.sort((a, b) {
              final statusA = a['status'] is int ? a['status'] : int.tryParse(a['status'].toString()) ?? 0;
              final statusB = b['status'] is int ? b['status'] : int.tryParse(b['status'].toString()) ?? 0;

              int getPriority(int status) {
                switch (status) {
                  case 2: return 0; // Accepted (Highest as requested)
                  case 3: return 1; // InProgress
                  case 0: return 2; // Pending
                  case 4: return 3; // Completed
                  case 6: return 4; // Rejected
                  default: return 5; // Others
                }
              }

              return getPriority(statusA).compareTo(getPriority(statusB));
            });
          }
        });
      }
    } catch (e) {
      print("❌ Error fetching jobs: $e");
    } finally {
      if (mounted && showLoading) setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '--:--';
    try {
      final date = DateTime.parse(dateStr);
      final year = date.year;
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      int hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$year-$month-$day $hour:$minute $period';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text('سجل طلباتي'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber[700], // Updated Color
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20 // Updated Text Color
        ),
        actions: [
          IconButton(
            onPressed: () => _fetchMyJobs(showLoading: true),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchMyJobs(showLoading: false),
              child: _myJobs.isEmpty
                  ? Center(
                      child: SingleChildScrollView( // Added to allow pull-to-refresh even when empty
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('لا توجد طلبات سابقة', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            const SizedBox(height: 100), // Spacing to ensure scrollability
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _myJobs.length,
                      itemBuilder: (context, index) {
                        return JobCard(
                          job: _myJobs[index],
                          onStatusUpdated: () => _fetchMyJobs(showLoading: true), // Refresh list after update
                        );
                      },
                    ),
            ),
    );
  }
}

class JobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final VoidCallback onStatusUpdated;

  const JobCard({super.key, required this.job, required this.onStatusUpdated});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _isExpanded = false;
  bool _isLoading = false;

  Future<void> _updateStatus(int newStatus, {double? price}) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final apiClient = ApiClient();
      final payload = {
        "orderId": widget.job['id'],
        "status": newStatus,
        if (price != null) "price": price,
      };

      print("🚀 Updating Status to $newStatus: ${ApiConstants.updateOrderStatus}");
      print("📦 Payload: $payload");

      await apiClient.post(ApiConstants.updateOrderStatus, payload, token: token);

      if (mounted) {
        Navigator.pop(context); // Close dialog
        widget.onStatusUpdated(); // Refresh parent list
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(newStatus == 4 ? 'تم إتمام الطلب بنجاح' : 'تم رفض الطلب')),
        );
      }
    } catch (e) {
      print("❌ Error updating status: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديث الحالة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCompletionDialog() {
    final TextEditingController priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال التكلفة النهائية للطلب:'),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر',
                border: OutlineInputBorder(),
                suffixText: 'جنية',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              if (priceController.text.isNotEmpty) {
                final price = double.tryParse(priceController.text);
                if (price != null) {
                  // Navigator.pop(context); // Removed to prevent double pop
                  _updateStatus(4, price: price);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال سعر صحيح')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال السعر')),
                );
              }
            },
            child: const Text('تأكيد وإتمام'),
          ),
        ],
      ),
    );
  }

  void _showFollowUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('متابعة الطلب'),
        content: const Text('حدد الإجراء الذي تريد اتخاذه لهذا الطلب:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _updateStatus(6), // 6 = Reject
            child: const Text('رفض الطلب'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context); // Close parent dialog
              _showCompletionDialog();
            }, // 4 = Complete
            child: const Text('إتمام الطلب'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب #${(widget.job['id']?.toString().length ?? 0) > 6 ? widget.job['id'].toString().substring(0, 6) : widget.job['id'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                _buildStatusBadge(widget.job['status']),
              ],
            ),
            const SizedBox(height: 12),
            
            // Basic Info
            _buildInfoRow(Icons.person, widget.job['customer']),
            _buildInfoRow(Icons.home_repair_service, widget.job['problemDescription']),
            _buildInfoRow(Icons.monetization_on, '${widget.job['amount']} جنية'),
            _buildInfoRow(Icons.access_time, widget.job['dateTime'] ?? ''),

            // Expanded Details
            if (_isExpanded) ...[
              const Divider(height: 20),
              _buildInfoRow(Icons.phone, widget.job['customerPhoneNumber'] ?? 'لا يوجد رقم'),
              _buildInfoRow(Icons.location_on, widget.job['address']),
              _buildInfoRow(Icons.payment, (widget.job['payWay'] == 0 || widget.job['payWay'] == '0') ? 'كاش' : 'اونلاين'),
              
              if (widget.job['problemImageUrl'] != null && widget.job['problemImageUrl'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.job['problemImageUrl'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                
              // Track Order Button - Show for ALL orders
              const SizedBox(height: 16),
              
              // Only hide "Follow Up" (Update Status) button for completed/rejected if needed, 
              // but user said "Track Order Location" button for ALL.
              // I will keep the "Follow Up" button logic as is (hidden for 4/6) if that was the intent,
              // but the user specific request " زرار تتبع موقع الطلب ده خليه لكل الطلبات" refers to the map button.
              // However, the code block I'm replacing covers both.
              
              if ((widget.job['status'] is int ? widget.job['status'] : int.tryParse(widget.job['status'].toString()) ?? 0) != 4 && 
                  (widget.job['status'] is int ? widget.job['status'] : int.tryParse(widget.job['status'].toString()) ?? 0) != 6) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _showFollowUpDialog,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('متابعة الطلب'),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Track Location Button - Visible for ALL orders
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    print("🚀 Opening Tracking for Job: ${widget.job}"); // Log Data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TechnicianOrderTrackingScreen(
                          orderId: widget.job['id'].toString(),
                          customerName: widget.job['customer'],
                          totalAmount: double.tryParse(widget.job['amount'].toString()) ?? 0.0,
                          specialization: widget.job['service'],
                          orderStatus: widget.job['status'] is int ? widget.job['status'] : int.tryParse(widget.job['status'].toString()) ?? 0,
                          address: widget.job['address'],
                          customerPhone: widget.job['customerPhoneNumber'],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('مراحل الطلب'),
                ),
              ),
            ],

            const SizedBox(height: 8),
            
            // Expand/Collapse Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton( // Changed back to ElevatedButton
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700], // Match requested color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isExpanded ? 'إخفاء التفاصيل' : 'عرض التفاصيل'),
                    const SizedBox(width: 8),
                    Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  ],
                ),
              ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(dynamic status) {
    Color color;
    String text;
    int statusId = 0;

    if (status is int) {
      statusId = status;
    } else if (status is String) {
      statusId = int.tryParse(status) ?? 0;
    }
    
    switch (statusId) {
      case 0: color = Colors.orange; text = 'قيد الانتظار'; break;
      case 1: color = Colors.blue; text = 'تم التعيين'; break;
      case 2: color = Colors.blue; text = 'مقبول'; break;
      case 3: color = Colors.purple; text = 'قيد التنفيذ'; break;
      case 4: color = Colors.green; text = 'مكتمل'; break;
      case 5: color = Colors.red; text = 'ملغي'; break;
      case 6: color = Colors.red; text = 'مرفوض'; break;
      default: color = Colors.grey; text = 'غير معروف';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
