import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StatisticsScreen.dart';
import '../../screens/role_selection_screen.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../technician_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Initial empty data
  final Map<String, dynamic> _technicianData = {
    'name': '',
    'phone': '',
    'email': '',
    'governorate': '',
    'address': '',
    'serviceType': '',
    'experience': '0 سنوات',
    'rating': 0.0,
    'totalEarnings': 0.0,
    'totalDiscounts': 0.0,
    'completedOrders': 0,
    'cancelledOrders': 0,
    'complaints': 0,
    'joinDate': '',
    'isOnline': false,
  };

  bool _isEditing = false;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      print("📤 Fetching profile...");
      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.profile, token: token);
      print("📦 Profile Response: $response");

      if (response != null && mounted) {
        // Handle response wrapping (if any)
        final data = response['data'] ?? response;
        
        setState(() {
          _technicianData['name'] = data['fullName'] ?? data['name'] ?? 'غير متوفر';
          _technicianData['phone'] = data['phoneNumber'] ?? 'غير متوفر';
          _technicianData['email'] = data['email'] ?? 'غير متوفر';
          _technicianData['address'] = data['address'] ?? 'غير محدد';
          _technicianData['governorate'] = data['governorateName'] ?? data['governorate'] ?? 'غير محدد';
          
          // Parse subcategories
          String services = 'فني';
          if (data['serviceSubCategories'] != null && data['serviceSubCategories'] is List) {
            final subs = data['serviceSubCategories'] as List;
            if (subs.isNotEmpty) {
              services = subs.map((sub) => sub['name'] ?? sub['Name'] ?? '').where((s) => s.toString().isNotEmpty).join(' - ');
            }
          } else if (data['serviceCategoryName'] != null) {
            services = data['serviceCategoryName'];
          }
          
          _technicianData['governorateId'] = data['governorateId'] ?? data['GovernorateId'];
          _technicianData['areaId'] = data['areaId'] ?? data['AreaId'];
          
          _technicianData['serviceType'] = services;
          _technicianData['joinDate'] = data['joinDate'] ?? data['createdAt'] ?? '';
          _technicianData['isOnline'] = data['isActive'] ?? false;
          
          // Update controllers
          _nameController.text = _technicianData['name'];
          _phoneController.text = _technicianData['phone'];
          _emailController.text = _technicianData['email'];
          _addressController.text = _technicianData['address'];
        });
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20
        ),
        iconTheme: const IconThemeData(color: Colors.white), // For back button if enabled, and actions
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _saveChanges();
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // صورة الملف الشخصي والمعلومات الأساسية
            _buildProfileHeader(),

            const SizedBox(height: 20),

            // المعلومات الشخصية
            _buildPersonalInfoCard(),

            const SizedBox(height: 16),

            // الإحصائيات

            const SizedBox(height: 16),

            // الحالة والمعلومات الإضافية

            const SizedBox(height: 20),

            // أزرار إضافية
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.amber,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.circle,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _technicianData['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _technicianData['serviceType'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المعلومات الشخصية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField('الاسم الكامل', _nameController, Icons.person),
            _buildEditableField('رقم الهاتف', _phoneController, Icons.phone),
            _buildEditableField(
                'البريد الإلكتروني', _emailController, Icons.email),
            _buildEditableField(
                'العنوان', _addressController, Icons.location_on),
            _buildReadOnlyField('المحافظة', _technicianData['governorate'],
                Icons.location_city),
            _buildReadOnlyField(
                'نوع الخدمة', _technicianData['serviceType'], Icons.handyman),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                    ),
                  )
                : ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      controller.text,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(label),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(label),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.amber[700], size: 20),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          // child: ElevatedButton.icon(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor:
          //         _technicianData['isOnline'] ? Colors.red : Colors.green,
          //     padding: const EdgeInsets.symmetric(vertical: 15),
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _technicianData['isOnline'] = !_technicianData['isOnline'];
          //     });
          //   },
          //   icon: Icon(
          //     _technicianData['isOnline']
          //         ? Icons.visibility_off
          //         : Icons.visibility,
          //     color: Colors.white,
          //   ),
          //   label: Text(
          //     _technicianData['isOnline'] ? 'تعطيل الحساب' : 'تفعيل الحساب',
          //     style: const TextStyle(color: Colors.white),
          //   ),
          // ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          // child: OutlinedButton.icon(
          //   style: OutlinedButton.styleFrom(
          //     padding: const EdgeInsets.symmetric(vertical: 15),
          //     side: BorderSide(color: Colors.grey[300]!),
          //   ),
          //   onPressed: () {
          //     _showStatistics(context);
          //   },
          //   icon: const Icon(Icons.bar_chart),
          //   label: const Text('عرض الإحصائيات الكاملة'),
          // ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              _logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل خروج'),
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      // Try to call API to invalidate session on server
      if (token != null) {
        final apiClient = ApiClient();
        // Assuming POST for logout
        try {
          await apiClient.post(ApiConstants.logout, {}, token: token);
        } catch (e) {
          print("⚠️ API Logout failed: $e");
          // Continue to clear local data anyway
        }
      }

      // Clear all local data
      await prefs.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TechnicianLoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print("❌ Error during logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final body = {
        "fullName": _nameController.text,
        "phoneNumber": _phoneController.text,
        "address": _addressController.text,
        "governorateId": _technicianData['governorateId'],
        "areaId": _technicianData['areaId']
      };

      print("📤 Updating profile: $body");
      final apiClient = ApiClient();
      await apiClient.put(ApiConstants.profile, body, token: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
        );
        setState(() => _isEditing = false);
        // Refresh data to ensure UI is in sync
        _fetchProfileData();
      }
    } catch (e) {
      print("❌ Error updating profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحفظ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showStatistics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
    );
  }
}
