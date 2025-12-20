import 'package:flutter/material.dart';
import 'shop_model.dart';
import '/sections/product_details_screen.dart'; // الشاشة الثالثة

class SubShopListScreen extends StatelessWidget {
  final String categoryName;

  const SubShopListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // عرض قائمة المحلات المنزلية
    final shops = homeRepairShops;

    return Scaffold(
      appBar: AppBar(
        title: Text("قائمة محلات الـ $categoryName"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "عدد المحلات المتاحة: ${shops.length}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(shop.icon, size: 30, color: Colors.blue),
                      title: Text("محل ${shop.name}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("اضغط لعرض المنتجات"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // **الربط بالشاشة الثالثة (ProductDetailsScreen)**
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              shopName: shop.name,
                              products: shop.products,
                            ),
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
      ),
    );
  }
}
