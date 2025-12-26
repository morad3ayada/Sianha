import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_constants.dart';
import '../core/api/api_client.dart';
import '../core/models/area_model.dart';
import '../core/models/merchant_model.dart';
import '../core/services/merchant_service.dart';
import '../sections/merchants/order_confirmation_screen.dart';
import '../sections/maintenance/OrderTrackingScreen.dart';


class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _error;

  // Search & Filter
  String _searchQuery = '';
  String? _selectedGovernorateId;
  String? _selectedAreaId;
  List<GovernorateWithAreas> _governorates = [];
  bool _isLoadingAreas = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    setState(() => _isLoadingAreas = true);
    try {
      final apiClient = ApiClient();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await apiClient.get(ApiConstants.areas, token: token);

      if (response is List) {
        List<AreaModel> allAreas = response.map((json) => AreaModel.fromJson(json)).toList();
        Map<String, List<AreaModel>> grouped = {};
        for (var area in allAreas) {
           if (!grouped.containsKey(area.governorateName)) {
             grouped[area.governorateName] = [];
           }
           grouped[area.governorateName]!.add(area);
        }
        
        List<GovernorateWithAreas> result = [];
        grouped.forEach((govName, areas) {
          result.add(GovernorateWithAreas(
            governorateId: areas.first.governorateId,
            governorateName: govName,
            areas: areas,
          ));
        });

        if (mounted) {
          setState(() {
            _governorates = result;
            _isLoadingAreas = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching areas: $e");
      if (mounted) setState(() => _isLoadingAreas = false);
    }
  }

  List<dynamic> get _filteredProducts {
    return _products.where((product) {
      // 1. Search Filter
      final name = (product['name'] ?? product['nameArabic'] ?? product['productName'] ?? '').toString().toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());

      // 2. Governorate Filter
      final matchesGov = _selectedGovernorateId == null || 
                         (product['governorateId'] != null && product['governorateId'].toString() == _selectedGovernorateId);

      // 3. Area Filter
      final matchesArea = _selectedAreaId == null || 
                          (product['areaId'] != null && product['areaId'].toString() == _selectedAreaId);

      return matchesSearch && matchesGov && matchesArea;
    }).toList();
  }

  Future<void> _fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('User not logged in');
      }

      print("Fetching products from: ${ApiConstants.merchantsWithProducts}");
      
      final response = await http.get(
        Uri.parse(ApiConstants.merchantsWithProducts),
        headers: {
          'accept': 'text/plain',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        List<dynamic> rawList = [];

        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
           if (decodedData['data'] is List) {
             rawList = decodedData['data'];
           }
        }

        List<dynamic> collectedProducts = [];
        
        // Flatten the structure: Merchants -> Products
        for (var item in rawList) {
          if (item is Map && item.containsKey('products') && item['products'] is List) {
            final productsList = item['products'] as List;
            // Optionally add merchant info to each product if needed
            for (var prod in productsList) {
              if (prod is Map) {
                // Add merchant name and other details to product for display and order creation
                final mName = item['shopName'] ?? item['fullName'] ?? item['name'] ?? item['FullName'] ?? item['Name'] ?? 'المتجر';
                prod['merchantName'] = mName.toString().isEmpty ? 'المتجر' : mName.toString();
                prod['merchantId'] = item['id'] ?? item['Id'];
                prod['areaId'] = item['areaId'] ?? item['AreaId'];
                prod['governorateId'] = item['governorateId'] ?? item['GovernorateId'];
                prod['serviceCategoryId'] = item['serviceCategoryId'] ?? item['ServiceCategoryId'];
                prod['serviceSubCategoryId'] = item['serviceSubCategoryId'] ?? item['ServiceSubCategoryId'];
                collectedProducts.add(prod);
              }
            }
          } else {
             // Fallback: maybe the list is directly products?
             collectedProducts.add(item);
          }
        }

        if (mounted) {
          setState(() {
            _products = collectedProducts;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in _fetchProducts: $e");
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine available areas
    List<AreaModel> availableAreas = [];
    if (_selectedGovernorateId != null && _governorates.isNotEmpty) {
      try {
        final gov = _governorates.firstWhere(
          (g) => g.governorateId == _selectedGovernorateId,
          orElse: () => _governorates.first, // Fallback safe
        );
        if (gov.governorateId == _selectedGovernorateId) {
            availableAreas = gov.areas;
        }
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'المنتجات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
         flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.yellow[600]!,
                Colors.yellow[700]!,
              ],
            ),
          ),
        ),
        elevation: 4,
         shadowColor: Colors.yellow.withOpacity(0.3),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'بحث عن منتج...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filters Row
                Row(
                  children: [
                    // Governorate Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedGovernorateId,
                        decoration: InputDecoration(
                          labelText: 'المحافظة',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: _governorates.map((g) {
                          return DropdownMenuItem(
                            value: g.governorateId,
                            child: Text(
                              g.governorateName,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedGovernorateId = val;
                            _selectedAreaId = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Area Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedAreaId,
                        decoration: InputDecoration(
                          labelText: 'المنطقة',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: availableAreas.map((a) {
                          return DropdownMenuItem(
                            value: a.id,
                            child: Text(
                              a.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _selectedGovernorateId == null
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedAreaId = val;
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('حدث خطأ: $_error'))
                    : _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text('لا توجد منتجات تطابق البحث', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final item = _filteredProducts[index];
                              // Try multiple keys for name
                              final name = item['name'] ?? 
                                           item['nameArabic'] ?? 
                                           item['productName'] ?? 
                                           'منتج غير معروف';
                                           
                              // Try multiple keys for image
                              String imagePath = item['imageUrl'] ?? 
                                                 item['imagePath'] ?? 
                                                 item['image'] ?? 
                                                 '';
                              
                              // Handle relative paths
                              if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
                                if (ApiConstants.baseUrl.endsWith('/') && imagePath.startsWith('/')) {
                                  imagePath = ApiConstants.baseUrl + imagePath.substring(1);
                                } else if (!ApiConstants.baseUrl.endsWith('/') && !imagePath.startsWith('/')) {
                                   imagePath = "${ApiConstants.baseUrl}/$imagePath";
                                } else {
                                   imagePath = "${ApiConstants.baseUrl}$imagePath";
                                }
                              }
                              
                              final price = item['price'] ?? 0;
                              
                              return _buildProductCard(item, name, imagePath, price);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, String name, String? imageUrl, dynamic price) {
    return Container(
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
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  _showFullScreenImage(context, imageUrl);
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        ),
                      )
                    : const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$price ج.م',
                      style: TextStyle(
                        color: Colors.yellow[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showQuantityDialog(context, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'شراء',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrderDirectly(Map<String, dynamic> product, int quantity) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('يجب تسجيل الدخول أولاً');

      final apiClient = ApiClient();
      final merchantService = MerchantService();

      // 1. Fetch User Profile
      final profile = await apiClient.get(ApiConstants.profile, token: token);
      if (profile == null || profile is! Map<String, dynamic>) {
        throw Exception('فشل في تحميل بيانات الملف الشخصي');
      }

      final String customerName = profile['fullName'] ?? profile['name'] ?? 'العميل';
      final String customerPhone = profile['phoneNumber'] ?? profile['phone'] ?? '';
      final String address = profile['address'] ?? '';
      final String areaId = profile['areaId']?.toString() ?? product['areaId']?.toString() ?? '';
      final String governorateId = profile['governorateId']?.toString() ?? product['governorateId']?.toString() ?? '';

      if (customerPhone.isEmpty || address.isEmpty || areaId.isEmpty || governorateId.isEmpty) {
        // Data incomplete, redirect to manual confirmation
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('برجاء استكمال بيانات العنوان والهاتف في ملفك الشخصي أولاً، أو سيتم توجيهك لشاشة التأكيد.')),
          );
          
          final productModel = ProductModel(
            id: product['id'],
            name: product['name'] ?? product['nameArabic'] ?? product['productName'] ?? '',
            price: (product['price'] ?? 0).toDouble(),
            imageUrl: product['imageUrl'] ?? product['imagePath'],
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(
                selectedProducts: [
                  SelectedProduct(product: productModel, quantity: quantity)
                ],
                merchantName: product['merchantName'] ?? 'المتجر',
                merchantPhone: product['merchantPhoneNumber'],
                merchantId: product['merchantId'].toString(),
                serviceCategoryId: (product['serviceCategoryId'] ?? "15db528b-a997-48bf-6275-08de3832fa71").toString(),
                serviceSubCategoryId: (product['serviceSubCategoryId'] ?? "94ee40a6-7a52-42a0-96fc-653f3da82161").toString(),
              ),
            ),
          );
          return;
        }
      }

      final String? merchantId = product['merchantId']?.toString();
      print("🔎 Checking merchantId for direct order: $merchantId");

      if (merchantId == null || merchantId.isEmpty || merchantId == "null") {
        throw Exception('فشل في العثور على معرّف التاجر (merchantId)');
      }

      // 2. Prepare Order Data
      final int totalPrice = (product['price'] ?? 0).toInt() * quantity;
      
      final orderData = {
        "serviceCategoryId": product['serviceCategoryId']?.toString() ?? "14797499-b482-478b-402e-08de4243d1ff",
        "serviceSubCategoryId": product['serviceSubCategoryId']?.toString() ?? "aa55fb73-b1c8-4e86-a982-283c8524f3c2",
        "price": totalPrice,
        "cost": 0,
        "costRate": 0,
        "problemDescription": "طلب شراء منتج: ${product['name'] ?? product['nameArabic'] ?? product['productName']}",
        "address": address,
        "governorateId": governorateId.toString(),
        "areaId": areaId.toString(),
        "payWay": 1, // Set to 1 as per curl
        "urgent": true,
        "title": "طلب شراء من ${product['merchantName'] != null && product['merchantName'].toString().isNotEmpty ? product['merchantName'] : 'المتجر'}",
        "customerPhoneNumber": customerPhone,
        "merchantId": merchantId,
        "orderProducts": [
          {
            "productId": product['id'].toString(),
            "quantity": quantity,
          }
        ],
      };

      // 3. Submit Order
      final response = await merchantService.createOrder(orderData, token: token);
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('تم تأكيد الطلب'),
              ],
            ),
            content: const Text('تم إرسال طلبك بنجاح! يمكنك متابعته من شاشة طلبياتي.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('حسناً', style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الطلب: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showQuantityDialog(BuildContext context, Map<String, dynamic> product) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('تحديد الكمية', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(product['name'] ?? product['nameArabic'] ?? product['productName'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setDialogState(() => quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setDialogState(() => quantity++);
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _submitOrderDirectly(product, quantity);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
                  child: const Text('تأكيد الشراء', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow clicking outside to close
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero, // Fullfill the screen
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The Image
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.9), // Dark background
              child: InteractiveViewer( // Allow zooming
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
                ),
              ),
            ),
            
            // Close Button
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
