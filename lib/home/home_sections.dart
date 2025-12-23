import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../sections/maintenance/maintenance_sections_screen.dart';
import '../sections/electronics/EmergencyServices/emergency_screen.dart';
import 'NotificationsScreen.dart';
import 'products_screen.dart'; // المنتجات
import 'complaint_screen.dart';
import 'OrdersScreen.dart';
import 'profile_screen.dart'; // البروفايل
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/models/service_category_model.dart';

// تم تحويلها إلى StatefulWidget لإدارة حالة شريط التنقل السفلي
class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  int _selectedIndex = 0; // لتعقب العنصر المختار في شريط التنقل السفلي

  // صفحات وهمية للأزرار الجديدة (يجب عليك استبدالها بشاشاتك الحقيقية)
  final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(), // 0: محتوى شاشة الرئيسية الحالي
    const ProductsScreen(), // 1: المنتجات
    const EmergencyScreen(), // 2: خدمة الطوارئ
    const ProfileScreen(), // 3: البروفايل
    const OrdersScreen(), // 4: الطلبات
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // بما أن الأزرار غير الرئيسية تستخدم Navigator.push، فيجب أن يعرض الـ Body دائماً محتوى الرئيسية
      // ولكن للحفاظ على سلوك الـ BottomNavigationBar القياسي، سنستخدم الـ _widgetOptions
      body: SafeArea(
        child: _widgetOptions[_selectedIndex],
      ),

      // **شريط التنقل السفلي الجديد (BottomNavigationBar)**
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          _buildNavBarItem(Icons.home_outlined, Icons.home, 'الرئيسية'),
          _buildNavBarItem(
              Icons.shopping_bag_outlined, Icons.shopping_bag, 'المنتجات'),
          // زر الطوارئ في المنتصف بتصميم خاص
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[700], // لون بارز
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.support_agent_outlined,
                  color: Colors.black87, size: 28),
            ),
            label: 'خدمة الطوارئ',
          ),
          _buildNavBarItem(
              Icons.person_outline, Icons.person, 'البروفايل'),
          _buildNavBarItem(Icons.list_alt_outlined, Icons.list_alt, 'الطلبات'),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed, // مهم لضمان ظهور جميع الأزرار
        selectedItemColor: Color(0xff757575),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 11,
      ),
    );
  }

  // وظيفة مساعدة لبناء عناصر الـ BottomNavigationBar العادية
  BottomNavigationBarItem _buildNavBarItem(
      IconData unselectedIcon, IconData selectedIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(unselectedIcon),
      activeIcon: Icon(selectedIcon, color: Colors.yellow[700]),
      label: label,
    );
  }
}

// **تم فصل محتوى شاشة الهوم (AppBar + GridView) إلى Widget منفصلة**
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<ServiceCategory> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      // Use the provided token or rely on ApiClient if it has logic for token
      // For now, I'll use the token provided in the prompt as a fallback or if convenient
      const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NDE4ZmYyOS02OTcyLTQ0MTAtOTdkOC01MGU1MjU5YzRhMmUiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJBZG1pbiIsImp0aSI6IjNhZTQ2YjIyLWY0MTMtNDU1OC1hMzcxLWNhNTllMDMxNTg2MiIsImV4cCI6MTc5Njk0MTExMSwiaXNzIjoiTWFpbnRlbmFuY2VBUEkiLCJhdWQiOiJNYWludGVuYW5jZUNsaWVudCJ9.OZMG2eh3IVO86FiWOhh7DMMifAJ3njcteOgHA1ln9Qs';
      
      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.serviceCategories, token: token);
      
      if (response is List) {
        setState(() {
          _categories = response.map((json) => ServiceCategory.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        print("Error fetching service categories: $e");
      }
    }
  }

  // Helper to map category to icon and page
  // This is temporary mapping based on names until backend sends this info
  Map<String, dynamic> _getCategoryConfig(ServiceCategory category) {
    IconData icon;
    if (category.name.contains("سيارات")) {
      icon = Icons.directions_car_filled;
    } else if (category.name.contains("منازل")) {
      icon = Icons.home_repair_service;
    } else if (category.name.contains("إلكترون") ||
        category.name.contains("الكترون")) {
      icon = Icons.electrical_services;
    } else if (category.name.contains("تشطيب")) {
      icon = Icons.construction;
    } else if (category.name.contains("تاجر") ||
        category.name.contains("تجار")) {
      icon = Icons.store_mall_directory;
    } else if (category.name.contains("موبايل") ||
        category.name.contains("هاتف")) {
      icon = Icons.phone_iphone;
    } else {
      icon = Icons.category;
    }

    return {
      'icon': icon,
      'page': MaintenanceSectionsScreen(
        serviceCategoryId: category.id,
        serviceCategoryName: category.name,
      )
    };
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.black87),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildYellowSectionTile(
    BuildContext context,
    String title,
    IconData icon,
    Widget? page, {
    String? imageUrl,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          } else {
            _showSnackBar(context, "الخدمة غير متاحة حالياً");
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.yellow[600]!,
                Colors.yellow[700]!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.yellow[800]!.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (context, url, error) =>
                              Icon(icon, size: 32, color: Colors.black87),
                        ),
                      )
                    : Icon(
                        icon,
                        size: 32,
                        color: Colors.black87,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.yellow[700],
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.black87,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // رأس التطبيق
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.yellow[600]!,
                Colors.yellow[700]!,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const SizedBox(width: 44), 
              const Spacer(),
              Column(
                children: [
                  Text(
                    'خدمة',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'حلول الصيانة الشاملة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildIconButton(
                Icons.phone_outlined,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ComplaintScreen()),
                ),
              ),
            ],
          ),
        ),

        // بطاقة الدفع
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xff06ffde),
                const Color(0xff00b8ff),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSnackBar(context, "الدفع هيتفعل قريبًا..."),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet,
                          color: Color(0xffffbc00), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'دفع من هنا',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'دفع آمن وسريع',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios,
                          color: Color(0xffffe700), size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // العنوان الرئيسي
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'ما الذي تحتاج؟',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
              height: 1.2,
              ),
            textAlign: TextAlign.center,
          ),
        ),

        // الأقسام الديناميكية
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('حدث خطأ: $_error'))
                : _categories.isEmpty
                    ? const Center(child: Text('لا توجد خدمات متاحة حالياً'))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final config = _getCategoryConfig(category);
                            
                            return _buildYellowSectionTile(
                              context,
                              category.name,
                              config['icon'],
                              config['page'],
                              imageUrl: category.fullImageUrl,
                            );
                          },
                        ),
                      ),
        ),
      ],
    );
  }
}
