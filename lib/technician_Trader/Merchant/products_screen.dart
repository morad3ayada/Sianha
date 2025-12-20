import 'package:flutter/material.dart';
import 'dart:async'; // Add Timer import
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _isLoading = true;
  List<dynamic> _products = [];
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        _fetchProducts();
      } else {
        _searchProducts(query);
      }
    });
  }

  Future<void> _searchProducts(String query) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final apiClient = ApiClient();
      // Using search endpoint
      final response = await apiClient.get(
        '${ApiConstants.merchantProductSearch}?query=$query',
        token: token,
      );

      if (response != null && response is List) {
        setState(() {
          _products = response;
        });
      }
    } catch (e) {
      // Handle error or empty state
      print("Search error: $e");
      setState(() => _products = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final apiClient = ApiClient();
      final response = await apiClient.get(
        ApiConstants.merchantAddProduct, // Using the same endpoint for GET
        token: token,
      );

      if (response != null && response is List) {
        setState(() {
          _products = response;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل المنتجات: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
    _fetchProducts(); // Refresh list after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'بحث عن منتج...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        color: const Color(0xFFFFD700),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
            : _products.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد منتجات مُضافة بعد',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        label: const Text('إضافة منتج جديد'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final String name = product['name'] ?? 'منتج بدون اسم';
    final String description = product['description'] ?? '';
    final double price = double.tryParse(product['price'].toString()) ?? 0.0;
    String? imageUrl = product['imageUrl'];
    
    // Handle relative URLs
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
       // Remove leading slash if present to avoid double slashes with baseUrl
       if (imageUrl.startsWith('/')) {
         imageUrl = imageUrl.substring(1);
       }
       imageUrl = '${ApiConstants.baseUrl}/$imageUrl';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Image Section
          GestureDetector(
            onTap: () {
              if (imageUrl != null && imageUrl!.isNotEmpty) {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        iconTheme: const IconThemeData(color: Colors.white),
                        elevation: 0,
                      ),
                      body: Center(
                        child: Hero(
                          tag: imageUrl!,
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Hero(
                      tag: imageUrl,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain, // Show full image (small size)
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image, 
                            size: 50, 
                            color: Colors.grey
                          ),
                        ),
                      ),
                    )
                  : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
          ),
          
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: description.isNotEmpty 
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$price ج.م', // EGP Currency
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDAA520), // Gold color
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFFFD700)), // Yellow Edit Icon
                  onPressed: () => _showEditProductDialog(product),
                ),
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteProduct(product),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProduct(dynamic product) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف "${product['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteProduct(product['id']);
    }
  }

  Future<void> _deleteProduct(String? id) async {
    if (id == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final apiClient = ApiClient();
      await apiClient.delete(
        '${ApiConstants.merchantAddProduct}/$id',
        token: token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المنتج بنجاح'), backgroundColor: Colors.green),
        );
        _fetchProducts(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحذف: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEditProductDialog(dynamic product) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController = TextEditingController(text: product['name']);
    final TextEditingController _descriptionController = TextEditingController(text: product['description']);
    final TextEditingController _priceController = TextEditingController(text: product['price']?.toString());
    
    // We don't have the File object for the existing image, only URL.
    // If user picks a new image, we send it. Otherwise we send empty URL field or handle as per API (API expects ImageUrl or Image file).
    // The curl request has ImageUrl empty and Image file.
    
    XFile? _newImage;
    bool _isUpdating = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تعديل المنتج'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image Picker in Dialog
                      GestureDetector(
                        onTap: () async {
                           final ImagePicker picker = ImagePicker();
                           final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                           if (image != null) {
                             setState(() => _newImage = image);
                           }
                        },
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _newImage != null
                              ? Image.file(File(_newImage!.path), fit: BoxFit.contain)
                              : (product['imageUrl'] != null
                                  ? Image.network(
                                      product['imageUrl'].startsWith('http') 
                                      ? product['imageUrl'] 
                                      : '${ApiConstants.baseUrl}/${product['imageUrl'].startsWith('/') ? product['imageUrl'].substring(1) : product['imageUrl']}',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_,__,___) => const Icon(Icons.add_a_photo),
                                    )
                                  : const Icon(Icons.add_a_photo, size: 40)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'اسم المنتج'),
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'الوصف'),
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'السعر'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _isUpdating ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    
                    setState(() => _isUpdating = true);
                    
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('auth_token');
                      final id = product['id']; // Assuming ID is present in product map
                      
                      if (id == null || token == null) {
                        throw Exception('بيانات غير مكتملة');
                      }

                      final apiClient = ApiClient();
                      
                      final fields = {
                        'Id': id.toString(),
                        'Name': _nameController.text,
                        'Description': _descriptionController.text,
                        'Price': _priceController.text,
                        'ImageUrl': '', // Provide empty as per curl requirement for update likely
                      };

                      File? imageFile;
                      if (_newImage != null) {
                        imageFile = File(_newImage!.path);
                      }

                      await apiClient.putMultipart(
                        '${ApiConstants.merchantAddProduct}/$id',
                        fields,
                        token: token,
                        file: imageFile,
                        fileField: 'Image',
                      );

                      if (mounted) {
                        Navigator.pop(context); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تحديث المنتج بنجاح'), backgroundColor: Colors.green),
                        );
                        _fetchProducts(); // Refresh list
                      }
                    } catch (e) {
                      print('Update error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('فشل التحديث: $e'), backgroundColor: Colors.red),
                      );
                    } finally {
                      if (mounted) setState(() => _isUpdating = false);
                    }
                  },
                  child: _isUpdating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
