import 'package:flutter/material.dart';

// استخدام الشاشات المستوردة بدلًا من التعريف المؤقت
import 'plumbing/shopingHome/sub_shop_list_screen.dart';
import 'electronics/Dealer/Electronicproducts/electronic_sales_screen.dart';
import 'plumbing/models/ShopSelectionScreen.dart';

// قائمة ببيانات الأقسام الرئيسية لتبسيط الكود
final List<Map<String, dynamic>> mainCategories = [
  {
    "title": "محلات الأدوات المنزلية",
    "subtitle": "أدوات صحية، كهرباء، سيراميك، وأكثر",
    "icon": Icons.home_work_rounded,
    "color": const Color(0xFF1976D2), // أزرق داكن
    "categoryName": "أدوات منزلية",
    "targetScreen":
        SubShopListScreen(categoryName: "أدوات منزلية"), // الشاشة المستهدفة
  },
  {
    "title": "محلات الإلكترونيات",
    "subtitle": "لابتوبات، أجهزة كهربائية، كاميرات",
    "icon": Icons.electrical_services_rounded,
    "color": const Color(0xFF388E3C), // أخضر داكن
    "categoryName": "إلكترونيات",
    "targetScreen": ElectronicSalesScreen(), // الشاشة المستهدفة
  },
  {
    "title": "محلات الموبايل والتابلت",
    "subtitle": "أجهزة، شواحن، أكسسوارات، وقطع غيار",
    "icon": Icons.smartphone_rounded,
    "color": const Color(0xFFE64A19), // برتقالي محروق
    "categoryName": "موبايل",
    "targetScreen":
        ShopSelectionScreen(), // الشاشة المستهدفة (يفترض أنها نفسها شاشة مبيعات الإلكترونيات)
  },
  {
    "title": "مواد البناء والتشطيب",
    "subtitle": "دهانات، خشب، حديد، وإمدادات",
    "icon": Icons.construction_rounded,
    "color": const Color(0xFF7B1FA2), // بنفسجي داكن
    "categoryName": "بناء",
    "targetScreen": SubShopListScreen(categoryName: "بناء"), // الشاشة المستهدفة
  },
];

class ShopListScreen extends StatelessWidget {
  const ShopListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfffff8e1), // لون أصفر فاتح جداً (Yellow 50)
      appBar: AppBar(
        title: const Text("أقسام المحلات الرئيسية"),
        backgroundColor: const Color(0xffffe700),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: mainCategories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final category = mainCategories[index];
          return _buildShopButton(
            context: context,
            title: category["title"],
            subtitle: category["subtitle"],
            icon: category["icon"],
            color: category["color"],
            // ✨ التعديل: استخدام الشاشة المستهدفة من الخريطة مباشرة ✨
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => category["targetScreen"],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // الدالة البانية لزر المحل بتصميم متطور
  Widget _buildShopButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        height: 120, // تحديد ارتفاع ثابت للبطاقة
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.white.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}
