import 'package:flutter/material.dart';
import '/sections/ElectronicPaymentScreen.dart';
import '/sections/GeneralRatingScreen.dart';

class MaintenanceTrackingScreen extends StatefulWidget {
  final String orderId;
  final String deviceName;
  final String customerName;
  final String? phoneNumber;
  final String issueDescription;
  final double serviceCost;

  const MaintenanceTrackingScreen({
    super.key,
    required this.orderId,
    required this.deviceName,
    required this.customerName,
    this.phoneNumber,
    required this.issueDescription,
    required this.serviceCost,
  });

  @override
  State<MaintenanceTrackingScreen> createState() =>
      _MaintenanceTrackingScreenState();
}

class _MaintenanceTrackingScreenState extends State<MaintenanceTrackingScreen> {
  int _currentStep = 0;
  bool _maintenanceCompleted = false;
  bool _deviceReturned = false;
  bool _paymentCompleted = false;
  bool _showPaymentOptions = false;
  bool _showRatingButton = false; // إضافة متغير لزر التقييم
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'تم استلام الجهاز',
      'icon': Icons.inventory_2,
      'description': 'تم استلام الجهاز في مركز الصيانة',
      'time': 'اليوم'
    },
    {
      'title': 'في انتظار الصيانة',
      'icon': Icons.build,
      'description': 'جاري فحص وتشخيص الجهاز',
      'time': 'خلال 24 ساعة'
    },
    {
      'title': 'جاري الصيانة',
      'icon': Icons.engineering,
      'description': 'يتم إصلاح الجهاز حالياً',
      'time': 'خلال 48 ساعة'
    },
    {
      'title': 'تم الإصلاح',
      'icon': Icons.check_circle,
      'description': 'تم إصلاح الجهاز بنجاح',
      'time': 'تم الإصلاح'
    },
    {
      'title': 'انتظار الدفع',
      'icon': Icons.payment,
      'description': 'في انتظار سداد قيمة الصيانة',
      'time': 'بانتظار الدفع'
    },
    {
      'title': 'تم الدفع',
      'icon': Icons.credit_card,
      'description': 'تم سداد المبلغ بنجاح',
      'time': 'تم الدفع'
    },
    {
      'title': 'تم تسليم الجهاز',
      'icon': Icons.local_shipping,
      'description': 'تم تسليم الجهاز للعميل',
      'time': 'تم التسليم'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startMaintenanceProcess();
  }

  void _startMaintenanceProcess() async {
    // بدء عملية الصيانة تلقائياً
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _currentStep = 1); // في انتظار الصيانة
    }

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _currentStep = 2); // جاري الصيانة
    }

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _currentStep = 3; // تم الإصلاح
        _maintenanceCompleted = true;
      });
      _showMaintenanceCompleteDialog();
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _currentStep = 4); // انتظار الدفع
    }
  }

  void _showMaintenanceCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                "تم إصلاح الجهاز بنجاح!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "تم إصلاح ${widget.deviceName} بنجاح\nتكلفة الإصلاح: ${widget.serviceCost} جنيه",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendRepairCompletionMessage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("تم الإرسال للعميل"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendRepairCompletionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("تم إرسال رسالة للعميل ${widget.customerName} بإتمام الصيانة"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _sendDeliveryMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("تم إرسال رسالة للعميل ${widget.customerName} باستلام الجهاز"),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPaymentOptionss() {
    setState(() {
      _showPaymentOptions = true;
    });
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });

    if (method == 'الكتروني') {
      _navigateToElectronicPayment();
    } else if (method == 'كاش') {
      _processCashPayment();
    }
  }

  void _navigateToElectronicPayment() {
    // الانتقال إلى شاشة الدفع الإلكتروني
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElectronicPaymentScreen(
          orderId: widget.orderId,
          amount: widget.serviceCost,
          serviceType: "صيانة ${widget.deviceName}",
        ),
      ),
    ).then((value) {
      // عند العودة من شاشة الدفع، إذا تم الدفع بنجاح
      if (value == true && mounted) {
        _completePayment();
      } else {
        // إذا لم يتم الدفع أو تم الإلغاء
        setState(() {
          _selectedPaymentMethod = null;
        });
      }
    });
  }

  void _processCashPayment() {
    // معالجة الدفع النقدي
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.money,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                "الدفع النقدي",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "تم اختيار الدفع النقدي\nسيتم استلام المبلغ عند تسليم الجهاز\nالمبلغ: ${widget.serviceCost} جنيه",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedPaymentMethod = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("إلغاء"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _completePayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("تأكيد"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completePayment() {
    setState(() {
      _paymentCompleted = true;
      _currentStep = 5; // تم الدفع
      _showPaymentOptions = false;
    });
    _completeOrder();
  }

  void _completeOrder() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _currentStep = 6; // تم التسليم
        _deviceReturned = true;
        _showRatingButton = true; // إظهار زر التقييم بعد التسليم
      });
      _sendDeliveryMessage();

      // عرض رسالة تشجيعية للتقييم بعد ثواني
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        _showRatingEncouragement();
      }
    }
  }

  void _showRatingEncouragement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("شكراً لاستخدامك خدماتنا! نرجو تقييم الخدمة"),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: "تقييم الآن",
          textColor: Colors.white,
          onPressed: _navigateToRatingScreen,
        ),
      ),
    );
  }

  void _navigateToRatingScreen() {
    // الانتقال إلى شاشة التقييم
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralRatingScreen(),
      ),
    ).then((value) {
      // عند العودة من شاشة التقييم
      if (value == true && mounted) {
        // إذا تم التقييم بنجاح
        setState(() {
          _showRatingButton = false; // إخفاء زر التقييم بعد التقييم
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("شكراً لتقييمك للخدمة!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _skipRating() {
    setState(() {
      _showRatingButton = false; // إخفاء زر التقييم
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("يمكنك تقييم الخدمة لاحقاً من خلال صفحة الطلبات"),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text("إلغاء الطلب"),
          ],
        ),
        content: const Text("هل أنت متأكد من إلغاء طلب الصيانة؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("تراجع"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCancellationMessage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("نعم، إلغاء"),
          ),
        ],
      ),
    );
  }

  void _showCancellationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم إلغاء طلب الصيانة بنجاح"),
        backgroundColor: Colors.orange,
      ),
    );

    // العودة للشاشة السابقة بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  Widget _buildStep({
    required String title,
    required IconData icon,
    required String description,
    required String time,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    Color iconColor = isCompleted
        ? Colors.green
        : (isActive ? Colors.orange : Colors.grey[400]!);
    Color textColor = isCompleted
        ? Colors.green
        : (isActive ? Colors.orange : Colors.grey[600]!);
    Color connectorColor = isCompleted ? Colors.green : Colors.grey[300]!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : (isActive
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.grey[100]),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor,
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              if (!isLast)
                Container(
                  height: 50,
                  width: 2,
                  color: connectorColor,
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      'جاري التنفيذ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            "${price.toStringAsFixed(2)} جنيه",
            style: TextStyle(
              fontSize: 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String title, String subtitle, IconData icon,
      Color color, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : color.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isSelected ? color : Colors.black,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color, size: 20)
            : const Icon(Icons.radio_button_unchecked, size: 20),
        onTap: () => _selectPaymentMethod(title),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "تتبع حالة الصيانة",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // زر إلغاء الطلب (يظهر فقط قبل الدفع)
          if (_currentStep < 5)
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white, size: 22),
              onPressed: _cancelOrder,
              tooltip: "إلغاء الطلب",
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFF5F9FF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // بطاقة معلومات الصيانة
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "طلب الصيانة #${widget.orderId}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _deviceReturned
                                    ? Colors.green[50]
                                    : (_paymentCompleted
                                        ? Colors.blue[50]
                                        : Colors.orange[50]),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _deviceReturned
                                      ? Colors.green
                                      : (_paymentCompleted
                                          ? Colors.blue
                                          : Colors.orange),
                                ),
                              ),
                              child: Text(
                                _deviceReturned
                                    ? "مكتمل"
                                    : (_paymentCompleted
                                        ? "تم الدفع"
                                        : "قيد الصيانة"),
                                style: TextStyle(
                                  color: _deviceReturned
                                      ? Colors.green
                                      : (_paymentCompleted
                                          ? Colors.blue
                                          : Colors.orange),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                            Icons.person, "العميل", widget.customerName),
                        _buildInfoRow(Icons.phone, "الجهاز", widget.deviceName),
                        if (widget.phoneNumber != null)
                          _buildInfoRow(
                              Icons.phone, "الهاتف", widget.phoneNumber!),
                        _buildInfoRow(Icons.description, "العطل",
                            widget.issueDescription),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _buildPriceRow("تكلفة الصيانة", widget.serviceCost,
                            isTotal: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // المحتوى الرئيسي
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // مسار التتبع
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.track_changes,
                                        color: Colors.green, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      "مسار تتبع الصيانة",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Column(
                                  children:
                                      List.generate(_steps.length, (index) {
                                    return _buildStep(
                                      title: _steps[index]['title'],
                                      icon: _steps[index]['icon'],
                                      description: _steps[index]['description'],
                                      time: _steps[index]['time'],
                                      isCompleted: index <= _currentStep,
                                      isActive: index == _currentStep,
                                      isLast: index == _steps.length - 1,
                                    );
                                  }),
                                ),

                                // زر الدفع - يظهر بعد اكتمال الصيانة وقبل الدفع
                                if (_maintenanceCompleted &&
                                    !_paymentCompleted &&
                                    !_showPaymentOptions)
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _showPaymentOptionss,
                                      icon: const Icon(Icons.payment, size: 22),
                                      label: const Text(
                                        "اختر طريقة الدفع",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 3,
                                      ),
                                    ),
                                  ),

                                // خيارات الدفع
                                if (_showPaymentOptions && !_paymentCompleted)
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "اختر طريقة الدفع:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildPaymentMethodCard(
                                          'الكتروني',
                                          'الدفع عبر التطبيق',
                                          Icons.credit_card,
                                          Colors.blue,
                                          _selectedPaymentMethod == 'الكتروني',
                                        ),
                                        const SizedBox(height: 10),
                                        _buildPaymentMethodCard(
                                          'كاش',
                                          'الدفع نقداً عند الاستلام',
                                          Icons.money,
                                          Colors.green,
                                          _selectedPaymentMethod == 'كاش',
                                        ),
                                        const SizedBox(height: 16),
                                        if (_selectedPaymentMethod != null)
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (_selectedPaymentMethod ==
                                                    'الكتروني') {
                                                  _navigateToElectronicPayment();
                                                } else if (_selectedPaymentMethod ==
                                                    'كاش') {
                                                  _processCashPayment();
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    _selectedPaymentMethod ==
                                                            'الكتروني'
                                                        ? Colors.blue
                                                        : Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                "متابعة الدفع ${_selectedPaymentMethod == 'الكتروني' ? 'إلكتروني' : 'نقدي'}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                // زر التقييم - يظهر بعد اكتمال الطلب
                                if (_showRatingButton)
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.orange, size: 20),
                                            SizedBox(width: 6),
                                            Text(
                                              "تقييم الخدمة",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "ساعدنا في تحسين خدماتنا من خلال تقييم تجربتك",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: _skipRating,
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "تخطي التقييم",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed:
                                                    _navigateToRatingScreen,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "تقييم الخدمة",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
