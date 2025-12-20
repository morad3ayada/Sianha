import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/sections/GeneralRatingScreen.dart'; // تأكد من المسار الصحيح

class AdvancedTrackingScreens extends StatefulWidget {
  final String orderId;
  final String customerName;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String? deliveryAddress;
  final String? phoneNumber;

  const AdvancedTrackingScreens({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    this.deliveryAddress,
    this.phoneNumber,
  });

  @override
  State<AdvancedTrackingScreens> createState() =>
      _AdvancedTrackingScreenState();
}

class _AdvancedTrackingScreenState extends State<AdvancedTrackingScreens>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _driverAnimation;
  bool _isDelivered = false;
  bool _showRatingButton = false;

  final List<Map<String, dynamic>> _trackingSteps = [
    {
      'title': 'تم تأكيد الطلب',
      'subtitle': 'تم تأكيد طلبك بنجاح',
      'icon': Icons.shopping_bag_outlined,
      'time': 'الآن',
      'color': Colors.green,
    },
    {
      'title': 'تجهيز الطلب',
      'subtitle': 'جاري تجهيز طلبك في المتجر',
      'icon': Icons.inventory_2_outlined,
      'time': 'خلال 15 دقيقة',
      'color': Colors.orange,
    },
    {
      'title': 'المندوب في الطريق',
      'subtitle': 'المندوب متجه إليك الآن',
      'icon': Icons.delivery_dining,
      'time': 'خلال 30 دقيقة',
      'color': Colors.blue,
    },
    {
      'title': 'تم الوصول',
      'subtitle': 'المندوب وصل إلى موقعك',
      'icon': Icons.location_on,
      'time': 'تم الوصول',
      'color': Colors.purple,
    },
    {
      'title': 'تم التسليم',
      'subtitle': 'تم تسليم الطلب بنجاح',
      'icon': Icons.check_circle,
      'time': 'تم التسليم',
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _driverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _startTrackingProcess();
  }

  void _startTrackingProcess() async {
    // بدء عملية التتبع بمدة وهمية لأغراض العرض
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 1);

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _currentStep = 2);

    // بدء تحريك المندوب
    _animationController.forward();

    await Future.delayed(const Duration(seconds: 15));
    if (mounted) setState(() => _currentStep = 3);

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _currentStep = 4;
        _isDelivered = true;
      });
      _showDeliverySuccess();
    }
  }

  void _showDeliverySuccess() {
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "تم التسليم بنجاح! 🎉",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "شكراً لثقتك - نتمنى لك تجربة سعيدة",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // بعد إغلاق الدايلوج، نظهر زر التقييمات
                    if (mounted) {
                      setState(() {
                        _showRatingButton = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("تم الاستلام"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRatingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralRatingScreen(
         
        ),
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

  Widget _buildTrackingStep(int index) {
    final step = _trackingSteps[index];
    final isCompleted = index <= _currentStep;
    final isActive = index == _currentStep;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // الخط والرقم
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? step['color'] : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              if (index < _trackingSteps.length - 1)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? step['color'] : Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),

          // المحتوى
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive
                    ? step['color'].withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? step['color'] : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    step['icon'],
                    color: isCompleted ? step['color'] : Colors.grey[400],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isCompleted ? step['color'] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['subtitle'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: step['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'جاري',
                        style: TextStyle(
                          color: step['color'],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverMap() {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double fixedWidth = 100;
    const double paddingAndSpacing = 16 * 2 + 16;
    final double pathWidth = screenWidth - fixedWidth - paddingAndSpacing;

    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
      ),
      child: Stack(
        children: [
          // الخريطة التخطيطية
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // المتجر
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child:
                          const Icon(Icons.store, color: Colors.red, size: 20),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "المتجر",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // الطريق
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: AnimatedBuilder(
                      animation: _driverAnimation,
                      builder: (context, child) {
                        double driverPositionOffset =
                            pathWidth * _driverAnimation.value;

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: pathWidth *
                                      (1.0 - _driverAnimation.value),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: driverPositionOffset,
                              top: -23,
                              child: Transform.rotate(
                                angle: 3.14159,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.delivery_dining,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // العميل
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Icon(Icons.person_pin_circle,
                          color: Colors.green, size: 20),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "موقعك",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // حالة المندوب
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delivery_dining,
                      color: Colors.blue, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _currentStep >= 2
                        ? "المندوب في الطريق"
                        : "في انتظار المندوب",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProductColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getProductIcon(String productName) {
    if (productName.toLowerCase().contains('تلفزيون') ||
        productName.toLowerCase().contains('شاشة')) {
      return Icons.tv;
    } else if (productName.toLowerCase().contains('لابتوب') ||
        productName.toLowerCase().contains('كمبيوتر')) {
      return Icons.laptop;
    } else if (productName.toLowerCase().contains('موبايل') ||
        productName.toLowerCase().contains('هاتف')) {
      return Icons.phone_iphone;
    } else if (productName.toLowerCase().contains('سماعة')) {
      return Icons.headset;
    } else if (productName.toLowerCase().contains('كاميرا')) {
      return Icons.camera_alt;
    } else {
      return Icons.shopping_bag;
    }
  }

  String _getProductType(String productName) {
    if (productName.toLowerCase().contains('تلفزيون') ||
        productName.toLowerCase().contains('شاشة')) {
      return 'أجهزة تلفزيون';
    } else if (productName.toLowerCase().contains('لابتوب') ||
        productName.toLowerCase().contains('كمبيوتر')) {
      return 'أجهزة كمبيوتر';
    } else if (productName.toLowerCase().contains('موبايل') ||
        productName.toLowerCase().contains('هاتف')) {
      return 'هواتف محمولة';
    } else if (productName.toLowerCase().contains('سماعة')) {
      return 'إكسسوارات';
    } else if (productName.toLowerCase().contains('كاميرا')) {
      return 'كاميرات';
    } else {
      return 'منتجات إلكترونية';
    }
  }

  Widget _buildProductItem(Map<String, dynamic> item, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getProductColor(index),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getProductIcon(item['name']),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "الكمية: ${item['quantity']}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "النوع: ${_getProductType(item['name'])}",
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 18),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "تتبع الطلب",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. بطاقة معلومات الطلب
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isDelivered
                                  ? Colors.green[50]
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    _isDelivered ? Colors.green : Colors.orange,
                              ),
                            ),
                            child: Text(
                              _isDelivered ? "مكتمل" : "قيد التوصيل",
                              style: TextStyle(
                                color:
                                    _isDelivered ? Colors.green : Colors.orange,
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
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "المبلغ الإجمالي:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${widget.totalAmount.toStringAsFixed(2)} جنيه",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. خريطة المندوب
              _buildDriverMap(),

              const SizedBox(height: 16),

              // 3. مسار التتبع
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
                          Icon(Icons.timeline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "مسار التتبع",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: List.generate(_trackingSteps.length, (index) {
                          return _buildTrackingStep(index);
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. المنتجات المطلوبة
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
                          Icon(Icons.shopping_basket, color: Colors.blue),
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
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.0,
                        ),
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          return _buildProductItem(widget.items[index], index);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 5. زر التقييمات (يظهر فقط بعد انتهاء التوصيل)
              if (_showRatingButton) _buildRatingButton(),
            ],
          ),
        ),
      ),
    );
  }
}