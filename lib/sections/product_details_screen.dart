import 'package:flutter/material.dart';
// يجب أن تكون هذه الملفات موجودة في المسارات المحددة في مشروعك
import 'plumbing/shopingHome/product_model.dart';
import 'plumbing/shopingHome/order_screen.dart';

// -----------------------------------------------------------------
// يفترض وجود تعريف لفئة Product في ملف 'product_model.dart'
// مثال افتراضي لفئة Product (إذا لم تكن معرفة):
/*
class Product {
  final String name;
  final IconData icon;
  final double price;
  final String description;

  Product({
    required this.name,
    required this.icon,
    required this.price,
    required this.description,
  });
}
*/
// -----------------------------------------------------------------

class ProductDetailsScreen extends StatefulWidget {
  final String shopName;
  final List<Product> products;

  const ProductDetailsScreen({
    super.key,
    required this.shopName,
    required this.products,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // السلة تحتوي على قائمة من المنتجات المضافة
  final List<Product> _cart = [];
  static const int _deliveryFee = 50; // رسوم التوصيل ثابتة

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    // إظهار رسالة تأكيد الإضافة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} أُضيف إلى السلة"),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  // حساب إجمالي سعر المنتجات في السلة
  int get _productsTotal => _cart.fold(0, (sum, p) => sum + p.price.toInt());

  // حساب الإجمالي الكلي (المنتجات + رسوم التوصيل)
  int get _totalPrice => _productsTotal + _deliveryFee;

  void _confirmOrder() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك اختر منتجات أولاً")),
      );
      return;
    }

    // 1. تحويل قائمة المنتجات (List<Product>) إلى قائمة خرائط (List<Map>)
    // لتناسب متطلبات الدالة البانية الجديدة لـ OrderScreen
    final List<Map<String, dynamic>> orderItemsMap = _cart
        .map((p) => {
              'name': p.name,
              'price': p.price,
              // يمكنك إضافة المزيد من الخصائص هنا مثل: 'icon': p.icon,
            })
        .toList();

    // 2. التنقل إلى شاشة الطلب (OrderScreen) مع تمرير البيانات المطلوبة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(
          // تمرير البيانات المطابقة لمتطلبات الدالة البانية
          cartItems: orderItemsMap,
          totalAmount: _totalPrice.toDouble(), // تحويل الإجمالي إلى double
          shopName: widget.shopName,
        ),
      ),
    ).then((_) {
      // 3. تنظيف السلة وعرض رسالة بعد العودة من شاشة OrderScreen (سواء تم الشراء أو الإلغاء)
      setState(() => _cart.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تجهيز الطلب للمرحلة التالية!")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("محل ${widget.shopName}"),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        actions: [
          // عرض أيقونة السلة وعدد المنتجات
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
          // قسم الأسعار (ثابت في الأعلى)
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
          // قائمة المنتجات
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

          // زر تأكيد الطلب
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
