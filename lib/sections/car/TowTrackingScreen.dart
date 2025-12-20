import 'package:flutter/material.dart';
import '/sections/ElectronicPaymentScreen.dart';
import '/sections/GeneralRatingScreen.dart';

class TowTrackingScreen extends StatefulWidget {
  final String orderId;
  final String serviceType;
  final String appointmentTime;
  final double estimatedPrice;

  const TowTrackingScreen({
    super.key,
    required this.orderId,
    required this.serviceType,
    required this.appointmentTime,
    required this.estimatedPrice,
  });

  @override
  State<TowTrackingScreen> createState() => _TowTrackingScreenState();
}

class _TowTrackingScreenState extends State<TowTrackingScreen> {
  int _currentStep = 0;
  bool _paymentCompleted = false;
  bool _serviceDelayed = false;
  String? _delayReason;
  bool _isPaying = false;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'تم استلام الطلب',
      'subtitle': 'جاري تجهيز الونش',
      'icon': Icons.receipt
    },
    {
      'title': 'تم بدء الرحلة',
      'subtitle': 'الونش في طريقه إليك',
      'icon': Icons.directions_car
    },
    {
      'title': 'تم الوصول',
      'subtitle': 'الونش وصل إلى موقعك',
      'icon': Icons.location_on
    },
    {
      'title': 'جاري التحميل',
      'subtitle': 'يتم تحميل المركبة على الونش',
      'icon': Icons.local_shipping
    },
    {
      'title': 'جاري النقل',
      'subtitle': 'يتم نقل المركبة إلى الوجهة',
      'icon': Icons.airport_shuttle
    },
    {
      'title': 'تم التسليم',
      'subtitle': 'تم تسليم المركبة بنجاح',
      'icon': Icons.check_circle
    },
    {
      'title': 'الدفع',
      'subtitle': 'انتظار إتمام السداد',
      'icon': Icons.payment
    },
  ];

  void _simulateProgress() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
        });
        _simulateProgress();
      } else if (_currentStep == _steps.length - 1 && !_paymentCompleted) {
        // تم الوصول لمرحلة الدفع - لا نفتح أي dialog تلقائي
      }
    });
  }

  // دالة الانتقال إلى شاشة الدفع الإلكتروني
  void _goToElectronicPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElectronicPaymentScreen(
          amount: widget.estimatedPrice,
          orderId: widget.orderId,
          serviceType: widget.serviceType,
        ),
      ),
    ).then((value) {
      // عند العودة من شاشة الدفع، نتحقق إذا تم الدفع بنجاح
      if (value == true) {
        setState(() {
          _paymentCompleted = true;
        });
        _showSuccessDialog('تم الدفع الإلكتروني بنجاح');
      }
    });
  }

  // دالة الانتقال إلى شاشة التقييم
  void _goToRatingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GeneralRatingScreen(),
      ),
    );
  }

  void _showPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'طريقة الدفع',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payment, size: 50, color: Colors.blue),
            const SizedBox(height: 15),
            Text(
              'المبلغ المستحق: ${widget.estimatedPrice.toStringAsFixed(2)} جنيه',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'اختر طريقة الدفع:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            _buildPaymentMethod('الدفع نقداً', Icons.money, () {
              Navigator.pop(context);
              _processCashPayment();
            }),
            const SizedBox(height: 10),
            _buildPaymentMethod('الدفع الإلكتروني', Icons.credit_card, () {
              Navigator.pop(context);
              _goToElectronicPayment();
            }),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDelayDialog();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('تأجيل الدفع'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  void _processCashPayment() {
    setState(() {
      _paymentCompleted = true;
    });
    _showSuccessDialog('تم تأكيد الدفع نقداً');
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تم بنجاح',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'تم إتمام الخدمة بنجاح',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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

  void _showDelayDialog() {
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'تأجيل الخدمة',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 50, color: Colors.orange),
                const SizedBox(height: 10),
                const Text('اختر سبب التأجيل:'),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedReason,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('اختر السبب'),
                    items: [
                      'المركبة غير قابلة للسحب',
                      'الموقع غير آمن',
                      'أسباب فنية في الونش',
                      'أخرى'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('إلغاء'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedReason == null
                          ? null
                          : () {
                              setState(() {
                                _delayReason = selectedReason;
                                _serviceDelayed = true;
                              });
                              Navigator.pop(context);
                              _showDelayConfirmation();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'تأكيد',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDelayConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تم التأجيل',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info, size: 50, color: Colors.orange),
            const SizedBox(height: 10),
            Text('تم تأجيل الخدمة بسبب: $_delayReason'),
            const SizedBox(height: 10),
            const Text(
              'سيتم التواصل معك لتحديد موعد جديد',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
              ),
              child: const Text(
                'موافق',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تتبع الونش',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfo(),
            const SizedBox(height: 30),
            _buildTrackingStepper(),
            const SizedBox(height: 20),

            // أزرار الدفع والتقييم
            if (_currentStep >= _steps.length - 1 && !_paymentCompleted)
              _buildPaymentButtons(),

            if (_paymentCompleted) _buildCompletedButtons(),

            if (_paymentCompleted) _buildPaymentStatus(),
            if (_serviceDelayed && _delayReason != null) _buildDelayStatus(),
          ],
        ),
      ),
    );
  }

  // أزرار الدفع
  Widget _buildPaymentButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: _showPaymentMethodDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 24),
                SizedBox(width: 10),
                Text(
                  'اختر طريقة الدفع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // أزرار بعد اكتمال الدفع
  Widget _buildCompletedButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: _goToRatingScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 24),
                SizedBox(width: 10),
                Text(
                  'تقييم الخدمة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('رقم الطلب:', widget.orderId),
          _buildInfoRow('نوع الخدمة:', widget.serviceType),
          _buildInfoRow('موعد الحضور:', widget.appointmentTime),
          _buildInfoRow(
              'السعر:', '${widget.estimatedPrice.toStringAsFixed(2)} جنيه'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff14ae75),
            ),
          ),
          const SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTrackingStepper() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حالة الطلب:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff15b2c0),
            ),
          ),
          const SizedBox(height: 15),
          ..._steps.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> step = entry.value;
            bool isCompleted = index < _currentStep;
            bool isActive = index == _currentStep;

            return _buildStepItem(
              icon: step['icon'],
              title: step['title'],
              subtitle: step['subtitle'],
              isCompleted: isCompleted,
              isActive: isActive,
              isLast: index == _steps.length - 1,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isActive
                        ? Colors.blue[800]
                        : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCompleted || isActive ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isCompleted || isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCompleted || isActive
                          ? Colors.grey
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
            width: 2,
            height: 20,
            color: isCompleted ? Colors.green : Colors.grey[300],
          ),
      ],
    );
  }

  Widget _buildPaymentStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'تم الدفع بنجاح واكتمال الخدمة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelayStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                'تم تأجيل الخدمة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('السبب: $_delayReason'),
          const SizedBox(height: 5),
          const Text(
            'سيتم التواصل معك لتحديد موعد جديد',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
