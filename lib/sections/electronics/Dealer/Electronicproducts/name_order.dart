// lib/sections/electronics/Dealer/Electronicproducts/name_order.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'product_model.dart'; // **[مهم]** استيراد Product هنا
import 'TraderTrackingScreen.dart';

class AddressSelectionScreen extends StatefulWidget {
  // **[تم التعديل]** لتلقي قائمة المنتجات، السعر الإجمالي، واسم المتجر
  final List<Product> products; // قائمة المنتجات من السلة
  final int totalPrice; // السعر الإجمالي شامل رسوم التوصيل
  final String shopName; // اسم المتجر

  const AddressSelectionScreen({
    super.key,
    required this.products,
    required this.totalPrice,
    required this.shopName,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? _selectedGovernorate;
  String? _selectedArea;
  String? _selectedDate;
  String? _selectedTime;

  // قوائم البيانات
  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الشرقية',
    'الغربية',
    'القليوبية',
    'المنوفية',
    'كفر الشيخ',
    'الفيوم',
    'بني سويف',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'أسوان',
    'الأقصر',
    'البحر الأحمر',
    'مرسى مطروح',
    'شمال سيناء',
    'جنوب سيناء'
  ];

  final List<String> _dates = [
    'غداً',
    'بعد غد',
    'الأسبوع القادم',
    'خلال 3 أيام',
    'خلال أسبوع'
  ];

  final List<String> _times = [
    '9:00 ص - 12:00 م',
    '12:00 م - 3:00 م',
    '3:00 م - 6:00 م',
    '6:00 م - 9:00 م'
  ];

  Map<String, List<String>> _areas = {
    'القاهرة': [
      'المعادي',
      'المقطم',
      'مدينة نصر',
      'الشيخ زايد',
      'التجمع الخامس',
      'مصر الجديدة',
      'الزمالك',
      'الدقي',
      'حدائق القبة',
      'شبرا'
    ],
    'الجيزة': [
      'الدقي',
      'المهندسين',
      'الهرم',
      'فيصل',
      'أكتوبر',
      'الشيخ زايد',
      'العجوزة',
      'إمبابة',
      'كيت كات'
    ],
    'الإسكندرية': [
      'سموحة',
      'سيدي جابر',
      'المنتزه',
      'العجمي',
      'المندرة',
      'اللبان',
      'الجمرك',
      'الظاهرية'
    ],
    'الدقهلية': ['المنصورة', 'طلخا', 'ميت غمر', 'بلقاس', 'أجا'],
    'الشرقية': ['الزقازيق', 'بلبيس', 'أبو حماد', 'ههيا', 'فاقوس'],
    'الغربية': ['طنطا', 'المحلة الكبرى', 'زفتى', 'سمنود', 'كفر الزيات'],
    'القليوبية': ['بنها', 'قليوب', 'شبرا الخيمة', 'الخانكة', 'كفر شكر'],
    'المنوفية': ['شبين الكوم', 'مدينة السادات', 'أشمون', 'الباجور', 'تلا'],
    'كفر الشيخ': ['كفر الشيخ', 'دسوق', 'فوه', 'مطوبس', 'بلطيم'],
    'الفيوم': ['الفيوم', 'طامية', 'سنورس', 'إطسا', 'يوسف الصديق'],
    'بني سويف': ['بني سويف', 'الواسطى', 'ناصر', 'إهناسيا', 'ببا'],
    'المنيا': ['المنيا', 'ملوي', 'دير مواس', 'مغاغة', 'بني مزار'],
    'أسيوط': ['أسيوط', 'أبنوب', 'أبو تيج', 'الغنايم', 'ساحل سليم'],
    'سوهاج': ['سوهاج', 'جرجا', 'أخميم', 'البلينا', 'مركز سوهاج'],
    'قنا': ['قنا', 'قفط', 'نقادة', 'دشنا', 'فرشوط'],
    'أسوان': ['أسوان', 'كوم أمبو', 'دراو', 'نصر النوبة', 'إدفو'],
    'الأقصر': ['الأقصر', 'الزينية', 'البياضية', 'الطود', 'أرمنت'],
  };

  final double _deliveryCost =
      50.0; // **[تم التعديل]** ليتوافق مع رسوم التوصيل في شاشة المنتجات (إذا كان يجب أن تكون موحدة)

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // محاكاة تحميل بيانات المستخدم
    _nameController.text = 'محمد أحمد';
    _phoneController.text = '01012345678';
  }

