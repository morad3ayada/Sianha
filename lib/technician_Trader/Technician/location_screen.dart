import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// تعريف مراحل الطلب
enum RequestStage {
  received, // تم استلام طلب
  technicianMoving, // تم تحرك الفني
  technicianArrived, // تم وصول الفني
  serviceInProgress, // جاري تنفيذ الخدمة
  priceAndDetails, // تحديد السعر والتفاصيل (مرحلة جديدة)
  paymentDue, // انتظار الدفع (مرحلة خاصة بالدفع)
  completedSuccess, // تم الانتهاء بنجاح
  cancelled, // إلغاء الطلب
  postponed, // تأجيل التصليح
}

class LocationScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const LocationScreen({super.key, required this.request});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // تتبع حالة الطلب الحالية
  RequestStage _currentStage = RequestStage.received;

  // متغيرات جديدة للسعر والتفاصيل والصور
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _repairDetailsController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  void dispose() {
    _priceController.dispose();
    _repairDetailsController.dispose();
    super.dispose();
  }

  // 📸 منطق التقاط الصور
  Future<void> _pickImages(StateSetter setDialogState) async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (images != null && images.isNotEmpty) {
        setDialogState(() {
          _selectedImages.addAll(images);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'تم رفع ${images.length} صور جديدة. العدد الكلي: ${_selectedImages.length}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في رفع الصور: $e')),
        );
      }
    }
  }

  void _removeImage(int index, StateSetter setDialogState) {
    setDialogState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildImageGrid(StateSetter setDialogState) {
    if (_selectedImages.isEmpty) {
      return GestureDetector(
        onTap: () => _pickImages(setDialogState),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('انقر لرفع صور بعد الصيانة',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('الصور المرفوعة:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _pickImages(setDialogState),
              icon: const Icon(Icons.add),
              label: const Text('إضافة المزيد'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            // التحقق من نوع الملف قبل التحويل إلى File
            final imagePath = _selectedImages[index].path;
            final imageFile = File(imagePath);

            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index, setDialogState),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // 📝 دالة إظهار مربع حوار تحديد السعر والتفاصيل
  void _showPriceAndDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // يستخدم لتحديث عداد الصور
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('📝 تحديد السعر وتفاصيل الصيانة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تحديد السعر
                  const Text('💰 سعر الصيانة (ريال):',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'أدخل سعر الصيانة',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // شرح الصيانة
                  const Text('📋 شرح ما تم في الصيانة:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _repairDetailsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'اشرح بالتفصيل ما تم إصلاحه...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // رفع الصور
                  const Text('📸 صور بعد الصيانة:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildImageGrid(setDialogState),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final String price = _priceController.text.trim();
                  final String details = _repairDetailsController.text.trim();

                  // التحقق من الحقول الإلزامية
                  if (price.isEmpty ||
                      details.isEmpty ||
                      _selectedImages.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'يرجى إدخال السعر والشرح ورفع صورة واحدة على الأقل')),
                    );
                    return;
                  }

                  // 🚀 هنا يتم إرسال البيانات المجمعة للباك إند:
                  // 1. السعر: price
                  // 2. الشرح: details
                  // 3. الصور: _selectedImages (يتم معالجتها للرفع)
                  print(
                      '✅ البيانات جاهزة للإرسال: السعر=$price، الشرح=$details، الصور=${_selectedImages.length}');

                  Navigator.pop(context);
                  _updateStage(RequestStage.paymentDue);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تم حفظ التفاصيل بنجاح، بانتظار الدفع.')),
                  );
                },
                child: const Text('حفظ والمتابعة للدفع'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🏗️ دالة البناء الرئيسية (تم تصحيح الـ Overflow هنا)
  @override
  Widget build(BuildContext context) {
    // استخراج بيانات الطلب مع التأكد من النوع لتجنب خطأ Object to String
    final customer = widget.request['customer'] as String? ?? 'غير محدد';
    final address = widget.request['address'] as String? ?? 'غير محدد';
    final governorate = widget.request['governorate'] as String? ?? 'غير محدد';
    final phone = widget.request['phone'] as String? ?? 'غير متوفر';

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.amber[700],
      ),
      body: Column(
        children: [
          // 1. الخريطة (الجزء العلوي) - محدد بارتفاع نسبي (Flex: 2)
          Expanded(
            flex: 2,
            child: _buildMapSection(context),
          ),

          // 2. معلومات الموقع والأزرار (الجزء السفلي) - محدد بارتفاع نسبي (Flex: 3)
          Expanded(
            // ⬅️ Expanded لتحديد حجم الجزء السفلي
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                // ⬅️ SingleChildScrollView لجعل المحتوى قابلاً للتمرير
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // تفاصيل الموقع
                    const Text(
                      'تفاصيل الموقع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLocationInfo('👤 العميل', customer),
                    _buildLocationInfo('📍 العنوان', address),
                    _buildLocationInfo('🏙️ المحافظة', governorate),
                    _buildLocationInfo('📞 الهاتف', phone),
                    const SizedBox(height: 16),
                    _buildDistanceInfo('المسافة', '2.5 كم'),
                    _buildDistanceInfo('الوقت المتوقع', '10 دقائق'),
                    _buildDistanceInfo('التكلفة التقريبية', '15 جنية'),

                    // عرض السعر إذا تم تحديده
                    if (_priceController.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildPriceInfo(
                          '💰 السعر المحدد', '${_priceController.text} جنية'),
                    ],

                    const SizedBox(height: 20),

                    // **منطقة التحكم في مراحل الطلب**
                    _buildStageControlButtons(context),

                    // عرض رسالة في حالة الإلغاء/التأجيل/الانتهاء
                    if (_currentStage == RequestStage.cancelled)
                      _buildStatusMessage(
                          '❌ تم إلغاء الطلب.', Colors.red[100]!, Colors.red),
                    if (_currentStage == RequestStage.postponed)
                      _buildStatusMessage('🕒 تم تأجيل التصليح.',
                          Colors.orange[100]!, Colors.orange),
                    if (_currentStage == RequestStage.completedSuccess)
                      _buildStatusMessage('✅ تم إنجاز الخدمة بنجاح.',
                          Colors.green[100]!, Colors.green),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- دالة تحديد عنوان الشريط العلوي بناءً على الحالة ---
  String _getAppBarTitle() {
    switch (_currentStage) {
      case RequestStage.received:
        return 'تم استلام الطلب';
      case RequestStage.technicianMoving:
        return 'الفني في الطريق';
      case RequestStage.technicianArrived:
        return 'الفني وصل الموقع';
      case RequestStage.serviceInProgress:
        return 'جاري تنفيذ الخدمة';
      case RequestStage.priceAndDetails:
        return 'تحديد السعر والتفاصيل';
      case RequestStage.paymentDue:
        return 'الدفع والمحاسبة';
      case RequestStage.completedSuccess:
        return 'الخدمة منتهية بنجاح';
      case RequestStage.cancelled:
        return 'الطلب ملغي';
      case RequestStage.postponed:
        return 'الطلب مؤجل';
    }
  }

  // --- دالة بناء قسم الخريطة (المحاكاة) ---
  Widget _buildMapSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          Container(
            color: Colors.grey[100],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('خريطة موقع العميل',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          ),
          Positioned(
            // تم تعديل الموقع ليتناسب مع flex: 2
            top: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.45,
            child: const Column(
              children: [
                Icon(Icons.location_pin, color: Colors.red, size: 40),
                Text('موقع العميل',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- دالة بناء الأزرار بناءً على المرحلة الحالية ---
  Widget _buildStageControlButtons(BuildContext context) {
    switch (_currentStage) {
      case RequestStage.received:
        return _buildActionRow(
          context,
          'تم تحرك الفني',
          () => _updateStage(RequestStage.technicianMoving),
        );

      case RequestStage.technicianMoving:
        return _buildActionRow(
          context,
          'تم وصول الفني',
          () => _updateStage(RequestStage.technicianArrived),
        );

      case RequestStage.technicianArrived:
        return _buildActionRow(
          context,
          'بدء تنفيذ الخدمة',
          () => _updateStage(RequestStage.serviceInProgress),
        );

      case RequestStage.serviceInProgress:
        return Column(
          children: [
            // زر تحديد السعر والتفاصيل (يؤدي إلى الـ Dialog)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _showPriceAndDetailsDialog,
                icon: const Icon(Icons.assignment, color: Colors.white),
                label: const Text(
                  'تحديد السعر والتفاصيل',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // أزرار الإلغاء والتأجيل
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancellationDialog(context),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('إلغاء الطلب',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPostponeDialog(context),
                    icon: const Icon(Icons.access_time, color: Colors.blue),
                    label: const Text('تأجيل التصليح',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ),
              ],
            ),
          ],
        );

      case RequestStage.priceAndDetails:
        // هذه الحالة يجب أن تنتقل مباشرة إلى paymentDue بعد حفظ التفاصيل من الـ Dialog
        // هذا الجزء هنا لتوفير إمكانية التعديل
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _showPriceAndDetailsDialog,
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'تعديل السعر والتفاصيل',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () => _updateStage(RequestStage.paymentDue),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text(
                  'المتابعة للدفع',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );

      case RequestStage.paymentDue:
        return Column(
          children: [
            // عرض ملخص المعلومات
            if (_priceController.text.isNotEmpty ||
                _repairDetailsController.text.isNotEmpty)
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ملخص الطلب',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      if (_priceController.text.isNotEmpty)
                        _buildPriceRow('السعر', '${_priceController.text} جنية'),
                      if (_repairDetailsController.text.isNotEmpty)
                        _buildPriceRow('الشرح', _repairDetailsController.text),
                      if (_selectedImages.isNotEmpty)
                        _buildPriceRow(
                            'الصور', '${_selectedImages.length} صورة'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),

            const Text(
              'اختر طريقة الدفع لإتمام الطلب:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // زر الدفع النقدي (كاش)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () => _completeRequest(context, 'كاش'),
                icon: const Icon(Icons.money, color: Colors.white),
                label: const Text(
                  'استلم الفني كاش',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // زر الدفع الإلكتروني
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blueAccent),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () => _completeRequest(context, 'إلكتروني'),
                icon: const Icon(Icons.credit_card, color: Colors.blueAccent),
                label: const Text(
                  'الدفع الإلكتروني (بطاقة)',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),

            // زر تعديل التفاصيل
            TextButton.icon(
              onPressed:
                  _showPriceAndDetailsDialog, // العودة للـ Dialog للتعديل
              icon: const Icon(Icons.edit),
              label: const Text('تعديل السعر والتفاصيل'),
            ),
          ],
        );

      case RequestStage.completedSuccess:
      case RequestStage.cancelled:
      case RequestStage.postponed:
        return const SizedBox.shrink();
    }
  }

  // --- دوال مساعدة لتصميم العناصر ---

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
      BuildContext context, String buttonText, VoidCallback onPressed) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: onPressed,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: Text(
              buttonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // زر الإلغاء والتأجيل يظهر دائماً حتى يتم بدء الخدمة أو الانتقال لمرحلة الدفع
        if (_currentStage != RequestStage.serviceInProgress &&
            _currentStage != RequestStage.paymentDue &&
            _currentStage != RequestStage.priceAndDetails)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCancellationDialog(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('إلغاء الطلب',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPostponeDialog(context),
                  icon: const Icon(Icons.access_time, color: Colors.blue),
                  label: const Text('تأجيل التصليح',
                      style: TextStyle(color: Colors.blue)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatusMessage(String message, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // الدوال المساعدة الأخرى
  Widget _buildLocationInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.amber[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- منطق تغيير المراحل (Update Logic) ---

  void _updateStage(RequestStage newStage) {
    setState(() {
      _currentStage = newStage;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث حالة الطلب إلى: ${_getAppBarTitle()}')),
    );
  }

  void _completeRequest(BuildContext context, String paymentMethod) {
    _updateStage(RequestStage.completedSuccess);

    // ملاحظة: لا يجب إغلاق الشاشة هنا إذا كان هذا الزر داخل شاشة تفاصيل الموقع
    // تم إزالة Navigator.pop(context); من دالة _completeRequest

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'تم إنهاء الخدمة بنجاح. طريقة الدفع: $paymentMethod - السعر: ${_priceController.text} جنية')),
    );
  }

  // --- دوال الـ Dialogs (إلغاء وتأجيل) ---

  void _showCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ReasonDialog(
        title: 'إلغاء الطلب',
        reasonLabel: 'سبب الإلغاء (من اختيار الفني)',
        stageToSet: RequestStage.cancelled,
        onConfirm: (reason) {
          _updateStage(RequestStage.cancelled);
          Navigator.pop(context); // إغلاق Dialog السبب
        },
        reasons: const [
          'العميل ألغى الطلب',
          'عدم توفر قطع الغيار',
          'لا يوجد فني مناسب',
          'أسباب أخرى',
        ],
      ),
    );
  }

  void _showPostponeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ReasonDialog(
        title: 'تأجيل التصليح',
        reasonLabel: 'سبب التأجيل (يجب توفره)',
        stageToSet: RequestStage.postponed,
        onConfirm: (reason) {
          _updateStage(RequestStage.postponed);
          Navigator.pop(context); // إغلاق Dialog السبب
        },
        reasons: const [
          'لا يوجد حل حالي',
          'في ضمن طلبات أخرى',
          'طلب قطع غيار إضافية',
          'تأجيل بناءً على طلب العميل',
        ],
      ),
    );
  }
}

// **مكون Dialog لإختيار سبب الإلغاء أو التأجيل**
class _ReasonDialog extends StatefulWidget {
  final String title;
  final String reasonLabel;
  final RequestStage stageToSet;
  final List<String> reasons;
  final Function(String) onConfirm;

  const _ReasonDialog({
    required this.title,
    required this.reasonLabel,
    required this.stageToSet,
    required this.reasons,
    required this.onConfirm,
  });

  @override
  State<_ReasonDialog> createState() => __ReasonDialogState();
}

class __ReasonDialogState extends State<_ReasonDialog> {
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.reasonLabel),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            value: _selectedReason,
            hint: const Text('اختر سبباً'),
            items: widget.reasons
                .map((reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('تراجع'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.stageToSet == RequestStage.cancelled
                ? Colors.red
                : Colors.blue,
          ),
          onPressed: _selectedReason == null
              ? null
              : () => widget.onConfirm(_selectedReason!),
          child: Text(
              'تأكيد ${widget.title.contains('إلغاء') ? 'الإلغاء' : 'التأجيل'}'),
        ),
      ],
    );
  }
}
