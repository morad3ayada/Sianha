import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/sections/ElectronicPaymentScreen.dart';
import '/sections/GeneralRatingScreen.dart';

class FinishingTrackingScreen extends StatefulWidget {
  final String finishingType;
  final double totalPrice;
  final bool isRejected;
  final String? rejectionReason;
  final String orderId;
  final String serviceType;

  const FinishingTrackingScreen({
    super.key,
    required this.finishingType,
    required this.totalPrice,
    required this.orderId,
    required this.serviceType,
    this.isRejected = false,
    this.rejectionReason,
  });

  @override
  State<FinishingTrackingScreen> createState() =>
      _FinishingTrackingScreenState();
}

class _FinishingTrackingScreenState extends State<FinishingTrackingScreen> {
  // متغيرات حالة الطلب
  int _currentStep = 0;
  String _technicianStatus = 'جاري إرسال فني للمعاينة';
  bool _isDepositPaid = false;
  bool _isFullPaymentPaid = false;
  double _depositAmount = 0.0;
  double _remainingAmount = 0.0;
  DateTime? _workStartDate;
  DateTime? _workEndDate;
  int _workDuration = 0; // بالأيام
  String? _selectedPaymentType; // 'cash' أو 'electronic'
  bool _showRatingButton = false; // متغير للتحكم في ظهور زر التقييم

  // بيانات المستخدم
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // بيانات الفني
  final Map<String, dynamic> _technician = {
    'name': 'إبراهيم محمد',
    'phone': '01123456789',
    'rating': '4.8/5',
    'projects': '47 مشروع',
    'image': 'assets/technician.jpg',
  };

  final List<Map<String, dynamic>> _steps = [
    {'title': 'إرسال فني للمعاينة', 'icon': Icons.engineering, 'days': 1},
    {'title': 'تم تأكيد الطلب', 'icon': Icons.check_circle_outline, 'days': 1},
    {'title': 'دفع العربون', 'icon': Icons.payment, 'days': 1},
    {'title': 'بدء أعمال التشطيب', 'icon': Icons.construction, 'days': 7},
    {'title': 'دفع المبلغ المتبقي', 'icon': Icons.credit_card, 'days': 1},
    {'title': 'تم الانتهاء من التشطيب', 'icon': Icons.done_all, 'days': 1},
    {'title': 'تسليم العمل', 'icon': Icons.handshake, 'days': 1},
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _simulateOrderProgress();
    _loadUserData();
  }

  void _loadUserData() {
    _phoneController.text = '01012345678';
    _nameController.text = 'محمد أحمد';
    _addressController.text = 'القاهرة - مصر';
  }

  void _initializeData() {
    _depositAmount = widget.totalPrice * 0.3;
    _remainingAmount = widget.totalPrice - _depositAmount;
  }

