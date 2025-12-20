// package:my_service_app/sections/electronics/Dealer/Electronicproducts/electronic_sales_screen.dart

import 'package:flutter/material.dart';
import 'electronic_models.dart'; // هذا الاستيراد سليم
import 'product_details_screen.dart'; // **تأكد من صحة هذا المسار**
import 'name_order.dart';

class ElectronicSalesScreen extends StatelessWidget {
  final String categoryName;

  const ElectronicSalesScreen({super.key, this.categoryName = "الإلكترونيات"});

  @override
  Widget build(BuildContext context) {
    final List<ElectronicShop> shops = electronicShops;

    return Scaffold(
      appBar: AppBar(
        title: Text("محلات $categoryName"),
        backgroundColor: Colors.amber.shade700,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "اختر محل الإلكترونيات المناسب:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(shop.icon,
                        size: 40, color: Colors.indigo.shade700),
                    title: Text(
                      shop.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text("عدد المنتجات: ${shop.products.length}"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            shopName: shop.name,
                            // **[التعديل الرئيسي هنا]: ببساطة نمرر shop.products**
                            // لأنها الآن List<Product> بشكل صحيح بعد تعديل electronic_models.dart
                            products: shop.products,
                          ),
                        ),
                      );
                    },
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
