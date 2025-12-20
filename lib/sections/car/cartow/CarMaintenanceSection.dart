import 'package:flutter/material.dart';
import 'MechanicTrackingScreen.dart'; // تأكد من وجود هذا الملف

class AddMechanicOrderScreen extends StatefulWidget {
  const AddMechanicOrderScreen({super.key});

  @override
  State<AddMechanicOrderScreen> createState() => _AddMechanicOrderScreenState();
}

class _AddMechanicOrderScreenState extends State<AddMechanicOrderScreen> {
  // Controllers
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _detailedAddressController =
      TextEditingController();

  // Selected values
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedMechanicType;
  String? _selectedGovernorate;
  String? _selectedArea;
  // محاكاة لملف الصورة
  String? _selectedImagePath;

  // =========================================================================
  // 💡 تحديث قائمة المحافظات والمناطق
  // =========================================================================

  // قائمة بأسماء محافظات مصر (إجمالي 27 محافظة)
  final List<String> governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الشرقية',
    'الدقهلية',
    'البحيرة',
    'القليوبية',
    'المنيا',
    'الغربية',
    'سوهاج',
    'أسيوط',
    'المنوفية',
    'قنا',
    'كفر الشيخ',
    'الفيوم',
    'بني سويف',
    'أسوان',
    'دمياط',
    'بورسعيد',
    'الإسماعيلية',
    'السويس',
    'الأقصر',
    'شمال سيناء',
    'جنوب سيناء',
    'مطروح',
    'البحر الأحمر',
    'الوادي الجديد'
  ];

  // خريطة شاملة للمناطق الرئيسية لكل محافظة
  Map<String, List<String>> areas = {
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

  // =========================================================================
  // باقي قوائم البيانات كما هي
  // =========================================================================
  final List<String> mechanicTypes = [
    'ميكانيكي عام',
    'ميكانيكي كهرباء',
    'ميكانيكي كوتش',
    'ميكانيكي ماتور'
        'ميكانيكي سيارات',
    'كهربائي سيارات',
    'متخصص محركات سيارات',
    'فريون وتكييف سيارات',
    'سمكرة سيارات',
    'دهان سيارات',
    'تلميع سيارات',
    'غسيل سيارات',
    'تغيير زيت وفلاتر',
    'صيانة فرامل',
    'صيانة كاوتش وعجلات',
    'صيانة دبرياج',
    'صيانة علبة تروس',
    'صيانة مساعدات',
    'صيانة كراسي',
    'صيانة راديتر',
    'صيانة دينمو',
    'صيانة ستارتر',
    'صيانة بواجي',
    'صيانة فلتر هواء',
    'صيانة فلتر بنزين',
    'صيانة طرمبة بنزين',
    'صيانة طرمبة مياه',
    'صيانة كمبروسر تكييف',
    'صيانة بودي كير',
  ];

  // =========================================================================
  // الدوال الخاصة بالـ State (بدون تغيير)
  // =========================================================================

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: 'اختر تاريخ الزيارة',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'اختر وقت الزيارة',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _selectLocation() {
    // 💡 محاكاة فتح خريطة (Map) لاختيار الموقع الدقيق
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('جاري فتح Google Maps لاختيار الموقع... (تمت المحاكاة)')),
    );
    setState(() {
      _locationController.text = 'الموقع المحدد على الخريطة (خط طول/عرض)';
    });
  }

  void _selectImage() {
    // 💡 محاكاة اختيار صورة من معرض الصور
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('جاري فتح معرض الصور لاختيار المشكلة... (تمت المحاكاة)')),
    );
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _selectedImagePath = 'problem_image_123.jpg';
      });
    });
  }

  void _submitOrder() {
    if (_locationController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedMechanicType == null ||
        _selectedGovernorate == null ||
        _selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'يرجى ملء جميع الحقول المطلوبة (الموقع، التليفون، التاريخ، النوع، المحافظة، المنطقة)')),
      );
      return;
    }

    // بناء رسالة نوع المشكلة
    String problemSummary = _selectedMechanicType!;
    if (_detailsController.text.isNotEmpty) {
      problemSummary +=
          ' - ${_detailsController.text.substring(0, _detailsController.text.length > 50 ? 50 : _detailsController.text.length)}...';
    } else {
      problemSummary += ' (بدون تفاصيل إضافية)';
    }

    // التوجيه إلى شاشة التتبع
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MechanicTrackingScreen(
          // بيانات محاكاة للميكانيكي لتظهر في شاشة التتبع
          mechanicName: 'أحمد فني سيارات',
          specialization: _selectedMechanicType!,
          phoneNumber: '01000000000',
          problemType: problemSummary,
          customerName: 'العميل: ${widget.key}', // مثال لتمرير بيانات
        ),
      ),
    );
  }

  // =========================================================================
  // الدوال الخاصة بالبناء (Widgets) - تصميم محسن (بدون تغيير)
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلب ميكانيكي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xffffe700),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // سعر الزيارة
            _buildVisitPriceCard(),

            const SizedBox(height: 25),

            // عنوان القسم
            _buildSectionTitle('📌 تفاصيل الموقع والاتصال'),
            const SizedBox(height: 15),

            // المحافظة
            _buildDropdownField(
              title: 'المحافظة',
              value: _selectedGovernorate,
              hint: 'اختر المحافظة',
              items: governorates,
              onChanged: (newValue) {
                setState(() {
                  _selectedGovernorate = newValue;
                  _selectedArea =
                      null; // إعادة تعيين المنطقة عند تغيير المحافظة
                });
              },
            ),

            const SizedBox(height: 15),

            // المنطقة
            _buildDropdownField(
              title: 'المنطقة',
              value: _selectedArea,
              hint: _selectedGovernorate == null
                  ? 'اختر المحافظة أولاً'
                  : 'اختر المنطقة',
              items: _selectedGovernorate != null
                  ? areas[_selectedGovernorate!]
                  : [],
              onChanged: (newValue) {
                setState(() {
                  _selectedArea = newValue;
                });
              },
              isEnabled: _selectedGovernorate != null,
            ),

            const SizedBox(height: 15),

            // موقع الخريطة (Google Maps)
            _buildMapLocationField(
              title: 'الموقع الدقيق على الخريطة',
              controller: _locationController,
              onTap: _selectLocation,
            ),

            const SizedBox(height: 15),

            // العنوان التفصيلي (ملاحظات العنوان)
            _buildSimpleInputField(
              title: 'ملاحظات العنوان (اختياري)',
              controller: _detailedAddressController,
              hintText: 'مثال: بجوار البنك الأهلي، عمارة 5',
              icon: Icons.details,
              keyboardType: TextInputType.streetAddress,
            ),

            const SizedBox(height: 25),

            // رقم التليفون
            _buildSimpleInputField(
              title: 'رقم التليفون',
              controller: _phoneController,
              hintText: 'ادخل رقم التليفون',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 25),
            _buildSectionTitle('🛠️ نوع الخدمة والوقت'),
            const SizedBox(height: 15),

            // نوع الميكانيكي
            _buildDropdownField(
              title: 'نوع الميكانيكي',
              value: _selectedMechanicType,
              hint: 'اختر نوع الميكانيكي المطلوب',
              items: mechanicTypes,
              onChanged: (newValue) {
                setState(() {
                  _selectedMechanicType = newValue;
                });
              },
            ),

            const SizedBox(height: 15),

            // التاريخ والوقت
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    title: 'التاريخ',
                    icon: Icons.calendar_today,
                    value: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : null,
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDateField(
                    title: 'الوقت',
                    icon: Icons.access_time,
                    value: _selectedTime != null
                        ? _selectedTime!
                            .format(context) // استخدام format للعرض الأفضل
                        : null,
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            _buildSectionTitle('📝 تفاصيل المشكلة والصور'),
            const SizedBox(height: 15),

            // تفاصيل المشكلة
            _buildTextFieldSection(
              title: 'وصف المشكلة (إلزامي)',
              controller: _detailsController,
              hintText:
                  'صف المشكلة بالتفصيل (مثل: السيارة لا تدور، تسريب زيت...)',
              maxLines: 4,
            ),

            const SizedBox(height: 15),

            // صورة المشكلة
            _buildImagePickerField(),

            const SizedBox(height: 30),

            // التعليمات
            _buildInstructions(),

            const SizedBox(height: 30),

            // زر إرسال الطلب
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[800],
      ),
    );
  }

  Widget _buildVisitPriceCard() {
    return Card(
      elevation: 5,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: Column(
          children: [
            Text(
              '💰 سعر الزيارة: 0 جنيه', // 💡 تم تعديل السعر ليكون رقمًا واقعيًا
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'سعر ثابت للكشف والتشخيص - لا يشمل قطع الغيار',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInputField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.blue[800]),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapLocationField({
    required String title,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                enabled: false,
                decoration: InputDecoration(
                  hintText: controller.text.isEmpty
                      ? 'اضغط لفتح الخريطة واختيار الموقع'
                      : controller.text,
                  hintStyle: TextStyle(
                    color: controller.text.isEmpty ? Colors.grey : Colors.black,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.map, color: Colors.red[600]),
                  suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String title,
    required IconData icon,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: Colors.blue[800]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      value ?? 'اختر $title',
                      style: TextStyle(
                        color: value != null ? Colors.black : Colors.grey,
                        fontWeight:
                            value != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String? value,
    required String hint,
    required List<String>? items,
    required Function(String?) onChanged,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(hint),
              underline: const SizedBox(),
              items: items!
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: isEnabled ? onChanged : null,
              disabledHint:
                  Text(hint, style: TextStyle(color: Colors.grey[400])),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldSection({
    required String title,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صورة المشكلة (اختياري)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectImage,
            icon: Icon(
                _selectedImagePath != null
                    ? Icons.check_circle
                    : Icons.camera_alt,
                color: Colors.white),
            label: Text(
              _selectedImagePath != null
                  ? 'تم اختيار الصورة: ${_selectedImagePath!.split('/').last}'
                  : 'إضافة صورة للمشكلة',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selectedImagePath != null ? Colors.green : Colors.blue[600],
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️ تعليمات مهمة:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.yellow[900],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '• تأكد من دقة اختيار **المحافظة والمنطقة** والموقع على الخريطة.\n'
            '• سيتم التواصل معك **تليفونياً** لتأكيد الموعد.\n'
            '• السعر 150 جنيه **فقط للكشف والتشخيص**.\n'
            '• في حالة التأجيل أو الإلغاء، يرجى إبلاغنا في أقرب وقت.',
            style: const TextStyle(
                fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.send),
      label: const Text(
        'إرسال طلب الميكانيكي',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _submitOrder,
    );
  }
}
