import 'package:flutter/material.dart';
import 'sub_shop_list_screen.dart'; // الشاشة الثانية

class ShopListScreen extends StatelessWidget {
  const ShopListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("محلات أدوات منزلية"),
        backgroundColor: const Color(0xffffe700),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // زر المحلات المنزلية (الذي يؤدي للشاشة الثانية)
            _buildShopButton(
              context: context,
              title: "محلات الأدوات المنزلية",
              subtitle: "أدوات صحية، كهرباء، سيراميك، وأكثر",
              icon: Icons.home_work_rounded,
              color: Colors.blue.shade700,
              onTap: () {
                // **الربط بالشاشة الثانية (SubShopListScreen)**
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SubShopListScreen(categoryName: "أدوات منزلية"),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // زر المحلات الإلكترونية (مثال آخر)
            _buildShopButton(
              context: context,
              title: "محلات الإلكترونيات",
              subtitle: "موبايلات، أجهزة كهربائية، أكسسوارات",
              icon: Icons.electrical_services_rounded,
              color: Colors.green.shade700,
              onTap: () {
                // يمكن أن يؤدي إلى شاشة محلات الإلكترونيات الفرعية
              },
            ),
          ],
        ),
      ),
    );
  }

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: color)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
