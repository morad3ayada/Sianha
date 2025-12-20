import 'package:flutter/material.dart';
import 'cartow/CarMaintenanceSection.dart'; // شاشة الميكانيكي
import 'showRequestDialog.dart'; // شاشة الونش

class SelectServiceTypeScreen extends StatelessWidget {
  const SelectServiceTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختر نوع الخدمة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xffd2c838),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // العنوان
              Text(
                'ما نوع الخدمة التي تريدها؟',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                'اختر الخدمة المناسبة لمشكلتك',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 30 : 40),

              // بطاقة الميكانيكي
              _buildServiceCard(
                title: 'ميكانيكي',
                subtitle: 'تصليح الأعطال الميكانيكية',
                description:
                    'تصليح المحرك، الفرامل، التعليق، وغيرها من الأعطال الميكانيكية',
                icon: Icons.build,
                color: Colors.orange,
                price: 'سعر الزيارة: ببلاش',
                onTap: () {
                  _navigateToMechanicOrder(context);
                },
                screenWidth: screenWidth,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: isSmallScreen ? 16 : 20),

              // بطاقة الونش
              _buildServiceCard(
                title: 'ونش',
                subtitle: 'خدمات السحب والنقل',
                description:
                    'سحب المركبة، نقلها إلى الورشة، خدمات الطوارئ على الطريق',
                icon: Icons.local_shipping,
                color: Colors.red,
                price: 'سعر الخدمة: يبدأ من 0 جنيه للكيلومتر',
                onTap: () {
                  _navigateToTowOrder(context);
                },
                screenWidth: screenWidth,
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: isSmallScreen ? 24 : 30),

              // معلومات إضافية
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info,
                            color: Colors.blue, size: isSmallScreen ? 16 : 18),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Text(
                          'معلومات مهمة:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Text(
                      '• أسعار الخدمة قد تختلف حسب المسافة ونوع المشكلة\n• الدفع إلكتروني عبر التطبيق\n• خدمة العملاء متاحة 24/7\n• يوجد ضمان على جميع الخدمات',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required String price,
    required VoidCallback onTap,
    required double screenWidth,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والأيقونة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 3 : 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 10),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(icon, color: color, size: isSmallScreen ? 25 : 30),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // الوصف
            Text(
              description,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            // السعر والزر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    price,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'اختر',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Icon(Icons.arrow_forward,
                          color: Colors.white, size: isSmallScreen ? 14 : 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // دالة للانتقال لشاشة طلب الميكانيكي
  void _navigateToMechanicOrder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMechanicOrderScreen(),
      ),
    );
  }

  // دالة للانتقال لشاشة طلب الونش
  void _navigateToTowOrder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CarMaintenanceSection(),
      ),
    );
  }
}
