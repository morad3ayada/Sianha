import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'order_tracking_screen.dart'; // تأكد من استيراد شاشة التتبع

class MobileRepairScreen extends StatefulWidget {
  final String shopName;

  const MobileRepairScreen({super.key, required this.shopName});

  @override
  State<MobileRepairScreen> createState() => _MobileRepairScreenState();
}

class _MobileRepairScreenState extends State<MobileRepairScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _googleAddressController =
      TextEditingController();
  final TextEditingController _detailedAddressController =
      TextEditingController();

  // القوائم المنسدلة
  String? _selectedGovernorate;
  String? _selectedDistrict;
  File? _selectedImage;

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
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'الوادي الجديد',
    'مطروح',
    'شمال سيناء',
    'جنوب سيناء',
  ];

  final Map<String, List<String>> _districts = {
    'القاهرة': [
      'المعادي',
      'المقطم',
      'مدينة نصر',
      'مصر الجديدة',
      'الزمالك',
      'الدقي',
      'المهندسين'
    ],
    'الجيزة': ['الدقي', 'المهندسين', 'العجوزة', 'الهرم', 'فيصل', 'أكتوبر'],
    'الإسكندرية': ['سموحة', 'المنتزه', 'العجمي', 'الجمرك', 'اللبان'],
    'الدقهلية': ['المنصورة', 'طلخا', 'ميت غمر', 'بلقاس'],
    'الشرقية': ['الزقازيق', 'بلبيس', 'أبو حماد', 'ههيا'],
    'الغربية': ['طنطا', 'المحلة الكبرى', 'زفتى', 'سمنود'],
  };

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("صيانة - ${widget.shopName}"),
        backgroundColor: Colors.orange[700],
        elevation: 4,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("معلومات العميل"),
              _buildTextField(
                controller: _phoneController,
                label: "رقم الهاتف",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                isRequired: true, // إجباري
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("عنوان الاستلام"),

              // المحافظة (Dropdown)
              _buildDropdown(
                value: _selectedGovernorate,
                label: "المحافظة",
                icon: Icons.location_city,
                items: _governorates,
                isRequired: true, // إجباري
                onChanged: (String? value) {
                  setState(() {
                    _selectedGovernorate = value;
                    _selectedDistrict = null;
                  });
                },
              ),

              const SizedBox(height: 12),

              // المنطقة (Dropdown) - يعتمد على المحافظة المختارة
              _buildDropdown(
                value: _selectedDistrict,
                label: "المنطقة",
                icon: Icons.place,
                items: _selectedGovernorate != null
                    ? _districts[_selectedGovernorate] ?? []
                    : [],
                isRequired: true, // إجباري
                onChanged: _selectedGovernorate != null
                    ? (String? value) {
                        setState(() {
                          _selectedDistrict = value;
                        });
                      }
                    : null,
              ),

              const SizedBox(height: 12),

              // عنوان جوجل (اختياري)
              _buildTextField(
                controller: _googleAddressController,
                label: "العنوان على خرائط جوجل (اختياري)",
                icon: Icons.map,
                onTap: _openGoogleMaps,
                isRequired: false, // اختياري
              ),

              const SizedBox(height: 12),

              // العنوان التفصيلي
              _buildTextField(
                controller: _detailedAddressController,
                label: "العنوان التفصيلي (الشارع - العمارة - الشقة)",
                icon: Icons.home,
                maxLines: 2,
                isRequired: true, // إجباري
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("تفاصيل الصيانة"),

              // تصوير التليفون
              _buildImagePicker(),

              const SizedBox(height: 12),

              // وصف المشكلة
              _buildTextField(
                controller: _issueController,
                label: "وصف مشكلة الموبايل",
                icon: Icons.report_problem,
                maxLines: 4,
                isRequired: true, // إجباري
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("موعد الاستلام"),
              _buildDateTimeSelection(),

              const SizedBox(height: 30),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    bool isRequired = true, // إضافة معيار الإجباري/الاختياري
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onTap: onTap,
          readOnly: onTap != null,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon:
                onTap != null ? const Icon(Icons.open_in_new, size: 18) : null,
          ),
        ),
        if (!isRequired) // إظهار نص "اختياري" للحقول غير الإجبارية
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Text(
              "اختياري",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?)? onChanged,
    bool isRequired = true, // إضافة معيار الإجباري/الاختياري
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
              hint: Text('اختر $label'),
              dropdownColor: Colors.white,
            ),
          ),
        ),
        if (!isRequired) // إظهار نص "اختياري" للحقول غير الإجبارية
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Text(
              "اختياري",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "تصوير التليفون:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Text(
                  "(اختياري)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null) ...[
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text("التقاط صورة"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blue!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text("المعرض"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.green!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text("حذف الصورة"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "اختر التاريخ والوقت:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Text(
                  "(اختياري)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      _selectedDate == null
                          ? "اختر التاريخ"
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(
                      _selectedTime == null
                          ? "اختر الوقت"
                          : _selectedTime!.format(context),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedDate != null && _selectedTime != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "موعد الاستلام: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} - ${_selectedTime!.format(context)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitForm,
        icon: const Icon(Icons.send, size: 24),
        label: const Text(
          "إرسال طلب الصيانة",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.4),
        ),
      ),
    );
  }

  // وظائف الخريطة والكاميرا
  void _openGoogleMaps() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("سيتم فتح خرائط جوجل لاختيار الموقع"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      cancelText: "إلغاء",
      confirmText: "تأكيد",
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      cancelText: "إلغاء",
      confirmText: "تأكيد",
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() {
    if (_validateForm()) {
      // إظهار رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "تم إرسال طلب الصيانة بنجاح",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // الانتقال لشاشة تتبع الصيانة بعد ثانيتين
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MobileRepairTrackingApp(),
          ),
        );
      });

      // تنظيف الحقول بعد الإرسال
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "يرجى ملء جميع الحقول المطلوبة",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _validateForm() {
    return _phoneController.text.isNotEmpty &&
        _selectedGovernorate != null &&
        _selectedDistrict != null &&
        _detailedAddressController.text.isNotEmpty &&
        _issueController.text.isNotEmpty;
    // تم إزالة الشروط التالية لجعلها اختيارية:
    // _googleAddressController.text.isNotEmpty &&
    // _selectedImage != null &&
    // _selectedDate != null &&
    // _selectedTime != null
  }

  void _clearForm() {
    setState(() {
      _phoneController.clear();
      _selectedGovernorate = null;
      _selectedDistrict = null;
      _googleAddressController.clear();
      _detailedAddressController.clear();
      _issueController.clear();
      _selectedImage = null;
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _issueController.dispose();
    _googleAddressController.dispose();
    _detailedAddressController.dispose();
    super.dispose();
  }
}
