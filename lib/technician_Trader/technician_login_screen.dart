import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'technician_forgot_password.dart';
import 'technician_register_screen.dart';
import 'choose_role_screen.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

import 'Technician/technician_home_screen.dart';
import 'Merchant/trader_home_screen.dart';
import '../auth/client_login_screen.dart';

class TechnicianLoginScreen extends StatefulWidget {
  const TechnicianLoginScreen({super.key});

  @override
  State<TechnicianLoginScreen> createState() => _TechnicianLoginScreenState();
}

class _TechnicianLoginScreenState extends State<TechnicianLoginScreen> {
  bool isTechnician = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  Future<void> _checkExistingLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');

    if (token != null && role != null) {
      if (mounted) {
        if (role.toLowerCase() == 'technician') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TechnicianHomeScreen()),
          );
        } else {
          // Trader/Merchant
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TraderHomeScreen()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      print("========================================");
      print("🔑 Starting login...");
      print("   Phone: ${phoneController.text}");
      print("   Role: ${isTechnician ? 'Technician' : 'Trader'}");
      
      final apiClient = ApiClient();
      final payload = {
        "phoneNumberOrEmail": phoneController.text,
        "password": passwordController.text,
      };
      
      print("📤 Sending login request to: ${ApiConstants.login}");
      final response = await apiClient.post(ApiConstants.login, payload);
      
      print("📦 Login Response Type: ${response.runtimeType}");
      print("📦 Login Response: $response");
      
      if (response != null && response is Map) {
        // Extract token and user data
        final data = response['data'] ?? {};
        // Handle both cases: token in data object (standard) or root (fallback)
        final token = (data is Map ? data['token'] : null) ?? response['token'] ?? response['Token'];
        final userRole = (data is Map ? data['role'] : null) ?? response['role'] ?? response['Role'] ?? '';
        
        print("✅ Login successful!");
        print("   Token: ${token?.toString().substring(0, 20)}...");
        print("   User Role: $userRole");
        print("========================================");
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString('auth_token', token.toString());
        }
        await prefs.setString('user_role', userRole.toString());
        await prefs.setString('user_data', response.toString());
        
        // Navigate based on role
        if (!mounted) return;
        
        if (userRole.toString().toLowerCase() == 'technician') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TechnicianHomeScreen(),
            ),
          );
        } else if (userRole.toString().toLowerCase() == 'trader' || 
                   userRole.toString().toLowerCase() == 'merchant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TraderHomeScreen(),
            ),
          );
        } else {
          // Default: use the selected role from UI
          if (isTechnician) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TechnicianHomeScreen(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TraderHomeScreen(),
              ),
            );
          }
        }
      } else {
        throw Exception('استجابة غير صالحة من السيرفر');
      }
    } catch (e, stackTrace) {
      print("❌ Login Error: $e");
      print("Stack: $stackTrace");
      print("========================================");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الدخول: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // الأيقونة
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.amber[700]!.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber[700]!, width: 2),
                ),
                child: Icon(
                  Icons.build_circle_outlined,
                  size: 60,
                  color: Colors.amber[700],
                ),
              ),

              const SizedBox(height: 32),

              // العنوان
              const Text(
                "تسجيل دخول",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // الوصف
              Text(
                "حساب الفني والتاجر",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              // نموذج تسجيل الدخول
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                  children: [
                    // زر اختيار النوع (فني / تاجر)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isTechnician = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isTechnician
                                      ? Colors.amber[700]
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "فني",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isTechnician
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isTechnician = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isTechnician
                                      ? Colors.amber[700]
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "تاجر",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !isTechnician
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // حقل رقم الهاتف
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: "رقم الهاتف",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.phone, color: Colors.amber[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.amber[700]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'أدخل رقم الهاتف' : null,
                    ),

                    const SizedBox(height: 20),

                    // حقل كلمة المرور
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "كلمة المرور",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.lock, color: Colors.amber[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.amber[700]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'أدخل كلمة المرور' : null,
                    ),

                    const SizedBox(height: 16),

                    // نسيت كلمة المرور
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TechnicianForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "هل نسيت كلمة المرور؟",
                          style: TextStyle(
                            color: Colors.red[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر تسجيل الدخول
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                "تسجيل الدخول (${isTechnician ? 'فني' : 'تاجر'})",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // إنشاء حساب جديد
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ليس لديك حساب؟",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChooseRoleScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "إنشاء حساب جديد",
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // زر تسجيل دخول كعميل
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClientLoginScreen(),
                    ),
                  );
                },
                child: Text(
                  'تسجيل الدخول كعميل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ملاحظة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.amber[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "هذا الحساب يشمل كل من الفنيين والتجار",
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
