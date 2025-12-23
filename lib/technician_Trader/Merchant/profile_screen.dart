// 5. 👤 شاشة الملف الشخصي - "Profile"
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../screens/role_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _specialization = '';
  String _about = '';
  String _profileImageUrl = '';
  String _rating = '0.0';
  String _ordersCount = '0';
  String _satisfaction = '0%';
  String? _governorateId;
  String? _areaId;
  
  // Quick stats
  String _todaySales = '0';
  String _newOrders = '0';
  String _totalCustomers = '0';
  String _avgRating = '0.0';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final apiClient = ApiClient();
      
      // Fetch both Profile and Shop data in parallel
      final results = await Future.wait([
        apiClient.get(ApiConstants.profile, token: token),
        apiClient.get(ApiConstants.myShop, token: token),
        apiClient.get(ApiConstants.shopOrders, token: token),
      ]);

      final profileResponse = results[0];
      final shopResponse = results[1];
      final ordersResponse = results[2];

      if (mounted) {
        setState(() {
          // --- Parse Profile Data ---
          if (profileResponse != null && profileResponse is Map<String, dynamic>) {
            final data = profileResponse['data'] ?? profileResponse;
            _name = data['fullName'] ?? data['name'] ?? 'مستخدم';
            _email = data['email'] ?? '';
            _phone = data['phoneNumber'] ?? '';
            
            // Address: Address + Governorate + Area
            String detailedAddress = data['address'] ?? '';
            String gov = data['governorateName'] ?? '';
            String area = data['areaName'] ?? '';
            
            _address = [gov, area, detailedAddress]
                .where((s) => s != null && s.isNotEmpty)
                .join('، ');
          }

          // --- Parse Shop Data ---
          if (shopResponse != null && shopResponse is Map<String, dynamic>) {
            final shopData = shopResponse['data'] ?? shopResponse;
            // Provide fallback if shopName is empty, use previously fetched name
            String shopName = shopData['shopName'] ?? '';
            if (shopName.isNotEmpty) {
              // If we want to show Shop Name as the main title instead of User Name
              // _name = shopName; 
              // Or keep _name as User Name and append Shop Name elsewhere?
              // The prompt says "تظهر التخصص (shopType) واسم المحل (shopName)"
              // Let's assume Shop Name is the secondary text or replacing the store name field if it existed
              // The original code had "متجر ملابس رجالية" as the secondary text. 
              // We will put shopName there if available.
              _about = shopName; // Using _about variable for the secondary text line for now
            }
            
            _specialization = shopData['shopType'] ?? 'غير محدد';
          }
          
          // Store governorate and area IDs
          if (profileResponse != null && profileResponse is Map<String, dynamic>) {
            final data = profileResponse['data'] ?? profileResponse;
            _governorateId = data['governorateId'];
            _areaId = data['areaId'];
          }
          
          // --- Parse Orders Data for Quick Stats ---
          if (ordersResponse != null) {
            List<dynamic> orders = [];
            if (ordersResponse is List) {
              orders = ordersResponse;
            } else if (ordersResponse is Map && ordersResponse.containsKey('data')) {
              orders = ordersResponse['data'];
            }
            
            final now = DateTime.now();
            double todaySalesAmount = 0.0;
            int newOrdersCount = 0;
            Set<String> uniqueCustomers = {};
            List<double> ratings = [];
            
            for (var order in orders) {
              // Check if order is from today
              final dateStr = order['createdOn'] ?? order['orderDate'] ?? order['createdAt'];
              if (dateStr != null) {
                final orderDate = DateTime.tryParse(dateStr);
                if (orderDate != null &&
                    orderDate.year == now.year &&
                    orderDate.month == now.month &&
                    orderDate.day == now.day) {
                  // Today's sales
                  final price = order['totalPrice'] ?? order['price'] ?? order['totalAmount'] ?? 0;
                  todaySalesAmount += double.tryParse(price.toString()) ?? 0.0;
                }
              }
              
              // New orders (status = 2)
              final status = order['orderStatus'] ?? order['status'];
              if (status != null && int.tryParse(status.toString()) == 2) {
                newOrdersCount++;
              }
              
              // Unique customers
              final customerId = order['customerId'] ?? order['userId'];
              if (customerId != null) {
                uniqueCustomers.add(customerId.toString());
              }
              
              // Ratings
              final rating = order['rating'];
              if (rating != null) {
                final ratingVal = double.tryParse(rating.toString());
                if (ratingVal != null && ratingVal > 0) {
                  ratings.add(ratingVal);
                }
              }
            }
            
            _todaySales = todaySalesAmount.toStringAsFixed(0);
            _newOrders = newOrdersCount.toString();
            _totalCustomers = uniqueCustomers.length.toString();
            _avgRating = ratings.isEmpty 
                ? '0.0' 
                : (ratings.reduce((a, b) => a + b) / ratings.length).toStringAsFixed(1);
          }
        });
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات')),
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
      appBar: AppBar(
        title: Text(
          'الملف الشخصي',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // بطاقة الصورة والمعلومات الأساسية
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFD700), Color(0xFFFFEB3B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: _profileImageUrl.isNotEmpty 
                                  ? NetworkImage(_profileImageUrl) 
                                  : null,
                              child: _profileImageUrl.isEmpty 
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xFFFFD700),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                          _name.isNotEmpty ? _name : 'مستخدم',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        // Display Shop Name here
                        Text(
                          _about.isNotEmpty ? _about : 'متجر',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _specialization.isNotEmpty ? _specialization : 'تاجر',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRatingItem(_rating, 'التقييم'),
                            SizedBox(width: 20),
                            _buildRatingItem(_ordersCount, 'الطلبات'),
                            SizedBox(width: 20),
                            _buildRatingItem(_satisfaction, 'رضا العملاء'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // معلومات الاتصال
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoItem(
                            icon: Icons.email,
                            title: 'البريد الإلكتروني',
                            value: _email.isNotEmpty ? _email : 'غير متوفر',
                            color: Colors.blue,
                          ),
                          Divider(height: 20),
                          _buildInfoItem(
                            icon: Icons.phone,
                            title: 'رقم الهاتف',
                            value: _phone.isNotEmpty ? _phone : 'غير متوفر',
                            color: Colors.green,
                          ),
                          Divider(height: 20),
                          _buildInfoItem(
                            icon: Icons.location_on,
                            title: 'العنوان',
                            value: _address.isNotEmpty ? _address : 'غير متوفر',
                            color: Colors.orange,
                          ),
                          Divider(height: 20),
                          _buildInfoItem(
                            icon: Icons.store,
                            title: 'تخصص المحل',
                            value: _specialization.isNotEmpty ? _specialization : 'غير متوفر',
                            color: Color(0xFFFFD700),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // إحصائيات سريعة
                  Text(
                    'إحصائيات سريعة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.4, // قللنا النسبة علشان يقل الطول
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      List<Map<String, dynamic>> quickStats = [
                        {
                          'title': 'مبيعات اليوم',
                          'value': '$_todaySales جنية',
                          'icon': Icons.attach_money,
                          'color': Colors.green
                        },
                        {
                          'title': 'طلبات جديدة',
                          'value': _newOrders,
                          'icon': Icons.shopping_cart,
                          'color': Colors.blue
                        },
                        {
                          'title': 'عملاء جدد',
                          'value': _totalCustomers,
                          'icon': Icons.people,
                          'color': Colors.purple
                        },
                        {
                          'title': 'التقييم',
                          'value': '$_avgRating/5',
                          'icon': Icons.star,
                          'color': Colors.orange
                        },
                      ];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                quickStats[index]['icon'],
                                color: quickStats[index]['color'],
                                size: 24,
                              ),
                              SizedBox(height: 8),
                              Text(
                                quickStats[index]['value'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                quickStats[index]['title'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  // الأزرار الرئيسية
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        _showEditProfileDialog();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'تعديل الملف الشخصي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        _showLogoutConfirmation(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'تسجيل الخروج',
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
    );
  }

  Widget _buildRatingItem(String value, String title) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد تسجيل الخروج'),
          ],
        ),
        content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Clear Shared Preferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Navigate to Role Selection
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen()),
              );
            },
            child: Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _name);
    final phoneController = TextEditingController(text: _phone);
    final addressController = TextEditingController(text: _address);
    
    // Fetch governorates and areas
    List<Map<String, dynamic>> governorates = [];
    List<Map<String, dynamic>> areas = [];
    String? selectedGovernorateId = _governorateId;
    String? selectedAreaId = _areaId;
    
    try {
      final apiClient = ApiClient();
      final govsResponse = await apiClient.get(ApiConstants.areas, token: '');
      
      if (govsResponse != null && govsResponse is List) {
        // Group by governorate
        Map<String, Map<String, dynamic>> govMap = {};
        for (var area in govsResponse) {
          String govId = area['governorateId'] ?? '';
          String govName = area['governorateName'] ?? '';
          if (govId.isNotEmpty && !govMap.containsKey(govId)) {
            govMap[govId] = {'id': govId, 'name': govName};
          }
        }
        governorates = govMap.values.toList();
        
        // Get areas for selected governorate
        if (selectedGovernorateId != null) {
          areas = govsResponse
              .where((a) => a['governorateId'] == selectedGovernorateId)
              .map<Map<String, dynamic>>((a) => {
                    'id': a['id'],
                    'name': a['areaName'] ?? a['name'] ?? ''
                  })
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching areas: $e');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text('تعديل الملف الشخصي'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedGovernorateId,
                  decoration: InputDecoration(
                    labelText: 'المحافظة',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: governorates.map((gov) {
                    return DropdownMenuItem<String>(
                      value: gov['id'],
                      child: Text(gov['name']),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    setDialogState(() {
                      selectedGovernorateId = value;
                      selectedAreaId = null;
                    });
                    
                    // Fetch areas for selected governorate
                    try {
                      final apiClient = ApiClient();
                      final govsResponse = await apiClient.get(ApiConstants.areas, token: '');
                      if (govsResponse != null && govsResponse is List) {
                        setDialogState(() {
                          areas = govsResponse
                              .where((a) => a['governorateId'] == value)
                              .map<Map<String, dynamic>>((a) => {
                                    'id': a['id'],
                                    'name': a['areaName'] ?? a['name'] ?? ''
                                  })
                              .toList();
                        });
                      }
                    } catch (e) {
                      print('Error fetching areas: $e');
                    }
                  },
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedAreaId,
                  decoration: InputDecoration(
                    labelText: 'المنطقة',
                    prefixIcon: Icon(Icons.place),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: areas.map((area) {
                    return DropdownMenuItem<String>(
                      value: area['id'],
                      child: Text(area['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedAreaId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _updateProfile(
                  nameController.text,
                  phoneController.text,
                  addressController.text,
                  selectedGovernorateId,
                  selectedAreaId,
                );
              },
              child: Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile(
    String name,
    String phone,
    String address,
    String? governorateId,
    String? areaId,
  ) async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: لم يتم العثور على رمز المصادقة')),
          );
        }
        return;
      }

      final apiClient = ApiClient();
      final response = await apiClient.put(
        ApiConstants.profile,
        {
          'fullName': name,
          'phoneNumber': phone,
          'address': address,
          'workHoursFrom': null,
          'workHoursTo': null,
          'governorateId': governorateId,
          'areaId': areaId,
        },
        token: token,
      );

      if (mounted) {
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث الملف الشخصي بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh profile data
          await _fetchProfileData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل تحديث الملف الشخصي'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
