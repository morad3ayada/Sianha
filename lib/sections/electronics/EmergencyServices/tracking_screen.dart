import 'package:flutter/material.dart';
import '/sections/ElectronicPaymentScreen.dart'; // تأكد من المسار الصحيح
import '/sections/GeneralRatingScreen.dart'; // تأكد من المسار الصحيح

class TrackingScreen extends StatefulWidget {
  final String problemType;
  final String totalPrice;

  const TrackingScreen({
    super.key,
    required this.problemType,
    required this.totalPrice,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _currentStep = 0;
  String _arrivalETA = 'سيتم التحديد قريباً';
  bool _showPaymentOptions = false;
  bool _paymentCompleted = false;
  bool _showRatingButton = false;
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'قيد الانتظار', 'icon': Icons.pending_actions},
    {'title': 'تم التوصيل', 'icon': Icons.directions_car},
    {'title': 'تم حل المشكلة', 'icon': Icons.done_all},
    {'title': 'انتظار الدفع', 'icon': Icons.payment},
    {'title': 'تم الدفع', 'icon': Icons.credit_card},
    {'title': 'مكتمل', 'icon': Icons.check_circle},
  ];

  @override
  void initState() {
    super.initState();
    _simulateOrderProgress();
  }

  void _simulateOrderProgress() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentStep = 1;
          _arrivalETA = 'الوصول خلال 15 دقيقة';
        });
      }
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _currentStep = 2;
        });
      }
    });
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        setState(() {
          _currentStep = 3;
          _showPaymentOptions = true;
        });
      }
    });
  }

  Widget _buildStep({
    required String title,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green
                        : isActive
                            ? Colors.blue
                            : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!isLast)
                  Container(
                    height: 50,
                    width: 3,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    if (isActive && title == 'تم التوصيل')
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _arrivalETA,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
          orderId: 'ORD${DateTime.now().microsecondsSinceEpoch}',
          amount: double.parse(widget.totalPrice),
          serviceType: widget.problemType,
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
                "تم اختيار الدفع النقدي\nسيتم استلام المبلغ عند التسليم\nالمبلغ: ${widget.totalPrice} جنيه",
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
      _currentStep = 4; // تم الدفع
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
          _currentStep = 5; // مكتمل
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
        duration: const Duration(seconds: 3),
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
          "تتبع طلبك",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطلب
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "معلومات الطلب",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "نوع الخدمة:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.problemType,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "التكلفة:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${widget.totalPrice} جنيه",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // مسار التتبع
            const Text(
              "حالة الطلب",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: List.generate(_steps.length, (index) {
                  return _buildStep(
                    title: _steps[index]['title'],
                    icon: _steps[index]['icon'],
                    isCompleted: index <= _currentStep,
                    isActive: index == _currentStep,
                    isLast: index == _steps.length - 1,
                  );
                }),
              ),
            ),

            const SizedBox(height: 30),

            // معلومات الفني
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "معلومات الفني",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person, "اسم الفني", "أحمد محمود"),
                  _buildInfoRow(Icons.phone, "رقم الهاتف", "01012345678"),
                  _buildInfoRow(Icons.timer, "وقت الوصول", _arrivalETA),
                  _buildInfoRow(Icons.star, "التقييم", "4.8/5"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // خيارات الدفع - تظهر بعد حل المشكلة
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
                        color: Colors.blue,
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
                            if (_selectedPaymentMethod == 'الكتروني') {
                              _navigateToElectronicPayment();
                            } else if (_selectedPaymentMethod == 'كاش') {
                              _processCashPayment();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedPaymentMethod == 'الكتروني'
                                    ? Colors.blue
                                    : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                        Icon(Icons.star, color: Colors.orange, size: 20),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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

            const SizedBox(height: 20),

            // أزرار التحكم
            Column(
              children: [
                if (_currentStep < 4)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // إلغاء الطلب
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('إلغاء الطلب'),
                            content: const Text('هل أنت متأكد من إلغاء الطلب؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('لا'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('نعم'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "إلغاء الطلب",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "العودة للرئيسية",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
