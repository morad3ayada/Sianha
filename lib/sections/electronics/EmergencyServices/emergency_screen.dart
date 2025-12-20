import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/models/service_category_model.dart';
import '../../../core/models/area_model.dart';
import '../../maintenance/OrderTrackingScreen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  // Service Selection
  List<ServiceCategory> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedSubCategoryId;
  String? _selectedSubCategoryName;
  bool _isLoadingCategories = true;
  bool _isLoadingSubcategories = false;

  // Form Fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  
  // Location
  String? _selectedGovernorateId;
  String? _selectedGovernorateName;
  String? _selectedAreaId;
  String? _selectedAreaName;
  List<GovernorateWithAreas> _governoratesData = [];
  Map<String, List<String>> _areasMap = {};
  bool _isLoadingAreas = true;

  // Image & Submission
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isPhoneValid = true;
  int _payWay = 0; // 0: Cash, 1: Online

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAreas();
  }

  Future<void> _fetchCategories() async {
    try {
      final apiClient = ApiClient();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await apiClient.get(
        ApiConstants.serviceCategories,
        token: token,
      );

      if (response is List && mounted) {
        setState(() {
          _categories = response
              .map((json) => ServiceCategory.fromJson(json))
              .toList();
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _fetchSubCategories(String categoryId) async {
    setState(() {
      _isLoadingSubcategories = true;
      _subcategories = [];
      _selectedSubCategoryId = null;
      _selectedSubCategoryName = null;
    });

    try {
      final apiClient = ApiClient();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await apiClient.get(
        ApiConstants.serviceSubCategories,
        token: token,
      );

      if (response is List && mounted) {
        // Filter subcategories by selected category
        final filtered = (response as List)
            .where((item) => item['serviceCategoryId'] == categoryId)
            .toList();

        setState(() {
          _subcategories = List<Map<String, dynamic>>.from(filtered);
          _isLoadingSubcategories = false;
        });
      }
    } catch (e) {
      print('Error fetching subcategories: $e');
      if (mounted) {
        setState(() {
          _isLoadingSubcategories = false;
        });
      }
    }
  }

  Future<void> _fetchAreas() async {
    try {
      final apiClient = ApiClient();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await apiClient.get(ApiConstants.areas, token: token);

      if (response is List && mounted) {
        List<AreaModel> allAreas = response
            .map((json) => AreaModel.fromJson(json))
            .toList();

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

        setState(() {
          _governoratesData = governorates;
          _areasMap = areasMap;
          _isLoadingAreas = false;
        });
      }
    } catch (e) {
      print('Error fetching areas: $e');
      if (mounted) {
        setState(() {
          _isLoadingAreas = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _validatePhoneNumber(String value) {
    if (value.isNotEmpty) {
      bool isValid = value.length == 11 && value.startsWith('01');
      setState(() {
        _isPhoneValid = isValid;
      });
    } else {
      setState(() {
        _isPhoneValid = true;
      });
    }
  }

  Future<void> _submit() async {
    // Validation
    if (_selectedCategoryId == null || _selectedSubCategoryId == null) {
      _showError('يرجى اختيار نوع الخدمة');
      return;
    }

    if (_phoneController.text.isEmpty) {
      _showError('يرجى إدخال رقم الهاتف');
      return;
    }

    if (_phoneController.text.length != 11 || !_phoneController.text.startsWith('01')) {
      _showError('رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ 01');
      return;
    }

    if (_selectedGovernorateId == null || _selectedAreaId == null) {
      _showError('يرجى اختيار المحافظة والمنطقة');
      return;
    }

    if (_addressController.text.isEmpty) {
      _showError('يرجى إدخال العنوان التفصيلي');
      return;
    }

    if (_priceController.text.isEmpty) {
      _showError('يرجى إدخال السعر المقترح');
      return;
    }

    if (_titleController.text.isEmpty) {
      _showError('يرجى إدخال عنوان الطلب');
      return;
    }

    double? enteredPrice = double.tryParse(_priceController.text);
    if (enteredPrice == null || enteredPrice <= 0) {
      _showError('يرجى إدخال سعر صحيح');
      return;
    }
    
    // Add 20% to price
    double finalPrice = enteredPrice * 1.20;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('User not logged in');
      }

      final apiClient = ApiClient();

      // Step 1: Upload image if selected
      String? problemImageUrl;
      if (_selectedImage != null) {
        try {
          print("Uploading image to get URL...");
          final uploadResponse = await apiClient.postMultipart(
            ApiConstants.uploadImage,
            {},
            token: token,
            file: _selectedImage,
            fileField: 'Image',
          );

          print("Upload response: $uploadResponse");

          if (uploadResponse != null && uploadResponse is Map<String, dynamic>) {
            String? relativeUrl = uploadResponse['profilePictureUrl']?.toString();

            if (relativeUrl != null && relativeUrl.isNotEmpty) {
              if (relativeUrl.startsWith('http://') ||
                  relativeUrl.startsWith('https://')) {
                problemImageUrl = relativeUrl;
              } else {
                problemImageUrl = "https://anamelorg.runasp.net$relativeUrl";
              }
              print("✅ Image uploaded: $problemImageUrl");
            }
          }
        } catch (e) {
          print("Error uploading image: $e");
          // Continue without image
        }
      }

      // Step 2: Create emergency order
      print("Creating emergency order...");
      final payload = {
        "title": _titleController.text,
        "serviceSubCategoryId": _selectedSubCategoryId,
        "serviceCategoryId": _selectedCategoryId,
        "serviceSubCategoryId": _selectedSubCategoryId,
        "serviceCategoryId": _selectedCategoryId,
        "price": finalPrice,
        "cost": 0,
        "costRate": 0,
        "problemDescription": _notesController.text.isEmpty
            ? "$_selectedCategoryName - $_selectedSubCategoryName - خدمة طوارئ"
            : "$_selectedCategoryName - $_selectedSubCategoryName - خدمة طوارئ\nملاحظات: ${_notesController.text}",
        "address": _addressController.text,
        "governorateId": _selectedGovernorateId,
        "areaId": _selectedAreaId,
        "governorateId": _selectedGovernorateId,
        "areaId": _selectedAreaId,
        "payWay": _payWay,
      };

      if (problemImageUrl != null && problemImageUrl.isNotEmpty) {
        payload["problemImageUrl"] = problemImageUrl;
      }

      print("Payload: $payload");

      final response = await apiClient.post(
        ApiConstants.createOrder,
        payload,
        token: token,
      );

      print("Order created: $response");

      String orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      if (response != null && response is Map<String, dynamic>) {
        orderId = response['id']?.toString() ?? orderId;
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show success and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء طلب الطوارئ بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(
              orderId: orderId,
              customerName: _phoneController.text,
              totalAmount: finalPrice,
              specialization: _selectedCategoryName ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error creating order: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _showError('فشل إنشاء الطلب: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
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
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            width: double.infinity,
            child: const Text(
              "خدمة الطوارئ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff06ffde),
                          Color(0xff00b8ff),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emergency, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "خدمة الطوارئ المنزلية",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "فنيون متخصصون متاحون 24/7 لحل مشاكلك بسرعة",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Service Selection
                  _buildSectionCard(
                    title: "نوع الخدمة المطلوبة",
                    icon: Icons.build_circle_outlined,
                    color: Colors.black87,
                    children: [
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "اختر نوع الخدمة الرئيسي",
                          fillColor: Colors.grey[50],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          prefixIcon: Icon(Icons.category, color: Colors.yellow[800]),
                        ),
                        value: _selectedCategoryId,
                        items: _categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(cat.name, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: _isLoadingCategories
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                    _selectedCategoryName = _categories
                                        .firstWhere((c) => c.id == value)
                                        .name;
                                  });
                                  _fetchSubCategories(value);
                                }
                              },
                      ),

                      if (_isLoadingSubcategories) ...[
                        const SizedBox(height: 12),
                        const Center(child: CircularProgressIndicator()),
                      ],

                      if (_subcategories.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "اختر الخدمة الفرعية",
                            fillColor: Colors.grey[50],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            prefixIcon: Icon(Icons.build, color: Colors.yellow[800]),
                          ),
                          value: _selectedSubCategoryId,
                          items: _subcategories
                              .map<DropdownMenuItem<String>>((sub) => DropdownMenuItem<String>(
                                    value: sub['id'],
                                    child: Text(sub['name'], style: const TextStyle(fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSubCategoryId = value;
                                _selectedSubCategoryName = _subcategories
                                    .firstWhere((s) => s['id'] == value)['name'];
                              });
                            }
                          },
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Phone Number
                  _buildSectionCard(
                    title: "رقم الهاتف",
                    icon: Icons.phone_outlined,
                    color: Colors.black87,
                    children: [
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        onChanged: _validatePhoneNumber,
                        decoration: InputDecoration(
                          labelText: "رقم الهاتف",
                          hintText: "01XXXXXXXXX",
                          fillColor: Colors.grey[50],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon: Icon(Icons.phone_android, color: Colors.yellow[800]),

                          suffixIcon: _isPhoneValid && _phoneController.text.isNotEmpty
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          errorText: _isPhoneValid ? null : "رقم هاتف غير صحيح",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Address
                  _buildSectionCard(
                    title: "العنوان",
                    icon: Icons.location_on_outlined,
                    color: Colors.black87,
                    children: [
                      // Governorate
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "المحافظة",
                          fillColor: Colors.grey[50],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          prefixIcon: Icon(Icons.location_city, color: Colors.yellow[800]),
                        ),
                        value: _selectedGovernorateName,
                        items: _governoratesData
                            .map((gov) => DropdownMenuItem(
                                  value: gov.governorateName,
                                  child: Text(gov.governorateName),
                                ))
                            .toList(),
                        onChanged: _isLoadingAreas
                            ? null
                            : (value) {
                                if (value != null) {
                                  final gov = _governoratesData
                                      .firstWhere((g) => g.governorateName == value);
                                  setState(() {
                                    _selectedGovernorateName = value;
                                    _selectedGovernorateId = gov.governorateId;
                                    _selectedAreaName = null;
                                    _selectedAreaId = null;
                                  });
                                }
                              },
                      ),

                      const SizedBox(height: 12),

                      // Area
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "المنطقة",
                          fillColor: Colors.grey[50],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          prefixIcon: Icon(Icons.map, color: Colors.yellow[800]),
                        ),
                        value: _selectedAreaName,
                        items: _selectedGovernorateName != null &&
                                _areasMap.containsKey(_selectedGovernorateName)
                            ? _areasMap[_selectedGovernorateName]!
                                .map((area) => DropdownMenuItem(
                                      value: area,
                                      child: Text(area),
                                    ))
                                .toList()
                            : [],
                        onChanged: _selectedGovernorateName == null
                            ? null
                            : (value) {
                                if (value != null) {
                                  final gov = _governoratesData.firstWhere(
                                      (g) => g.governorateName == _selectedGovernorateName);
                                  final area = gov.areas.firstWhere((a) => a.name == value);
                                  setState(() {
                                    _selectedAreaName = value;
                                    _selectedAreaId = area.id;
                                  });
                                }
                              },
                      ),

                      const SizedBox(height: 12),

                      // Detailed Address
                      TextField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "العنوان التفصيلي",
                          hintText: "الشارع، رقم المبنى، الدور...",
                          fillColor: Colors.grey[50],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon: Icon(Icons.home, color: Colors.yellow[800]),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Additional Notes
                  _buildSectionCard(
                    title: "ملاحظات إضافية",
                    icon: Icons.note_outlined,
                    color: Colors.black87,
                    children: [
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "ملاحظات إضافية (اختياري)",
                          hintText: "أي معلومات إضافية تساعد الفني...",
                          fillColor: Colors.grey[50],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon: Icon(Icons.description, color: Colors.yellow[800]),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title Field
                  _buildSectionCard(
                    title: "عنوان الطلب",
                    icon: Icons.title_outlined,
                    color: Colors.black87,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "عنوان الطلب",
                          hintText: "أدخل عنوان واضح للطلب...",
                          fillColor: Colors.grey[50],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon: Icon(Icons.text_fields, color: Colors.yellow[800]),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price Field
                  _buildSectionCard(
                    title: "السعر المقترح",
                    icon: Icons.monetization_on_outlined,
                    color: Colors.black87,
                    children: [
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "السعر المتوقع (جنية)",
                          hintText: "أدخل السعر المقترح...",
                          fillColor: Colors.grey[50],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon: Icon(Icons.attach_money, color: Colors.yellow[800]),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Payment Method
                  _buildSectionCard(
                    title: "طريقة الدفع",
                    icon: Icons.payment,
                    color: Colors.black87,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text("كاش"),
                              value: 0,
                              groupValue: _payWay,
                              activeColor: Colors.yellow[800],
                              onChanged: (value) {
                                setState(() {
                                  _payWay = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text("أونلاين"),
                              value: 1,
                              groupValue: _payWay,
                              activeColor: Colors.yellow[800],
                              onChanged: (value) {
                                setState(() {
                                  _payWay = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Image Upload
                  _buildSectionCard(
                    title: "صورة المشكلة (اختياري)",
                    icon: Icons.image_outlined,
                    color: Colors.black87,
                    children: [
                      if (_selectedImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(_selectedImage == null ? Icons.add_a_photo : Icons.change_circle),
                        label: Text(_selectedImage == null ? 'إضافة صورة' : 'تغيير الصورة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.emergency, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'إرسال طلب الطوارئ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
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

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
