import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'shop_model.dart';
import 'ShopProductsScreen.dart';

class ShopSelectionScreen extends StatelessWidget {
  const ShopSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'اختر محل الهواتف',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أفضل محلات الهواتف',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'اختر من بين أفضل المحلات الموثوقة',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 20.0,
            ),
            child: Container(
              height: isSmallScreen ? 50 : 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن محل...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Categories Filter
          SizedBox(
            height: isSmallScreen ? 45 : 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
              ),
              children: [
                _buildCategoryChip('الكل', true, isSmallScreen),
                _buildCategoryChip('الأعلى تقييماً', false, isSmallScreen),
                _buildCategoryChip('الأقرب', false, isSmallScreen),
                _buildCategoryChip('متاجر مميزة', false, isSmallScreen),
                _buildCategoryChip('عروض خاصة', false, isSmallScreen),
              ],
            ),
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Shops List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
              ),
              itemCount: availableShops.length,
              itemBuilder: (context, index) {
                final shop = availableShops[index];
                return _buildShopCard(
                    shop, context, screenWidth, screenHeight, isSmallScreen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String text, bool isActive, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
      child: ChoiceChip(
        label: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.blue[700],
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 12 : 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        selected: isActive,
        onSelected: (bool value) {},
        backgroundColor: Colors.white,
        selectedColor: Colors.blue[700],
        side: BorderSide(
          color: Colors.blue[700]!,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildShopCard(Shop shop, BuildContext context, double screenWidth,
      double screenHeight, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Row(
              children: [
                // Shop Image - مرن مع MediaQuery
                Container(
                  width: isSmallScreen ? 70 : 80,
                  height: isSmallScreen ? 70 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue[50],
                    image: DecorationImage(
                      image: NetworkImage(shop.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(width: isSmallScreen ? 12 : 16),

                // Shop Info - استخدام Expanded لجعل المحتوى مرن
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              shop.name,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (shop.isVerified)
                            Icon(
                              Icons.verified,
                              color: Colors.blue[500],
                              size: isSmallScreen ? 16 : 18,
                            ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 3 : 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: isSmallScreen ? 3 : 4),
                          Expanded(
                            child: Text(
                              shop.location,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[600],
                            size: isSmallScreen ? 14 : 16,
                          ),
                          SizedBox(width: isSmallScreen ? 3 : 4),
                          Text(
                            shop.rating.toString(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: isSmallScreen ? 2 : 4),
                          Expanded(
                            child: Text(
                              '(${shop.reviewCount} تقييم)',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 13,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 6 : 8,
                              vertical: isSmallScreen ? 3 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: shop.isOpen
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: shop.isOpen
                                    ? Colors.green[200]!
                                    : Colors.red[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color:
                                        shop.isOpen ? Colors.green : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 3 : 4),
                                Text(
                                  shop.isOpen ? 'مفتوح' : 'مغلق',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: shop.isOpen
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      if (shop.specialOffers.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 8,
                            vertical: isSmallScreen ? 3 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                size: isSmallScreen ? 12 : 14,
                                color: Colors.orange[600],
                              ),
                              SizedBox(width: isSmallScreen ? 3 : 4),
                              Expanded(
                                child: Text(
                                  shop.specialOffers,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(width: isSmallScreen ? 8 : 12),

                // Enter Button
                Container(
                  width: isSmallScreen ? 45 : 50,
                  height: isSmallScreen ? 45 : 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
