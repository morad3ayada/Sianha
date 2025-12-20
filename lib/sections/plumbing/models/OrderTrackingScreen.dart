import 'package:flutter/material.dart';
import '/sections/ElectronicPaymentScreen.dart'; // تأكد من المسار الصحيح
import '/sections/GeneralRatingScreen.dart'; // تأكد من المسار الصحيح

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String storeName;
  final String storePhone;
  final String deliveryName;
  final String deliveryPhone;
  final double orderAmount;
  final String purchaseInvoice;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.storeName,
    required this.storePhone,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.orderAmount,
    required this.purchaseInvoice,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _currentStep = 0;
  bool _showPaymentOptions = false;
  bool _paymentCompleted = false;
  bool _showRatingButton = false;
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'تم استلام الطلب',
      'icon': Icons.shopping_cart_checkout,
      'description': 'تم استلام طلبك بنجاح',
      'time': 'الآن'
    },
    {
      'title': 'تأكيد الطلب',
      'icon': Icons.verified,
      'description': 'جاري تأكيد تفاصيل الطلب',
      'time': 'خلال 10 دقائق'
    },
    {
      'title': 'تجهيز الطلب',
      'icon': Icons.inventory_2,
      'description': 'يتم تجهيز طلبك الآن',
      'time': 'خلال 30 دقيقة'
    },
    {
      'title': 'تم التسليم للمندوب',
      'icon': Icons.delivery_dining,
      'description': 'تم تسليم الطلب للمندوب',
      'time': 'جاري التوصيل'
    },
    {
      'title': 'في انتظار الدفع',
      'icon': Icons.payment,
      'description': 'بانتظار سداد قيمة الطلب',
      'time': 'بانتظار الدفع'
    },
    {
      'title': 'تم الدفع',
      'icon': Icons.credit_card,
      'description': 'تم سداد قيمة الطلب',
      'time': 'تم الدفع'
    },
    {
      'title': 'مكتمل',
      'icon': Icons.check_circle,
      'description': 'تم تسليم الطلب بنجاح',
      'time': 'مكتمل'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startOrderProcess();
  }

  void _startOrderProcess() async {
    // محاكاة عملية الطلب تلقائياً
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _currentStep = 1); // تأكيد الطلب
    }

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _currentStep = 2); // تجهيز الطلب
    }

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() => _currentStep = 3); // تم التسليم للمندوب
    }

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _currentStep = 4); // انتظار الدفع
    }
  }

  void _showPaymentSelection() {
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
          amount: widget.orderAmount,
          serviceType: "طلب من ${widget.storeName}",
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
                "تم اختيار الدفع النقدي\nسيتم استلام المبلغ عند التسليم\nالمبلغ: ${widget.orderAmount} جنيه",
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
      _showRatingButton = true; // إظهار زر التقييم بعد الدفع
    });

    // عرض رسالة نجاح الدفع
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("تم الدفع بنجاح!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // الانتقال للخطوة النهائية بعد ثواني
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentStep = 6; // مكتمل
        });
      }
    });

    // عرض رسالة تشجيعية للتقييم بعد ثواني
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _showRatingEncouragement();
      }
    });
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

  void _contactStore() {
    // محاكاة الاتصال بالمحل
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("جاري الاتصال بـ ${widget.storeName}"),
        backgroundColor: Colors.yellow[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _contactDelivery() {
    // محاكاة الاتصال بالمندوب
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("جاري الاتصال بالمندوب ${widget.deliveryName}"),
        backgroundColor: Colors.yellow[700],
        duration: const Duration(seconds: 2),
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
        : (isActive ? Colors.yellow[700]! : Colors.grey[400]!);
    Color textColor = isCompleted
        ? Colors.green
        : (isActive ? Colors.yellow[700]! : Colors.grey[600]!);
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
                          ? Colors.yellow[700]!.withOpacity(0.1)
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
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.yellow[700]!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.yellow[700]!),
                    ),
                    child: Text(
                      'جاري التنفيذ',
                      style: TextStyle(
                        color: Colors.yellow[700],
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
          "تتبع الطلب",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFFBEB),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "الطلب #${widget.orderId}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _paymentCompleted
                                    ? Colors.green[50]
                                    : Colors.yellow[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _paymentCompleted
                                      ? Colors.green
                                      : Colors.yellow[700]!,
                                ),
                              ),
                              child: Text(
                                _paymentCompleted ? "مكتمل" : "قيد التنفيذ",
                                style: TextStyle(
                                  color: _paymentCompleted
                                      ? Colors.green
                                      : Colors.yellow[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                            Icons.store, "اسم المحل", widget.storeName,
                            onTap: _contactStore),
                        _buildInfoRow(
                            Icons.phone, "رقم التليفون", widget.storePhone,
                            onTap: _contactStore),
                        _buildInfoRow(
                            Icons.person, "اسم المندوب", widget.deliveryName,
                            onTap: _contactDelivery),
                        _buildInfoRow(
                            Icons.phone, "رقم المندوب", widget.deliveryPhone,
                            onTap: _contactDelivery),
                        _buildInfoRow(Icons.receipt, "فاتورة الشراء",
                            widget.purchaseInvoice),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Colors.grey),
                        const SizedBox(height: 12),
                        _buildPriceRow("المبلغ الإجمالي", widget.orderAmount,
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
                        // مسار التتبع
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.timeline,
                                        color: Colors.black, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      "مسار تتبع الطلب",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
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
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // خيارات الدفع (تظهر فقط بعد تجهيز الطلب)
                        if (_currentStep == 4 &&
                            !_paymentCompleted &&
                            !_showPaymentOptions)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.payment,
                                          color: Colors.black, size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        "سداد قيمة الطلب",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "طلبك جاهز للتسليم. يرجى سداد مبلغ ${widget.orderAmount} جنيه",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _showPaymentSelection,
                                      icon: Icon(Icons.payment,
                                          color: Colors.white),
                                      label: const Text("اختيار طريقة الدفع",
                                          style: TextStyle(fontSize: 16)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow[700],
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
                                ],
                              ),
                            ),
                          ),

                        // خيارات الدفع
                        if (_showPaymentOptions && !_paymentCompleted)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "اختر طريقة الدفع:",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
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
                                            _selectedPaymentMethod == 'الكتروني'
                                                ? Colors.blue
                                                : Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
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

                        // زر التقييم - يظهر بعد اكتمال الدفع
                        if (_showRatingButton)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.orange, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      "تقييم الخدمة",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "تخطي التقييم",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _navigateToRatingScreen,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
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

                        // رسالة الاستلام النهائية
                        if (_paymentCompleted && _currentStep == 6)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.celebration,
                                    color: Colors.green, size: 40),
                                const SizedBox(height: 8),
                                const Text(
                                  "تم تسليم الطلب بنجاح! 🎉",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "شكراً لثقتك - نتمنى لك تجربة سعيدة",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),
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

  Widget _buildInfoRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.yellow[700], size: 20),
            const SizedBox(width: 12),
            Text(
              "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(Icons.phone, color: Colors.yellow[700], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            "${amount.toStringAsFixed(2)} جنيه",
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.yellow[700] : Colors.green,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
