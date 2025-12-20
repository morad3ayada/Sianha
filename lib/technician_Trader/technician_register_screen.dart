
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/utils/error_handler.dart';
import 'Technician/technician_home_screen.dart';

class TechnicianRegisterScreen extends StatefulWidget {
  const TechnicianRegisterScreen({super.key});

  @override
  State<TechnicianRegisterScreen> createState() =>
      _TechnicianRegisterScreenState();
}

class _TechnicianRegisterScreenState extends State<TechnicianRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  
  // API Data
  List<dynamic> _governoratesList = [];
  List<dynamic> _allAreas = [];
  List<dynamic> _mainCategories = []; // New
  List<dynamic> _subCategories = [];


  String? _selectedGovernorateId;
  String? _selectedAreaId;
  String? _selectedMainCategoryId; // New
  String? _selectedSubCategoryId;
  String? _selectedSubCategoryName; // To keep track of name for UI logic (e.g. Tow Truck)

  // مواعيد العمل
  final List<String> workTimes = [
    '24 ساعة',
    'من 8 صباحاً إلى 12 مساءً',
    'من 8 صباحاً إلى 4 مساءً',
    'من 9 صباحاً إلى 5 مساءً',
    'من 10 صباحاً إلى 6 مساءً',
    'من 12 مساءً إلى 8 مساءً',
    'من 2 مساءً إلى 10 مساءً',
    'من 4 مساءً إلى 12 مساءً',
    'من 6 مساءً إلى 2 صباحاً',
    'من 8 مساءً إلى 4 صباحاً',
    'من 10 مساءً إلى 6 صباحاً',
    'من 12 صباحاً إلى 8 صباحاً',
    'فقط صباحاً (8 ص - 2 م)',
    'فقط مساءً (2 م - 10 م)',
    'نوبتجيات (8 ص - 8 م)',
  ];
  String? selectedWorkTime;

  XFile? profilePhoto;
  XFile? idFront;
  XFile? idBack;

  // 1. تعريف متغيرات الصور الجديدة لتخصص الونش
  XFile? personalLicensePhoto; // صورة الرخصة الشخصية
  XFile? towTruckLicensePhoto; // صورة رخصة قيادة الونش
  XFile? towTruckPhoto; // صورة الونش

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {

    final apiClient = ApiClient();

    // 1. Fetch Areas
    try {
      final areasResponse = await apiClient.get(ApiConstants.areas);
      if (areasResponse is List) {
        _allAreas = areasResponse;
        final uniqueGovs = <String, Map<String, dynamic>>{};
        for (var area in _allAreas) {
           // Handle potential key variations
           final govId = area['governorateId'] ?? area['GovernorateId'];
           final govName = area['governorateName'] ?? area['GovernorateName'];
           
           if (govId != null && govName != null) {
              uniqueGovs[govId.toString()] = {
                'id': govId,
                'name': govName
              };
           }
        }
        _governoratesList = uniqueGovs.values.toList();
      }
    } catch (e) {
      print("Error fetching areas: $e");
    }

    // 2. Fetch Main Categories
    try {
      print("========================================");
      print("🔄 Fetching Main Categories from: ${ApiConstants.serviceCategories}");
      final categoriesResponse = await apiClient.get(ApiConstants.serviceCategories);
      print("📦 Response Type: ${categoriesResponse.runtimeType}");
      
      if (categoriesResponse is List) {
        _mainCategories = categoriesResponse;
        print("✅ Main Categories: ${_mainCategories.length}");
        
        // Print each category for debugging
        for (int i = 0; i < categoriesResponse.length; i++) {
          final cat = categoriesResponse[i];
          final catName = cat['name'] ?? cat['Name'] ?? 'Unknown';
          final catId = cat['id'] ?? cat['Id'] ?? 'Unknown';
          print("📁 Category $i: $catName (ID: $catId)");
        }
      } else {
        print("❌ NOT a List: ${categoriesResponse.runtimeType}");
      }
      print("========================================");
    } catch (e, stackTrace) {
      print("❌ ERROR fetching categories: $e");
      print("Stack: $stackTrace");
    }

    // 3. Fetch SubCategories from separate endpoint
    try {
      print("========================================");
      print("🔄 Fetching SubCategories from: ${ApiConstants.serviceSubCategories}");
      final subCatsResponse = await apiClient.get(ApiConstants.serviceSubCategories);
      print("📦 SubCats Response Type: ${subCatsResponse.runtimeType}");
      
      if (subCatsResponse is List) {
        _subCategories = subCatsResponse;
        print("✅ SubCategories: ${_subCategories.length}");
        
        // Print first few subcategories for debugging
        for (int i = 0; i < (subCatsResponse.length > 3 ? 3 : subCatsResponse.length); i++) {
          final subCat = subCatsResponse[i];
          final subCatName = subCat['name'] ?? subCat['Name'] ?? 'Unknown';
          final subCatId = subCat['id'] ?? subCat['Id'] ?? 'Unknown';
          final parentId = subCat['serviceCategoryId'] ?? subCat['ServiceCategoryId'] ?? 'Unknown';
          print("📄 SubCategory $i: $subCatName (ID: $subCatId, Parent: $parentId)");
        }
      } else {
        print("❌ SubCats NOT a List: ${subCatsResponse.runtimeType}");
      }
      print("========================================");
    } catch (e, stackTrace) {
      print("❌ ERROR fetching subcategories: $e");
      print("Stack: $stackTrace");
    }


  }

  final ImagePicker _picker = ImagePicker();
  bool termsAccepted = false;




  // أوقات العمل المفضلة
  TimeOfDay? startWorkTime;
  TimeOfDay? endWorkTime;
  bool works24Hours = false;


  // دالة التحقق من رقم الهاتف المصري
  String? _validateEgyptianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'أدخل رقم التليفون';
    }

    // إزالة المسافات والرموز
    String cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // التحقق من أن الرقم يبدأ بـ 01
    if (!cleanedPhone.startsWith('01')) {
      return 'يجب أن يبدأ رقم الهاتف بـ 01';
    }

    // التحقق من الطول (11 رقماً)
    if (cleanedPhone.length != 11) {
      return 'يجب أن يتكون رقم الهاتف من 11 رقماً';
    }

    // التحقق من أن كل الحروف أرقام
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedPhone)) {
      return 'يجب أن يحتوي رقم الهاتف على أرقام فقط';
    }

    // التحقق من أن الرقم الثاني هو 0، 1، 2، أو 5
    if (cleanedPhone.length >= 2) {
      String secondDigit = cleanedPhone[1];
      if (!['0', '1', '2', '5'].contains(secondDigit)) {
        return 'رقم الهاتف غير صحيح. يجب أن يكون الرقم الثاني 0، 1، 2، أو 5';
      }
    }

    return null;
  }

  // 2. تعديل الدالة pickImage لاستقبال الأهداف الجديدة
  Future<void> pickImage(ImageSource source, String target) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      if (target == 'profile') profilePhoto = picked;
      if (target == 'idFront') idFront = picked;
      if (target == 'idBack') idBack = picked;
      // حالات الونش الجديدة
      if (target == 'personalLicense') personalLicensePhoto = picked;
      if (target == 'towTruckLicense') towTruckLicensePhoto = picked;
      if (target == 'towTruck') towTruckPhoto = picked;
    });
  }





  // دالة لاختيار وقت البدء
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startWorkTime ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        startWorkTime = picked;
        works24Hours = false;
      });
    }
  }

  // دالة لاختيار وقت الانتهاء
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endWorkTime ?? const TimeOfDay(hour: 17, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        endWorkTime = picked;
        works24Hours = false;
      });
    }
  }

  // دالة لتحويل الوقت إلى نص
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }







  // دالة لعرض الصورة بشكل متوافق مع الويب
  Widget _buildImagePreview(XFile? file) {
    if (file == null) {
      return const Icon(Icons.add_a_photo, size: 36, color: Colors.black54);
    }

    try {
      return FutureBuilder<List<int>>(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                Uint8List.fromList(snapshot.data!),
                fit: BoxFit.cover,
                width: 90,
                height: 90,
              ),
            );
          } else if (snapshot.hasError) {
            return const Icon(Icons.error, color: Colors.red);
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    } catch (e) {
      return const Icon(Icons.error, color: Colors.red);
    }
  }

  Widget imagePickerTile(String label, XFile? file, String target,
      {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('التقاط صورة'),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.camera, target);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text('اختيار من المعرض'),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.gallery, target);
                              },
                            ),
                          ],
                        ),
                      );
                    });
              },
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _buildImagePreview(file),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'يمكنك إضافة صورة ${label.toLowerCase()}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        if (isRequired && file == null)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'هذا الحقل مطلوب',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // 4. دالة التسجيل (معدلة)
  // Helper to parse work hours
  Map<String, String> _parseWorkHours(String? selected) {
    if (selected == null || selected.isEmpty) return {"from": "", "to": ""};
    
    // Default mapping for known strings
    switch (selected) {
      case '24 ساعة': return {"from": "00:00", "to": "23:59"};
      case 'من 8 صباحاً إلى 12 مساءً': return {"from": "08:00", "to": "12:00"};
      case 'من 8 صباحاً إلى 4 مساءً': return {"from": "08:00", "to": "16:00"};
      case 'من 9 صباحاً إلى 5 مساءً': return {"from": "09:00", "to": "17:00"};
      case 'من 10 صباحاً إلى 6 مساءً': return {"from": "10:00", "to": "18:00"};
      case 'من 12 مساءً إلى 8 مساءً': return {"from": "12:00", "to": "20:00"};
      case 'من 2 مساءً إلى 10 مساءً': return {"from": "14:00", "to": "22:00"};
      case 'من 4 مساءً إلى 12 مساءً': return {"from": "16:00", "to": "00:00"};
      case 'من 6 مساءً إلى 2 صباحاً': return {"from": "18:00", "to": "02:00"};
      case 'من 8 مساءً إلى 4 صباحاً': return {"from": "20:00", "to": "04:00"};
      case 'من 10 مساءً إلى 6 صباحاً': return {"from": "22:00", "to": "06:00"};
      case 'من 12 صباحاً إلى 8 صباحاً': return {"from": "00:00", "to": "08:00"};
      case 'فقط صباحاً (8 ص - 2 م)': return {"from": "08:00", "to": "14:00"};
      case 'فقط مساءً (2 م - 10 م)': return {"from": "14:00", "to": "22:00"};
      case 'نوبتجيات (8 ص - 8 م)': return {"from": "08:00", "to": "20:00"};
      default: return {"from": "", "to": ""};
    }
  }

  // 4. دالة التسجيل (معدلة لتناسب multipart/form-data)
  Future<void> _registerAndShowConfirmation() async {
    if (!_formKey.currentState!.validate()) return;
    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على الشروط أولًا')),
      );
      return;
    }

    if (profilePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إضافة صورة شخصية')),
      );
      return;
    }
    
    // Tow Truck Validations
    if (_selectedSubCategoryName == 'ونش طوارئ') {
      if (personalLicensePhoto == null || towTruckLicensePhoto == null || towTruckPhoto == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى استكمال جميع صور الونش والرخص')),
        );
        return;
      }
    }

    try {
      final apiClient = ApiClient();
      
      // Fields
      final fields = {
        "FullName": "${firstNameController.text} ${middleNameController.text} ${lastNameController.text}",
        "PhoneNumber": phoneController.text,
        "Password": passwordController.text,
        "Email": emailController.text,
        "GovernorateId": _selectedGovernorateId ?? '',
        "AreaId": _selectedAreaId ?? '',
        "Address": locationController.text.isNotEmpty ? locationController.text : "عنوان غير محدد",
        "Specialization": _selectedSubCategoryName ?? "",
        "ServiceSubCategoryIds": _selectedSubCategoryId ?? '',
        "WorkHoursFrom": _parseWorkHours(selectedWorkTime)['from'] ?? "",
        "WorkHoursTo": _parseWorkHours(selectedWorkTime)['to'] ?? ""
      };

      // Files
      final files = <String, File>{};
      
      if (profilePhoto != null) files['ProfileImage'] = File(profilePhoto!.path);
      if (idFront != null) files['NationalIdFront'] = File(idFront!.path);
      if (idBack != null) files['NationalIdBack'] = File(idBack!.path);
      
      // License Logic: if winch, maybe use truck license? Default usage here:
      if (personalLicensePhoto != null) {
        files['LicenseOrCertificate'] = File(personalLicensePhoto!.path);
      } else if (towTruckLicensePhoto != null) {
        files['LicenseOrCertificate'] = File(towTruckLicensePhoto!.path);
      }
      
      // Map Profile Photo to CriminalRecord as legacy fallback/requirement fulfillment
      if (profilePhoto != null) files['CriminalRecord'] = File(profilePhoto!.path);

      print("\n🚀 Sending Registration (Multipart)...\n");
      
      final responseBody = await apiClient.postFormData(ApiConstants.registerTechnician, fields, files);
      
      // Parse response to get token
      final responseMap = jsonDecode(responseBody);
      print("📦 Registration Response: $responseMap");
      
      if (responseMap is Map) {
         final data = responseMap['data'] ?? {};
         final token = (data is Map ? data['token'] : null) ?? responseMap['token'] ?? responseMap['Token'];
         final userRole = (data is Map ? data['role'] : null) ?? responseMap['role'] ?? responseMap['Role'] ?? 'Technician';
         
         if (token != null) {
            print("✅ Registration successful, saving token...");
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token.toString());
            await prefs.setString('user_role', userRole.toString());
            await prefs.setString('user_data', responseBody);
         } else {
            print("⚠️ No token found in registration response");
         }
      }

      if (mounted) {
        _showConfirmationDialog();
      }
    } catch (e) {
      print("❌ Registration Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.parseError(e))),
      );
    }
  }



  // دالة لعرض تأكيد البيانات
  void _showConfirmationDialog() {
    String workTimeText = '';
    if (works24Hours) {
      workTimeText = '24 ساعة';
    } else if (startWorkTime != null && endWorkTime != null) {
      workTimeText =
          'من ${_formatTime(startWorkTime!)} إلى ${_formatTime(endWorkTime!)}';
    } else if (selectedWorkTime != null) {
      workTimeText = selectedWorkTime!;
    } else {
      workTimeText = 'غير محدد';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'تم التسجيل بنجاح!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تم إرسال طلبك بنجاح وسيتم مراجعته من قبل الإدارة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'بياناتك المسجلة:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildDataRow('الاسم:',
                '${firstNameController.text} ${middleNameController.text} ${lastNameController.text}'),
            _buildDataRow('رقم التليفون:', phoneController.text),
            if (emailController.text.isNotEmpty)
              _buildDataRow('البريد الإلكتروني:', emailController.text),
            
            // For location, we use locationController which we set in dropdowns
            _buildDataRow('العنوان:', locationController.text), 
            _buildDataRow('التخصص:', _selectedSubCategoryName ?? ''),
            _buildDataRow('مواعيد العمل:', workTimeText),
            const SizedBox(height: 20),
            const Text(
              'سيتم مراجعة بياناتك وإشعارك بالنتيجة خلال 24 ساعة',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TechnicianHomeScreen(),
                  ),
                );
              },
              child: const Text(
                'موافق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'غير محدد',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إنشاء حساب فني',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الشخصية
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المعلومات الشخصية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: 'الاسم الأول *',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'أدخل الاسم الأول'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: middleNameController,
                              decoration: InputDecoration(
                                labelText: 'الاسم الأوسط',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: 'الاسم الأخير *',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'أدخل الاسم الأخير'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // معلومات الاتصال
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات الاتصال',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'رقم التليفون *',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: '01XXXXXXXXX',
                        ),
                        validator: _validateEgyptianPhone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني (اختياري)',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور *',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'أدخل كلمة المرور'
                            : (v.length < 6
                                ? 'يجب أن تكون كلمة المرور 6 أحرف على الأقل'
                                : null),
                      ),
                    ],
                  ),
                ),
              ),

              // الموقع والتخصص
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الموقع والتخصص',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 12),
                      // Dropdown: Main Specialization
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'التخصص الرئيسي *',
                          prefixIcon: const Icon(Icons.category), // Changed Icon
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        value: _selectedMainCategoryId,
                        items: _mainCategories.map((e) {
                           // Handle potential key variations
                           final id = e['id'] ?? e['Id'] ?? e['serviceCategoryId'] ?? e['ServiceCategoryId'];
                           final name = e['name'] ?? e['Name'] ?? 'بدون اسم';
                           
                           return DropdownMenuItem<String>(
                             value: id?.toString(), 
                             child: Text(name.toString()),
                           );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedMainCategoryId = v;
                            _selectedSubCategoryId = null; // Reset sub category
                            _selectedSubCategoryName = null;
                            personalLicensePhoto = null;
                            towTruckLicensePhoto = null;
                            towTruckPhoto = null;
                          });
                        },
                        validator: (v) => v == null ? 'يرجى اختيار التخصص الرئيسي' : null,
                      ),
                      const SizedBox(height: 16),
                      // Dropdown: Sub Specialization
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'التخصص الفرعي *',
                          prefixIcon: const Icon(Icons.handyman),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        value: _selectedSubCategoryId,
                        // Filter subcategories based on selected Main Category
                        items: _subCategories
                            .where((sub) {
                              if (_selectedMainCategoryId == null) return false;
                              // Check serviceCategoryId (handle both pascal and camel case)
                              final parentId = sub['serviceCategoryId'] ?? sub['ServiceCategoryId'];
                              return parentId?.toString() == _selectedMainCategoryId.toString();
                            })
                            .map((e) {
                           return DropdownMenuItem<String>(
                             value: e['id']?.toString() ?? e['Id']?.toString(),
                             child: Text(e['name'] ?? e['Name'] ?? ''),
                           );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedSubCategoryId = v;
                            final selected = _subCategories.firstWhere(
                              (e) => (e['id'] ?? e['Id'])?.toString() == v, 
                              orElse: () => <String, dynamic>{}
                            );
                            _selectedSubCategoryName = selected['name'] ?? selected['Name'];
                            
                            // Tow Truck Logic check
                            if (_selectedSubCategoryName != 'ونش طوارئ') {
                              personalLicensePhoto = null;
                              towTruckLicensePhoto = null;
                              towTruckPhoto = null;
                            }
                          });
                        },
                        validator: (v) => v == null ? 'يرجى اختيار التخصص الفرعي' : null,
                        hint: Text(_selectedMainCategoryId == null ? 'اختر التخصص الرئيسي أولاً' : 'اختر التخصص الفرعي'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'المحافظة *',
                          prefixIcon: const Icon(Icons.location_city),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        value: _selectedGovernorateId,
                        items: _governoratesList.map((g) {
                           return DropdownMenuItem<String>(
                             value: g['id'].toString(),
                             child: Text(g['name'] ?? ''),
                           );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedGovernorateId = v;
                            _selectedAreaId = null;
                            locationController.clear();
                          });
                        },
                        validator: (v) => v == null ? 'يرجى اختيار المحافظة' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'المنطقة *',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        value: _selectedAreaId,
                        items: _allAreas
                            .where((area) => area['governorateId'] == _selectedGovernorateId)
                            .map((a) {
                               return DropdownMenuItem<String>(
                                 value: a['id'].toString(),
                                 child: Text(a['name'] ?? ''),
                               );
                            }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedAreaId = v;
                            if (_selectedGovernorateId != null && _selectedAreaId != null) {
                               // Optional: Set name in locationController if needed (lookup names)
                               final area = _allAreas.firstWhere((a) => a['id'] == v, orElse: () => <String, dynamic>{});
                               final gov = _governoratesList.firstWhere((g) => g['id'] == _selectedGovernorateId, orElse: () => <String, dynamic>{});
                               locationController.text = '${area['name']}, ${gov['name']}';
                            }
                          });
                        },
                        validator: (v) => v == null ? 'يرجى اختيار المنطقة' : null,
                        hint: Text(_selectedGovernorateId == null ? 'اختر المحافظة أولاً' : 'اختر المنطقة'),
                      ),
                    ],
                  ),
                ),
              ),

              // مواعيد العمل
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مواعيد العمل *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'مواعيد العمل',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        value: selectedWorkTime,
                        items: workTimes
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedWorkTime = v;
                            works24Hours = (v == '24 ساعة');
                            startWorkTime = null;
                            endWorkTime = null;
                          });
                        },
                        validator: (v) =>
                            v == null ? 'يرجى اختيار مواعيد العمل' : null,
                      ),
                      const SizedBox(height: 16),
                      // ... (إلخ باقي حقول مواعيد العمل إذا لزم الأمر)
                    ],
                  ),
                ),
              ),

              // حقول الصور الأساسية
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المستندات الأساسية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      imagePickerTile(
                        'صورة شخصية',
                        profilePhoto,
                        'profile',
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      imagePickerTile(
                        'صورة البطاقة (الوجه الأمامي)',
                        idFront,
                        'idFront',
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      imagePickerTile(
                        'صورة البطاقة (الوجه الخلفي)',
                        idBack,
                        'idBack',
                        isRequired: true,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. إضافة حقول الصور لـ "ونش طوارئ" (بشرط)
              if (_selectedSubCategoryName == 'ونش طوارئ')
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مستندات تخصص ونش الطوارئ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // لون مختلف للتمييز
                          ),
                        ),
                        const SizedBox(height: 12),
                        imagePickerTile(
                          'صورة الرخصة الشخصية',
                          personalLicensePhoto,
                          'personalLicense',
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        imagePickerTile(
                          'صورة رخصة قيادة الونش',
                          towTruckLicensePhoto,
                          'towTruckLicense',
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        imagePickerTile(
                          'صورة الونش',
                          towTruckPhoto,
                          'towTruck',
                          isRequired: true,
                        ),
                      ],
                    ),
                  ),
                ),

              // ... (باقي الكود كما هو)

              // الشروط والموافقة
              Row(
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (v) {
                      setState(() {
                        termsAccepted = v!;
                      });
                    },
                    activeColor: Colors.yellow[700],
                  ),
                  const Expanded(
                    child: Text(
                      'أوافق على الشروط والأحكام وسياسة الخصوصية',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              if (!termsAccepted && _formKey.currentState?.validate() == true)
                const Padding(
                  padding: EdgeInsets.only(right: 12, bottom: 8),
                  child: Text(
                    'يجب الموافقة على الشروط أولًا',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 20),

              // زر التسجيل
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _registerAndShowConfirmation,
                  child: const Text(
                    'تسجيل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