  void _simulateOrderProgress() {
    if (!widget.isRejected) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _currentStep = 1;
            _technicianStatus = 'تم تأكيد الطلب، والفني في طريقه.';
          });
        }
      });

      Future.delayed(const Duration(seconds: 6), () {
        if (mounted) {
          setState(() {
            _currentStep = 2;
            _technicianStatus = 'في انتظار دفع العربون لبدء العمل';
          });
        }
      });
    }
  }

  void _startWork() {
    setState(() {
      _currentStep = 3;
      _workStartDate = DateTime.now();
      _workEndDate = _workStartDate!.add(Duration(days: _steps[3]['days']));
      _workDuration = _steps[3]['days'];
      _technicianStatus = 'بدأت أعمال التشطيب في موقعك';
    });
  }

  void _completeWork() {
    setState(() {
      _currentStep = 5;
      _technicianStatus = 'تم الانتهاء من أعمال التشطيب بنجاح';
    });
  }

  void _callTechnician() {
    _showDialog(
      'الاتصال بالفني',
      'سيتم الاتصال بالفني: ${_technician['phone']}',
      Icons.phone,
    );
  }

  void _messageTechnician() {
    _showDialog(
      'مراسلة الفني',
      'سيتم فتح محادثة مع الفني ${_technician['name']}',
      Icons.message,
    );
  }

  void _showDialog(String title, String content, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  // الانتقال لشاشة الدفع الإلكتروني
  void _navigateToElectronicPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElectronicPaymentScreen(
          orderId: widget.orderId,
          amount: _currentStep == 2 ? _depositAmount : _remainingAmount,
          serviceType: widget.serviceType,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _onPaymentSuccess();
      }
    });
  }

  void _onPaymentSuccess() {
    if (mounted) {
      setState(() {
        if (_currentStep == 2) {
          _isDepositPaid = true;
          _currentStep = 3;
          _startWork();
        } else if (_currentStep == 4) {
          _isFullPaymentPaid = true;
          _currentStep = 5;
          _completeWork();
          _showRatingButton = true; // إظهار زر التقييم بعد اكتمال الدفع
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "تم الدفع بنجاح ${_selectedPaymentType == 'cash' ? 'نقداً' : 'إلكترونياً'}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // الانتقال لشاشة التقييمات
  void _navigateToGeneralRating() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralRatingScreen(

            // يمكن إضافة باراميترات أخرى حسب متطلبات شاشة التقييم
            ),
      ),
    );
  }

  void _processCashPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.money, color: Colors.green),
            SizedBox(width: 8),
            Text("الدفع نقداً"),
          ],
        ),
        content: Text(
          "سيتم الدفع نقداً بمبلغ ${_currentStep == 2 ? _depositAmount.toStringAsFixed(2) : _remainingAmount.toStringAsFixed(2)} جنيه\n\nسيقوم الفني باستلام المبلغ عند الزيارة",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _onPaymentSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('تأكيد الدفع'),
          ),
        ],
      ),
    );
  }

  void _handlePayment() {
    if (_selectedPaymentType == 'cash') {
      _processCashPayment();
    } else if (_selectedPaymentType == 'electronic') {
      _navigateToElectronicPayment();
    }
  }

  Widget _buildStep({
    required String title,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
    required int days,
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : isActive
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.grey[100],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor,
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (!isLast)
                Container(
                  height: 40,
                  width: 2,
                  color: connectorColor,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$days يوم',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      'جاري التنفيذ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
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

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "معلومات العميل",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'الاسم بالكامل',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      if (value.length < 10) {
                        return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _addressController,
                    label: 'العنوان',
                    icon: Icons.location_on,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال العنوان';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveUserInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('حفظ المعلومات'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _saveUserInfo() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ المعلومات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "تفاصيل الدفع",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPaymentDetail("المبلغ الإجمالي", "${widget.totalPrice} جنيه"),
            _buildPaymentDetail(
                "العربون (30%)", "${_depositAmount.toStringAsFixed(2)} جنيه",
                isPaid: _isDepositPaid),
            _buildPaymentDetail(
                "المبلغ المتبقي", "${_remainingAmount.toStringAsFixed(2)} جنيه",
                isPaid: _isFullPaymentPaid),

            // إضافة خيارات الدفع
            if ((_currentStep == 2 && !_isDepositPaid) ||
                (_currentStep == 4 && !_isFullPaymentPaid))
              _buildPaymentOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          "اختر طريقة الدفع:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // خيار الدفع نقداً
        _buildPaymentOption(
          title: "الدفع نقداً",
          subtitle: "الدفع عند استلام الخدمة",
          icon: Icons.money,
          isSelected: _selectedPaymentType == 'cash',
          onTap: () {
            setState(() {
              _selectedPaymentType = 'cash';
            });
          },
        ),

        const SizedBox(height: 12),

        // خيار الدفع الإلكتروني
        _buildPaymentOption(
          title: "الدفع الإلكتروني",
          subtitle: "الدفع عبر التطبيق",
          icon: Icons.credit_card,
          isSelected: _selectedPaymentType == 'electronic',
          onTap: () {
            setState(() {
              _selectedPaymentType = 'electronic';
            });
          },
        ),

        const SizedBox(height: 16),

        // زر تأكيد الدفع
        if (_selectedPaymentType != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _currentStep == 2
                    ? "دفع العربون ${_depositAmount.toStringAsFixed(2)} جنيه"
                    : "دفع المبلغ المتبقي ${_remainingAmount.toStringAsFixed(2)} جنيه",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String value,
      {bool isPaid = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : Colors.blue,
                ),
              ),
              if (isPaid) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, color: Colors.green, size: 18),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkSchedule() {
    if (_workStartDate == null) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "جدول العمل",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildScheduleItem("تاريخ البدء", _formatDate(_workStartDate!)),
            _buildScheduleItem(
                "تاريخ الانتهاء المتوقع", _formatDate(_workEndDate!)),
            _buildScheduleItem("مدة العمل", "$_workDuration أيام"),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _calculateProgress(),
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              "${(_calculateProgress() * 100).toStringAsFixed(1)}% مكتمل",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  double _calculateProgress() {
    if (_workStartDate == null || _workEndDate == null) return 0.0;
    final totalDays = _workEndDate!.difference(_workStartDate!).inDays;
    final passedDays = DateTime.now().difference(_workStartDate!).inDays;
    if (passedDays <= 0) return 0.0;
    if (passedDays >= totalDays) return 1.0;
    return passedDays / totalDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تتبع طلب التشطيب"),
        backgroundColor: Colors.orange[700],
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الطلب
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        widget.finishingType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${widget.totalPrice.toStringAsFixed(2)} جنيه",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _technicianStatus,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // حالة الرفض
              if (widget.isRejected)
                _buildRejectionNotice()
              else
                Column(
                  children: [
                    // معلومات العميل
                    _buildUserInfoSection(),

                    // مسار التتبع
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.track_changes,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "مسار التتبع",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: List.generate(_steps.length, (index) {
                                return _buildStep(
                                  title: _steps[index]['title'] as String,
                                  icon: _steps[index]['icon'] as IconData,
                                  days: _steps[index]['days'] as int,
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

                    // جدول العمل
                    if (_workStartDate != null) _buildWorkSchedule(),

                    // تفاصيل الدفع
                    _buildPaymentSection(),

                    // تفاصيل الفني
                    _buildTechnicianInfo(),

                    // أزرار التحكم الأساسية + زر التقييم
                    _buildActionButtons(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRejectionNotice() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.red[50],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 50),
            const SizedBox(height: 12),
            const Text(
              "تم رفض طلبك",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.rejectionReason ?? 'لا يوجد سبب محدد',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("العودة للرئيسية"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.engineering, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "معلومات الفريق",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTechDetail(Icons.person, "اسم الفريق ", _technician['name']),
            _buildTechDetail(Icons.phone, "رقم الهاتف", _technician['phone']),
            _buildTechDetail(Icons.star, "التقييم", _technician['rating']),
            _buildTechDetail(
                Icons.work, "عدد المشاريع", _technician['projects']),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _callTechnician,
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('اتصال'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _messageTechnician,
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('مراسلة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildTechDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 18),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // زر التقييم بعد اكتمال الدفع
        if (_showRatingButton)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToGeneralRating,
              icon: const Icon(Icons.star, size: 20),
              label: const Text("تقييم الخدمة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

        if (_currentStep == 5)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 6;
                  _showRatingButton =
                      true; // إظهار زر التقييم بعد تأكيد الاستلام
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("تم تأكيد استلام العمل بنجاح"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("تأكيد استلام العمل"),
            ),
          ),
        if (_currentStep == 6)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              children: [
                Icon(Icons.celebration, color: Colors.green, size: 50),
                const SizedBox(height: 12),
                const Text(
                  "مبروك! اكتمل طلبك بنجاح",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  "تم الانتهاء من أعمال التشطيب وتأكيد الاستلام",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey[400]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "العودة للرئيسية",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
