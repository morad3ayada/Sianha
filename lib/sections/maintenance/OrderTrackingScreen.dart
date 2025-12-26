import 'package:flutter/material.dart';
import '../ElectronicPaymentScreen.dart';
import '../GeneralRatingScreen.dart';
// import '/sections/CancelOrderScreen.dart'; // Removed as we use API directly
import '../../home/home_sections.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String customerName;
  final double totalAmount;
  final String specialization;
  final String? technicianName;
  final String? technicianPhone;
  final String? merchantPhone;
  final String? arrivalTime;
  final int orderStatus;
  final String? address;
  final String? customerPhone;
  final bool isFromConfirmation;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.totalAmount,
    required this.specialization,
    this.technicianName,
    this.technicianPhone,
    this.merchantPhone,
    this.arrivalTime,
    required this.orderStatus,
    this.address,
    this.customerPhone,
    this.isFromConfirmation = false,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _currentStep = 0;
  bool _orderCancelled = false;
  String? _cancellationReason;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
  }

  void _initializeStatus() {
    final status = widget.orderStatus;
    // 0: Pending, 1: Assigned, 2: Accepted, 3: InProgress, 4: Completed, 5: Cancelled, 6: Rejected

    if (status == 5 || status == 6) {
      _orderCancelled = true;
      _cancellationReason = status == 5 ? "تم الإلغاء" : "تم رفض الطلب";
      return;
    }

    setState(() {
      if (status >= 4) {
        _currentStep = 4;
      } else {
        _currentStep = status;
      }
    });
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
        return type; // Return the name directly if it's already a display name
    }
  }

  // 1. دالة اختيار طريقة الدفع
  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر طريقة الدفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // خيار الدفع نقداً
            _buildPaymentOption(
              icon: Icons.money,
              title: 'الدفع نقداً',
              subtitle: 'ادفع نقداً عند الاستلام',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                _processCashPayment();
              },
            ),

            const SizedBox(height: 15),

            // خيار الدفع الإلكتروني
            _buildPaymentOption(
              icon: Icons.credit_card,
              title: 'الدفع الإلكتروني',
              subtitle: 'ادفع عبر البطاقة أو المحفظة الإلكترونية',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _navigateToElectronicPayment();
              },
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  // 2. معالجة الدفع النقدي
  void _processCashPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'تم تأكيد الدفع نقداً',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            Text(
              'المبلغ: ${widget.totalAmount.toStringAsFixed(2)} جنيه',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'سيقوم المندوب/التاجر باستلام المبلغ نقداً عند التوصيل',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (mounted) setState(() => _currentStep = 4);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'تم',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. الدفع الإلكتروني
  void _navigateToElectronicPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElectronicPaymentScreen(
          orderId: widget.orderId,
          amount: widget.totalAmount,
          serviceType: widget.specialization,
        ),
      ),
    ).then((result) {
      if (result == true) {
        if (mounted) setState(() => _currentStep = 4);
      }
    });
  }

  // 4. API-based Cancel Order
  Future<void> _cancelOrder() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد أنك تريد إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final apiClient = ApiClient();

      final url = "${ApiConstants.cancelOrder}/${widget.orderId}";
      
      await apiClient.post(
        url,
        {}, // Empty body
        token: token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء الطلب بنجاح'), backgroundColor: Colors.green),
        );
        setState(() {
          _orderCancelled = true;
          _cancellationReason = "تم الإلغاء من قبل العميل";
        });
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreens()), 
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إلغاء الطلب: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 5. دالة التوجيه إلى شاشة التقييم
  void _navigateToRatingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralRatingScreen(orderId: widget.orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'تتبع الطلب',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: !widget.isFromConfirmation,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOrderInfoCard(),
            const SizedBox(height: 20),
            _buildTechnicianInfoCard(),
            const SizedBox(height: 20),
            _buildTrackingStepper(),
            const SizedBox(height: 20),
            if (_orderCancelled) _buildCancellationStatus(),
            const SizedBox(height: 20),
            if (!_orderCancelled)
              Column(
                children: [
                   if (_currentStep < 4)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                      onPressed: _cancelOrder,
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'إلغاء الطلب',
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

                  if (_currentStep < 4) const SizedBox(height: 10),

                   // Payment button logic (removed for now as per previous state, assuming handled elsewhere or auto)

                  if (_currentStep == 4)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToRatingScreen,
                        icon: const Icon(Icons.star, color: Colors.white),
                        label: const Text(
                          'تقييم الخدمة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                ],
              ),
            
            if (widget.isFromConfirmation) ...[
               const SizedBox(height: 20),
               SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreens()), 
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text(
                    'العودة للصفحة الرئيسية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
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
                'تم إلغاء الطلب',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_cancellationReason != null)
            Text('سبب الإلغاء: $_cancellationReason'),
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
            // _buildInfoRow('رقم الطلب:', widget.orderId, Icons.confirmation_number), // Removed
            // _buildInfoRow('العميل:', ...), // Removed
            _buildInfoRow('رقم العميل:', (widget.customerPhone != null && widget.customerPhone!.isNotEmpty) ? widget.customerPhone! : 'غير متوفر', Icons.phone_android),
            _buildInfoRow('العنوان:', (widget.address != null && widget.address!.isNotEmpty) ? widget.address! : 'غير محدد', Icons.location_on),
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

  Widget _buildTechnicianInfoCard() {
    final String techName = widget.technicianName ?? 'لم يتم التعيين بعد';
    final String techPhone = widget.merchantPhone ?? widget.technicianPhone ?? '---';

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
                  child: Icon(Icons.store, color: Colors.yellow[800]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'معلومات التاجر/الفني',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('اسم التاجر/الفني :', techName, Icons.storefront),
            _buildInfoRow('رقم الهاتف:', techPhone, Icons.phone),
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
                  child: Icon(Icons.local_shipping, color: Colors.yellow[800]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'حالة التوصيل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Updated steps for Merchant/Product Order Flow
            _buildStep('تم إرسال الطلب', 'تم إرسال طلبك للتاجر بنجاح', 0),
            _buildStep('قيد المراجعة/التجهيز', 'يقوم التاجر بتجهيز طلبك', 1),
            _buildStep('تم قبول الطلب', 'الطلب جاهز وجاري ترتيب التوصيل', 2),
            _buildStep('جاري التوصيل', 'مندوب التوصيل في الطريق إليك', 3),
            _buildStep('تم الاستلام', 'تم استلام الطلب واكتمال العملية', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String description, int stepNumber) {
    bool isCompleted = stepNumber <= _currentStep;
    bool isCurrent = stepNumber == _currentStep;
    bool isCancelled = _orderCancelled;

    Color stepColor = isCancelled
        ? Colors.grey
        : isCompleted
            ? Colors.yellow[700]!
            : Colors.grey[400]!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCancelled
            ? Colors.grey[50]
            : (isCompleted ? Colors.yellow[50] : Colors.grey[50]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCancelled
              ? Colors.grey[300]!
              : (isCompleted ? Colors.yellow[300]! : Colors.grey[300]!),
        ),
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
              isCancelled
                  ? Icons.cancel
                  : (isCompleted ? Icons.check : Icons.local_shipping),
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
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCancelled
                        ? Colors.grey[600]
                        : (isCompleted ? Colors.black87 : Colors.grey[600]),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isCancelled
                        ? Colors.grey[500]
                        : (isCompleted ? Colors.grey[600] : Colors.grey[500]),
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
}
