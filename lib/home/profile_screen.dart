// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import 'EditProfileScreen.dart';
import 'SettingsScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedSection = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  bool _isOrdersLoading = false;
  List<dynamic> _orders = [];
  bool _ordersFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        // إذا لم يكن هناك توكن، يمكن توجيه المستخدم لتسجيل الدخول
        // او عرض بيانات افتراضية
        setState(() => _isLoading = false);
        return;
      }

      final apiClient = ApiClient();
      final response = await apiClient.get(
        ApiConstants.profile,
        token: token,
      );

      if (mounted) {
        setState(() {
          _profileData = response;
          _isLoading = false;
        });
        // Always fetch orders to update the count in the header
        if (!_ordersFetched) {
          _fetchMyOrders();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل الملف الشخصي: $e')),
        );
      }
    }
  }

  Future<void> _fetchMyOrders() async {
    setState(() {
      _isOrdersLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.myOrders, token: token);
      
      if (mounted) {
        setState(() {
          if (response is List) {
            _orders = response;
          } else if (response is Map && response.containsKey('data')) {
            _orders = response['data'] ?? [];
          }
          _ordersFetched = true;
        });
      }
    } catch (e) {
      print("Error fetching my orders: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isOrdersLoading = false;
        });
      }
    }
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final apiClient = ApiClient();
        await apiClient.post(
          ApiConstants.changePassword, 
          {
            "currentPassword": currentPassword,
            "newPassword": newPassword
          }, 
          token: token
        );
        
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("تم تغيير كلمة المرور بنجاح"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل تغيير كلمة المرور: $e")),
        );
      }
    }
  }

  void _showConfirmationDialog(String currentPassword, String newPassword) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
            const SizedBox(width: 10),
            const Text("تحذير", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "هل أنت متأكد من رغبتك في تغيير كلمة المرور؟",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close warning
              _changePassword(currentPassword, newPassword);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("نعم، تغيير"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "تغيير كلمة المرور",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور الحالية",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.yellow[700]!),
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? "مطلوب" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور الجديدة",
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.yellow[700]!),
                    ),
                  ),
                  validator: (val) => val!.length < 6 ? "يجب أن تكون 6 أحرف على الأقل" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "تأكيد كلمة المرور الجديدة",
                    prefixIcon: const Icon(Icons.check_circle_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.yellow[700]!),
                    ),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) return "مطلوب";
                    if (val != newPassController.text) return "كلمات المرور غير متطابقة";
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context); // Close input dialog
                _showConfirmationDialog(
                  currentPassController.text, 
                  newPassController.text
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final apiClient = ApiClient();
        await apiClient.post(ApiConstants.logout, {}, token: token).catchError((e) {
             print("Logout API error (ignored): $e");
        });
      }

      await prefs.clear();
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/role-selection',
          (route) => false,
        );
      }
    } catch (e) {
      print("Logout error: $e");
      // Force logout on error
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pop(context);
         Navigator.pushNamedAndRemoveUntil(
          context,
          '/role-selection',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "الملف الشخصي",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // بطاقة المعلومات الشخصية
          _buildProfileCard(),

          // أقسام التبويب
          _buildSectionTabs(),

          // محتوى الأقسام
          Expanded(
            child: _buildSectionContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // استخدام البيانات من الـ API أو قيم افتراضية
    final name = _profileData?['fullName'] ?? _profileData?['name'] ?? 'مستخدم';
    final userType = _profileData?['roles'] != null ? (_profileData!['roles'] is List ? (_profileData!['roles'] as List).first : 'عميل') : 'عميل';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.yellow[100]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // الصورة الشخصية
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.yellow[700]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 40,
              color: Colors.yellow[700],
            ),
          ),

          const SizedBox(width: 16),

          // المعلومات الأساسية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.yellow[300]!),
                      ),
                      child: Text(
                        userType.toString(), // تحويل الـ List/String لنص
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.yellow[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.yellow[700],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "4.8",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.assignment_rounded,
                      color: Colors.blue[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${_orders.length} طلبات",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    const List<String> sections = [
      'المعلومات',
      'الطلبات',
    ];

    const List<IconData> sectionIcons = [
      Icons.person_outline,
      Icons.assignment_outlined,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(sections.length, (index) {
          final isSelected = _selectedSection == index;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSection = index;
                  });
                  if (index == 1 && !_ordersFetched) {
                    _fetchMyOrders();
                  }
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.yellow[700] : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sectionIcons[index],
                        color: isSelected ? Colors.black : Colors.grey[500],
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sections[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case 0: // المعلومات
        return _buildInfoSection();
      case 1: // الطلبات
        return _buildOrdersSection();
      case 2: // الإحصائيات

      default:
        return _buildInfoSection();
    }
  }

  Widget _buildInfoSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final name = _profileData?['fullName'] ?? _profileData?['name'] ?? 'غير متوفر';
    final email = _profileData?['email'] ?? 'غير متوفر';
    final phone = _profileData?['phoneNumber'] ?? _profileData?['phone'] ?? 'غير متوفر';
    // لا نعرف بنية العنوان في الـ API، سنتركه فارغاً أو نحاول التخمين
    final city = _profileData?['city'] ?? 'غير متوفر';
    final address = _profileData?['address'] ?? 'غير متوفر';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            'المعلومات الشخصية',
            Icons.person_rounded,
            [
              _buildInfoItem(Icons.person_outline, 'الاسم:', name),
              _buildInfoItem(Icons.email_outlined, 'البريد:', email),
              _buildInfoItem(Icons.phone_android, 'رقم الهاتف:', phone),
            ],
          ),

          const SizedBox(height: 16),

          _buildInfoCard(
            'العنوان',
            Icons.location_on_rounded,
            [
              _buildInfoItem(Icons.location_city, 'المحافظة:', _profileData?['governorateName'] ?? _profileData?['governorate'] ?? 'غير محدد'),
              _buildInfoItem(Icons.map_outlined, 'المنطقة:', _profileData?['areaName'] ?? _profileData?['area'] ?? 'غير محدد'),
              _buildInfoItem(
                  Icons.home_work, 'العنوان:', address),
            ],
         
          ),

          const SizedBox(height: 16),



          // أزرار الإجراءات
          Row(
            children: [

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // الانتقال لشاشة تعديل البيانات
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                    // Refresh profile after returning
                    _fetchProfile();
                  },
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  label: const Text("تعديل البيانات"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // تسجيل الخروج
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("تسجيل الخروج"),
                        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("إلغاء"),
                          ),
                          TextButton(
                            onPressed: () {
                              // Call logout function
                              _logout(context);
                            },
                            child: const Text("نعم، خروج", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text("تسجيل الخروج"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]!),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.lock, size: 20),
              label: const Text("تغيير كلمة المرور"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[800],
                side: BorderSide(color: Colors.grey[400]!),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    if (_isOrdersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("لا توجد طلبات حالياً", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلباتي (${_orders.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              // Filter button removed for simplicity or can be kept
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              return _buildOrderCard(order);
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: Colors.grey[200]!,
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.yellow[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

Widget _buildInfoItem(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Widget _buildRatingItem(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget _buildOrderCard(dynamic order) {
  // Print order data for debugging
  print("📦 Order Data: $order");
  
  // Map API fields safely
  final id = order['id'] ?? 'N/A';
  final serviceName = order['problemDescription'] ?? 'خدمة عامة';
  final statusId = order['orderStatus'] ?? 0;
  String statusText = 'غير معروف';
  Color statusColor = Colors.grey;
  
  // Map status according to enum: Pending=0, Assigned=1, Accepted=2, InProgress=3, Completed=4, Cancelled=5, Rejected=6
  switch (statusId) {
    case 0:
      statusText = 'قيد الانتظار';
      statusColor = Colors.orange;
      break;
    case 1:
      statusText = 'تم التعيين';
      statusColor = Colors.blue;
      break;
    case 2:
      statusText = 'مقبول';
      statusColor = Colors.lightBlue;
      break;
    case 3:
      statusText = 'قيد التنفيذ';
      statusColor = Colors.purple;
      break;
    case 4:
      statusText = 'مكتمل';
      statusColor = Colors.green;
      break;
    case 5:
      statusText = 'ملغي';
      statusColor = Colors.red;
      break;
    case 6:
      statusText = 'مرفوض';
      statusColor = Colors.red;
      break;
  }

  final date = order['createdDate'] != null 
      ? order['createdDate'].toString().split('T')[0] 
      : '---';
  final price = order['price'] ?? 0;
  final technician = order['techniciaName'] ?? order['technicianName'] ?? order['TechnicianName'] ?? order['merchantName'] ?? order['MerchantName'] ?? order['assignedTechnician'] ?? 'غير محدد';
  
  print("👤 Technician/Merchant Name: $technician");

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: Colors.grey[200]!,
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "طلب #$id",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          serviceName,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 16,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              technician,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            Text(
              '$date',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$price جنيه',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.yellow[700],
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     // عرض تفاصيل الطلب
            //   },
            //   style: TextButton.styleFrom(
            //     foregroundColor: Colors.yellow[700],
            //     padding: EdgeInsets.zero,
            //   ),
            //   child: const Text('عرض التفاصيل'),
            // ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
