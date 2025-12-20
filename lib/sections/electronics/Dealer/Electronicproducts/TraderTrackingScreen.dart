import 'package:flutter/material.dart';
import '/sections/ElectronicPaymentScreen.dart'; // تأكد من المسار الصحيح
import '/sections/GeneralRatingScreen.dart'; // تأكد من المسار الصحيح

class TraderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String customerName;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String? paymentMethod;
  final String? deliveryAddress;
  final String? phoneNumber;

  const TraderTrackingScreen({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    this.paymentMethod,
    this.deliveryAddress,
    this.phoneNumber,
  });

  @override
  State<TraderTrackingScreen> createState() => _TraderTrackingScreenState();
}

class _TraderTrackingScreenState extends State<TraderTrackingScreen> {
  int _currentStep = 0;
  bool _isDelivered = false;
  bool _isConfirmed = false;
  bool _isPaid = false;
  bool _showRatingButton = false;
  String _selectedPaymentMethod = 'كاش'; // القيمة الافتراضية
  final double _deliveryCost = 30.0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'تم الطلب',
      'icon': Icons.shopping_bag_outlined,
      'description': 'تم تأكيد عملية الشراء',
      'time': 'الآن'
    },
    {
      'title': 'انتظار الدفع',
      'icon': Icons.payment,
      'description': 'في انتظار تأكيد الدفع',
      'time': 'بانتظار الدفع'
    },
    {
      'title': 'تم الدفع',
      'icon': Icons.credit_card,
      'description': 'تم استلام المبلغ بنجاح',
      'time': 'خلال دقائق'
    },
    {
      'title': 'جاري التوصيل',
      'icon': Icons.local_shipping_outlined,
      'description': 'المندوب في الطريق إليك',
      'time': 'خلال 12 ساعة'
    },
    {
      'title': 'تم التوصيل',
      'icon': Icons.check_circle_outlined,
      'description': 'تم التسليم بنجاح',
      'time': 'تم التسليم'
    },
    {
      'title': 'تم التأكيد',
      'icon': Icons.verified,
      'description': 'تم تأكيد الجهاز بدون عيوب',
      'time': 'تم التأكيد'
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _currentStep = 1); // انتظار الدفع
    }
  }

  void _showPaymentOptions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "اختر طريقة الدفع",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // خيار كاش
              _buildPaymentOption('كاش', Icons.money, 'cash'),
              const SizedBox(height: 12),

              // خيار إلكتروني
              _buildPaymentOption('إلكتروني', Icons.credit_card, 'electronic'),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("إلغاء"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _processPaymentSelection();
                      },
                      child: const Text("متابعة"),
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

  Widget _buildPaymentOption(String title, IconData icon, String method) {
    bool isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE8F5E8) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Color(0xFF2E7D32) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF2E7D32) : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Color(0xFF2E7D32) : Colors.grey[700],
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }

  void _processPaymentSelection() {
    if (_selectedPaymentMethod == 'electronic') {
      // الانتقال لشاشة الدفع الإلكتروني
      _navigateToElectronicPayment();
    } else {
      // الدفع كاش - اكمال العملية مباشرة
      _completeCashPayment();
    }
  }

  void _navigateToElectronicPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElectronicPaymentScreen(
          orderId: widget.orderId,
          amount: widget.totalAmount + _deliveryCost,
          serviceType: "طلب من المتجر",
        ),
      ),
    ).then((value) {
      // عند العودة من شاشة الدفع
      if (value == true && mounted) {
        _completeElectronicPayment();
      } else {
        // إذا تم إلغاء الدفع
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إلغاء عملية الدفع"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _completeCashPayment() {
    // محاكاة عملية الدفع النقدي
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 20),
              const Text(
                "جاري تأكيد الدفع النقدي...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // إغلاق dialog التحميل

      setState(() {
        _isPaid = true;
        _currentStep = 2; // تم الدفع
      });

      _showPaymentSuccess();
      _continueAfterPayment();
    });
  }

  void _completeElectronicPayment() {
    setState(() {
      _isPaid = true;
      _currentStep = 2; // تم الدفع
    });

    _showPaymentSuccess();
    _continueAfterPayment();
  }

  void _showPaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_selectedPaymentMethod == 'electronic'
            ? "تم الدفع الإلكتروني بنجاح!"
            : "تم تأكيد الدفع النقدي!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _continueAfterPayment() async {
    // 1. جاري التوصيل
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _currentStep = 3);
    }

    // 2. تم التوصيل
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _currentStep = 4;
        _isDelivered = true;
      });
    }
  }

  void _confirmDelivery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified, color: Colors.green),
            SizedBox(width: 8),
            Text("تأكيد الاستلام"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("هل تم استلام الجهاز وهو بحالة جيدة؟"),
            SizedBox(height: 8),
            Text(
              "برجاء التأكد من:\n• سلامة الجهاز\n• عدم وجود عيوب\n• مطابقة المواصفات",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("لاحقاً"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isConfirmed = true;
                _currentStep = 5;
                _showRatingButton = true; // إظهار زر التقييمات
              });
              _showSuccessMessage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("نعم، تم التأكيد"),
          ),
        ],
      ),
    );
  }

  void _navigateToRatingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralRatingScreen(),
      ),
    );
  }

  Widget _buildRatingButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _navigateToRatingScreen,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'تقييم الخدمة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
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
        content: const Text("هل أنت متأكد من إلغاء هذا الطلب؟"),
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

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم تأكيد الاستلام بنجاح - شكراً لثقتك!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCancellationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم إلغاء الطلب بنجاح"),
        backgroundColor: Colors.orange,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  // الدوال المساعدة
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            "${amount.toStringAsFixed(2)} جنيه",
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
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
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (!isLast)
                Container(
                  height: 60,
                  width: 2,
                  color: connectorColor,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      'جاري التنفيذ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "تتبع حالة الطلب",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange[700],
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_currentStep < 2)
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white),
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
              Color(0xFFFFF8E1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // بطاقة معلومات الطلب
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "الطلب #${widget.orderId}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isConfirmed
                                    ? Colors.green[50]
                                    : (_isPaid
                                        ? Colors.blue[50]
                                        : Colors.orange[50]),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isConfirmed
                                      ? Colors.green
                                      : (_isPaid ? Colors.blue : Colors.orange),
                                ),
                              ),
                              child: Text(
                                _isConfirmed
                                    ? "مكتمل"
                                    : (_isPaid ? "تم الدفع" : "بانتظار الدفع"),
                                style: TextStyle(
                                  color: _isConfirmed
                                      ? Colors.green
                                      : (_isPaid ? Colors.blue : Colors.orange),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            Icons.person, "العميل", widget.customerName),
                        if (widget.phoneNumber != null)
                          _buildInfoRow(
                              Icons.phone, "الهاتف", widget.phoneNumber!),
                        if (widget.deliveryAddress != null)
                          _buildInfoRow(Icons.location_on, "العنوان",
                              widget.deliveryAddress!),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildPriceRow("سعر المنتجات", widget.totalAmount),
                        _buildPriceRow("سعر التوصيل", _deliveryCost),
                        _buildPriceRow("المبلغ الإجمالي",
                            widget.totalAmount + _deliveryCost,
                            isTotal: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // المحتوى الرئيسي
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // تفاصيل المنتجات
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.shopping_basket,
                                        color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                      "المنتجات المطلوبة",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...widget.items.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return Container(
                                    margin: EdgeInsets.only(
                                        bottom: index == widget.items.length - 1
                                            ? 0
                                            : 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${index + 1}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "الكمية: ${item['quantity']}",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // زر الدفع (يظهر فقط في مرحلة انتظار الدفع)
                        if (_currentStep == 1 && !_isPaid)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "يتطلب الطلب إتمام عملية الدفع",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _showPaymentOptions,
                                      icon: const Icon(Icons.payment,
                                          color: Colors.white),
                                      label: const Text(
                                        "إتمام الدفع الآن",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[600],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // تتبع حالة الطلب (Timeline)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.timeline, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text(
                                      "حالة تتبع الطلب",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                ..._steps.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final step = entry.value;
                                  return _buildStep(
                                    title: step['title']!,
                                    icon: step['icon']!,
                                    description: step['description']!,
                                    time: step['time']!,
                                    isCompleted: index < _currentStep,
                                    isActive: index == _currentStep,
                                    isLast: index == _steps.length - 1,
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // زر تأكيد الاستلام
                        if (_currentStep == 4 && !_isConfirmed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _confirmDelivery,
                                icon: const Icon(Icons.delivery_dining,
                                    color: Colors.white),
                                label: const Text(
                                  "تأكيد استلام الجهاز",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // زر التقييمات (يظهر بعد انتهاء الطلب)
                        if (_showRatingButton) _buildRatingButton(),
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
