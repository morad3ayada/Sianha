
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/utils/error_handler.dart';

// استيراد الشاشة الرئيسية للتاجر
import 'Merchant/trader_home_screen.dart';

/// شاشة تسجيل كتاجر
class MerchantRegisterScreen extends StatefulWidget {
  const MerchantRegisterScreen({super.key});

  @override
  State<MerchantRegisterScreen> createState() => _MerchantRegisterScreenState();
}

class _MerchantRegisterScreenState extends State<MerchantRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController streetController = TextEditingController();

  // API Data
  List<dynamic> _governoratesList = [];
  List<dynamic> _allAreas = [];
  List<dynamic> _subCategories = []; // Used for Shop Types

  String? _selectedGovernorateId;
  String? _selectedAreaId;
  String? _selectedSubCategoryId;
  
  // Work Hours
  String workTime = '24 ساعة';
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


  File? _shopPhoto;
  Uint8List? _shopPhotoBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

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
        setState(() {
          _allAreas = areasResponse;
          final uniqueGovs = <String, Map<String, dynamic>>{};
          for (var area in _allAreas) {
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
        });
      }
    } catch (e) {
      print("Error fetching areas: $e");
    }

    // 2. Fetch SubCategories (Shop Types)
    try {
      final subCatsResponse = await apiClient.get(ApiConstants.serviceSubCategories);
      if (subCatsResponse is List) {
        setState(() {
          _subCategories = subCatsResponse;
        });
      }
    } catch (e) {
      print("Error fetching subcategories: $e");
    }
  }


  // دالة التحقق من رقم الهاتف
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'أدخل رقم الهاتف';
    }
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length != 11) return 'يجب أن يتكون الرقم من 11 رقم';
    if (!cleanPhone.startsWith('01')) return 'يجب أن يبدأ الرقم بـ 01';
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _shopPhoto = File(pickedFile.path);
          _shopPhotoBytes = bytes;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorSnackBar('حدث خطأ في اختيار الصورة');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 16),
              const Text(
                'تم التسجيل بنجاح!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            'تم استلام طلبك للمراجعة.\n\nسيتم مراجعة الحساب خلال 24 ساعة والموافقة عليه أو الرد عليك عبر بريدك الإلكتروني.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToTraderHome();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حسناً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTraderHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TraderHomeScreen()),
    );
  }
  
  Map<String, String> _parseWorkHours(String? selected) {
    if (selected == null || selected.isEmpty) return {"from": "", "to": ""};
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGovernorateId == null || _selectedAreaId == null) {
      _showErrorSnackBar('اختر المحافظة والمنطقة');
      return;
    }
    if (_shopPhoto == null) {
      _showErrorSnackBar('أضف صورة المحل');
      return;
    }
    if (_selectedSubCategoryId == null) {
       _showErrorSnackBar('اختر نوع النشاط');
       return;
    }

    setState(() { _isLoading = true; });

    try {
      final apiClient = ApiClient();
      
      final fullName = "${firstNameController.text} ${middleNameController.text} ${lastNameController.text}";
      
      final fields = {
        "ShopName": "محل $fullName", // Default shop name or add field for it? User didn't specify. Assuming name or simple string as per curl 'string'. Let's use FullName or just "Store". I'll use "متجر $fullName"
        "AreaId": _selectedAreaId!,
        "WorkHoursFrom": _parseWorkHours(workTime)['from'] ?? "",
        "ServiceSubCategoryIds": _selectedSubCategoryId!,
        "ShopType": _selectedSubCategoryId!, // Sending ID as ShopType string as per curl example where ShopType=string. Maybe Name? I'll send ID or Name? The curl says string. I'll send Name maybe safer or ID? Let's check curl: ShopType=string. I'll use the selected category name.
        // Wait, logic check: ShopType usually is an enum or string desc. ServiceSubCategoryIds is the ID.
        // I will use SubCategory Name for ShopType.
        "Address": streetController.text.isNotEmpty ? streetController.text : "عنوان غير محدد",
        "GovernorateId": _selectedGovernorateId!,
        "PhoneNumber": phoneController.text,
        "WorkHoursTo": _parseWorkHours(workTime)['to'] ?? "",
        "FullName": fullName,
        "Password": passwordController.text,
        "Email": emailController.text
      };
      
      // Fix ShopType logic
      final subCat = _subCategories.firstWhere((element) => (element['id'] ?? element['Id']) == _selectedSubCategoryId, orElse: () => null);
      if (subCat != null) {
        fields["ShopType"] = subCat['name'] ?? subCat['Name'] ?? "General";
        fields["ShopName"] = "متجر ${subCat['name'] ?? ''}"; // Better default shop name
      }

      final files = <String, File>{};
      if (_shopPhoto != null) {
        files['ProfileImage'] = _shopPhoto!;
      }

      final responseBody = await apiClient.postFormData(ApiConstants.registerMerchant, fields, files);

      // Parse Token
      if (responseBody.isNotEmpty) {
         try {
           final responseMap = jsonDecode(responseBody);
           if (responseMap is Map) {
             var token = responseMap['token'] ?? responseMap['jwt'] ?? responseMap['accessToken'] ?? responseMap['result'];
             if (token == null && responseMap['data'] is Map) {
               token = responseMap['data']['token'];
             }
             
             if (token != null && token is String) {
               final prefs = await SharedPreferences.getInstance();
               await prefs.setString('auth_token', token);
               await prefs.setString('user_role', 'Trader'); // Save role as Trader
               await prefs.setString('user_data', jsonEncode(responseMap)); // Save full profile data
             }
           }
         } catch (e) {
           print("Error parsing token: $e");
         }
      }

      setState(() { _isLoading = false; });
      // Skip dialog and go straight to home if successful? 
      // User said: "لما تسجيل دخول وخلاص يحفظ التوكن ولما اطلع من التطبيق يدخلني علطول"
      // But also user usually expects success message. 
      // However, usually after register we either go to login or home. 
      // Since we auto-logged in, we can show success then navigate, or navigate immediately.
      // I'll show success dialog which navigates to TraderHomeScreen.
      _showSuccessDialog();

    } catch (e) {
      setState(() { _isLoading = false; });
      print("Registration error: $e");
      _showErrorSnackBar(ErrorHandler.parseError(e));
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter areas based on governorate
    List<dynamic> filteredAreas = [];
    if (_selectedGovernorateId != null) {
      filteredAreas = _allAreas.where((area) {
        final gId = area['governorateId'] ?? area['GovernorateId'];
        return gId.toString() == _selectedGovernorateId;
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "تسجيل كتاجر",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow)))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFDE7), Colors.white, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Form
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("البيانات الشخصية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _buildTextField(firstNameController, "الاسم الأول", Icons.person)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildTextField(middleNameController, "الاسم الأوسط", Icons.person_outline)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(lastNameController, "الاسم الأخير", Icons.person, isLast: true),
                              const SizedBox(height: 16),

                              const Text("بيانات الاتصال", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration("رقم الهاتف", Icons.phone),
                                validator: _validatePhone,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration("البريد الإلكتروني (اختياري)", Icons.email),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: _inputDecoration("كلمة المرور", Icons.lock),
                                validator: (val) => val != null && val.length < 6 ? 'كلمة المرور قصيرة' : null,
                              ),

                              const SizedBox(height: 24),
                              const Text("بيانات المحل", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                              const SizedBox(height: 16),
                              
                              // Governorates Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedGovernorateId,
                                items: _governoratesList.map<DropdownMenuItem<String>>((gov) {
                                  return DropdownMenuItem<String>(
                                    value: gov['id'].toString(),
                                    child: Text(gov['name']),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedGovernorateId = val;
                                    _selectedAreaId = null;
                                  });
                                },
                                decoration: _inputDecoration("المحافظة", Icons.location_city),
                                validator: (val) => val == null ? 'مطلوب' : null,
                              ),
                              const SizedBox(height: 12),

                              // Areas Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedAreaId,
                                items: filteredAreas.map<DropdownMenuItem<String>>((area) {
                                  return DropdownMenuItem<String>(
                                    value: (area['id'] ?? area['Id']).toString(),
                                    child: Text(area['name'] ?? area['Name']),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedAreaId = val;
                                  });
                                },
                                decoration: _inputDecoration("المنطقة", Icons.map),
                                validator: (val) => val == null ? 'مطلوب' : null,
                              ),
                              const SizedBox(height: 12),

                              // Shop Type (SubCategories)
                              DropdownButtonFormField<String>(
                                value: _selectedSubCategoryId,
                                items: _subCategories.map<DropdownMenuItem<String>>((cat) {
                                  return DropdownMenuItem<String>(
                                    value: (cat['id'] ?? cat['Id']).toString(),
                                    child: Text(cat['name'] ?? cat['Name']),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedSubCategoryId = val;
                                  });
                                },
                                decoration: _inputDecoration("نوع النشاط", Icons.store),
                                validator: (val) => val == null ? 'مطلوب' : null,
                              ),
                              
                               const SizedBox(height: 12),
                              TextFormField(
                                controller: streetController,
                                decoration: _inputDecoration("العنوان بالتفصيل", Icons.home),
                                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                              ),

                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: workTime,
                                items: workTimes.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                                onChanged: (val) => setState(() => workTime = val!),
                                decoration: _inputDecoration("مواعيد العمل", Icons.access_time),
                              ),

                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                                  ),
                                  child: _shopPhotoBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.memory(_shopPhotoBytes!, fit: BoxFit.cover),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                                            const SizedBox(height: 8),
                                            Text("اضغط لإضافة صورة المحل", style: TextStyle(color: Colors.grey[600])),
                                          ],
                                        ),
                                ),
                              ),


                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow[700],
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  child: const Text("إنشاء حساب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isLast = false}) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange, width: 2)),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }
}
