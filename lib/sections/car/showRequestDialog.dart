import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'TowTrackingScreen.dart'; // تأكد من وجود هذا الملف في مشروعك

class CarMaintenanceSection extends StatefulWidget {
  const CarMaintenanceSection({super.key});

  @override
  State<CarMaintenanceSection> createState() => _CarMaintenanceSectionState();
}

class _CarMaintenanceSectionState extends State<CarMaintenanceSection> {
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  double _estimatedPrice = 0.0;
  final double _pricePerKm = 50.0;

  final Map<String, List<String>> _governorateAreas = {
    // بيانات المحافظات والمناطق الحقيقية بدون تكرار

    "القاهرة": [
      "المعادي",
      "المقطم",
      "مدينة نصر",
      "مصر الجديدة",
      "الزمالك",
      "الدقي",
      "المهندسين",
      "الزيتون",
      "شبرا",
      "العباسية",
      "عين شمس",
      "الوايلي",
      "حدائق القبة",
      "المنيل",
      "الخليفة",
      "السيدة زينب",
      "البساتين",
      "دار السلام",
      "المطرية",
      "السلام أول",
      "السلام ثان",
      "النزهة",
      "المرج",
      "15 مايو",
      "حلوان",
      "التبين",
      "طرة",
      "عين الصيرة",
      "الفسطاط",
      "الحدائق"
    ],

    "الجيزة": [
      "الدقي",
      "المهندسين",
      "العجوزة",
      "الهرم",
      "امبابة",
      "البدرشين",
      "العمرانية",
      "الوراق",
      "كرداسة",
      "أوسيم",
      "الصف",
      "الحوامدية",
      "المنصورية",
      "الطالبية",
      "أبو النمرس",
      "بولاق الدكرور",
      "الجزيرة",
      "فيصل",
      "الأوقاف",
      "المنيب",
      "الزاوية",
      "صقر",
      "الطوابق",
      "العياط",
      "أطفيح"
    ],

    "الإسكندرية": [
      "سموحة",
      "المنتزه",
      "العصافرة",
      "اللبان",
      "الجمرك",
      "المنشية",
      "الظاهرية",
      "كرموز",
      "محطة الرمل",
      "السيوف",
      "الابراهيمية",
      "الورديان",
      "الانفوشي",
      "القباري",
      "العبور",
      "برج العرب",
      "برج العرب الجديدة",
      "المعمورة",
      "الهانوفيل",
      "المكس",
      "البيطاش",
      "العجمي",
      "الحضرة",
      "المنتزة",
      "البحري"
    ],

    "الدقهلية": [
      "المنصورة",
      "طلخا",
      "ميت غمر",
      "أجا",
      "السنبلاوين",
      "بلقاس",
      "شربين",
      "تمي الأمديد",
      "الجمالية",
      "محلة دمنة",
      "منية النصر",
      "دكرنس",
      "ميت سلسيل",
      "المنزلة",
      "بني عبيد",
      "المنصورة الجديدة",
      "ميت الخولي",
      "الروضة",
      "شربين الجديدة",
      "السنبلاوين الجديدة"
    ],

    "الشرقية": [
      "الزقازيق",
      "بلبيس",
      "أبو حماد",
      "ههيا",
      "فاقوس",
      "كفر صقر",
      "أبو كبير",
      "الحسينية",
      "صان الحجر",
      "مشتول السوق",
      "منيا القمح",
      "الإبراهيمية",
      "أولاد صقر",
      "الصالحية",
      "العاشر من رمضان",
      "القنايات",
      "ديرب نجم",
      "العباسة",
      "ههيا الجديدة",
      "الزقازيق الجديدة"
    ],

    "الغربية": [
      "طنطا",
      "المحلة الكبرى",
      "زفتى",
      "سمنود",
      "كفر الزيات",
      "بسيون",
      "قطور",
      "السنطة",
      "شبراخيت",
      "ميت غمر",
      "طنطا الجديدة",
      "المحلة الجديدة",
      "زفتى الجديدة",
      "سمنود الجديدة",
      "كفر الزيات الجديدة"
    ],

    "القليوبية": [
      "بنها",
      "قليوب",
      "شبرا الخيمة",
      "القناطر الخيرية",
      "الخانكة",
      "كفر شكر",
      "طوخ",
      "الصف",
      "أبو زعبل",
      "مسطرد",
      "الخصوص",
      "بنها الجديدة",
      "قليوب الجديدة",
      "شبرا الخيمة الجديدة",
      "الخانكة الجديدة"
    ],

    "المنوفية": [
      "شبين الكوم",
      "مدينة السادات",
      "منوف",
      "أشمون",
      "الباجور",
      "قويسنا",
      "بركة السبع",
      "تلا",
      "الشهداء",
      "السادات",
      "شبين الكوم الجديدة",
      "منوف الجديدة",
      "أشمون الجديدة",
      "الباجور الجديدة",
      "قويسنا الجديدة"
    ],

    "كفر الشيخ": [
      "كفر الشيخ",
      "دسوق",
      "فوه",
      "مطوبس",
      "بلطيم",
      "الحامول",
      "بيلا",
      "الرياض",
      "سيدي سالم",
      "برج البرلس",
      "كفر الشيخ الجديدة",
      "دسوق الجديدة",
      "فوه الجديدة",
      "مطوبس الجديدة",
      "بلطيم الجديدة"
    ],

    "الفيوم": [
      "الفيوم",
      "طامية",
      "سنورس",
      "إطسا",
      "يوسف الصديق",
      "الفيوم الجديدة",
      "طامية الجديدة",
      "سنورس الجديدة",
      "إطسا الجديدة",
      "يوسف الصديق الجديدة"
    ],

    "بني سويف": [
      "بني سويف",
      "بني سويف الجديدة",
      "الواسطى",
      "ناصر",
      "إهناسيا",
      "ببا",
      "الفشن",
      "سمسطا",
      "الواسطى الجديدة",
      "ناصر الجديدة"
    ],

    "أسوان": [
      "أسوان",
      "كوم أمبو",
      "دراو",
      "نصر النوبة",
      "كلابشة",
      "إدفو",
      "الرديسية",
      "البصيلية",
      "أسوان الجديدة",
      "كوم أمبو الجديدة"
    ],

    "الأقصر": [
      "الأقصر",
      "الزينية",
      "البياضية",
      "الطود",
      "أرمنت",
      "إسنا",
      "القرنة",
      "الأقصر الجديدة",
      "الزينية الجديدة",
      "البياضية الجديدة"
    ],

    "البحر الأحمر": [
      "الغردقة",
      "رأس غارب",
      "مرسى علم",
      "شلاتين",
      "حلايب",
      "الغردقة الجديدة",
      "رأس غارب الجديدة",
      "مرسى علم الجديدة",
      "شلاتين الجديدة",
      "حلايب الجديدة"
    ],

    "الوادي الجديد": [
      "الخارجة",
      "الداخلة",
      "باريس",
      "موط",
      "الفرافرة",
      "الخارجة الجديدة",
      "الداخلة الجديدة",
      "باريس الجديدة",
      "موط الجديدة",
      "الفرافرة الجديدة"
    ],

    "مرسى مطروح": [
      "مرسى مطروح",
      "الحمام",
      "العلمين",
      "الضبعة",
      "سيوة",
      "مرسى مطروح الجديدة",
      "الحمام الجديدة",
      "العلمين الجديدة",
      "الضبعة الجديدة",
      "سيوة الجديدة"
    ],

    "شمال سيناء": [
      "العريش",
      "الشيخ زويد",
      "رفح",
      "بئر العبد",
      "الحسنة",
      "العريش الجديدة",
      "الشيخ زويد الجديدة",
      "رفح الجديدة",
      "بئر العبد الجديدة",
      "الحسنة الجديدة"
    ],

    "جنوب سيناء": [
      "الطور",
      "شرم الشيخ",
      "دهب",
      "نويبع",
      "رأس سدر",
      "الطور الجديدة",
      "شرم الشيخ الجديدة",
      "دهب الجديدة",
      "نويبع الجديدة",
      "رأس سدر الجديدة"
    ],

    "السويس": [
      "السويس",
      "الأربعين",
      "عتاقة",
      "الجناين",
      "فايد",
      "السويس الجديدة",
      "الأربعين الجديدة",
      "عتاقة الجديدة",
      "الجناين الجديدة",
      "فايد الجديدة"
    ],

    "بورسعيد": [
      "بورسعيد",
      "حي الزهور",
      "حي الشرق",
      "حي الغرب",
      "حي الجنوب",
      "بورسعيد الجديدة",
      "حي الزهور الجديدة",
      "حي الشرق الجديدة",
      "حي الغرب الجديدة",
      "حي الجنوب الجديدة"
    ],

    "الإسماعيلية": [
      "الإسماعيلية",
      "فايد",
      "القنطرة غرب",
      "القنطرة شرق",
      "التل الكبير",
      "الإسماعيلية الجديدة",
      "فايد الجديدة",
      "القنطرة غرب الجديدة",
      "القنطرة شرق الجديدة",
      "التل الكبير الجديدة"
    ],

    "دمياط": [
      "دمياط",
      "دمياط الجديدة",
      "رأس البر",
      "فارسكور",
      "الزرقا",
      "دمياط الجديدة",
      "رأس البر الجديدة",
      "فارسكور الجديدة",
      "الزرقا الجديدة",
      "كفر سعد"
    ]
  };

