import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  
  List<dynamic> _userOrders = [];
  dynamic _selectedOrderData;
  bool _isLoadingOrders = false;
  bool _isSubmitting = false;

  List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedComplaintType;
  final List<String> _complaintTypes = [
    'تأخير في الموعد',
    'سوء في الأداء',
    'سلوك غير لائق',
    'جودة العمل غير مرضية',
    'أسعار غير متفق عليها',
    'أخرى'
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoadingOrders = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final client = ApiClient();
        final response = await client.get(ApiConstants.myOrders, token: token);
        
        if (response != null && response is List) {
          setState(() {
            _userOrders = response;
          });
        }
      }
    } catch (e) {
      print("Error fetching orders for complaints: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showSnackBar('حدث خطأ في اختيار الصورة');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.yellow[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedOrderData == null) {
        _showSnackBar('الرجاء اختيار رقم الطلب أولاً', isError: true);
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token == null) {
          throw Exception('يجب تسجيل الدخول أولاً');
        }

        final client = ApiClient();
        
        // Mapping as per USER_REQUEST:
        // Title -> _selectedComplaintType
        // ProblemDescription -> _complaintController.text
        // customerPhoneNumber -> _phoneController.text
        // Address -> "شكوي من الخدمة" (fixed)
        // IDs inherited from selected order
        
        final payload = {
          "title": _selectedComplaintType,
          "address": "شكوي من الخدمة",
          "problemDescription": _complaintController.text,
          "customerPhoneNumber": _phoneController.text,
          "price": 0,
          "cost": 0,
          "costRate": 0,
          "areaId": _selectedOrderData['areaId'] ?? _selectedOrderData['AreaId'],
          "governorateId": _selectedOrderData['governorateId'] ?? _selectedOrderData['GovernorateId'],
          "payWay": 0,
          "urgent": false,
          "serviceSubCategoryId": _selectedOrderData['serviceSubCategoryId'] ?? _selectedOrderData['ServiceSubCategoryId'],
          "serviceCategoryId": _selectedOrderData['serviceCategoryId'] ?? _selectedOrderData['ServiceCategoryId'],
        };

        final response = await client.post(
          ApiConstants.createOrder,
          payload,
          token: token,
        );

        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        _showSnackBar('فشل إرسال الشكوى: ${e.toString()}', isError: true);
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'تم إرسال الشكوى',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'شكراً لتواصلكم. سنقوم بمراجعة شكواك والرد خلال 24 ساعة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('حسناً'),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildImageGrid() {
    if (_selectedImages.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'الصور المرفوعة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(_selectedImages[index].path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashedBorder() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            color: Colors.grey[500],
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'إضافة صورة',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'تقديم شكوى',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.red[50]!,
                      Colors.orange[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red[100]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نحن هنا لمساعدتك',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'سيتم مراجعة شكواك من قبل فريق الدعم خلال 24 ساعة',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Complaint Type
              Text(
                'نوع الشكوى *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedComplaintType,
                  items: _complaintTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedComplaintType = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintText: 'اختر نوع الشكوى',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار نوع الشكوى';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 20),

              // Phone Number
              Text(
                'رقم الهاتف *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'أدخل رقم هاتفك',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon:
                      Icon(Icons.phone_rounded, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.yellow[700]!),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  if (value.length < 10) {
                    return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Order Number Dropdown
              Text(
                'رقم الطلب *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              _isLoadingOrders 
                ? Center(child: CircularProgressIndicator(color: Colors.yellow[700]))
                : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonFormField<dynamic>(
                    value: _selectedOrderData,
                    items: _userOrders.map((dynamic order) {
                      final orderId = order['id'] ?? order['Id'] ?? '---';
                      final service = order['serviceSubCategoryName'] ?? order['ServiceSubCategoryName'] ?? 'طلب خدمة';
                      return DropdownMenuItem<dynamic>(
                        value: order,
                        child: Text(
                          '#${orderId.toString().substring(0, 8)} - $service',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (dynamic newValue) {
                      setState(() {
                        _selectedOrderData = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      hintText: _userOrders.isEmpty ? 'لا توجد طلبات سابقة' : 'اختر رقم الطلب',
                      prefixIcon: Icon(Icons.receipt_rounded, color: Colors.grey[600]),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'الرجاء اختيار رقم الطلب';
                      }
                      return null;
                    },
                  ),
                ),

              SizedBox(height: 20),

              // Complaint Details
              Text(
                'تفاصيل الشكوى *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _complaintController,
                textAlign: TextAlign.right,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'صف مشكلتك بالتفصيل...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.yellow[700]!),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء كتابة تفاصيل الشكوى';
                  }
                  if (value.length < 20) {
                    return 'الرجاء كتابة وصف مفصل لا يقل عن 20 حرف';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Image Upload Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة صور (اختياري)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'يمكنك إضافة صور توضح المشكلة (الحد الأقصى 3 صور)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_selectedImages.length < 3)
                      GestureDetector(
                        onTap: _pickImage,
                        child: _buildDashedBorder(),
                      ),
                    _buildImageGrid(),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting 
                  ? CircularProgressIndicator(color: Colors.black)
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded),
                      SizedBox(width: 8),
                      Text(
                        'إرسال الشكوى',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _complaintController.dispose();
    super.dispose();
  }
}
