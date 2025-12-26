import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/merchant_service.dart';
import '../../core/models/merchant_model.dart';
import 'order_confirmation_screen.dart';

class MerchantDetailsScreen extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  final String serviceCategoryId; // Added
  final String serviceSubCategoryId; // Added

  const MerchantDetailsScreen({
    super.key,
    required this.merchantId,
    required this.merchantName,
    required this.serviceCategoryId, // Added
    required this.serviceSubCategoryId, // Added
  });

  @override
  State<MerchantDetailsScreen> createState() => _MerchantDetailsScreenState();
}

class _MerchantDetailsScreenState extends State<MerchantDetailsScreen> {
  final MerchantService _merchantService = MerchantService();
  MerchantModel? _merchant;
  bool _isLoading = true;
  String? _error;
  final List<SelectedProduct> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadMerchantDetails();
  }

  Future<void> _loadMerchantDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final merchant = await _merchantService.getMerchantById(widget.merchantId, token: token);
      if (mounted) {
        setState(() {
          _merchant = merchant;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _addProduct(ProductModel product) {
    setState(() {
      final existingIndex = _selectedProducts.indexWhere(
        (sp) => sp.product.id == product.id,
      );
      
      if (existingIndex >= 0) {
        _selectedProducts[existingIndex].quantity++;
      } else {
        _selectedProducts.add(SelectedProduct(product: product));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${product.name}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeProduct(String productId) {
    setState(() {
      _selectedProducts.removeWhere((sp) => sp.product.id == productId);
    });
  }

  void _updateQuantity(String productId, int delta) {
    setState(() {
      final index = _selectedProducts.indexWhere(
        (sp) => sp.product.id == productId,
      );
      
      if (index >= 0) {
        _selectedProducts[index].quantity += delta;
        if (_selectedProducts[index].quantity <= 0) {
          _selectedProducts.removeAt(index);
        }
      }
    });
  }

  void _copyPhoneNumber(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم نسخ رقم الهاتف: $phoneNumber'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.merchantName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ في تحميل البيانات',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadMerchantDetails();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Merchant Info Card
                            _buildMerchantInfoCard(),
                            const SizedBox(height: 16),
                            
                            // Shop Images
                            if (_merchant?.shopImages != null && _merchant!.shopImages!.isNotEmpty)
                              _buildShopImages(),
                            if (_merchant?.shopImages != null && _merchant!.shopImages!.isNotEmpty)
                              const SizedBox(height: 16),
                            
                            // Phone Number Card
                            _buildPhoneCard(),
                            const SizedBox(height: 16),
                            
                            // Products Section
                            _buildProductsSection(),
                          ],
                        ),
                      ),
                    ),
                    
                    // Confirm Order Button
                    if (_selectedProducts.isNotEmpty)
                      _buildConfirmOrderButton(),
                  ],
                ),
    );
  }

  Widget _buildMerchantInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.yellow[600]!, Colors.yellow[700]!],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.store, color: Colors.black87, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات المتجر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.storefront, 'اسم المتجر', _merchant?.shopName ?? 'غير متوفر'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person, 'اسم المالك', _merchant?.userAccountFullName ?? 'غير متوفر'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'رقم الهاتف', _merchant?.userAccountPhoneNumber ?? 'غير متوفر'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صور المتجر',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _merchant!.fullShopImages.length,
            itemBuilder: (context, index) {
              final imageUrl = _merchant!.fullShopImages[index];
              return Container(
                width: 300,
                margin: EdgeInsets.only(
                  right: index < _merchant!.fullShopImages.length - 1 ? 12 : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.yellow[700],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ ERROR Loading Image: $imageUrl');
                      print('❌ Error Details: $error');
                      return Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'فشل تحميل الصورة',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneCard() {
    final phoneNumber = _merchant?.userAccountPhoneNumber;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.green[600]!, Colors.green[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: phoneNumber != null ? () => _copyPhoneNumber(phoneNumber) : null,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'رقم الهاتف',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber ?? 'غير متوفر',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.copy, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    if (_merchant == null || _merchant!.products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'لا توجد منتجات متاحة',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'المنتجات المتاحة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (_selectedProducts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedProducts.length} منتج',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _merchant!.products.length,
          itemBuilder: (context, index) {
            final product = _merchant!.products[index];
            final selectedProduct = _selectedProducts.firstWhere(
              (sp) => sp.product.id == product.id,
              orElse: () => SelectedProduct(product: product, quantity: 0),
            );
            
            return _buildProductCard(product, selectedProduct.quantity);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, int quantity) {
    final isSelected = quantity > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.yellow[700]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.fullImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.fullImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: Colors.yellow[700],
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.shopping_bag,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      ),
                    )
                  : Icon(Icons.shopping_bag, color: Colors.grey[400], size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (product.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!isSelected)
              ElevatedButton.icon(
                onPressed: () => _addProduct(product),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            else
              Row(
                children: [
                  IconButton(
                    onPressed: () => _updateQuantity(product.id, -1),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                    iconSize: 28,
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _updateQuantity(product.id, 1),
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.green,
                    iconSize: 28,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmOrderButton() {
    final totalItems = _selectedProducts.fold<int>(
      0,
      (sum, sp) => sum + sp.quantity,
    );
    final totalPrice = _selectedProducts.fold<double>(
      0,
      (sum, sp) => sum + sp.totalPrice,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderConfirmationScreen(
                  selectedProducts: _selectedProducts,
                  merchantName: widget.merchantName,
                  merchantPhone: _merchant?.userAccountPhoneNumber,
                  merchantId: widget.merchantId,
                  serviceCategoryId: widget.serviceCategoryId,
                  serviceSubCategoryId: widget.serviceSubCategoryId,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 24),
              const SizedBox(width: 8),
              Text(
                'تأكيد الطلب ($totalItems منتج - ${totalPrice.toStringAsFixed(2)} ج.م)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
