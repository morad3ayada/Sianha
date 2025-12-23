import 'package:flutter/material.dart';
// import '/sections/CancelOrderScreen.dart'; // Removed as we use API directly
import '../../home/home_sections.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TechnicianOrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String customerName;
  final double totalAmount;
  final String specialization;
  final String? technicianName;
  final String? technicianPhone;
  final String? arrivalTime;
  final int orderStatus;
  final String? address;
  final String? customerPhone;

  const TechnicianOrderTrackingScreen({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.totalAmount,
    required this.specialization,
    this.technicianName,
    this.technicianPhone,
    this.arrivalTime,
    required this.orderStatus,
    this.address,
    this.customerPhone,
  }) : super(key: key);

  @override
  State<TechnicianOrderTrackingScreen> createState() => _TechnicianOrderTrackingScreenState();
}


class _TechnicianOrderTrackingScreenState extends State<TechnicianOrderTrackingScreen> {
  int _currentStatus = 0; // Store actual status ID
  bool _orderCancelled = false;
  String? _cancellationReason;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.orderStatus;
    _initializeStatus();
  }

  void _initializeStatus() {
    // 0: Pending, 1: Assigned, 2: Accepted, 3: Moving, 4: Completed
  }

  String _getSpecializationTitle(String type) {
    switch (type) {
      case 'electricity_home':
      case 'electricity':
        return 'كهربائي منازل';
      case 'plumbing_leak':
      case 'plumbing':
        return 'سباكة';
      case 'carpentry_furniture':
      case 'carpentry':
        return 'نجارة وموبيليا';
      case 'painting_decor':
      case 'painting':
        return 'دهانات ونقاشة';
      case 'ac_unit_repair':
      case 'ac':
        return 'تبريد وتكييف';
      case 'security_cameras':
        return 'كاميرات مراقبة';
      case 'cleaning_laundry':
        return 'نظافة وغسيل';
      default:
        return 'خدمة صيانة';
    }
  }

  Future<void> _updateStatus(int newStatus, {double? price}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final apiClient = ApiClient();

      final payload = {
        "orderId": widget.orderId,
        "status": newStatus,
        if (price != null) "price": price
      };

      print("🚀 Updating Status to $newStatus: ${ApiConstants.updateOrderStatus}");
      print("📦 Payload: $payload");

      await apiClient.post(ApiConstants.updateOrderStatus, payload, token: token);

      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(newStatus == 4 ? 'تم إتمام الطلب بنجاح' : 'تم تحديث الحالة بنجاح'), backgroundColor: Colors.green),
        );
        if (newStatus == 4) {
             Navigator.pop(context); 
        }
      }
    } catch (e) {
      print("❌ Error updating status: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحديث الحالة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // API-based Reject Order
  Future<void> _rejectOrder() async {
    final TextEditingController reasonController = TextEditingController();
    
    String? reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text('هل أنت متأكد أنك تريد رفض هذا الطلب؟'),
             const SizedBox(height: 10),
             TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                border: OutlineInputBorder(),
                hintText: 'أدخل سبب الرفض...',
              ),
              maxLines: 3,
             ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
               if (reasonController.text.trim().isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('الرجاء كتابة سبب الرفض')),
                 );
                 return;
               }
               Navigator.pop(context, reasonController.text.trim());
            },
            child: const Text('تأكيد الرفض', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (reason == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final apiClient = ApiClient();

      final payload = {
        "orderId": widget.orderId,
        "rejectionReason": reason
      };
      
      await apiClient.post(
        ApiConstants.rejectOrder,
        payload,
        token: token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض الطلب بنجاح'), backgroundColor: Colors.green),
        );
        setState(() {
          _orderCancelled = true; // reusing existing variable for UI state, could rename to _orderRejected if doing a full refactor but logical enough
          _cancellationReason = reason;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل رفض الطلب: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPriceDialog() {
    final TextEditingController priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إتمام الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('من فضلك أدخل السعر النهائي للخدمة:'),
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
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price != null && price > 0) {
                Navigator.pop(context);
                _updateStatus(4, price: price);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال سعر صحيح')),
                );
              }
            },
            child: const Text('تأكيد وإتمام'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'تتبع الطلب (فني)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOrderInfoCard(),
            const SizedBox(height: 20),
            _buildTrackingStepper(),
            const SizedBox(height: 20),
            if (_orderCancelled) _buildCancellationStatus(),
            const SizedBox(height: 20),
            if (!_orderCancelled)
              Column(
                children: [
                  if (_currentStatus < 4)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _rejectOrder,
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'رفض الطلب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStatus < 4) const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                         Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text(
                        'العودة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
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

  Widget _buildCancellationStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'تم رفض الطلب',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_cancellationReason != null)
            Text('سبب الرفض: $_cancellationReason'),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.yellow[700]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long, color: Colors.yellow[800]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'معلومات الطلب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                'رقم الطلب:', widget.orderId, Icons.confirmation_number),
            _buildInfoRow('العميل:', widget.customerName.isEmpty || widget.customerName == 'العميل' || widget.customerName == 'عميل' ? 'غير متوفر' : widget.customerName, Icons.person),
            _buildInfoRow('رقم العميل:', (widget.customerPhone == null || widget.customerPhone!.isEmpty) ? 'غير متوفر' : widget.customerPhone!, Icons.phone_android),
            _buildInfoRow('العنوان:', (widget.address == null || widget.address!.isEmpty) ? 'غير محدد' : widget.address!, Icons.location_on),
            _buildInfoRow(
                'المبلغ:',
                '${widget.totalAmount.toStringAsFixed(2)} جنيه',
                Icons.attach_money),
            _buildInfoRow('نوع الخدمة:',
                _getSpecializationTitle(widget.specialization), Icons.build),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow[700], size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStepper() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.track_changes, color: Colors.yellow[800]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تحديث حالة الطلب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildInteractiveStep(
              title: 'قبول الطلب',
              description: 'اضغط لقبول الطلب وبدء العمل',
              isActive: _currentStatus >= 2,
              isNext: _currentStatus < 2, 
              onTap: () {
                if (_currentStatus < 2) _updateStatus(2);
              },
            ),

            _buildInteractiveStep(
              title: 'التحرك للعميل',
              description: 'اضغط عند التحرك لموقع العميل',
              isActive: _currentStatus >= 3,
              isNext: _currentStatus == 2,
              onTap: () {
                if (_currentStatus == 2) _updateStatus(3);
              },
            ),

            _buildInteractiveStep(
              title: 'تم إنجاز العمل',
              description: 'اضغط عند الانتهاء لتحديد السعر',
              isActive: _currentStatus >= 4,
              isNext: _currentStatus == 3,
              onTap: () {
                 if (_currentStatus == 3) _showPriceDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveStep({
    required String title,
    required String description,
    required bool isActive,
    required bool isNext,
    required VoidCallback onTap,
  }) {
    // Restore Original Colors: Yellow/Gray
    Color stepColor = isActive ? Colors.yellow[700]! : (isNext ? Colors.yellow[400]! : Colors.grey[300]!);
    Color bgColor = isActive ? Colors.yellow[50]! : (isNext ? Colors.white : Colors.grey[50]!);
    
    // Icon Logic
    IconData icon = isActive ? Icons.check : (isNext ? Icons.touch_app : Icons.lock);

    return InkWell(
      onTap: (isNext && !isActive) ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: stepColor),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: stepColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isActive || isNext ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
             if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'اضغط',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

