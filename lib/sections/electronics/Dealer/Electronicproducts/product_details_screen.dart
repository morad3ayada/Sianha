// lib/sections/product_details_screen.dart
import 'package:flutter/material.dart';
// تأكد من أن هذا المسار صحيح لملف product_model.dart
import 'product_model.dart';
// **[تم التصحيح]** تأكد من أن هذا المسار صحيح لملف name_order.dart
import 'name_order.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String shopName;
  final List<Product> products; // هنا نستخدم Product من product_model.dart

  const ProductDetailsScreen({
    super.key,
    required this.shopName,
    required this.products,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final List<Product> _cart = []; // التأكد من أن _cart هي من نوع Product
  static const int _deliveryFee = 50;

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product.name} أُضيف إلى السلة")),
    );
  }

  int get _productsTotal => _cart.fold(0, (sum, p) => sum + p.price.toInt());
  int get _totalPrice => _productsTotal + _deliveryFee;

  // **[التعديل هنا]**: إضافة كود الانتقال إلى شاشة name_order.dart
  void _confirmOrder() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("السلة فارغة، أضف بعض المنتجات أولاً!")),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressSelectionScreen(
          products: _cart, // قائمة من نوع Product
          totalPrice: _totalPrice, // عدد صحيح (int)
          shopName: widget.shopName, // نص (String)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("محل ${widget.shopName}"),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.shopping_cart, size: 28, color: Colors.white),
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Text(
                      "${_cart.length}",
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.yellow[700],
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text("الإجمالي: $_productsTotal جنيه",
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                Text("رسوم التوصيل: $_deliveryFee جنيه",
                    style: const TextStyle(color: Colors.black)),
                Text("الإجمالي الكلي: $_totalPrice جنيه",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(product.icon,
                        size: 40, color: Colors.teal.shade800),
                    title: Text(product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${product.price} جنيه"),
                        Text(product.description,
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(60, 40),
                      ),
                      child: const Text("+"),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("تأكيد الطلب",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _confirmOrder,
            ),
          ),
        ],
      ),
    );
  }
}
