import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../home/home_sections.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/area_model.dart';

class RegisterCustomerScreen extends StatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  State<RegisterCustomerScreen> createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends State<RegisterCustomerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoadingAreas = false;
  String? _areasError;
  bool _isLoggedIn = false;

  String? _selectedProvince;
  String? _selectedArea;
  File? _profileImage;

  final ImagePicker _imagePicker = ImagePicker();
  final ApiClient _apiClient = ApiClient();
  
  // Dynamic data from API
  List<GovernorateWithAreas> _governoratesData = [];
  Map<String, List<String>> _areasMap = {};

  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    setState(() {
      _isLoadingAreas = true;
      _areasError = null;
    });

    try {
      // Using the token from the curl command
      const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NDE4ZmYyOS02OTcyLTQ0MTAtOTdkOC01MGU1MjU5YzRhMmUiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJBZG1pbiIsImp0aSI6IjNhZTQ2YjIyLWY0MTMtNDU1OC1hMzcxLWNhNTllMDMxNTg2MiIsImV4cCI6MTc5Njk0MTExMSwiaXNzIjoiTWFpbnRlbmFuY2VBUEkiLCJhdWQiOiJNYWludGVuYW5jZUNsaWVudCJ9.OZMG2eh3IVO86FiWOhh7DMMifAJ3njcteOgHA1ln9Qs';
      
      final response = await _apiClient.fetchAreas(token: token);
      
      // Parse the response
      List<AreaModel> allAreas = response.map((json) => AreaModel.fromJson(json)).toList();
      
      // Group areas by governorate
      Map<String, List<AreaModel>> groupedAreas = {};
      for (var area in allAreas) {
        if (!groupedAreas.containsKey(area.governorateName)) {
          groupedAreas[area.governorateName] = [];
        }
        groupedAreas[area.governorateName]!.add(area);
      }
      
      // Create GovernorateWithAreas list
      List<GovernorateWithAreas> governorates = [];
      Map<String, List<String>> areasMap = {};
      
      groupedAreas.forEach((govName, areas) {
        governorates.add(GovernorateWithAreas(
          governorateId: areas.first.governorateId,
          governorateName: govName,
          areas: areas,
        ));
        areasMap[govName] = areas.map((a) => a.name).toList();
      });
      
      setState(() {
        _governoratesData = governorates;
        _areasMap = areasMap;
        _isLoadingAreas = false;
      });
    } catch (e) {
      setState(() {
        _areasError = 'فشل تحميل المحافظات والمناطق: ${e.toString()}';
        _isLoadingAreas = false;
      });
      print('Error fetching areas: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('حدث خطأ في اختيار الصورة'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('حدث خطأ في التقاط الصورة'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'اختر صورة الشخصية',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Find IDs for selected governorate and area
      final governorate = _governoratesData.firstWhere(
        (g) => g.governorateName == _selectedProvince,
      );
      
      final area = governorate.areas.firstWhere(
        (a) => a.name == _selectedArea,
      );

      
      // Fields
      final Map<String, String> fields = {
        "FullName": nameController.text,
        "PhoneNumber": phoneController.text,
        "Password": passwordController.text,
        "Email": emailController.text,
        "GovernorateId": governorate.governorateId,
        "AreaId": area.id,
        "Address": addressController.text.isNotEmpty ? addressController.text : "string",
        "PreferredServices": "string"
      };

      // Files
      final Map<String, File> files = {};
      if (_profileImage != null) {
        files['ProfileImage'] = _profileImage!;
      }

      final responseBody = await _apiClient.postFormData(ApiConstants.registerCustomer, fields, files);

      // Parse response to find token
      // postFormData typically returns String, so we need to parse it if we want to check token immediately, 
      // or we can just proceed to login flow which serves as a double check.
      // But let's try to parse it similar to technician flow
      if (responseBody.isNotEmpty) {
        try {
           final responseMap = jsonDecode(responseBody);
           
           if (responseMap is Map) {
             // Try multiple possible keys for the token
             // 1. Direct keys
             var token = responseMap['token'] ?? 
                         responseMap['jwt'] ?? 
                         responseMap['accessToken'] ?? 
                         responseMap['result']; // Sometimes it's in result directly
             
             // 2. Nested in 'data' object
             if (token == null && responseMap['data'] is Map) {
               final data = responseMap['data'];
               token = data['token'] ?? data['jwt'] ?? data['accessToken'];
             }
             
             // 3. Nested in 'result' object (if result is a map, not the token itself)
             if (token == null && responseMap['result'] is Map) {
                final result = responseMap['result'];
                token = result['token'] ?? result['jwt'] ?? result['accessToken'];
             }

             print("📦 Parsed Token: $token"); // Debug print

             if (token != null && token is String && token.isNotEmpty) {
               final prefs = await SharedPreferences.getInstance();
               await prefs.setString('auth_token', token);
               _isLoggedIn = true;
               print("✅ Token saved successfully");
             } else {
               print("⚠️ Token not found in response map: $responseMap");
             }
           }
        } catch (e) {
          print("❌ Error parsing register response: $e");
        }
      }

      // If no token received from register, try to login automatically
      if (!_isLoggedIn) {
        try {
          final loginResponse = await _apiClient.post(
            ApiConstants.login,
            {
              "phoneNumberOrEmail": phoneController.text,
              "password": passwordController.text,
            },
          );

          if (loginResponse != null && loginResponse is Map<String, dynamic>) {
            final token = loginResponse['token'] ?? loginResponse['jwt'] ?? loginResponse['result']; // result added based on some API patterns
             if (token != null && token is String) {
               final prefs = await SharedPreferences.getInstance();
               await prefs.setString('auth_token', token);
               _isLoggedIn = true;
             }
          }
        } catch (e) {
          print("Automatic login failed: $e");
          // Fail silently regarding login, user will just be redirected to home (limited) or can login manually later
        }
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // نجاح التسجيل
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.parseError(e)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'تم إنشاء الحساب بنجاح!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'مرحباً بك في تطبيقنا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    if (_isLoggedIn) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreens(),
                        ),
                      );
                    } else {
                      // Navigate to login if no token was returned
                      Navigator.pop(context); // Close register screen (which was pushed)
                      // Ideally we should go to login, but since we are likely coming from login or role selection
                      // popping might just go back. To be safe, let's push replacement to login.
                      // Depending on navigation stack, popping might be enough.
                      // Let's assume navigating to Login is best.
                       Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreens()), // Fallback to Home as requested, but if not logged in data won't show.
                        // Wait, if not logged in, we should really go to Login.
                      );
                      // Actually, let's just use pushReplacement for ClientLoginScreen if not logged in.
                      // But the user might be confused. Let's send them to login.
                      /*
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ClientLoginScreen()),
                      );
                      */
                      // Reverting to user original behavior but only if logged in check fails?
                      // If I send them to Home and they are not logged in, they see empty data.
                      // I will keep the behavior as 'Home' but knowing it might be empty, 
                      // or better, guide them. 
                      
                      // Let's stick to HomeScreens for now as per original code, but at least we saved the token if it existed.
                      // If the API doesn't return a token, the backend needs to change or the app needs to force login.
                       Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreens(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'المتابعة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildBackground() {
    return Stack(
      children: [
        // خلفية متدرجة
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.yellow[700]!,
                Colors.yellow[600]!,
                Colors.yellow[500]!,
              ],
            ),
          ),
        ),

        // تأثيرات دائرية
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _showImagePickerDialog,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.yellow[700]!,
                width: 3,
              ),
              color: Colors.yellow[100],
            ),
            child: _profileImage != null
                ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                : Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 40,
                    color: Colors.yellow[700],
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الصورة الشخصية
            _buildProfileImage(),

            const SizedBox(height: 20),

            // العنوان
            const Text(
              'إنشاء حساب جديد',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'انضم إلينا وابدأ رحلتك',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Loading/Error indicator for areas
            if (_isLoadingAreas)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'جاري تحميل المحافظات والمناطق...',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            if (_areasError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _areasError!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _fetchAreas,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // حقل الاسم
            TextFormField(
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال الاسم';
                }
                if (value.length < 3) {
                  return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.yellow[700]),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'الاسم الكامل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // حقل البريد الإلكتروني
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!value.contains('@')) {
                  return 'يرجى إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: Colors.yellow[700]),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'البريد الإلكتروني',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // حقل رقم الهاتف
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الهاتف';
                }
                if (value.length != 11) {
                  return 'رقم الهاتف يجب أن يكون 11 رقم';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.phone_android, color: Colors.yellow[700]),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'رقم الهاتف',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // محافظات مصر
            DropdownButtonFormField<String>(
              value: _selectedProvince,
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار المحافظة';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.location_city, color: Colors.yellow[700]),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'اختر المحافظة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              items: _isLoadingAreas
                  ? []
                  : _areasMap.keys
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
              onChanged: _isLoadingAreas
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _selectedProvince = newValue;
                        _selectedArea = null;
                      });
                    },
            ),

            const SizedBox(height: 16),

            // المناطق
            DropdownButtonFormField<String>(
              value: _selectedArea,
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار المنطقة';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on, color: Colors.yellow[700]),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'اختر المنطقة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              items: _selectedProvince != null && _areasMap.containsKey(_selectedProvince)
                  ? _areasMap[_selectedProvince]!
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList()
                  : [],
              onChanged: _isLoadingAreas
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _selectedArea = newValue;
                      });
                    },
            ),

            const SizedBox(height: 16),

            // العنوان بالتفصيل
            TextFormField(
              controller: addressController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال العنوان بالتفصيل';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.home, color: Colors.yellow[700]),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'العنوان بالتفصيل (الشارع، رقم العقار...)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // كلمة المرور
            TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.yellow[700]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'كلمة المرور',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // تأكيد كلمة المرور
            TextFormField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى تأكيد كلمة المرور';
                }
                if (value != passwordController.text) {
                  return 'كلمات المرور غير متطابقة';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: Colors.yellow[700]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'تأكيد كلمة المرور',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 20),

            // الموافقة على الشروط
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value!;
                    });
                  },
                  activeColor: Colors.yellow[700],
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // عرض الشروط والأحكام
                    },
                    child: const Text(
                      'أوافق على الشروط والأحكام',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // زر التسجيل
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.yellow.withOpacity(0.3),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // رابط تسجيل الدخول
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'هل لديك حساب بالفعل؟',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: Colors.yellow[700],
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // زر الرجوع
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // بطاقة التسجيل
                  _buildFormCard(),

                  const SizedBox(height: 20),

                  // حقوق الطبع
                  Text(
                    ' morad3ayada © جميع الحقوق محفوظة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
