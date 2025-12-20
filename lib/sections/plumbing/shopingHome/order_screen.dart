import 'package:flutter/material.dart';
import 'AdvancedTrackingScreen.dart';
import '/sections/ElectronicPaymentScreen.dart'; // تأكد من المسار الصحيح
import '/sections/GeneralRatingScreen.dart'; // تأكد من المسار الصحيح

class OrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;
  final String shopName;

  const OrderScreen({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
    required this.shopName,
  }) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String? selectedGovernorate;
  String? selectedDistrict;
  String? selectedPaymentMethod;
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool orderConfirmed = false;
  String orderId = '';

  // بيانات محافظات ومناطق مصر كاملة
  final Map<String, List<String>> governorateDistricts = {
    'القاهرة': [
      'المعادي',
      'المطرية',
      'النزهة',
      'الوايلي',
      'الزيتون',
      'الزمالك',
      'مصر الجديدة',
      'شبرا',
      'حدائق القبة',
      'العباسية',
      'باب الشعرية',
      'السيدة زينب',
      'الخليفة',
      'المقطم',
      '15 مايو',
      'السلام',
      'الشرابية',
      'الدراسة',
      'الأزبكية',
      'غرب القاهرة',
      'وسط القاهرة',
      'شرق القاهرة',
      'منشأة ناصر',
      'البساتين',
      'دار السلام',
      'المستقبل',
      'المرج',
      'عين شمس',
      'المنيل',
      'روض الفرج',
      'امبابة',
      'الوراق',
      'العمرانية',
      'التحرير',
      'الفسطاط',
      'الموسكي',
      'القلعة'
    ],
    'الجيزة': [
      'الدقي',
      'المهندسين',
      'العجوزة',
      'الهرم',
      'بولاق',
      'الوراق',
      'امبابة',
      'العمرانية',
      'المنيب',
      'كرداسة',
      'أوسيم',
      'الصف',
      'أطفيح',
      'الواحات البحرية',
      'منشأة القناطر',
      'أبو النمرس',
      'كفر غطاطي',
      'منشأة البكاري',
      'البداري',
      'المنصورية',
      'البساتين',
      'الطالبية',
      'الوحدة',
      'العمرانية',
      'الهرم'
    ],
    'الإسكندرية': [
      'سموحة',
      'المعمورة',
      'المنتزه',
      'العصافرة',
      'اللبان',
      'الجمرك',
      'الأنفوشي',
      'العطارين',
      'محطة مصر',
      'الظاهرية',
      'كرموز',
      'السبورتنج',
      'سيدي جابر',
      'فلمنج',
      'ستانلي',
      'سان ستيفانو',
      'فيكتوريا',
      'بولكلي',
      'جليم',
      'كامب شيزار',
      'الأزاريطة',
      'مينا البصل',
      'الدخيلة',
      'العجمي',
      'الهانوفيل',
      'المكس',
      'المندرة',
      'أبو قير',
      'برج العرب',
      'برج العرب الجديدة',
      'المعمورة',
      'المنشية'
    ],
    'الدقهلية': [
      'المنصورة',
      'طلخا',
      'ميت غمر',
      'دكرنس',
      'أجا',
      'منية النصر',
      'السنبلاوين',
      'بلقاس',
      'شربين',
      'تمي الأمديد',
      'الجمالية',
      'بني عبيد',
      'المنزلة',
      'ميت سلسيل',
      'جمصة',
      'شروين',
      'نبروه',
      'محلة دمنة',
      'المنصورة الجديدة'
    ],
    'البحيرة': [
      'دمنهور',
      'كفر الدوار',
      'رشيد',
      'إدكو',
      'أبو المطامير',
      'أبو حمص',
      'الدلنجات',
      'المحمودية',
      'الرحمانية',
      'إيتاي البارود',
      'حوش عيسى',
      'شبراخيت',
      'كوم حمادة',
      'بدر',
      'وادي النطرون',
      'النوبارية',
      'المريوطية',
      'الدلنجات'
    ],
    'القليوبية': [
      'بنها',
      'قليوب',
      'شبرا الخيمة',
      'القناطر الخيرية',
      'الخانكة',
      'كفر شكر',
      'طوخ',
      'العويضة',
      'الخصوص',
      'كفر شكر',
      'الخانكة'
    ],
    'الغربية': [
      'طنطا',
      'المحلة الكبرى',
      'زفتى',
      'سمنود',
      'كفر الزيات',
      'بسيون',
      'قطور',
      'سنبلاوين',
      'بسيون',
      'صفتا',
      'طنطا'
    ],
    'المنوفية': [
      'شبين الكوم',
      'مدينة السادات',
      'منوف',
      'أشمون',
      'الباجور',
      'قويسنا',
      'بركة السبع',
      'تلا',
      'الشهداء',
      'سرس الليان',
      'الباجور',
      'شبين الكوم'
    ],
    'الفيوم': [
      'الفيوم',
      'طامية',
      'سنورس',
      'إطسا',
      'يوسف الصديق',
      'الجامعة',
      'الفنت',
      'الفيوم الجديدة'
    ],
    'المنيا': [
      'المنيا',
      'ملوي',
      'دير مواس',
      'مغاغة',
      'بني مزار',
      'مطاي',
      'سمالوط',
      'العدوة',
      'ابوقرقاص',
      'مغاغة',
      'المنيا الجديدة'
    ],
    'أسيوط': [
      'أسيوط',
      'ديروط',
      'قوصيا',
      'أبنوب',
      'منفلوط',
      'الفتح',
      'أبو تيج',
      'غرب أسيوط',
      'صدفا',
      'البداري',
      'القوصية',
      'أسيوط الجديدة'
    ],
    'سوهاج': [
      'سوهاج',
      'جرجا',
      'أخميم',
      'البلينا',
      'المراغة',
      'جهينة',
      'دار السلام',
      'طما',
      'طهطا',
      'المنشاة',
      'ساقلته',
      'سوهاج الجديدة'
    ],
    'قنا': [
      'قنا',
      'قفط',
      'نقادة',
      'دشنا',
      'فرشوط',
      'قوص',
      'ابو تشت',
      'الوقف',
      'الرحمانية',
      'نجع حمادي',
      'قنا الجديدة'
    ],
    'أسوان': [
      'أسوان',
      'كوم أمبو',
      'دراو',
      'نصر النوبة',
      'إدفو',
      'الرديسية',
      'البصيلية',
      'السباعية',
      'كلابشة',
      'أسوان الجديدة'
    ],
    'الأقصر': [
      'الأقصر',
      'الزينية',
      'البياضية',
      'الطود',
      'أرمنت',
      'اسنا',
      'القرنة',
      'الأقصر الجديدة'
    ],
    'البحر الأحمر': [
      'الغردقة',
      'رأس غارب',
      'سفاجا',
      'القصير',
      'مرسى علم',
      'حلايب',
      'شلاتين',
      'الغردقة الجديدة'
    ],
    'الوادي الجديد': [
      'الخارجة',
      'الداخلة',
      'باريس',
      'موط',
      'بلاط',
      'الفرافرة',
      'الخارجة الجديدة'
    ],
    'مرسى مطروح': [
      'مرسى مطروح',
      'الحمام',
      'العلمين',
      'الضبعة',
      'النجيلة',
      'سيدي براني',
      'السلوم',
      'مرسى مطروح الجديدة'
    ],
    'شمال سيناء': [
      'العريش',
      'الشيخ زويد',
      'رفح',
      'بئر العبد',
      'الحسنة',
      'نخل',
      'العريش الجديدة'
    ],
    'جنوب سيناء': [
      'الطور',
      'شرم الشيخ',
      'دهب',
      'نويبع',
      'رأس سدر',
      'أبو رديس',
      'أبو زنيمة',
      'سانت كاترين',
      'الطور الجديدة'
    ],
    'بورسعيد': [
      'بورسعيد',
      'حي الشرق',
      'حي الغرب',
      'حي الجنوب',
      'حي الضواحي',
      'حي الزهور',
      'بورسعيد الجديدة'
    ],
    'الإسماعيلية': [
      'الإسماعيلية',
      'فايد',
      'القنطرة شرق',
      'القنطرة غرب',
      'التل الكبير',
      'أبو صوير',
      'الإسماعيلية الجديدة'
    ],
    'السويس': [
      'السويس',
      'حي الأربعين',
      'حي عتاقة',
      'حي الجناين',
      'حي السويس',
      'السويس الجديدة'
    ],
    'كفر الشيخ': [
      'كفر الشيخ',
      'دسوق',
      'فوه',
      'مطوبس',
      'بلطيم',
      'الحامول',
      'سيدي سالم',
      'الرياض',
      'بيلا',
      'برج البرلس',
      'كفر الشيخ الجديدة'
    ],
    'بنى سويف': [
      'بني سويف',
      'الواسطي',
      'ناصر',
      'إهناسيا',
      'ببا',
      'سمسطا',
      'الفشن',
      'مغاغة',
      'بني سويف الجديدة'
    ],
    'الشرقية': [
      'الزقازيق',
      'بلبيس',
      'أبو حماد',
      'ههيا',
      'فاقوس',
      'منيا القمح',
      'أبو كبير',
      'الحسينية',
      'صان الحجر',
      'كفر صقر',
      'الإبراهيمية',
      'ديرب نجم',
      'الشرقية الجديدة'
    ],
    'دمياط': [
      'دمياط',
      'دمياط الجديدة',
      'الروضة',
      'السرو',
      'كفر سعد',
      'الزرقا',
      'ميت أبو غالب',
      'فارسكور',
      'دمياط الجديدة'
    ],
    'السادس من أكتوبر': [
      'الحي الأول',
      'الحي الثاني',
      'الحي الثالث',
      'الحي الرابع',
      'الحي الخامس',
      'الحي السادس',
      'الحي السابع',
      'الحي الثامن',
      'الحي التاسع',
      'الحي العاشر'
    ],
    'حلوان': ['حلوان', 'التبين', '15 مايو', ' المعصرة', 'طرة', 'حلوان الجديدة'],
  };

  // استخدام المنتجات المرسلة من الشاشة الأولى
  List<Map<String, dynamic>> get products => widget.cartItems;
  double get totalPrice => widget.totalAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'إتمام الطلب - ${widget.shopName}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم العنوان
            _buildAddressSection(),
            SizedBox(height: 20),

            // قسم المنتجات
            _buildProductsSection(),
            SizedBox(height: 20),

            // قسم طرق الدفع المبسط
            _buildPaymentSection(),
            SizedBox(height: 30),

            // زر تأكيد الطلب
            _buildConfirmButton(),

            // زر تتبع الطلب (يظهر فقط بعد تأكيد الطلب)
            if (orderConfirmed) ...[
              SizedBox(height: 16),
              _buildAdvancedTrackingButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                ),
                SizedBox(width: 12),
                Text(
                  'عنوان التوصيل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // اختيار المحافظة
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المحافظة',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGovernorate,
                      isExpanded: true,
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('اختر المحافظة'),
                      ),
                      items:
                          governorateDistricts.keys.map((String governorate) {
                        return DropdownMenuItem<String>(
                          value: governorate,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              governorate,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGovernorate = newValue;
                          selectedDistrict = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // اختيار المنطقة
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنطقة',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDistrict,
                      isExpanded: true,
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('اختر المنطقة'),
                      ),
                      items: selectedGovernorate != null
                          ? governorateDistricts[selectedGovernorate]!
                              .map((String district) {
                              return DropdownMenuItem<String>(
                                value: district,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    district,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }).toList()
                          : null,
                      onChanged: selectedGovernorate != null
                          ? (String? newValue) {
                              setState(() {
                                selectedDistrict = newValue;
                              });
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // العنوان التفصيلي
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'العنوان التفصيلي',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText:
                          'ادخل العنوان بالتفصيل (الشارع - العمارة - الشقة)',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // رقم الهاتف مع التحقق من البدء بـ 01
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رقم الهاتف',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم الهاتف (يجب أن يبدأ بـ 01)',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    onChanged: (value) {
                      // التحقق من أن الرقم يبدأ بـ 01
                      if (value.isNotEmpty && !value.startsWith('01')) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                if (phoneController.text.isNotEmpty &&
                    !phoneController.text.startsWith('01'))
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'يجب أن يبدأ رقم الهاتف بـ 01',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
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

  Widget _buildProductsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shopping_bag, color: Color(0xFFFFA000)),
                ),
                SizedBox(width: 12),
                Text(
                  'المنتجات المطلوبة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA000),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // قائمة المنتجات
            ...products.map((product) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'الكمية: ${product['quantity']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${product['price']} ج.م',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            Divider(height: 30, color: Colors.grey[300]),

            // المجموع الكلي
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المجموع الكلي:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    '$totalPrice ج.م',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
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

  Widget _buildPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.payment, color: Color(0xFF1976D2)),
                ),
                SizedBox(width: 12),
                Text(
                  'طريقة الدفع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // طرق الدفع المبسطة
            Column(
              children: [
                _buildPaymentOption('كاش', Icons.money, 'cash'),
                SizedBox(height: 12),
                _buildPaymentOption(
                    'الكتروني', Icons.credit_card, 'electronic'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String method) {
    bool isSelected = selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE8F5E8) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Color(0xFF2E7D32) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF2E7D32) : Colors.grey[600],
              size: 32,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Color(0xFF2E7D32) : Colors.grey[700],
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    bool isFormValid = selectedGovernorate != null &&
        selectedDistrict != null &&
        addressController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        phoneController.text.startsWith('01') &&
        selectedPaymentMethod != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E7D32).withOpacity(isFormValid ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: isFormValid ? _confirmOrder : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid ? Color(0xFF2E7D32) : Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'تأكيد الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedTrackingButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _navigateToAdvancedTracking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2196F3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.track_changes, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'تتبع حالة الطلب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAdvancedTracking() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => AdvancedTrackingScreens(
          orderId: orderId,
          customerName: 'العميل',
          items: products,
          totalAmount: totalPrice,
          deliveryAddress:
              '$selectedGovernorate - $selectedDistrict - ${addressController.text}',
          phoneNumber: phoneController.text.isNotEmpty
              ? phoneController.text
              : '01000000000',
        ),
      ),
      (route) => false,
    );
  }

  void _confirmOrder() {
    if (selectedGovernorate == null || selectedDistrict == null) {
      _showMessage('يرجى اختيار العنوان بالكامل');
      return;
    }

    if (addressController.text.isEmpty) {
      _showMessage('يرجى إدخال العنوان التفصيلي');
      return;
    }

    if (phoneController.text.isEmpty) {
      _showMessage('يرجى إدخال رقم الهاتف');
      return;
    }

    if (!phoneController.text.startsWith('01')) {
      _showMessage('يجب أن يبدأ رقم الهاتف بـ 01');
      return;
    }

    if (phoneController.text.length != 11) {
      _showMessage('يجب أن يتكون رقم الهاتف من 11 رقم');
      return;
    }

    if (selectedPaymentMethod == null) {
      _showMessage('يرجى اختيار طريقة الدفع');
      return;
    }

    // إذا كان الدفع إلكتروني، انتقل لشاشة الدفع
    if (selectedPaymentMethod == 'electronic') {
      _navigateToElectronicPayment();
    } else {
      // إذا كان الدفع كاش، أكمل العملية مباشرة
      _completeOrder();
    }
  }

  void _navigateToElectronicPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElectronicPaymentScreen(
          orderId: 'ORD${DateTime.now().microsecondsSinceEpoch}',
          amount: totalPrice,
          serviceType: "طلب من ${widget.shopName}",
        ),
      ),
    ).then((value) {
      // عند العودة من شاشة الدفع، إذا تم الدفع بنجاح
      if (value == true && mounted) {
        _completeOrder();
      } else {
        // إذا لم يتم الدفع أو تم الإلغاء
        _showMessage('تم إلغاء عملية الدفع');
      }
    });
  }

  void _completeOrder() {
    setState(() {
      orderConfirmed = true;
      orderId = 'EG${DateTime.now().microsecondsSinceEpoch}';
    });

    // عرض رسالة نجاح
    _showSuccessMessage();

    // الانتقال لشاشة التتبع بعد ثواني
    Future.delayed(Duration(seconds: 2), () {
      _navigateToAdvancedTracking();
    });
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedPaymentMethod == 'electronic'
              ? 'تم الدفع بنجاح! جاري توجيهك لصفحة التتبع...'
              : 'تم تأكيد الطلب بنجاح! جاري توجيهك لصفحة التتبع...',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
