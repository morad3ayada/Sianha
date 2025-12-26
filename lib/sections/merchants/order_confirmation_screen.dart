import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/merchant_model.dart';
import '../../core/models/area_model.dart';
import '../../core/services/merchant_service.dart';
import '../maintenance/OrderTrackingScreen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final List<SelectedProduct> selectedProducts;
  final String merchantName;
  final String? merchantPhone;
  final String merchantId;
  final String serviceCategoryId; // Added
  final String serviceSubCategoryId; // Added

  const OrderConfirmationScreen({
    super.key,
    required this.selectedProducts,
    required this.merchantName,
    this.merchantPhone,
    required this.merchantId,
    required this.serviceCategoryId, // Added
    required this.serviceSubCategoryId, // Added
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantService = MerchantService();
  
  // Controllers
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  // State
  bool _isLoading = false;
  List<AreaModel> _areas = [];
  List<Map<String, String>> _governorates = [];
  String? _selectedGovernorateId;
  AreaModel? _selectedArea;
  int _payWay = 0; // 0: Cash, 1: Online
  String _customerName = "العميل"; // Default

  @override
  void initState() {
    super.initState();
    _fetchAreas();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerName = prefs.getString('name') ?? prefs.getString('userName') ?? "العميل";
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchAreas() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final areas = await _merchantService.getAreas(token: token);
      
      // Extract unique governorates
      final uniqueIds = <String>{};
      final governorates = <Map<String, String>>[];
      for (var area in areas) {
        if (uniqueIds.add(area.governorateId)) {
          governorates.add({
            'id': area.governorateId, 
            'name': area.governorateName
          });
        }
      }

      setState(() {
        _areas = areas;
        _governorates = governorates;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل المناطق: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المنطقة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("🔎 Checking merchantId for manual order: ${widget.merchantId}");
      if (widget.merchantId.isEmpty || widget.merchantId == "null") {
         throw Exception('فشل في العثور على معرّف التاجر (merchantId)');
      }

      final orderData = {
        "serviceCategoryId": widget.serviceCategoryId.toString(),
        "serviceSubCategoryId": widget.serviceSubCategoryId.toString(),
        "price": totalPrice.toInt(),
        "cost": 0,
        "costRate": 0,
        "problemDescription": _notesController.text.isEmpty ? "طلب شراء منتجات" : _notesController.text,
        "address": _addressController.text,
        "governorateId": _selectedArea!.governorateId.toString(),
        "areaId": _selectedArea!.id.toString(),
        "payWay": _payWay == 0 ? 1 : _payWay, 
        "urgent": true,
        "title": "طلب شراء من ${widget.merchantName.toString().isNotEmpty ? widget.merchantName : 'المتجر'}",
        "customerPhoneNumber": _phoneController.text,
        "merchantId": widget.merchantId.toString(),
        "orderProducts": widget.selectedProducts.map((sp) => {
          "productId": sp.product.id.toString(),
          "quantity": sp.quantity.toInt(),
        }).toList(),
      };

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Call API
      final response = await _merchantService.createOrder(orderData, token: token);
      
      // Extract Order details
      // Check if response is Map and has id, otherwise empty
      final String orderId = (response is Map && response.containsKey('id')) 
          ? response['id'].toString() 
          : ((response is Map && response.containsKey('orderId')) ? response['orderId'].toString() : "---");
      
      if (mounted) {
        // Success Dialog
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
            content: const Text('تم إرسال طلبك بنجاح!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate to Order Tracking
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingScreen(
                        orderId: orderId,
                        customerName: _customerName, // Use loaded name
                        totalAmount: totalPrice,
                        specialization: "مشتريات",
                        orderStatus: 0, // Pending
                        technicianName: widget.merchantName,
                        merchantPhone: widget.merchantPhone,
                        address: _addressController.text,
                        customerPhone: _phoneController.text,
                        isFromConfirmation: true, 
                      ),
                    ),
                    (route) => route.isFirst, 
                  );
                },
                child: Text('تتبع الطلب', style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('خطأ'),
            content: Text('فشل إرسال الطلب: $e'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً')),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get totalPrice => widget.selectedProducts.fold<double>(
        0,
        (sum, sp) => sum + sp.totalPrice,
      );

  int get totalItems => widget.selectedProducts.fold<int>(
        0,
        (sum, sp) => sum + sp.quantity,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'تأكيد الطلب',
          style: TextStyle(
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
          ? Center(child: CircularProgressIndicator(color: Colors.yellow[700]))
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Merchant Summary
                          _buildMerchantSummary(),
                          const SizedBox(height: 20),

                          // Order Summary (Products)
                          _buildProductsList(),
                          const SizedBox(height: 20),

                          // Delivery Address Form
                          _buildDeliveryAddressCard(),
                          const SizedBox(height: 20),

                          // Payment Method
                          _buildPaymentMethodCard(),
                          const SizedBox(height: 20),

                          // Total Price
                          _buildTotalCard(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Confirm Button
                  _buildConfirmButton(context),
                ],
              ),
            ),
    );
  }

  Widget _buildMerchantSummary() {
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
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الطلب من',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.merchantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (widget.merchantPhone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        widget.merchantPhone!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ملخص الطلب',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalItems منتج',
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
          itemCount: widget.selectedProducts.length,
          itemBuilder: (context, index) {
            final selectedProduct = widget.selectedProducts[index];
            return _buildProductItem(selectedProduct);
          },
        ),
      ],
    );
  }

  Widget _buildProductItem(SelectedProduct selectedProduct) {
    final product = selectedProduct.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
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
                      errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag, color: Colors.grey[400]),
                    ),
                  )
                : Icon(Icons.shopping_bag, color: Colors.grey[400]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${product.price.toStringAsFixed(2)} × ${selectedProduct.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '${selectedProduct.totalPrice.toStringAsFixed(2)} ج.م',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.yellow[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.location_on, color: Colors.yellow[700]),
              const SizedBox(width: 8),
              const Text(
                'عنوان التوصيل',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Governorate Dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'المحافظة',
              prefixIcon: Icon(Icons.location_city, color: Colors.grey[600]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            value: _selectedGovernorateId,
            items: _governorates.map((gov) {
              return DropdownMenuItem(
                value: gov['id'],
                child: Text(gov['name'] ?? ''),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedGovernorateId = val;
                _selectedArea = null; // Reset area when governorate changes
              });
            },
            validator: (val) => val == null ? 'مطلوب' : null,
          ),
          const SizedBox(height: 12),

          // Area Dropdown
          DropdownButtonFormField<AreaModel>(
            decoration: InputDecoration(
              labelText: 'المنطقة',
              prefixIcon: Icon(Icons.map, color: Colors.grey[600]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            value: _selectedArea,
            items: _selectedGovernorateId == null 
                ? [] 
                : _areas
                    .where((area) => area.governorateId == _selectedGovernorateId)
                    .map((area) {
                      return DropdownMenuItem(
                        value: area,
                        child: Text(
                          area.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
            onChanged: _selectedGovernorateId == null 
                ? null // Disable if no governorate selected
                : (val) => setState(() => _selectedArea = val),
            validator: (val) => val == null ? 'مطلوب' : null,
            hint: _selectedGovernorateId == null 
                ? const Text('اختر المحافظة أولاً') 
                : const Text('اختر المنطقة'),
            disabledHint: const Text('اختر المحافظة أولاً'),
          ),
          const SizedBox(height: 12),

          // Detailed Address
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'العنوان بالتفصيل',
              prefixIcon: Icon(Icons.home, color: Colors.grey[600]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (val) => val!.isEmpty ? 'مطلوب' : null,
          ),
          const SizedBox(height: 12),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف للتواصل',
              prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (val) => val!.isEmpty ? 'مطلوب' : null,
          ),
           const SizedBox(height: 12),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'ملاحظات إضافية (اختياري)',
              prefixIcon: Icon(Icons.note, color: Colors.grey[600]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.payment, color: Colors.yellow[700]),
              const SizedBox(width: 8),
              const Text(
                'طريقة الدفع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RadioListTile<int>(
            value: 0,
            groupValue: _payWay,
            onChanged: (val) => setState(() => _payWay = val!),
            title: const Text('دفع نقداً (Cash)'),
            activeColor: Colors.yellow[700],
            secondary: const Icon(Icons.money),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: _payWay,
            onChanged: (val) => setState(() => _payWay = val!),
            title: const Text('دفع إلكتروني (Online)'),
            activeColor: Colors.yellow[700],
            secondary: const Icon(Icons.credit_card),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.green[600]!, Colors.green[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'الإجمالي النهائي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${totalPrice.toStringAsFixed(2)} ج.م',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.done_all, size: 24),
              SizedBox(width: 8),
              Text(
                'تأكيد نهائي للطلب',
                style: TextStyle(
                  fontSize: 18,
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
