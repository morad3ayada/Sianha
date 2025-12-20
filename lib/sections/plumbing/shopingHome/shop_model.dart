import 'product_model.dart';
import 'package:flutter/material.dart';

// نموذج المحل الفرعي
class Shop {
  final String name; // اسم المحل (أدوات صحية، كهرباء، إلخ)
  final IconData icon;
  final List<Product> products;

  Shop({
    required this.name,
    required this.icon,
    required this.products,
  });
}

// قائمة بيانات المحلات المنزلية (التي تظهر في الشاشة 2)
List<Shop> homeRepairShops = [
  Shop(
    name: "أدوات صحية",
    icon: Icons.plumbing,
    products: [
      Product(
          name: "خلاط دش ايطالي",
          icon: Icons.shower,
          price: 1500.0,
          description: "خلاط عالي الجودة مع ضمان 5 سنوات."),
      Product(
          name: "مواسير PVC 4 بوصة",
          icon: Icons.water_damage, // تم التغيير: استخدام أيقونة بديلة للمواسير
          price: 150.0,
          description: "متر مواسير بلاستيك مقاومة للصدأ."),
    ],
  ),
  Shop(
    name: "كهرباء",
    icon: Icons.electrical_services,
    products: [
      Product(
          name: "مفتاح إضاءة مزدوج",
          icon: Icons.switch_left,
          price: 85.0,
          description: "مفتاح كهرباء أبيض مودرن."),
      Product(
          name: "أسلاك نحاس 3 مم",
          icon: Icons.cable,
          price: 450.0,
          description: "لفة أسلاك نحاسية عالية التوصيل."),
    ],
  ),
  Shop(
    name: "سيراميك",
    icon: Icons.grid_on,
    products: [
      Product(
          name: "بلاط حائط مطبخ",
          icon: Icons.square_foot,
          price: 120.0,
          description: "سعر المتر المربع، تصميم عصري."),
    ],
  ),
  Shop(
    name: "قزاز (زجاج)",
    icon: Icons.crop_square_rounded,
    products: [
      Product(
          name: "زجاج سيكوريت 6 مم",
          icon: Icons.crop_portrait,
          price: 350.0,
          description: "سعر المتر المربع، مقاوم للكسر."),
    ],
  ),
  Shop(
    name: "باب خشب",
    // تم التعديل: استخدام أيقونة door_front_door بدلاً من door_front
    icon: Icons.door_front_door,
    products: [
      Product(
          name: "باب غرفة جاهز",
          icon: Icons.door_sliding,
          price: 3500.0,
          description: "باب خشب موسكي عالي الجودة، يشمل المقابض."),
    ],
  ),
];
