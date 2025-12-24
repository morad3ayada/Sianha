import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/models/area_model.dart';
import 'LocationPickerSimulator.dart';
import 'searching_offers_screen.dart';

class AddOrderScreen extends StatefulWidget {
  final String serviceCategoryId;
  final String serviceSubCategoryId;

  const AddOrderScreen({
    super.key,
    required this.serviceCategoryId,
    required this.serviceSubCategoryId,
  });

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _userPhone;
  String? _selectedAddress;
  Map<String, dynamic>? _selectedLocation;
  
  // Selection
  String? _selectedGovernorate;
  String? _selectedArea;
  
  // Areas Data
  bool _isLoadingAreas = false;
  List<GovernorateWithAreas> _governoratesData = [];
  Map<String, List<String>> _areasMap = {};
  String? _areasError;

  // Image & Payment
  File? _selectedImage;
  int _selectedPayWay = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    print('Location service initialized');
    _fetchAreas();
    _fetchUserProfile();
  }

  Future<void> _fetchAreas() async {
    setState(() {
      _isLoadingAreas = true;
      _areasError = null;
    });

    try {
      final apiClient = ApiClient();
       final prefs = await SharedPreferences.getInstance();
       final token = prefs.getString('auth_token');
      
       final response = await apiClient.get(ApiConstants.areas, token: token);

       if (response is List) {
          List<AreaModel> allAreas = response.map((json) => AreaModel.fromJson(json)).toList();
          
          Map<String, List<AreaModel>> groupedAreas = {};
          for (var area in allAreas) {
            if (!groupedAreas.containsKey(area.governorateName)) {
              groupedAreas[area.governorateName] = [];
            }
            groupedAreas[area.governorateName]!.add(area);
          }
          
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
          
          if (mounted) {
            setState(() {
              _governoratesData = governorates;
              _areasMap = areasMap;
              _isLoadingAreas = false;
            });
          }
       }
    } catch (e) {
      if (mounted) {
        setState(() {
          _areasError = 'فشل تحميل المحافظات';
          _isLoadingAreas = false;
        });
        print('Error fetching areas: $e');
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token'); // Or the constant if testing without login

      if (token != null) {
        final apiClient = ApiClient();
        final response = await apiClient.get(ApiConstants.profile, token: token);
        
        if (response != null && response is Map<String, dynamic>) {
           setState(() {
             _userPhone = response['phoneNumber']?.toString();
           });
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
      // Fallback or error handling if needed
    }
  }





  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }



  // **الدالة المحدثة لتحديد الموقع الحقيقي**
  void _addAddress() async {
    // 1. إظهار رسالة للمستخدم
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('جاري تحديد موقعك الحالي...'),
          duration: Duration(seconds: 2)),
    );

    // 2. استدعاء الخدمة الحقيقية لتحديد الموقع
    final result = await LocationPickerService.getCurrentLocation();

    // 3. التحقق من وجود نتيجة وتحديث الحالة
    if (result != null) {
      if (result['success'] == true) {
        setState(() {
          _selectedLocation = result['location'] as Map<String, dynamic>;
          _selectedAddress = result['address'] as String;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديد الموقع بنجاح: ${_selectedAddress!}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // رسالة خطأ من الخدمة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } else {
      // رسالة خطأ في حالة فشل تحديد الموقع
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل في تحديد الموقع. يرجى تفعيل GPS وإعطاء الصلاحية.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // **اختيار صورة من المعرض**
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم اختيار الصورة بنجاح')),
      );
    }
  }

  void _addPhoto() {
    _pickImage();
  }

  void _analyzeProblem() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تحليل المشكلة...')),
    );
  }

  void _submitOrder() async {
    if (_selectedGovernorate == null ||
        _selectedArea == null ||
        _selectedAddress == null ||
        _selectedAddress!.isEmpty ||
        _titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إكمال جميع الحقول المطلوبة (العنوان، المحافظة، المنطقة، عنوان المشكلة، الوصف)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("المستخدم غير مسجل دخول. يرجى تسجيل الدخول أولاً.");
      }

      final apiClient = ApiClient();
      
      // Get IDs from selection
      final governorateId = _governoratesData.firstWhere(
        (g) => g.governorateName == _selectedGovernorate,
        orElse: () => _governoratesData.first
      ).governorateId;

      final areaId = _governoratesData.firstWhere(
        (g) => g.governorateName == _selectedGovernorate,
        orElse: () => _governoratesData.first
      ).areas.firstWhere(
        (a) => a.name == _selectedArea,
        orElse: () => AreaModel(id: '', name: '', governorateId: '', governorateName: '')
      ).id;
      
      
      // Step 1: Upload image first if selected, to get URL
      String? problemImageUrl;
      if (_selectedImage != null) {
        try {
          print("Uploading image to get URL...");
          final uploadResponse = await apiClient.postMultipart(
            ApiConstants.uploadImage,
            {}, // No additional fields needed
            token: token,
            file: _selectedImage,
            fileField: 'Image', // Field name as per API
          );
          
          
          // Debug: Print full response
          print("=== UPLOAD RESPONSE ===");
          print("Type: ${uploadResponse.runtimeType}");
          print("Full response: $uploadResponse");
          print("======================");
          
          // Extract image URL from response
          if (uploadResponse != null) {
            String? relativeUrl;
            
            if (uploadResponse is String) {
              relativeUrl = uploadResponse;
            } else if (uploadResponse is Map<String, dynamic>) {
               // First check standard 'data' wrapper from recent logs
               if (uploadResponse.containsKey('data') && uploadResponse['data'] is Map) {
                 relativeUrl = uploadResponse['data']['profilePictureUrl']?.toString();
               }
               
               // Fallback to direct keys
               if (relativeUrl == null) {
                  relativeUrl = uploadResponse['profilePictureUrl']?.toString() ?? 
                               uploadResponse['imageUrl']?.toString() ?? 
                               uploadResponse['url']?.toString() ??
                               uploadResponse['path']?.toString();
               }
              
              print("Extracted relative path: $relativeUrl");
            }
            
            // Convert to full URL if it's a relative path
            if (relativeUrl != null && relativeUrl.isNotEmpty) {
              if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) {
                problemImageUrl = relativeUrl;
              } else {
                problemImageUrl = "https://anamelorg.runasp.net$relativeUrl";
              }
              print("✅ Image uploaded successfully!");
              print("Full URL: $problemImageUrl");
            } else {
              print("❌ No URL found in upload response after parsing");
            }
          }
        } catch (e) {
          print("Error uploading image: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تحذير: فشل رفع الصورة. سيتم إنشاء الطلب بدون صورة.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      
      // Step 2: Create order with image URL (if available)
      print("Creating order with data...");
      final payload = {
        "serviceSubCategoryId": widget.serviceSubCategoryId,
        "serviceCategoryId": widget.serviceCategoryId,
        "title": _titleController.text, // User input enforced
        "price": double.tryParse(_priceController.text) ?? 0,
        "cost": 0,
        "costRate": 0,
        "problemDescription": _descriptionController.text,
        "address": _selectedAddress,
        "governorateId": governorateId,
        "areaId": areaId,
        "payWay": _selectedPayWay,
      };
      
      // Add image URL if available
      if (problemImageUrl != null && problemImageUrl.isNotEmpty) {
        payload["problemImageUrl"] = problemImageUrl;
        print("Including image URL in order: $problemImageUrl");
      }
      
      final response = await apiClient.post(
        ApiConstants.createOrder,
        payload,
        token: token,
      );

      // Extract order ID from response
      String orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}'; // Fallback
      String? customerName;
      
      if (response != null && response is Map<String, dynamic>) {
        orderId = response['id']?.toString() ?? orderId;
        customerName = response['customerName']?.toString();
        print("Order created successfully with ID: $orderId");
      }

      // نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إنشاء الطلب بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Return to Home (Root)
        // Navigate to Searching Screen instead of Home immediately
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SearchingOffersScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال الطلب: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة طلب',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // سعر الزيارة
            // سعر الزيارة (إدخال)
            _buildTextFieldSection(
              title: 'السعر المقترح',
              controller: _priceController,
              hintText: 'أدخل السعر المقترح للخدمة',
              keyboardType: TextInputType.number,
            ),



            const SizedBox(height: 20),

            // العنوان المفصل (تحديد الموقع)
            _buildSection(
              title: 'العنوان المفصل (تحديد الموقع الحالي)',
              icon: Icons.my_location,
              onTap: _addAddress,
              value: _selectedAddress,
            ),

            const SizedBox(height: 20),



            const SizedBox(height: 20),

            // المحافظة
            _buildDropdownField(
              title: 'اختيار المحافظة',
              icon: Icons.map,
              value: _selectedGovernorate,
              items: _areasMap.keys.toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGovernorate = newValue;
                  _selectedArea = null; 
                });
              },
              enabled: !_isLoadingAreas,
            ),
            
            if (_isLoadingAreas)
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_areasError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(_areasError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),

            const SizedBox(height: 20),

            // المنطقة
            _buildDropdownField(
              title: 'اختيار المنطقة',
              icon: Icons.location_city,
              value: _selectedArea,
              items: _selectedGovernorate != null
                  ? _areasMap[_selectedGovernorate!] ?? []
                  : [],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedArea = newValue;
                });
              },
              enabled: _selectedGovernorate != null,
            ),

            const SizedBox(height: 20),

            // صورة العطل
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'صورة العطل (اختياري)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _addPhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('إضافة صورة'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 50),
                      ),
                      onPressed: _analyzeProblem,
                      child: const Text('التحليل'),
                    ),
                  ],
                ),
                
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // عنوان الطلب (جديد)
            _buildTextFieldSection(
              title: 'عنوان المشكلة',
              controller: _titleController,
              hintText: 'مثال: تسريب مياه في الحمام',
              maxLines: 1,
            ),

            const SizedBox(height: 20),

            // الوصف
            _buildTextFieldSection(
              title: 'الوصف التفصيلي',
              controller: _descriptionController,
              hintText: 'صف المشكلة بالتفصيل...',
              maxLines: 4,
            ),

            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'طريقة الدفع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('كاش'),
                        value: 0,
                        groupValue: _selectedPayWay,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedPayWay = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('أونلاين'),
                        value: 1,
                        groupValue: _selectedPayWay,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedPayWay = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // زر إرسال الطلب
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSubmitting ? Colors.grey : Colors.blue[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting ? null : _submitOrder,
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'جاري الإرسال...',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : const Text(
                      'إرسال الطلب',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- الدوال المساعدة ---


  Widget _buildDropdownField({
    required String title,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border:
                Border.all(color: enabled ? Colors.grey : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey.shade100,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              hint: Row(
                children: [
                  Icon(icon, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              items: items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              style: TextStyle(
                color: enabled ? Colors.black : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildSection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value ?? title,
                    style: TextStyle(
                      color: value != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildTextFieldSection({
    required String title,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
