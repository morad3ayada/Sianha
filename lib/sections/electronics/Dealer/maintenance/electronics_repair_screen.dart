import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'MaintenanceTrackingScreen.dart';

class ElectronicsRepairScreen extends StatefulWidget {
  final String shopName;

  const ElectronicsRepairScreen({super.key, required this.shopName});

  @override
  State<ElectronicsRepairScreen> createState() =>
      _ElectronicsRepairScreenState();
}

class _ElectronicsRepairScreenState extends State<ElectronicsRepairScreen> {
  final TextEditingController deviceTypeController = TextEditingController();
  final TextEditingController issueController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedGovernorate;
  String? selectedArea;
  File? selectedImage;
  bool _isPhoneValid = true;

  // قوائم البيانات
  final List<String> governorates = [
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

  Map<String, List<String>> areas = {
    "القاهرة": [
      "المعادي",
      "المقطم",
      "المطرية",
      "النزهة",
      "الوايلي",
      "باب الشعرية",
      "حدائق القبة",
      "حلوان",
      "دار السلام",
      "شبرا",
      "عين شمس",
      "مدينة نصر",
      "مصر الجديدة",
      "منشأة ناصر",
      "وسط البلد",
      "الزمالك",
      "الزيتون",
      "التجمع الأول",
      "التجمع الثالث",
      "التجمع الخامس",
      "العبور",
      "الشروق",
      "15 مايو",
      "السلام",
      "المرج",
      "المستقبل",
      "القاهرة الجديدة"
    ],
    "الجيزة": [
      "الدقي",
      "العجوزة",
      "الهرم",
      "المريوطية",
      "الوراق",
      "امبابة",
      "بولاق الدكرور",
      "حدائق الأهرام",
      "كيت كات",
      "المهندسين",
      "فيصل",
      "أوسيم",
      "أبو النمرس",
      "6 أكتوبر",
      "الشيخ زايد",
      "الحوامدية",
      "الصف",
      "البدرشين",
      "العمرانية",
      "المنصورية",
      "إمبابة"
    ],
    // ... باقي المناطق (نفس الكود السابق)
  };

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _validatePhoneNumber(String value) {
    if (value.isNotEmpty) {
      bool isValid = value.length == 11 && value.startsWith('01');
      setState(() {
        _isPhoneValid = isValid;
      });
    } else {
      setState(() {
        _isPhoneValid = true;
      });
    }
  }

  void _submitRequest() {
    if (_validateForm()) {
      _showConfirmationDialog();
    }
  }

  bool _validateForm() {
    // التحقق من الحقول المطلوبة
    if (deviceTypeController.text.isEmpty ||
        issueController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedGovernorate == null ||
        selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى ملء جميع الحقول المطلوبة"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // التحقق من رقم الهاتف
    if (phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى إدخال رقم هاتف مكون من 11 رقم"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isPhoneValid = false;
      });
      return false;
    }

    if (!phoneController.text.startsWith('01')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يجب أن يبدأ رقم الهاتف بـ 01"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isPhoneValid = false;
      });
      return false;
    }

    // تحقق إضافي من شركات المحمول المصرية
    if (!['0', '1', '2', '5'].contains(phoneController.text[2])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "رقم الهاتف غير صحيح. يجب أن يكون من شركات: 010, 011, 012, 015"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isPhoneValid = false;
      });
      return false;
    }

    return true;
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  SizedBox(width: 8),
                  Text(
                    "تأكيد الطلب",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "هل أنت متأكد من طلب الصيانة؟",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildConfirmationItem("الجهاز", deviceTypeController.text),
              _buildConfirmationItem("المشكلة", issueController.text),
              _buildConfirmationItem("المحافظة", selectedGovernorate!),
              _buildConfirmationItem("المنطقة", selectedArea!),
              _buildConfirmationItem("الهاتف", phoneController.text),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "سيتم التواصل معك خلال 24 ساعة لتأكيد التفاصيل النهائية",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("تعديل"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSuccessMessage();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("تأكيد الطلب"),
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

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value)),
          ],
        ));
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                "تم إرسال الطلب بنجاح!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "سيتم التواصل معك قريباً لتأكيد التفاصيل",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("متابعة حالة الطلب"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToTrackingScreen() {
    // توليد رقم طلب فريد
    String orderId = 'MNT${DateTime.now().microsecondsSinceEpoch}';

    // الانتقال إلى شاشة تتبع الصيانة
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenanceTrackingScreen(
          orderId: orderId,
          deviceName: deviceTypeController.text,
          customerName: 'العميل',
          phoneNumber: phoneController.text,
          issueDescription: issueController.text,
          serviceCost: _calculateEstimatedCost(),
        ),
      ),
      (route) => false,
    );
  }

  double _calculateEstimatedCost() {
    // تقدير تكلفة الصيانة بناءً على نوع الجهاز والمشكلة
    String device = deviceTypeController.text.toLowerCase();
    String issue = issueController.text.toLowerCase();

    double baseCost = 100.0;

    if (device.contains('تلفزيون') || device.contains('شاشة')) {
      baseCost += 200.0;
    } else if (device.contains('لابتوب') || device.contains('كمبيوتر')) {
      baseCost += 300.0;
    } else if (device.contains('موبايل') || device.contains('هاتف')) {
      baseCost += 150.0;
    }

    if (issue.contains('شاشة') || issue.contains('كسر')) {
      baseCost += 250.0;
    } else if (issue.contains('بطارية') || issue.contains('شحن')) {
      baseCost += 100.0;
    } else if (issue.contains('برمجي') || issue.contains('سوفتوير')) {
      baseCost += 80.0;
    }

    return baseCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "طلب صيانة - ${widget.shopName}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // بطاقة الترحيب
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.build_circle, color: Colors.white, size: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "خدمة الصيانة المنزلية",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "فنيون متخصصون لصيانة جميع الأجهزة الإلكترونية",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // معلومات الجهاز
              _buildSectionCard(
                title: "معلومات الجهاز",
                icon: Icons.devices_other,
                children: [
                  TextField(
                    controller: deviceTypeController,
                    decoration: const InputDecoration(
                      labelText: "نوع الجهاز",
                      hintText: "مثال: تلفزيون - لابتوب - مروحة...",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: issueController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "وصف المشكلة",
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // المعلومات الشخصية
              _buildSectionCard(
                title: "المعلومات الشخصية",
                icon: Icons.person,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        onChanged: _validatePhoneNumber,
                        decoration: InputDecoration(
                          labelText: "رقم الهاتف",
                          hintText: "01XXXXXXXXX",
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          counterText: "",
                          prefixIcon: const Icon(Icons.phone),
                          // prefixText: "",
                          suffixIcon:
                              _isPhoneValid && phoneController.text.isNotEmpty
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : null,
                          errorText: _isPhoneValid ? null : "رقم هاتف غير صحيح",
                          errorStyle: const TextStyle(fontSize: 12),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isPhoneValid ? Colors.blue : Colors.red,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _isPhoneValid ? Colors.grey : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _isPhoneValid ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isPhoneValid ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isPhoneValid
                                  ? Icons.info_outline
                                  : Icons.error_outline,
                              color: _isPhoneValid ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isPhoneValid && phoneController.text.isNotEmpty
                                    ? "✓ رقم هاتف صحيح"
                                    : "يجب أن يبدأ الرقم بـ 01 ويتكون من 11 رقم",
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _isPhoneValid ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "أمثلة للأرقام الصحيحة: 01012345678, 01123456789, 01234567890, 01512345678",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // العنوان
              _buildSectionCard(
                title: "العنوان",
                icon: Icons.location_on,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedGovernorate,
                    decoration: const InputDecoration(
                      labelText: "المحافظة",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    items: governorates.map((governorate) {
                      return DropdownMenuItem(
                        value: governorate,
                        child: Text(governorate),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGovernorate = value;
                        selectedArea = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedArea,
                    decoration: const InputDecoration(
                      labelText: "المنطقة",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    items: (areas[selectedGovernorate] ?? []).map((area) {
                      return DropdownMenuItem(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    onChanged: selectedGovernorate == null
                        ? null
                        : (value) {
                            setState(() {
                              selectedArea = value;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "العنوان التفصيلي (اختياري)",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // صورة الجهاز
              _buildSectionCard(
                title: "صورة الجهاز",
                icon: Icons.camera_alt,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("تصوير الجهاز"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                        if (selectedImage != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(selectedImage!, height: 120),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "تم إضافة صورة الجهاز",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // زر الإرسال
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton.icon(
                  onPressed: _submitRequest,
                  icon: const Icon(Icons.send, size: 20),
                  label: const Text(
                    "إرسال طلب الصيانة",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
