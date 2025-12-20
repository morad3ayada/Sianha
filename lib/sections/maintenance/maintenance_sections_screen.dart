import 'package:flutter/material.dart';
import 'add_order_screen.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/models/service_subcategory_model.dart';

class MaintenanceSectionsScreen extends StatefulWidget {
  final String serviceCategoryId;
  final String serviceCategoryName;

  const MaintenanceSectionsScreen({
    super.key,
    required this.serviceCategoryId,
    required this.serviceCategoryName,
  });

  @override
  State<MaintenanceSectionsScreen> createState() => _MaintenanceSectionsScreenState();
}

class _MaintenanceSectionsScreenState extends State<MaintenanceSectionsScreen> {
  List<ServiceSubCategory> _subCategories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    try {
      const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NDE4ZmYyOS02OTcyLTQ0MTAtOTdkOC01MGU1MjU5YzRhMmUiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJBZG1pbiIsImp0aSI6IjNhZTQ2YjIyLWY0MTMtNDU1OC1hMzcxLWNhNTllMDMxNTg2MiIsImV4cCI6MTc5Njk0MTExMSwiaXNzIjoiTWFpbnRlbmFuY2VBUEkiLCJhdWQiOiJNYWludGVuYW5jZUNsaWVudCJ9.OZMG2eh3IVO86FiWOhh7DMMifAJ3njcteOgHA1ln9Qs';
      
      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.serviceSubCategories, token: token);
      
      if (response is List) {
        final allSubCategories = response.map((json) => ServiceSubCategory.fromJson(json)).toList();
        
        // Filter by the passed category ID
        final filtered = allSubCategories.where((sub) => sub.serviceCategoryId == widget.serviceCategoryId).toList();
        
        if (mounted) {
          setState(() {
            _subCategories = filtered;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        print("Error fetching subcategories: $e");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    // تحديد اللون الكهرماني/الأصفر الموحد
    final Color primaryAmber = Colors.amber.shade700;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceCategoryName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryAmber, // لون موحد
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('حدث خطأ: $_error'))
              : _subCategories.isEmpty
                  ? const Center(child: Text('لا توجد خدمات فرعية متاحة'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _subCategories.length,
                      itemBuilder: (context, index) {
                        final subCategory = _subCategories[index];
                        // يمكنك تعيين ألوان وأيقونات ديناميكية هنا إذا توفرت في الـ API
                        // حالياً سنستخدم قيم افتراضية
                        final Color color = primaryAmber.withOpacity(0.8);
                        final IconData icon = Icons.handyman; 

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddOrderScreen(
                                      serviceCategoryId: widget.serviceCategoryId,
                                      serviceSubCategoryId: subCategory.id,
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: color.withOpacity(0.4), width: 1.5),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(icon, size: 40, color: primaryAmber),
                                  const SizedBox(height: 10),
                                  Text(
                                    subCategory.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey[800],
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryAmber,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "اطلب الآن",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      ),
    );
  }
}
