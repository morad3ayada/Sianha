import 'package:flutter/material.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';

class MerchantShopScreen extends StatefulWidget {
  const MerchantShopScreen({super.key});

  @override
  State<MerchantShopScreen> createState() => _MerchantShopScreenState();
}

class _MerchantShopScreenState extends State<MerchantShopScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _shopData;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final apiClient = ApiClient();
      final response = await apiClient.get(ApiConstants.myShop, token: token);

      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          _shopData = response;
        });
      }
    } catch (e) {
      print("Error fetching shop details: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateShopInfo(String name, String type) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final apiClient = ApiClient();
      final body = {
        "shopName": name,
        "shopType": type,
      };

      await apiClient.put(ApiConstants.updateShopInfo, body, token: token);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث بيانات المتجر بنجاح'), backgroundColor: Colors.green),
        );
        _fetchShopDetails(); // Refresh
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحديث: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndAddImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token == null) return;

        final apiClient = ApiClient();
        // Correct signature: endpoint, fields (positional), named args
        await apiClient.postMultipart(
          ApiConstants.addShopImage,
          {}, // Empty fields map
          token: token,
          file: File(pickedFile.path),
          fileField: 'Image',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الصورة بنجاح'), backgroundColor: Colors.green),
          );
          _fetchShopDetails(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إضافة الصورة: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteShopImage(String imageId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الصورة'),
        content: const Text('هل أنت متأكد من حذف هذه الصورة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final apiClient = ApiClient();
      await apiClient.delete(
        '${ApiConstants.deleteShopImage}?ImageId=$imageId',
        token: token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الصورة بنجاح'), backgroundColor: Colors.green),
        );
        _fetchShopDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف الصورة: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditDialog() {
    if (_shopData == null) return;

    final nameController = TextEditingController(text: _shopData!['shopName'] ?? _shopData!['name']);
    final typeController = TextEditingController(text: _shopData!['shopType'] ?? _shopData!['specialization']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات المتجر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المتجر'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'نوع المتجر / التخصص'),
            ),
          ],
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
            onPressed: () {
              Navigator.pop(context);
              _updateShopInfo(nameController.text, typeController.text);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('متجري',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFD700),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _shopData == null
              ? const Center(child: Text('لا توجد بيانات للمتجر'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Shop Header Card
                      _buildShopHeaderCard(),
                      const SizedBox(height: 20),
                      // Shop Details List
                      _buildDetailItem(Icons.store, 'اسم المتجر', _shopData!['shopName'] ?? _shopData!['name'] ?? 'غير متوفر'),
                      _buildDetailItem(Icons.category, 'نوع المتجر', _shopData!['shopType'] ?? _shopData!['specialization'] ?? 'غير محدد'),
                      
                      if (_shopData!['email'] != null)
                        _buildDetailItem(Icons.email, 'البريد الإلكتروني', _shopData!['email']),
                        
                      if (_shopData!['phoneNumber'] != null)
                        _buildDetailItem(Icons.phone, 'رقم الهاتف', _shopData!['phoneNumber']),

                      if (_shopData!['governorate'] != null)
                        _buildDetailItem(Icons.location_city, 'المحافظة', _shopData!['governorate']),

                      if (_shopData!['city'] != null)
                        _buildDetailItem(Icons.location_city, 'المدينة', _shopData!['city']),

                      if (_shopData!['address'] != null)
                        _buildDetailItem(Icons.location_on, 'العنوان', _shopData!['address']),
                        
                      if (_shopData!['description'] != null)
                        _buildDetailItem(Icons.description, 'الوصف', _shopData!['description']),

                      if (_shopData!['shopImages'] != null)
                        _buildShopImages(_shopData!['shopImages']),
                    ],
                  ),
                ),
    );
  }

  Widget _buildShopImages(dynamic items) {
     List<dynamic> images = [];
     if (items is List) {
       images = items;
     }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'صور المعرض',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: _pickAndAddImage,
              icon: const Icon(Icons.add_a_photo, size: 20),
              label: const Text('إضافة صورة'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFD700),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: _pickAndAddImage,
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFFFFD700), style: BorderStyle.solid),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFFFF8C00), size: 32),
                  ),
                );
              }

              final imageIndex = index - 1;
              dynamic item = images[imageIndex];
              String imageUrl = '';
              String? imageId;

              if (item is String) {
                imageUrl = item;
              } else if (item is Map) {
                // Try common keys if it's an object
                imageUrl = item['imageUrl'] ?? item['url'] ?? item['path'] ?? item['image'] ?? '';
                imageId = item['id'] ?? item['imageId'] ?? item['ImageId'];
              }
              
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                if (imageUrl.startsWith('/')) imageUrl = imageUrl.substring(1);
                imageUrl = '${ApiConstants.baseUrl}/$imageUrl';
              }
              
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (imageUrl.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.black,
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              children: [
                                Center(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        image: imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            )
                          : null,
                      ),
                    ),
                  ),
                  if (imageId != null)
                    Positioned(
                      top: 4,
                      right: 16, // Adjusting for margin
                      child: GestureDetector(
                        onTap: () => _deleteShopImage(imageId!),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopHeaderCard() {
    String? imageUrl = _shopData!['imageUrl'];
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
       // Remove leading slash if present
       if (imageUrl.startsWith('/')) {
         imageUrl = imageUrl.substring(1);
       }
        imageUrl = '${ApiConstants.baseUrl}/$imageUrl';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
           Container(
             height: 150,
             width: double.infinity,
             decoration: BoxDecoration(
               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
               color: Colors.grey[200],
               image: imageUrl != null
                   ? DecorationImage(
                       image: NetworkImage(imageUrl),
                       fit: BoxFit.cover,
                       onError: (_, __) {},
                     )
                   : null,
             ),
             child: imageUrl == null
                 ? Icon(Icons.store, size: 60, color: Colors.grey[400])
                 : null,
           ),
           Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               children: [
                 Text(
                   _shopData!['shopName'] ?? _shopData!['name'] ?? 'متجري',
                   style: const TextStyle(
                     fontSize: 22,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 if (_shopData!['shopType'] != null || _shopData!['specialization'] != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 8),
                     child: Text(
                       _shopData!['shopType'] ?? _shopData!['specialization'],
                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
                     ),
                   ),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFF8C00)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
