import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// استيراد شاشة التتبع
import 'finishing_tracking_screen.dart';

class FinishingRequestScreen extends StatefulWidget {
  const FinishingRequestScreen({super.key});

  @override
  State<FinishingRequestScreen> createState() => _FinishingRequestScreenState();
}

class _FinishingRequestScreenState extends State<FinishingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? finishingType;
  String? placeType;
  String? governorate;
  String? area;
  File? _selectedImage;
  String? duration;

  final List<String> finishingOptions = [
    'سوبر لوكس',
    'لوكس',
    'تشطيب عادي',
    'تشطيب اقتصادي'
  ];

  final List<String> placeOptions = [
    'شقة',
    'محل',
    'فيلا',
    'مكتب',
    'عمارة',
    'مصنع',
    'مستودع',
    'مطعم',
    'كافيه',
    'عيادة',
    'مدرسة',
    'جامعة'
  ];

  final Map<String, List<String>> governorateAreas = {
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
    "الإسكندرية": [
      "المنتزه",
      "السيوف",
      "العصافرة",
      "الأنفوشي",
      "الابراهيمية",
      "الأزاريطة",
      "البيطاش",
      "الجمرك",
      "الحضرة",
      "الدخيلة",
      "السيوف",
      "العجمي",
      "القبارى",
      "اللبان",
      "المعمورة",
      "المندرة",
      "المكس",
      "المنشية",
      "باب شرق",
      "برج العرب",
      "بولكلي",
      "كامب شيزار",
      "كرموز",
      "كليوباترا",
      "محطة الرمل",
      "ميامي",
      "سابا باشا",
      "سموحة",
      "سيدي بشر",
      "سيدي جابر",
      "فلمنج",
      "زيزينيا",
      "ستانلي",
      "سان ستيفانو",
      "الرأس السوداء",
      "المكس الجديدة"
    ],
    "الدقهلية": [
      "المنصورة",
      "أجا",
      "السنبلاوين",
      "ميت غمر",
      "دكرنس",
      "بلقاس",
      "شربين",
      "تمي الأمديد",
      "الجمالية",
      "منية النصر",
      "المنزلة",
      "ميت سلسيل",
      "طلخا",
      "بني عبيد",
      "نبروه",
      "جمصة"
    ],
    "الشرقية": [
      "الزقازيق",
      "أبو حماد",
      "أبو كبير",
      "الإبراهيمية",
      "بلبيس",
      "الحسينية",
      "ديرب نجم",
      "فاقوس",
      "كفر صقر",
      "ههيا",
      "مشتول السوق",
      "منيا القمح",
      "العاشر من رمضان",
      "صان الحجر",
      "القنايات",
      "أولاد صقر",
      "أبو حماد",
      "كفر صقر"
    ],
    "الغربية": [
      "طنطا",
      "المحلة الكبرى",
      "كفر الزيات",
      "زفتى",
      "السنطة",
      "بسيون",
      "قطور",
      "سمنود",
      "كفر الزيات"
    ],
    "المنوفية": [
      "شبين الكوم",
      "السادات",
      "أشمون",
      "الباجور",
      "تلا",
      "بركة السبع",
      "قويسنا",
      "منوف",
      "الباجور"
    ],
    "القليوبية": [
      "بنها",
      "شبرا الخيمة",
      "القناطر الخيرية",
      "الخانكة",
      "كفر شكر",
      "طوخ",
      "قليوب",
      "الخانكة"
    ],
    "الإسماعيلية": [
      "الإسماعيلية",
      "التل الكبير",
      "فايد",
      "القصاصين",
      "أبو صوير",
      "القنطرة غرب",
      "القنطرة شرق",
      "فايد"
    ],
    "بورسعيد": [
      "بورسعيد",
      "بورفؤاد",
      "حي الضواحي",
      "حي الشرق",
      "حي الغرب",
      "حي الجنوب",
      "بورفؤاد"
    ],
    "السويس": [
      "السويس",
      "حي الأربعين",
      "حي عتاقة",
      "حي الجناين",
      "حي فيصل",
      "حي الأربعين"
    ],
    "دمياط": [
      "دمياط",
      "فارسكور",
      "الزرقا",
      "كفر سعد",
      "روض الفرج",
      "السرو",
      "رأس البر",
      "فارسكور"
    ],
    "كفر الشيخ": [
      "كفر الشيخ",
      "دسوق",
      "فوه",
      "مطوبس",
      "بلطيم",
      "الحامول",
      "سيدي سالم",
      "الرياض",
      "بيلا",
      "دسوق"
    ],
    "الفيوم": [
      "الفيوم",
      "طامية",
      "سنورس",
      "إطسا",
      "يوسف الصديق",
      "السيالة",
      "ابشواي",
      "زاوية الكرداسة",
      "طامية"
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
      "الواسطى"
    ],
    "المنيا": [
      "المنيا",
      "المنيا الجديدة",
      "ملوي",
      "دير مواس",
      "مغاغة",
      "بني مزار",
      "مطاي",
      "سمالوط",
      "أبو قرقاص",
      "ملوي"
    ],
    "أسيوط": [
      "أسيوط",
      "أسيوط الجديدة",
      "ديروط",
      "منفلوط",
      "القوصية",
      "أبنوب",
      "أبو تيج",
      "الغنايم",
      "ساحل سليم",
      "ديروط"
    ],
    "سوهاج": [
      "سوهاج",
      "سوهاج الجديدة",
      "أخميم",
      "بلينا",
      "المراغة",
      "المنشأة",
      "دار السلام",
      "جرجا",
      "طهطا",
      "أخميم"
    ],
    "قنا": [
      "قنا",
      "قنا الجديدة",
      "أبو تشت",
      "نجع حمادي",
      "دشنا",
      "الوقف",
      "قفط",
      "نقادة",
      "نجع حمادي"
    ],
    "الأقصر": [
      "الأقصر",
      "الزينية",
      "البياضية",
      "الطود",
      "أسنا",
      "إسنا",
      "القرنة",
      "أرمنت",
      "الزينية"
    ],
    "أسوان": [
      "أسوان",
      "أسوان الجديدة",
      "دراو",
      "كوم أمبو",
      "نصر النوبة",
      "إدفو",
      "الرديسية",
      "البصيلية",
      "دراو"
    ],
    "البحر الأحمر": [
      "الغردقة",
      "رأس غارب",
      "القصير",
      "سفاجا",
      "مرسى علم",
      "شلاتين",
      "حلايب",
      "رأس غارب"
    ],
    "الوادي الجديد": [
      "الخارجة",
      "الداخلة",
      "باريس",
      "موط",
      "الفرافرة",
      "بلاط",
      "الداخلة"
    ],
    "مطروح": [
      "مرسى مطروح",
      "الحمام",
      "العلمين",
      "الضبعة",
      "النجيلة",
      "سيوة",
      "براني",
      "الحمام"
    ],
    "شمال سيناء": [
      "العريش",
      "الشيخ زويد",
      "رفح",
      "بئر العبد",
      "الحسنة",
      "نخل",
      "الشيخ زويد"
    ],
    "جنوب سيناء": [
      "الطور",
      "شرم الشيخ",
      "دهب",
      "نويبع",
      "رأس سدر",
      "أبو رديس",
      "أبو زنيمة",
      "سانت كاترين",
      "شرم الشيخ"
    ]
  };

  final List<String> durationOptions = [
    'أسبوع',
    'أسبوعين',
    'شهر',
    'شهرين',
    'ثلاثة أشهر',
    'أكثر من ثلاثة أشهر'
  ];

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // جمع بيانات الطلب
      Map<String, dynamic> orderData = {
        'finishingType': finishingType,
        'placeType': placeType,
        'governorate': governorate,
        'area': area,
        'phone': _phoneController.text,
        'notes': _notesController.text,
        'duration': duration,
        'hasImage': _selectedImage != null,
        'orderNumber':
            DateTime.now().millisecondsSinceEpoch.toString().substring(8),
        'orderDate': DateTime.now().toString(),
      };

      // الانتقال إلى شاشة التتبع
      // مثال للاستدعاء الصحيح من شاشة أخرى:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinishingTrackingScreen(
            finishingType: 'تشطيب شقة',
            totalPrice: 50000.0,
            orderId: 'ORD-123456', // ← مطلوب
            serviceType: 'تشطيب داخلي', // ← مطلوب
            isRejected: false,
            rejectionReason: null,
          ),
        ),
      );
    }
  }

  // التحقق إذا كانت جميع الحقول المطلوبة مملوءة
  bool get _isFormComplete {
    return finishingType != null &&
        placeType != null &&
        governorate != null &&
        area != null &&
        _phoneController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "طلب خدمة تشطيب",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff1e66d4),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // بطاقة الترحيب مع الصورة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE0B2)),
                ),
                child: Column(
                  children: [
                    // صورة خدمة التشطيب
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD46F1E),
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                      child: const Icon(
                        Icons.architecture,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "مرحباً بك في خدمة التشطيب",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD46F1E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "املأ النموذج التالي بدقة وسنوفر لك أفضل المقاولين مع عروض أسعار تنافسية",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // نوع التشطيب
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "نوع التشطيب",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: finishingType,
                        items: finishingOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            finishingType = newValue;
                          });
                        },
                        hint: const Text("اختر نوع التشطيب"),
                      ),
                    ),
                  ],
                ),
              ),

              // نوع المكان
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "نوع المكان",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: placeType,
                        items: placeOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            placeType = newValue;
                          });
                        },
                        hint: const Text("اختر نوع المكان"),
                      ),
                    ),
                  ],
                ),
              ),

              // المحافظة والمنطقة في صف واحد
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "المحافظة",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              value: governorate,
                              items: governorateAreas.keys
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  governorate = newValue;
                                  area = null;
                                });
                              },
                              hint: const Text("اختر المحافظة"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "المنطقة",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              value: area,
                              items: (governorate != null
                                      ? governorateAreas[governorate]!
                                      : <String>[])
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  area = newValue;
                                });
                              },
                              hint: const Text("اختر المنطقة"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // زر تحديد الموقع على الخريطة
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // تحديد الموقع على الخريطة
                  },
                  icon: const Icon(Icons.map, color: Colors.white, size: 20),
                  label: const Text(
                    "تحديد الموقع على الخريطة",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // رقم الهاتف
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "رقم الهاتف",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        hintText: "أدخل رقم الهاتف",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم الهاتف';
                        }
                        if (value.length < 11) {
                          return 'رقم الهاتف يجب أن يكون 11 رقم على الأقل';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              // الملاحظات
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ملاحظات إضافية",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        hintText: "أضف أي ملاحظات أو متطلبات إضافية...",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              // إضافة صورة
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "إضافة صورة للمكان",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedImage == null
                                ? Colors.grey[300]!
                                : Colors.green,
                            width: 1,
                          ),
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    "اضغط لإضافة صورة للمكان",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white, size: 18),
                                        onPressed: _removeImage,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // المدة المتاحة للتنفيذ
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "المدة المتاحة للتنفيذ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: duration,
                        items: durationOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            duration = newValue;
                          });
                        },
                        hint: const Text("اختر المدة المتاحة"),
                      ),
                    ),
                  ],
                ),
              ),

              // ملخص الطلب (يظهر عندما تكتمل البيانات)
              if (_isFormComplete) _buildOrderSummary(),

              // زر إرسال الطلب
              Container(
                width: double.infinity,
                height: 55,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFormComplete ? const Color(0xFFD46F1E) : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isFormComplete ? _submitForm : null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "إرسال الطلب",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ملخص طلبك:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          if (finishingType != null)
            _buildSummaryItem("نوع التشطيب", finishingType!),
          if (placeType != null) _buildSummaryItem("نوع المكان", placeType!),
          if (governorate != null) _buildSummaryItem("المحافظة", governorate!),
          if (area != null) _buildSummaryItem("المنطقة", area!),
          if (_phoneController.text.isNotEmpty)
            _buildSummaryItem("رقم الهاتف", _phoneController.text),
          if (_notesController.text.isNotEmpty)
            _buildSummaryItem("الملاحظات", _notesController.text),
          if (duration != null) _buildSummaryItem("المدة المتاحة", duration!),
          if (_selectedImage != null) _buildSummaryItem("صورة مرفقة", "نعم"),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFC8E6C9)),
          const SizedBox(height: 8),
          const Text(
            "جاهز للإرسال",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label: ",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
