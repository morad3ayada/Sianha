import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_constants.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
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
                // Add merchant name to product for display if useful
                prod['merchantName'] = item['fullName'] ?? item['name'] ?? '';
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('حدث خطأ: $_error'))
              : _products.isEmpty
                  ? const Center(child: Text('لا توجد منتجات متاحة حالياً'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final item = _products[index];
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
                          // Ensure no double slash if baseUrl ends with / and path starts with /
                          if (ApiConstants.baseUrl.endsWith('/') && imagePath.startsWith('/')) {
                            imagePath = ApiConstants.baseUrl + imagePath.substring(1);
                          } else if (!ApiConstants.baseUrl.endsWith('/') && !imagePath.startsWith('/')) {
                             imagePath = "${ApiConstants.baseUrl}/$imagePath";
                          } else {
                             imagePath = "${ApiConstants.baseUrl}$imagePath";
                          }
                        }
                        
                        final price = item['price'] ?? 0;
                        
                        return _buildProductCard(name, imagePath, price);
                      },
                    ),
    );
  }

  Widget _buildProductCard(String name, String? imageUrl, dynamic price) {
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
                Text(
                  '$price ج.م',
                  style: TextStyle(
                    color: Colors.yellow[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
