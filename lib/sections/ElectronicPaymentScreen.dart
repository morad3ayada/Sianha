import 'package:flutter/material.dart';

class ElectronicPaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final String serviceType;

  const ElectronicPaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
    required this.serviceType,
  });

  @override
  State<ElectronicPaymentScreen> createState() =>
      _ElectronicPaymentScreenState();
}

class _ElectronicPaymentScreenState extends State<ElectronicPaymentScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  int _selectedPaymentMethod = 0; // 0: بطاقة, 1: فودافون كاش, 2: آخرين

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'البطاقة الإئتمانية',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'title': 'فودافون كاش',
      'icon': Icons.phone_android,
      'color': Colors.red,
    },
    {
      'title': 'محافظ رقمية أخرى',
      'icon': Icons.wallet,
      'color': Colors.green,
    },
  ];

  void _processPayment() {
    if (_selectedPaymentMethod == 0) {
      // دفع بالبطاقة
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى ملء جميع بيانات البطاقة')),
        );
        return;
      }
    } else if (_selectedPaymentMethod == 1) {
      // فودافون كاش
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال رقم الهاتف')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    // محاكاة عملية الدفع
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });

      // 80% نجاح, 20% فشل (لمحاكاة الواقع)
      if (DateTime.now().millisecond % 5 != 0) {
        _showPaymentSuccess();
      } else {
        _showPaymentError();
      }
    });
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'تم الدفع بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            Text(
              'تم دفع ${widget.amount} جنيه بنجاح',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'شكراً لاستخدامك خدماتنا',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق dialog
                _navigateToRatingScreen();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'تقييم الخدمة',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'فشل في الدفع',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 50),
            SizedBox(height: 15),
            Text(
              'لم يتم إتمام عملية الدفع',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'يرجى المحاولة مرة أخرى أو استخدام طريقة دفع أخرى',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
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
                  onPressed: () {
                    Navigator.pop(context);
                    _processPayment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'حاول مرة أخرى',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToRatingScreen() {
    // العودة للشاشة الرئيسية مع فتح شاشة التقييم
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/rating',
      (route) => false,
      arguments: {
        'orderId': widget.orderId,
        'serviceType': widget.serviceType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الدفع الإلكتروني',
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
            // معلومات الطلب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'المبلغ: ${widget.amount} جنيه',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'رقم الطلب: ${widget.orderId}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'نوع الخدمة: ${widget.serviceType}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // طرق الدفع
            const Text(
              'اختر طريقة الدفع:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            ..._paymentMethods.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> method = entry.value;
              return _buildPaymentMethodCard(method, index);
            }).toList(),

            const SizedBox(height: 20),

            // نموذج الدفع (يظهر حسب الطريقة المختارة)
            if (_selectedPaymentMethod == 0) _buildCardPaymentForm(),
            if (_selectedPaymentMethod == 1) _buildVodafoneCashForm(),
            if (_selectedPaymentMethod == 2) _buildOtherPaymentForm(),

            const SizedBox(height: 30),

            // زر الدفع
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'إتمام الدفع',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, int index) {
    bool isSelected = _selectedPaymentMethod == index;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isSelected ? method['color'].withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? method['color'] : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(method['icon'], color: method['color']),
        title: Text(
          method['title'],
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: method['color'],
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () {
          setState(() {
            _selectedPaymentMethod = index;
          });
        },
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'بيانات البطاقة:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'رقم البطاقة',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
            hintText: '1234 5678 9012 3456',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: 'تاريخ الانتهاء',
                  border: OutlineInputBorder(),
                  hintText: 'MM/YY',
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                  hintText: '123',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVodafoneCashForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'دفع عبر فودافون كاش:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            hintText: '0100 000 0000',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        const Text(
          'سيصلك رسالة على هاتفك لتأكيد عملية الدفع',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOtherPaymentForm() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طرق دفع أخرى:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Text(
          'يمكنك استخدام أي من التطبيقات التالية:',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 10),
        Text('• فوري\n• اتصالات pay\n• اورانج money\n• المصرفية عبر الهاتف'),
      ],
    );
  }
}
