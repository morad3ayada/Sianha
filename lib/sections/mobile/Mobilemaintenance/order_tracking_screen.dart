import 'package:flutter/material.dart';

// مسار افتراضي لشاشة الدفع. تأكد من إنشاء هذا الملف!
import '/sections/ElectronicPaymentScreen.dart';
import '/sections/GeneralRatingScreen.dart';

void main() {
  runApp(const MobileRepairTrackingApp());
}

class MobileRepairTrackingApp extends StatelessWidget {
  const MobileRepairTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تتبع صيانة الموبايل',
      theme: ThemeData(
        fontFamily: 'Tajawal',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MobileRepairTrackingPage(),
    );
  }
}

class MobileRepairTrackingPage extends StatefulWidget {
  const MobileRepairTrackingPage({super.key});

  @override
  State<MobileRepairTrackingPage> createState() =>
      _MobileRepairTrackingPageState();
}

class _MobileRepairTrackingPageState extends State<MobileRepairTrackingPage>
    with SingleTickerProviderStateMixin {
  final String _shopName = "الورشة السريعة للصيانة";
  final String _issueType = "تغيير شاشة و بطارية";
  final String _orderId = "REP789";
  final double _totalAmount = 350.0;

  List<Map<String, dynamic>> _trackingSteps = [
    {
      "title": "تم استلام الموبايل",
      "subtitle": "تم استلام الموبايل من قبل المندوب بنجاح",
      "details": {
        "المسؤول": "أحمد محمد",
        "الوقت": "10:30 ص",
        "التاريخ": "2023-10-15",
        "ملاحظات": "تم استلام الجهاز بحالة جيدة"
      },
      "isCompleted": false,
      "isActive": false,
      "isExpanded": false,
      "icon": Icons.phone_android_outlined,
      "color": Color(0xFF00C853),
      "gradient": [Color(0xFF00C853), Color(0xFF64DD17)],
    },
    {
      "title": "تم بدء فحص",
      "subtitle": "جاري فحص الجهاز لتحديد المشكلة بدقة",
      "details": {
        "المسؤول": "محمد علي",
        "الوقت": "11:45 ص",
        "التاريخ": "2023-10-15",
        "ملاحظات": "تم اكتشاف مشاكل في الشاشة والبطارية"
      },
      "isCompleted": false,
      "isActive": false,
      "isExpanded": false,
      "icon": Icons.search,
      "color": Color(0xFF2196F3),
      "gradient": [Color(0xFF2196F3), Color(0xFF03A9F4)],
    },
    {
      "title": "تم الصيانة",
      "subtitle": "الآن، تتم عملية الصيانة الفنية للجهاز",
      "details": {
        "المسؤول": "خالد محمود",
        "الوقت": "02:30 م",
        "التاريخ": "2023-10-15",
        "ملاحظات": "جاري استبدال الشاشة وإصلاح البطارية"
      },
      "isCompleted": false,
      "isActive": false,
      "isExpanded": false,
      "icon": Icons.build,
      "color": Color(0xFFFF9800),
      "gradient": [Color(0xFFFF9800), Color(0xFFFFB74D)],
    },
    {
      "title": "تم إرساله مع المندوب",
      "subtitle": "الموبايل الآن في طريقه إليك لتسليمه",
      "details": {
        "المسؤول": "محمود أحمد",
        "الوقت": "04:15 م",
        "التاريخ": "2023-10-15",
        "ملاحظات": "الجهاز جاهز للتسليم"
      },
      "isCompleted": false,
      "isActive": false,
      "isExpanded": false,
      "icon": Icons.delivery_dining,
      "color": Color(0xFF9C27B0),
      "gradient": [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
    },
    {
      "title": "الدفع",
      "subtitle": "في انتظار إتمام السداد لإكمال العملية",
      "details": {
        "المسؤول": "لم يتم التحديد",
        "الوقت": "--:--",
        "التاريخ": "--/--/----",
        "ملاحظات": "بانتظار اكتمال الصيانة"
      },
      "isCompleted": false,
      "isActive": false,
      "isExpanded": false,
      "icon": Icons.payments_outlined,
      "color": Color(0xFF607D8B),
      "gradient": [Color(0xFF607D8B), Color(0xFF90A4AE)],
    },
  ];

  late AnimationController _animationController;
  bool _showPaymentButton = false;
  bool _isPaymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _startStepAnimation();
  }

  void _startStepAnimation() async {
    for (int i = 0; i < _trackingSteps.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      setState(() {
        _trackingSteps[i]["isActive"] = true;
        for (int j = 0; j <= i; j++) {
          _trackingSteps[j]["isCompleted"] = true;
        }
        if (i == _trackingSteps.length - 1) {
          _showPaymentButton = true;
          _trackingSteps[i]["isExpanded"] = true;
        }
      });
      _animationController.forward(from: 0.0);
    }
  }

  void _completePayment() {
    setState(() {
      _isPaymentCompleted = true;
      _showPaymentButton = false;
    });
  }

  void _toggleExpanded(int index) {
    setState(() {
      _trackingSteps[index]["isExpanded"] =
          !_trackingSteps[index]["isExpanded"];
    });
  }

  void _restartAnimation() {
    setState(() {
      for (var step in _trackingSteps) {
        step["isCompleted"] = false;
        step["isActive"] = false;
        step["isExpanded"] = false;
      }
      _showPaymentButton = false;
      _isPaymentCompleted = false;
    });
    _startStepAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A237E),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "تتبع صيانة الموبايل",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF1A237E),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF1A237E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: _restartAnimation,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          _buildHeaderCard(),

          Expanded(
            child: Stack(
              children: [
                // Background Pattern
                _buildBackgroundPattern(),

                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Tracking Steps
                      _buildTrackingList(),
                      const SizedBox(height: 20),

                      // Payment or Rating Section
                      if (_showPaymentButton || _isPaymentCompleted)
                        _buildActionSection(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.phone_iphone_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shopName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _issueType,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderInfo(
                  "رقم الطلب", _orderId, Icons.confirmation_number_rounded),
              const SizedBox(width: 20),
              _buildHeaderInfo(
                  "المبلغ",
                  "${_totalAmount.toStringAsFixed(2)} ر.س",
                  Icons.attach_money_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPatternPainter(),
      ),
    );
  }

  Widget _buildTrackingList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: List.generate(_trackingSteps.length, (index) {
            final step = _trackingSteps[index];
            bool isLast = index == _trackingSteps.length - 1;
            return _buildTrackingStep(
              index: index,
              icon: step["icon"] as IconData,
              title: step["title"] as String,
              subtitle: step["subtitle"] as String,
              details: step["details"] as Map<String, String>,
              isCompleted: step["isCompleted"] as bool,
              isActive: step["isActive"] as bool,
              isExpanded: step["isExpanded"] as bool,
              isLast: isLast,
              stepColor: step["color"] as Color,
              gradient: step["gradient"] as List<Color>,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTrackingStep({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Map<String, String> details,
    required bool isCompleted,
    required bool isActive,
    required bool isExpanded,
    required bool isLast,
    required Color stepColor,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Colors.grey.shade100,
                  width: 1,
                ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCompleted ? () => _toggleExpanded(index) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Indicator
                _buildTimelineIndicator(
                  icon: icon,
                  isCompleted: isCompleted,
                  isActive: isActive,
                  gradient: gradient,
                  isLast: isLast,
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? stepColor
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isCompleted
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: isCompleted
                                  ? LinearGradient(
                                      colors: gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isCompleted ? null : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isCompleted ? "مكتمل" : "قيد الانتظار",
                              style: TextStyle(
                                color: isCompleted
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Expandable Details
                      if (isExpanded) ...[
                        const SizedBox(height: 16),
                        _buildStepDetails(details),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineIndicator({
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
    required List<Color> gradient,
    required bool isLast,
  }) {
    return Column(
      children: [
        // Step Circle
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: isCompleted
                ? LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isCompleted ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(22),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: gradient.first.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 3,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey.shade400,
              size: 20,
            ),
          ),
        ),

        // Connecting Line
        if (!isLast)
          Container(
            width: 2,
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradient.first.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStepDetails(Map<String, String> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildDetailItem(
              "المسؤول", details["المسؤول"]!, Icons.person_rounded),
          const SizedBox(height: 12),
          _buildDetailItem(
              "الوقت", details["الوقت"]!, Icons.access_time_rounded),
          const SizedBox(height: 12),
          _buildDetailItem(
              "التاريخ", details["التاريخ"]!, Icons.calendar_today_rounded),
          const SizedBox(height: 12),
          _buildDetailItem("ملاحظات", details["ملاحظات"]!, Icons.note_rounded),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.blue.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _showPaymentButton
          ? _buildPaymentSection(context)
          : _buildRatingSection(context),
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "اختر طريقة الدفع",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  "نقدي",
                  "الدفع عند الاستلام",
                  Icons.money_rounded,
                  [Color(0xFF00C853), Color(0xFF64DD17)],
                  () {
                    _completePayment();
                    _showSuccessMessage(context, "تم اختيار الدفع النقدي");
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentOption(
                  "إلكتروني",
                  "الدفع عبر التطبيق",
                  Icons.credit_card_rounded,
                  [Color(0xFF2196F3), Color(0xFF03A9F4)],
                  () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ElectronicPaymentScreen(
                          amount: _totalAmount,
                          orderId: _orderId,
                          serviceType: "Repair",
                        ),
                      ),
                    );
                    _completePayment();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon,
      List<Color> gradient, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "كيف كانت تجربتك؟",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "شاركنا رأيك لنساعدك بشكل أفضل",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GeneralRatingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star_rounded, size: 20),
                  label: const Text("تقييم الخدمة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  _showSuccessMessage(context, "شكراً لك على استخدام التطبيق");
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                child: Text(
                  "تخطي",
                  style: TextStyle(
                    color: Colors.grey.shade600,
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

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade50.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (int i = 0; i < 10; i++) {
      final x = size.width * (i / 10);
      final y = size.height * 0.2;
      canvas.drawCircle(Offset(x, y), 40, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
