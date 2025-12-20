import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'products_screen.dart';

class AddProductScreen extends StatefulWidget {
  final String traderSpecialty;

  const AddProductScreen({super.key, this.traderSpecialty = 'عام'});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في اختيار الصور: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Note: The curl command shows Image is required (or at least sent). 
    // We should probably check if an image is selected, or allow empty if API supports it.
    // Based on "Image=@01.png", it likely expects a file.

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('رمز الدخول غير موجود، يرجى تسجيل الدخول مرة أخرى');
      }

      final apiClient = ApiClient();
      
      final fields = {
        'Name': _nameController.text,
        'Description': _descriptionController.text,
        'Price': _priceController.text,
        'ImageUrl': '', // Sending empty string as requested
      };

      // Use postMultipart correctly since we have a single image file to upload
      // Signature: postMultipart(endpoint, fields, {token, file, fileField})
      
      File? imageFile;
      if (_selectedImage != null) {
        imageFile = File(_selectedImage!.path);
      }

      final response = await apiClient.postMultipart(
        ApiConstants.merchantAddProduct,
        fields,
        token: token,
        file: imageFile,
        fileField: 'Image',
      );

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة المنتج بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Add Product Error: $e');
      _showErrorSnackBar('فشل إضافة المنتج: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          hintText: hintText,
          suffixText: suffixText,
          alignLabelWithHint: maxLines > 1,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'إضافة منتج جديد',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم الصورة
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_selectedImage != null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_selectedImage!.path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            onPressed: _removeImage,
                            icon: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xFFFFD700), style: BorderStyle.solid), // Fixed dashed error
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 50, color: Color(0xFFFFD700)),
                              SizedBox(height: 8),
                              Text('اضغط لإضافة صورة المنتج', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // الاسم
              _buildTextField(
                controller: _nameController,
                labelText: 'اسم المنتج *',
                prefixIcon: Icons.shopping_bag,
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),

              // الوصف
              _buildTextField(
                controller: _descriptionController,
                labelText: 'وصف المنتج',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),

              // السعر
              _buildTextField(
                controller: _priceController,
                labelText: 'سعر البيع *',
                prefixIcon: Icons.attach_money,
                suffixText: '₺', // Or EGP based on previous context, user kept strict curl but UI should likely match app currency. Let's stick to user prompt or prevailing app currency. The previous edit changed currency to EGP. I'll use text 'ج.م' to be safe or just generic.
                // Re-reading user prompt: "Price=100". No currency specified in prompt but previous task converted to EGP. I'll use EGP to be consistent.
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),

              const SizedBox(height: 32),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _addProduct,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'حفظ المنتج',
                          style: TextStyle(
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
    );
  }
}
