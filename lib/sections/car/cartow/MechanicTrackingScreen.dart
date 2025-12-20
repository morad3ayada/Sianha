import 'package:flutter/material.dart';
import '/sections/ElectronicPaymentScreen.dart';
import '/sections/GeneralRatingScreen.dart'; // 💡 الاستيراد المطلوب لشاشة التقييمات

// **************************************************************************
// ملاحظة: يُفترض أن شاشة GeneralRatingScreen موجودة ولها Constructor يستقبل
// mechanicName و serviceType على الأقل لتجنب الأخطاء.
// **************************************************************************

class MechanicTrackingScreen extends StatefulWidget {
  final String mechanicName;
  final String specialization;
  final String phoneNumber;
  final String problemType;
  final String customerName;

  const MechanicTrackingScreen({
    super.key,
    required this.mechanicName,
    required this.specialization,
    required this.phoneNumber,
    required this.problemType,
    required this.customerName,
  });

  @override
  State<MechanicTrackingScreen> createState() => _MechanicTrackingScreenState();
}

class _MechanicTrackingScreenState extends State<MechanicTrackingScreen> {
  int _currentStep = 0;
  bool _orderCancelled = false;
  bool _orderCompleted = false; // 💡 حالة جديدة لتتبع إكمال الطلب (بعد الدفع)
  String? _cancellationReason;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'تم بدء الرحلة',
      'subtitle': 'الميكانيكي في طريقه إليك',
      'icon': Icons.directions_car
    },
    {
      'title': 'تم الوصول',
      'subtitle': 'الميكانيكي وصل إلى موقعك',
      'icon': Icons.location_on
    },
    {
      'title': 'جاري التشخيص',
      'subtitle': 'يتم فحص السيارة الآن',
      'icon': Icons.search
    },
    {
      'title': 'جاري التصليح',
      'subtitle': 'يتم إصلاح العطل',
      'icon': Icons.build
    },
    {
      'title': 'تم التصليح',
      'subtitle': 'تم إصلاح السيارة بنجاح',
      'icon': Icons.check_circle
    },
    // الخطوة الأخيرة هي الدفع
    {
      'title': 'الدفع',
      'subtitle': 'اختر طريقة الدفع لإنهاء الطلب', // تم تحديث الوصف
      'icon': Icons.payment
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  // =========================================================================
  // 💡 الدوال الجديدة والمعدلة
  // =========================================================================

  void _simulateProgress() {
    if (_orderCancelled || _orderCompleted) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _currentStep < _steps.length - 1 && !_orderCancelled) {
        setState(() {
          _currentStep++;
        });
        _simulateProgress();
      }
    });
  }

  // 1. دالة توجيه إلى شاشة الدفع الإلكتروني
  void _navigateToElectronicPayment() {
    Navigator.pop(context); // إغلاق دالة اختيار طريقة الدفع
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElectronicPaymentScreen(
          orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
          amount: 150.0,
          serviceType: widget.problemType,
        ),
      ),
    );
  }

  // 2. دالة إنهاء الطلب بعد الدفع النقدي (كاش)
  void _completeOrderWithCash() {
    setState(() {
      _orderCompleted = true;
    });
    Navigator.pop(context); // إغلاق دالة اختيار طريقة الدفع
    _showOrderCompletionConfirmation();
  }

  // 3. دالة إظهار تأكيد إكمال الطلب
  void _showOrderCompletionConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'تم إكمال الطلب بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.thumb_up, color: Colors.green, size: 50),
            SizedBox(height: 15),
            Text(
              'نشكرك على استخدام الخدمة. تم إنهاء الطلب.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // يمكن هنا التوجيه إلى الشاشة الرئيسية أو شاشة سجل الطلبات
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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

  // 4. دالة عرض خيارات الدفع (Cash / Electronic)
  void _showPaymentOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'اختر طريقة الدفع',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentOptionButton(
              title: 'الدفع إلكترونياً (بالبطاقة)',
              icon: Icons.credit_card,
              color: Colors.blue[800]!,
              onPressed: _navigateToElectronicPayment,
            ),
            const SizedBox(height: 15),
            _buildPaymentOptionButton(
              title: 'الدفع نقداً (كاش)',
              icon: Icons.money,
              color: Colors.green,
              onPressed: _completeOrderWithCash,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // 5. 💡 دالة التوجيه إلى شاشة التقييمات (المضافة حديثاً)
  void _navigateToRatingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralRatingScreen(),
      ),
    );
  }

  // =========================================================================
  // 💡 تعديل الدوال الموجودة
  // =========================================================================

  void _showCancelOrderDialog() {
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'إلغاء الطلب',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cancel, size: 50, color: Colors.red),
                const SizedBox(height: 15),
                const Text(
                  'اختر سبب الإلغاء:',
                  style: TextStyle(fontSize: 16),
                ),
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
                    hint: const Text('اختر سبب الإلغاء'),
                    items: [
                      'تأخر الفني في الوصول',
                      'الفني غير متاح',
                      'لا توجد قطع غيار',
                      'المشكلة تم حلها',
                      'أسباب شخصية',
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
                      child: const Text('تراجع'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedReason == null
                          ? null
                          : () {
                              setState(() {
                                _cancellationReason = selectedReason;
                                _orderCancelled = true;
                              });
                              Navigator.pop(context);
                              _showCancellationConfirmation();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'تأكيد الإلغاء',
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

  void _showCancellationConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'تم إلغاء الطلب',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.red, size: 50),
            const SizedBox(height: 15),
            Text(
              'سبب الإلغاء: $_cancellationReason',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'سيتم إبلاغ الفني بإلغاء الطلب',
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
                backgroundColor: Colors.red,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تتبع الطلب',
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
            // معلومات الميكانيكي والطلب
            _buildOrderInfo(),
            const SizedBox(height: 25),

            // حالة التتبع
            _buildTrackingStepper(),
            const SizedBox(height: 25),

            // حالة الإلغاء إذا تم الإلغاء
            if (_orderCancelled) _buildCancellationStatus(),

            // حالة اكتمال الطلب إذا تم إكماله
            if (_orderCompleted) _buildCompletionStatus(),

            // الأزرار
            if (!_orderCancelled &&
                !_orderCompleted &&
                _currentStep < _steps.length - 1)
              _buildCancelButton(),

            // عند الوصول إلى خطوة الدفع (الخطوة الأخيرة) يظهر زر الدفع
            if (!_orderCancelled &&
                !_orderCompleted &&
                _currentStep == _steps.length - 1)
              _buildActionButtons(),
          ],
        ),
      ),
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
          const Text(
            'معلومات الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('اسم الميكانيكي:', widget.mechanicName),
          _buildInfoRow('التخصص:', widget.specialization),
          _buildInfoRow('رقم التليفون:', widget.phoneNumber),
          _buildInfoRow('نوع المشكلة:', widget.problemType),
          _buildInfoRow('اسم العميل:', widget.customerName),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff14ae5c),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
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
            bool isCancelled = _orderCancelled;

            // في حالة اكتمال الطلب، نعرض جميع الخطوات على أنها مكتملة ما عدا إذا كان ملغياً
            if (_orderCompleted) {
              isCompleted = true;
              isActive = false;
            }

            return _buildStepItem(
              icon: step['icon'],
              title: step['title'],
              subtitle: step['subtitle'],
              isCompleted: isCompleted && !isCancelled,
              isActive: isActive &&
                  !isCancelled &&
                  !_orderCompleted, // لا يوجد خطوة نشطة بعد الاكتمال
              isCancelled: isCancelled,
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
    required bool isCancelled,
    required bool isLast,
  }) {
    Color stepColor = isCancelled
        ? Colors.grey
        : isCompleted
            ? Colors.green
            : isActive
                ? Colors.blue[800]!
                : Colors.grey[300]!;

    // تعديل الألوان لتظهر الخطوة الأخيرة باللون الأخضر عند إكمال الطلب
    if (isLast && _orderCompleted) {
      stepColor = Colors.green;
    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stepColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCompleted || isActive || _orderCompleted
                    ? Colors.white
                    : Colors.grey[600],
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
                      color: isCancelled
                          ? Colors.grey
                          : isCompleted || isActive || _orderCompleted
                              ? Colors.black
                              : Colors.grey,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCancelled
                          ? Colors.grey[400]!
                          : isCompleted || isActive || _orderCompleted
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
            color: isCancelled
                ? Colors.grey[300]!
                : isCompleted || _orderCompleted
                    ? Colors.green
                    : Colors.grey[300]!,
          ),
      ],
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
          Text('سبب الإلغاء: $_cancellationReason'),
        ],
      ),
    );
  }

  // 💡 دالة جديدة لعرض حالة اكتمال الطلب (تم تعديلها لإضافة زر التقييم)
  Widget _buildCompletionStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text(
                'اكتمل الطلب بنجاح',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
              'تم إتمام الدفع بنجاح. يمكنك تقييم الخدمة الآن.'), // 💡 تحديث النص
          const SizedBox(height: 20),

          // 💡 زر التنقل إلى شاشة التقييمات
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToRatingScreen,
              icon: const Icon(Icons.star, color: Colors.white),
              label: const Text(
                'تقييم الخدمة',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800], // لون مميز لزر التقييم
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showCancelOrderDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'إلغاء الطلب',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // 💡 تم ربط الزر بدالة فتح خيارات الدفع
        onPressed: _showPaymentOptionsDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'اختيار طريقة الدفع',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
