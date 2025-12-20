// package:my_service_app/sections/electronics/Dealer/Electronicproducts/electronic_models.dart

import 'package:flutter/material.dart';
// **أضف هذا الاستيراد:**
import 'product_model.dart'; // مسار ملف Product الرئيسي

// **[حذف]: لم نعد بحاجة إلى كلاس ElectronicProduct**

class ElectronicShop {
  final String name;
  final IconData icon;
  // **[تغيير هنا]: أصبح List<Product> بدلاً من List<ElectronicProduct>**
  final List<Product> products;

  ElectronicShop({
    required this.name,
    required this.icon,
    required this.products,
  });
}

List<ElectronicShop> electronicShops = [
  ElectronicShop(
    name: "محل لابتوب",
    icon: Icons.laptop_mac,
    products: [
      // **[تغيير هنا]: أصبح Product() بدلاً من ElectronicProduct()**
      Product(
          name: "لابتوب Dell XPS 15",
          icon: Icons.computer,
          price: 18000.0,
          description: "معالج i7، رام 16 جيجا، SSD 512 جيجا."),
      Product(
          name: "لابتوب HP Pavilion",
          icon: Icons.computer,
          price: 12500.0,
          description: "معالج i5، رام 8 جيجا، SSD 256 جيجا."),
      Product(
          name: "ماك بوك آير M2",
          icon: Icons.apple,
          price: 25000.0,
          description: "أداء فائق وعمر بطارية طويل."),
    ],
  ),
  ElectronicShop(
    name: "محل تلفزيونات",
    icon: Icons.tv,
    products: [
      Product(
          name: "تلفزيون سامسونج 55 بوصة 4K",
          icon: Icons.tv,
          price: 11000.0,
          description: "شاشة ذكية بدقة 4K فائقة."),
      Product(
          name: "تلفزيون LG OLED 65 بوصة",
          icon: Icons.tv,
          price: 28000.0,
          description: "ألوان حقيقية وتباين لا مثيل له."),
    ],
  ),
  ElectronicShop(
    name: "محل ألعاب (بلايستيشن/اكس بوكس)",
    icon: Icons.gamepad,
    products: [
      Product(
          name: "بلايستيشن 5",
          icon: Icons.videogame_asset,
          price: 15000.0,
          description: "أحدث جيل من أجهزة الألعاب."),
      Product(
          name: "Xbox Series X",
          icon: Icons.videogame_asset_outlined,
          price: 14500.0,
          description: "قوة وسرعة لا مثيل لهما."),
      Product(
          name: "يد تحكم إضافية DualSense",
          icon: Icons.gamepad_outlined,
          price: 1800.0,
          description: "تجربة لعب غامرة."),
    ],
  ),
];