  List<String> _availableAreas = [];
  String? _selectedGovernorate;
  String? _selectedArea;

  @override
  void initState() {
    super.initState();
    // تهيئة قائمة المناطق لتكون فارغة في البداية
    _availableAreas = [];
  }

  void _calculatePrice() {
    if (_distanceController.text.isNotEmpty) {
      double distance = double.tryParse(_distanceController.text) ?? 0;
      setState(() {
        _estimatedPrice = distance * _pricePerKm;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _getCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جارٍ تحديد موقعك الحالي...'),
        backgroundColor: Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحديد موقعك بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      // 🚀 التعديل الأهم: استخدام StatefulBuilder لتحديث الـ UI داخل الـ Dialog
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeader(),
                    const SizedBox(height: 24),
                    _buildProblemField(),
                    const SizedBox(height: 16),
                    _buildPhoneField(),
                    const SizedBox(height: 16),
                    // تمرير دالة تحديث حالة الـ Dialog
                    _buildLocationSection(dialogSetState),
                    const SizedBox(height: 16),
                    _buildAddressField(),
                    const SizedBox(height: 16),
                    _buildDistancePriceSection(),
                    const SizedBox(height: 20),
                    _buildImageSection(),
                    const SizedBox(height: 20),
                    _buildInstructionsCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping, color: Colors.yellow[700], size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "طلب ونش",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                  ),
                ),
                Text(
                  "خدمة سحب ونقل المركبات",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.yellow[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "وصف المشكلة بالتفصيل",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _problemController,
            maxLines: 3,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: "صف مشكلة سيارتك بالتفصيل...",
              prefixIcon: Icon(Icons.description, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "رقم التليفون",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: "أدخل رقم هاتفك",
              prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  // 🌟 تم تعديل الدالة لقبول دالة تحديث حالة الـ Dialog
  Widget _buildLocationSection(Function dialogSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "الموقع",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton.icon(
            onPressed: _getCurrentLocation,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[300]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.location_on, size: 20),
            label: const Text("تحديد موقعي الحالي"),
          ),
        ),
        // تمرير دالة تحديث حالة الـ Dialog
        _buildGovernorateDropdown(dialogSetState),
        const SizedBox(height: 12),
        // تمرير دالة تحديث حالة الـ Dialog
        _buildAreaDropdown(dialogSetState),
      ],
    );
  }

  // 🌟 تم تعديل الدالة لقبول دالة تحديث حالة الـ Dialog واستخدامها لتحديث الـ State
  Widget _buildGovernorateDropdown(Function dialogSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "المحافظة",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              "*",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedGovernorate == null
                  ? Colors.grey[300]!
                  : Colors.yellow[700]!,
              width: 2,
            ),
            color:
                _selectedGovernorate == null ? Colors.white : Colors.yellow[50],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedGovernorate,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: _selectedGovernorate == null
                    ? Colors.grey[600]
                    : Colors.yellow[700],
                size: 30,
              ),
              hint: Row(
                children: [
                  Icon(Icons.location_city, color: Colors.grey[500], size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'اختر المحافظة',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              items: _governorateAreas.keys.map((String governorate) {
                return DropdownMenuItem<String>(
                  value: governorate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.location_city,
                            color: Colors.yellow[700], size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            governorate,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _selectedGovernorate == governorate
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedGovernorate == governorate
                                  ? Colors.yellow[800]
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                        if (_selectedGovernorate == governorate)
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
              // 🚀 التعديل: استخدام dialogSetState لتحديث حالة الـ Dropdown داخل الـ Dialog
              onChanged: (String? value) {
                dialogSetState(() {
                  _selectedGovernorate = value;
                  _selectedArea = null; // تصفير المنطقة عند تغيير المحافظة
                  if (value != null) {
                    // تحديث قائمة المناطق المتاحة
                    _availableAreas = _governorateAreas[value] ?? [];
                  } else {
                    _availableAreas = [];
                  }
                });
              },
            ),
          ),
        ),
        if (_selectedGovernorate != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text(
                  "المحافظة المختارة: ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  _selectedGovernorate!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 🌟 تم تعديل الدالة لقبول دالة تحديث حالة الـ Dialog واستخدامها لتحديث الـ State
  Widget _buildAreaDropdown(Function dialogSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "المنطقة",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              "*",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedArea == null
                  ? Colors.grey[300]!
                  : Colors.yellow[700]!,
              width: 2,
            ),
            color: _selectedArea == null ? Colors.white : Colors.yellow[50],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedArea,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: _selectedArea == null
                    ? Colors.grey[600]
                    : Colors.yellow[700],
                size: 30,
              ),
              hint: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[500], size: 22),
                  const SizedBox(width: 12),
                  Text(
                    _selectedGovernorate == null
                        ? 'اختر المحافظة أولاً'
                        : 'اختر المنطقة',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              items: _availableAreas.map((String area) {
                return DropdownMenuItem<String>(
                  value: area,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.yellow[700], size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            area,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _selectedArea == area
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedArea == area
                                  ? Colors.yellow[800]
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                        if (_selectedArea == area)
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
              // تعطيل إذا لم يتم اختيار محافظة
              onChanged: _selectedGovernorate == null
                  ? null
                  // 🚀 التعديل: استخدام dialogSetState لتحديث حالة الـ Dropdown داخل الـ Dialog
                  : (String? value) {
                      dialogSetState(() {
                        _selectedArea = value;
                      });
                    },
            ),
          ),
        ),
        if (_selectedArea != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text(
                  "المنطقة المختارة: ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  _selectedArea!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "العنوان التفصيلي",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: "الشارع - العمارة - الشقة...",
              prefixIcon: Icon(Icons.home, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistancePriceSection() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "المسافة بالكيلومتر",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculatePrice(),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: "أدخل المسافة التقريبية",
                  prefixIcon:
                      Icon(Icons.directions_car, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_estimatedPrice > 0) _buildPriceCard(),
      ],
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_money, color: Colors.green[800], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "السعر المتوقع",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_estimatedPrice.toStringAsFixed(2)} جنيه",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "سعر الكيلومتر: $_pricePerKm جنيه",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "إضافة صورة للمشكلة",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedImage == null
                    ? Colors.grey[300]!
                    : Colors.yellow[700]!,
                width: _selectedImage == null ? 1 : 2,
              ),
            ),
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        "اضغط لإضافة صورة للمشكلة",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!,
                        fit: BoxFit.cover, width: double.infinity),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.orange[800], size: 20),
              const SizedBox(width: 8),
              const Text(
                "تعليمات مهمة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...[
            "• تأكد من دقة العنوان والموقع",
            "• سيتم التواصل معك خلال 10 دقائق",
            "• الدفع نقداً أو إلكترونياً متاح",
            "• السعر النهائي قد يختلف حسب حالة السيارة",
            "• تأكد من توفر مساحة كافية لسحب المركبة",
          ]
              .map((instruction) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      instruction,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "إلغاء",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: _submitRequest,
            child: const Text(
              "تأكيد الطلب",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitRequest() {
    if (_problemController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedGovernorate == null ||
        _selectedArea == null ||
        _distanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("يرجى ملء جميع الحقول المطلوبة"),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    String orderId = 'TOW${DateTime.now().millisecondsSinceEpoch}';
    String appointmentTime =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TowTrackingScreen(
          orderId: orderId,
          serviceType: 'ونش',
          appointmentTime: appointmentTime,
          estimatedPrice: _estimatedPrice,
        ),
      ),
    );

    _resetForm();
  }

  void _resetForm() {
    _problemController.clear();
    _phoneController.clear();
    _addressController.clear();
    _distanceController.clear();
    setState(() {
      _selectedImage = null;
      _selectedGovernorate = null;
      _selectedArea = null;
      _estimatedPrice = 0.0;
      _availableAreas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "طلب ونش",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.yellow[700]!,
              Colors.white,
            ],
            stops: const [0.0, 0.2],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: const Column(
                children: [
                  Icon(Icons.local_shipping, size: 64, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    "خدمة الونش",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _showRequestDialog,
                    icon: const Icon(Icons.add_road),
                    label: const Text(
                      'طلب ونش جديد',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
