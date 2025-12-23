import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // متغير لتخزين وقت التجهيز (يمكن أن يكون فارغاً)
  late String _preparationTime;
  // **متغير جديد لتتبع الحالة الرقمية**
  late int _currentStatusId; 
  // **متغير لعرض النص العربي للحالة**
  late String _currentStatusText;
  // **متغير لتغيير لون الحالة**
  late Color _currentStatusColor;

  @override
  void initState() {
    super.initState();
    _preparationTime = widget.order['preparationTime'] ?? '--';
    
    // Initialize Status ID
    if (widget.order['rawStatus'] != null && widget.order['rawStatus'] is int) {
      _currentStatusId = widget.order['rawStatus'];
    } else {
      // Fallback parsing or default
      _currentStatusId = 0; 
    }
    
    _updateStatusDisplay();
  }

  void _updateStatusDisplay() {
    switch (_currentStatusId) {
      case 0: // Pending
        _currentStatusText = 'قيد الانتظار';
        _currentStatusColor = Color(0xFFFFD700);
        break;
      case 1: // Assigned
        _currentStatusText = 'تم التعيين';
        _currentStatusColor = Colors.blue;
        break;
      case 2: // Accepted
        _currentStatusText = 'تم القبول';
        _currentStatusColor = Colors.teal;
        break;
      case 3: // InProgress
        _currentStatusText = 'قيد التنفيذ';
        _currentStatusColor = Colors.orange;
        break;
      case 4: // Completed
        _currentStatusText = 'مكتمل';
        _currentStatusColor = Colors.green;
        break;
      case 5: // Cancelled
        _currentStatusText = 'ملغي';
        _currentStatusColor = Colors.red;
        break;
      case 6: // Rejected
        _currentStatusText = 'مرفوض';
        _currentStatusColor = Colors.red[900]!;
        break;
      default:
        _currentStatusText = 'غير معروف';
        _currentStatusColor = Colors.grey;
    }
  }

  // 5. دالة تحديث الحالة في السيرفر
  Future<void> _updateStatusOnServer(int newStatus, {double? price}) async {
    try {
      // إظهار مؤشر تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)))),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final apiClient = ApiClient();

      if (token == null) {
        Navigator.pop(context);
        return;
      }

      final orderId = widget.order['rawId'];
      // استخراج السعر الحالي من البيانات المعروضة (سعر الوحدة أو الإجمالي)
      final currentPrice = price ?? double.tryParse(widget.order['amount']?.toString().replaceAll(' ج.م', '') ?? '0') ?? 0.0;

      print('🚀 Updating Order $orderId to status $newStatus with price $currentPrice');
      
      final response = await apiClient.put(
        ApiConstants.merchantUpdateOrderStatus,
        {
          "orderId": orderId.toString(),
          "status": newStatus,
          "price": currentPrice
        },
        token: token,
      );

      Navigator.pop(context); // إخفاء مؤشر التحميل

      if (response != null) {
        setState(() {
          _currentStatusId = newStatus;
          _updateStatusDisplay();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث حالة الطلب بنجاح'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحديث الحالة: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // دالة الرفض المتخصصة
  Future<void> _rejectOrderFromServer() async {
    final TextEditingController reasonController = TextEditingController();
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل أنت متأكد من رفض الطلب؟'),
            SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'سبب الرفض...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('رفض الطلب', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى كتابة سبب الرفض')));
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => Center(child: CircularProgressIndicator()),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final apiClient = ApiClient();
      final orderId = widget.order['rawId'];

      // استدعاء API الرفض المتخصص (POST)
      final response = await apiClient.post(
        ApiConstants.merchantRejectOrder,
        {
          "orderId": orderId.toString(),
          "rejectionReason": reason
        },
        token: token,
      );

      Navigator.pop(context);

      if (response != null) {
        setState(() {
          _currentStatusId = 6;
          _updateStatusDisplay();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم رفض الطلب بنجاح'), backgroundColor: Colors.green));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الرفض: $e'), backgroundColor: Colors.red));
    }
  }

  // 1. قبول الطلب
  void _confirmOrder() {
    _updateStatusOnServer(2); // Accepted
  }

  // 2. وضايف التنفيذ
  void _showPreparationTimeDialog() {
    _updateStatusOnServer(3); // InProgress
  }

  // 3. إتمام الطلب
  void _completeOrder() {
    _updateStatusOnServer(4); // Completed
  }

  @override
  Widget build(BuildContext context) {
    bool isCancelled = _currentStatusId == 5;
    bool isRejected = _currentStatusId == 6;
    bool isDoneOrCancelled = _currentStatusId >= 4;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.order['title'] ?? ''} - ${widget.order['items'] != null && (widget.order['items'] as List).isNotEmpty ? (widget.order['items'] as List)[0]['name'] : ''}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16, // Reduced size to fit both
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطلب الأساسية والمبلغ (يستخدم المتغيرات الجديدة)
            _buildOrderSummaryCard(context),

            SizedBox(height: 24),

            // معلومات العميل
            _buildCustomerAndAgentInfo(),

            SizedBox(height: 24),

            // عنوان خطوات التتبع
            Text(
              'حالة ومراحل تنفيذ الطلب 🚚',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            // خطوات التتبع الفعلية
            Container(
              padding: EdgeInsets.all(16),
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
              child: _buildTrackingSteps(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (!isCancelled && !isRejected && !isDoneOrCancelled) 
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: _rejectOrderFromServer,
              icon: Icon(Icons.cancel),
              label: Text('رفض الطلب نهائياً'),
            ),
          )
        : null,
    );
  }

  // 2. دالة بناء بطاقة ملخص الطلب
  Widget _buildOrderSummaryCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_cart, color: Colors.black, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'العميل: ${widget.order['customer']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'رقم الطلب: ${widget.order['id']}',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.order['amount'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _currentStatusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentStatusText,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. دالة بناء معلومات العميل فقط
  Widget _buildCustomerAndAgentInfo() {
    // محاولة استخراج معلومات العميل من عدة مصادر محتملة في الـ API
    final String name = widget.order['customerName'] ?? widget.order['customer'] ?? widget.order['customerInfo']?['name'] ?? 'غير متوفر';
    final String phone = widget.order['customerPhoneNumber'] ?? widget.order['customerPhone'] ?? widget.order['customerInfo']?['phone'] ?? '--';
    final String addr = widget.order['address'] ?? widget.order['customerInfo']?['address'] ?? 'غير متوفر';

    return Container(
      width: double.infinity,
      child: _buildInfoCard(
        title: 'معلومات العميل',
        icon: Icons.person,
        details: [
          _buildDetailRow('الاسم:', name),
          _buildDetailRow('العنوان:', addr),
          _buildDetailRow('الهاتف:', phone, isPhone: true),
        ],
        color: Colors.blue,
      ),
    );
  }

  // 4. دالة بناء بطاقة معلومات
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> details,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: color.withOpacity(0.5), height: 15),
          ...details,
        ],
      ),
    );
  }

  // 5. دالة بناء صف تفصيلي
  Widget _buildDetailRow(String label, String value, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                decoration:
                    isPhone ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. دالة بناء خطوات التتبع (متوافقة مع Enum OrderStatus)
  Widget _buildTrackingSteps() {
    Color activeColor = Color(0xFFFFD700);
    
    // Status Logic
    // 0: Pending, 1: Assigned, 2: Accepted, 3: InProgress, 4: Completed, 5: Cancelled, 6: Rejected
    bool isCancelled = _currentStatusId == 5;
    bool isRejected = _currentStatusId == 6;
    bool isDoneOrCancelled = _currentStatusId >= 4;

    List<Map<String, dynamic>> trackingSteps = [
      {
        'arabic_step': 'استلام الطلب',
        'completed': true,
        'active': true,
      },
      {
        'arabic_step': 'تم قبول الطلب',
        'completed': _currentStatusId >= 2 && !isCancelled && !isRejected,
        'active': _currentStatusId >= 2,
        'showAction': _currentStatusId == 0,
        'actionType': 'confirm',
      },
      {
        'arabic_step': 'قيد التنفيذ والتجهيز',
        'completed': _currentStatusId >= 3 && !isCancelled && !isRejected,
        'active': _currentStatusId >= 3,
        'showAction': _currentStatusId == 2,
        'actionType': 'start',
      },
      {
        'arabic_step': 'تم التسليم والاكتمال',
        'completed': _currentStatusId == 4,
        'active': _currentStatusId == 4,
        'showAction': _currentStatusId == 3,
        'actionType': 'complete',
      },
    ];

    // إضافة خطوة الرفض أو الإلغاء إذا حدث ذلك
    if (isCancelled || isRejected) {
      trackingSteps.add({
        'arabic_step': isCancelled ? 'تم إلغاء الطلب' : 'تم رفض الطلب',
        'completed': true,
        'active': true,
        'isError': true,
        'reason': widget.order['rejectionReason'] ?? '',
      });
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: trackingSteps.length,
      itemBuilder: (context, index) {
        final step = trackingSteps[index];
        bool isLast = index == trackingSteps.length - 1;
        bool isCompleted = step['completed'] ?? false;
        bool isError = step['isError'] ?? false;
        
        Widget? actionButton;
        if (step['showAction'] == true) {
           if (step['actionType'] == 'confirm') {
             actionButton = ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
               onPressed: _confirmOrder,
               child: Text('قبول الطلب', style: TextStyle(fontSize: 12, color: Colors.white)),
             );
           } else if (step['actionType'] == 'start') {
             actionButton = ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
               onPressed: _showPreparationTimeDialog,
               child: Text('بدء التنفيذ', style: TextStyle(fontSize: 12, color: Colors.white)),
             );
           } else if (step['actionType'] == 'complete') {
             actionButton = ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
               onPressed: _completeOrder,
               child: Text('إتمام الطلب', style: TextStyle(fontSize: 12, color: Colors.white)),
             );
           }
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicator
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isError ? Colors.red : (isCompleted ? activeColor : Colors.grey[300]),
                        shape: BoxShape.circle,
                      ),
                      child: isError 
                          ? Icon(Icons.close, color: Colors.white, size: 18)
                          : (isCompleted
                            ? Icon(Icons.check, color: Colors.black, size: 18)
                            : Center(
                                child: Text('${index + 1}',
                                    style: TextStyle(
                                        color: Colors.black54, fontWeight: FontWeight.bold)))),
                    ),
                    if (!isLast)
                      Container(
                        height: 50,
                        width: 2,
                        color: isCompleted ? activeColor : Colors.grey[300],
                      ),
                  ],
                ),
                SizedBox(width: 16),
                
                // Text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['arabic_step'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isError ? Colors.red : (isCompleted ? Colors.black : Colors.grey),
                          ),
                        ),
                        if (isError && step['reason'] != null && step['reason'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'السبب: ${step['reason']}',
                              style: TextStyle(fontSize: 13, color: Colors.red[700], fontStyle: FontStyle.italic),
                            ),
                          ),
                        if (actionButton != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: actionButton,
                          ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 7. دالة مساعدة لعرض رسائل النجاح
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