  void _selectFromMap() {
    // محاكاة فتح خرائط جوجل
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.map, color: Colors.blue),
            SizedBox(width: 8),
            Text("اختيار الموقع من الخريطة"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 50, color: Colors.blue),
                    SizedBox(height: 8),
                    Text("خريطة جوجل"),
                    Text("سيتم فتح تطبيق الخرائط",
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "سيتم فتح تطبيق Google Maps لاختيار موقعك بدقة",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateMapSelection();
            },
            child: const Text("فتح الخريطة"),
          ),
        ],
      ),
    );
  }

  void _simulateMapSelection() {
    // محاكاة اختيار موقع من الخريطة
    setState(() {
      _selectedGovernorate = 'القاهرة';
      _selectedArea = 'مدينة نصر';
      _addressController.text = 'مدينة نصر - شارع مصطفى النحاس - برج النخيل';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم تحديد الموقع من الخريطة بنجاح"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _submitOrder() {
    if (_validateForm()) {
      _showOrderSummary();
    }
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedGovernorate == null ||
        _selectedArea == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى ملء جميع الحقول المطلوبة"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى إدخال رقم هاتف مكون من 11 رقم"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _showOrderSummary() {
    // **[تم التعديل]** استخدام totalPrice الذي تم تمريره
    final double totalAmount = widget.totalPrice.toDouble();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_cart_checkout,
                        color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "تأكيد الطلب",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // **[تم التعديل]** لعرض قائمة المنتجات
                const Text("المنتجات:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...widget.products
                    .map((product) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(product.icon, size: 20, color: Colors.teal),
                              const SizedBox(width: 8),
                              Expanded(child: Text(product.name)),
                              Text("${product.price} جنيه"),
                            ],
                          ),
                        ))
                    .toList(),
                const SizedBox(height: 10),

                _buildSummaryItem(
                    "إجمالي المنتجات", "${_getProductsSubtotal()} جنيه"),
                _buildSummaryItem("تكلفة التوصيل", "${_deliveryCost} جنيه"),
                _buildSummaryItem(
                    "الإجمالي الكلي", "${totalAmount.toStringAsFixed(2)} جنيه",
                    isTotal: true),

                const SizedBox(height: 16),
                const Divider(thickness: 1),
                const SizedBox(height: 16),

                // معلومات التوصيل
                _buildSummaryItem("الاسم", _nameController.text),
                _buildSummaryItem("الهاتف", _phoneController.text),
                _buildSummaryItem("المحافظة", _selectedGovernorate!),
                _buildSummaryItem("المنطقة", _selectedArea!),
                if (_addressController.text.isNotEmpty)
                  _buildSummaryItem(
                      "العنوان التفصيلي", _addressController.text),
                _buildSummaryItem(
                    "موعد التسليم", "$_selectedDate - $_selectedTime"),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "سيتم توصيل الطلب خلال 12 ساعة\nسيتم التواصل معك للتأكيد النهائي",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: const Text(
                          "تعديل",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _processOrder();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "تأكيد الطلب",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // **[تم التعديل]** حساب إجمالي سعر المنتجات فقط
  double _getProductsSubtotal() {
    return widget.products
        .fold(0.0, (sum, product) => sum + product.price.toDouble());
  }

  // **[هذه الدالة لم تعد ضرورية لأن السعر الإجمالي يمرر جاهزاً]**
  // double _extractProductPrice() {
  //   // ... الكود الأصلي
  // }

  String _convertArabicNumbersToEnglish(String input) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < arabicNumbers.length; i++) {
      result = result.replaceAll(arabicNumbers[i], englishNumbers[i]);
    }
    return result;
  }

  Widget _buildSummaryItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.blue : Colors.grey[700],
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? Colors.blue : Colors.black,
                fontSize: isTotal ? 16 : 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _processOrder() {
    // محاكاة معالجة الطلب
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
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                strokeWidth: 4,
              ),
              SizedBox(height: 20),
              Text(
                "جاري معالجة طلبك...",
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
      _showSuccessMessage();
    });
  }

  void _showSuccessMessage() {
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
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "تم تأكيد طلبك بنجاح!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "سيتم التواصل معك خلال دقائق لتأكيد التفاصيل النهائية",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _goToTrackingScreen();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "متابعة حالة الطلب",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToTrackingScreen() {
    // **[تم التعديل]** استخدام widget.totalPrice مباشرة
    final double totalAmount = widget.totalPrice.toDouble();

    // **[تم التعديل]** بناء قائمة الـ items لتتوافق مع TraderTrackingScreen
    final List<Map<String, dynamic>> orderItems = widget.products
        .map((p) => {
              'name': p.name,
              'quantity':
                  1, // نفترض 1 لكل منتج في هذه الشاشة، يمكنك تعديلها إذا كان لديك عداد كمية
            })
        .toList();

    // الانتقال إلى شاشة التتبع
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TraderTrackingScreen(
          orderId: 'ORD${DateTime.now().microsecondsSinceEpoch}',
          customerName: _nameController.text,
          items: orderItems, // **[تم التعديل]**
          totalAmount: totalAmount,
          paymentMethod: 'بطاقة ائتمان', // أو يمكنك جعلها خيارًا
          deliveryAddress:
              '${_selectedGovernorate} - ${_selectedArea} - ${_addressController.text}',
          phoneNumber: _phoneController.text,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تأكيد الطلب والتوصيل - ${widget.shopName}", // **[إضافة]** عرض اسم المتجر
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // بطاقة المنتج (تم تعديلها لعرض قائمة المنتجات)
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "منتجات من ${widget.shopName}:",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true, // مهم داخل Column/Expanded
                          physics:
                              const NeverScrollableScrollPhysics(), // لمنع التعارض مع SingleChildScrollView الخارجي
                          itemCount: widget.products.length,
                          itemBuilder: (context, index) {
                            final product = widget.products[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Icon(product.icon,
                                      size: 24, color: Colors.blue[700]),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "${product.price} جنيه",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "الإجمالي الكلي للطلب:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            Text(
                              "${widget.totalPrice} جنيه",
                              style: const TextStyle(
                                fontSize: 20,
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

                const SizedBox(height: 16),

                // محتوى النموذج
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // المعلومات الشخصية
                        _buildSectionCard(
                          title: "المعلومات الشخصية",
                          icon: Icons.person_outline,
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "الاسم بالكامل",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 11,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ], // لضمان إدخال الأرقام فقط
                              decoration: const InputDecoration(
                                labelText: "رقم الهاتف (11 رقم)",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                prefixIcon: Icon(Icons.phone),
                                counterText: "",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // العنوان
                        _buildSectionCard(
                          title: "العنوان",
                          icon: Icons.location_on_outlined,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _selectFromMap,
                                icon: const Icon(Icons.map, size: 20),
                                label: const Text("اختيار الموقع من الخريطة"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(thickness: 1),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedGovernorate,
                              decoration: const InputDecoration(
                                labelText: "المحافظة",
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              items: _governorates.map((governorate) {
                                return DropdownMenuItem(
                                  value: governorate,
                                  child: Text(governorate),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGovernorate = value;
                                  _selectedArea =
                                      null; // إعادة تعيين المنطقة عند تغيير المحافظة
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedArea,
                              decoration: const InputDecoration(
                                labelText: "المنطقة",
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                prefixIcon: Icon(Icons.explore),
                              ),
                              items: _selectedGovernorate == null
                                  ? []
                                  : (_areas[_selectedGovernorate!] ?? [])
                                      .map((area) {
                                      return DropdownMenuItem(
                                        value: area,
                                        child: Text(area),
                                      );
                                    }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedArea = value;
                                });
                              },
                              hint: const Text("اختر المنطقة"),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _addressController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: "عنوان تفصيلي (اختياري)",
                                hintText: "رقم الشقة، الدور، علامة مميزة...",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                prefixIcon: Icon(Icons.add_location_alt),
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // موعد التسليم
                        _buildSectionCard(
                          title: "موعد التسليم",
                          icon: Icons.calendar_today_outlined,
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedDate,
                              decoration: const InputDecoration(
                                labelText: "تاريخ التسليم",
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              items: _dates.map((date) {
                                return DropdownMenuItem(
                                  value: date,
                                  child: Text(date),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDate = value;
                                });
                              },
                              hint: const Text("اختر تاريخ التسليم"),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedTime,
                              decoration: const InputDecoration(
                                labelText: "وقت التسليم",
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              items: _times.map((time) {
                                return DropdownMenuItem(
                                  value: time,
                                  child: Text(time),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTime = value;
                                });
                              },
                              hint: const Text("اختر وقت التسليم"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // زر تأكيد الطلب النهائي
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_cart_checkout,
                                color: Colors.white),
                            label: const Text("إتمام عملية الشراء",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _submitOrder,
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}
