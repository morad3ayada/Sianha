import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shop_model.dart';
import 'product_model.dart';
import 'order_confirmation_screen.dart';
import 'mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomNavIndex = 0;
  final ScrollController _scrollController = ScrollController();

  void _navigateToOrderConfirmation(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(product: product),
      ),
    );
  }

  void _goBack() {
    Navigator.maybePop(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // AppBar ثابت في الأعلى
              _buildCustomAppBar(screenWidth, isSmallScreen),

              // محتوى قابل للتمرير مع خاصية السحب
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 20),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.015),

                      // البانر الترويجي مع خاصية السحب
                      _buildDraggablePromotionalBanner(
                          screenWidth, screenHeight, isSmallScreen),

                      SizedBox(height: screenHeight * 0.025),

                      // قسم المنتجات الشائعة مع خاصية السحب الأفقية
                      _buildDraggablePopularSection(
                          screenWidth, screenHeight, isSmallScreen),

                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(screenWidth),
    );
  }

  Widget _buildCustomAppBar(double screenWidth, bool isSmallScreen) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // زر الرجوع مع تأثير اللمس
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _goBack,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: isSmallScreen ? 36 : 40,
                height: isSmallScreen ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: isSmallScreen ? 16 : 18,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ),

          // Location Section
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // إمكانية إضافة وظيفة عند النقر على الموقع
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: isSmallScreen ? 40 : 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: isSmallScreen ? 16 : 18,
                        color: const Color(0xFF6C757D),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          'مصر ام الديا',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? screenWidth * 0.030
                                : screenWidth * 0.034,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: isSmallScreen ? 16 : 18,
                        color: const Color(0xFF6C757D),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Icons Section
          Container(
            height: isSmallScreen ? 40 : 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAppBarIcon(
                  Icons.shopping_bag_outlined,
                  screenWidth,
                  isSmallScreen,
                  onPressed: () {},
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                _buildAppBarIcon(
                  Icons.notifications_none,
                  screenWidth,
                  isSmallScreen,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, double screenWidth, bool isSmallScreen,
      {VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: isSmallScreen ? 28 : 32,
          height: isSmallScreen ? 28 : 32,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 16 : 18,
            color: const Color(0xFF495057),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggablePromotionalBanner(
      double screenWidth, double screenHeight, bool isSmallScreen) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // السماح بالسحب العمودي للبانر
        _scrollController.jumpTo(_scrollController.offset - details.delta.dy);
      },
      child: _buildPromotionalBanner(screenWidth, screenHeight, isSmallScreen),
    );
  }

  Widget _buildPromotionalBanner(
      double screenWidth, double screenHeight, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        height: isSmallScreen ? screenHeight * 0.20 : screenHeight * 0.22,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB800), Color(0xFFFFD166)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB800).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // الخلفية الزخرفية المتحركة
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: isSmallScreen ? 80 : 100,
                height: isSmallScreen ? 80 : 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: isSmallScreen ? 60 : 80,
                height: isSmallScreen ? 60 : 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(
                  isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مجموعة جديدة',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? screenWidth * 0.042
                                : screenWidth * 0.045,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        Text(
                          'عروض خاطفة تصل إلى 40% هذا الأسبوع.',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? screenWidth * 0.032
                                : screenWidth * 0.035,
                            color: const Color(0xFF555555),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Container(
                          width: isSmallScreen
                              ? screenWidth * 0.32
                              : screenWidth * 0.35,
                          height: isSmallScreen
                              ? screenHeight * 0.045
                              : screenHeight * 0.05,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'تسوق الآن',
                                    style: TextStyle(
                                      fontSize: isSmallScreen
                                          ? screenWidth * 0.032
                                          : screenWidth * 0.035,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFFB800),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Container(
                    width:
                        isSmallScreen ? screenWidth * 0.18 : screenWidth * 0.2,
                    height:
                        isSmallScreen ? screenWidth * 0.18 : screenWidth * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_offer_outlined,
                        size: isSmallScreen
                            ? screenWidth * 0.1
                            : screenWidth * 0.12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggablePopularSection(
      double screenWidth, double screenHeight, bool isSmallScreen) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // السماح بالسحب العمودي للقسم
        _scrollController.jumpTo(_scrollController.offset - details.delta.dy);
      },
      child: _buildPopularNowSection(screenWidth, screenHeight, isSmallScreen),
    );
  }

  Widget _buildPopularNowSection(
      double screenWidth, double screenHeight, bool isSmallScreen) {
    final popularProducts = shopProducts.take(4).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأكثر شيوعاً الآن',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? screenWidth * 0.038
                        : screenWidth * 0.042,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // إمكانية إضافة وظيفة عند النقر على عرض الكل
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'عرض الكل',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? screenWidth * 0.030
                              : screenWidth * 0.035,
                          color: const Color(0xFFFFB800),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          SizedBox(
            height: isSmallScreen ? screenHeight * 0.32 : screenHeight * 0.36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: popularProducts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _navigateToOrderConfirmation(
                        context, popularProducts[index]);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == popularProducts.length - 1
                          ? 0
                          : screenWidth * 0.035,
                    ),
                    child: _buildHorizontalProductCard(
                      popularProducts[index],
                      screenWidth,
                      screenHeight,
                      isSmallScreen,
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

  Widget _buildHorizontalProductCard(Product product, double screenWidth,
      double screenHeight, bool isSmallScreen) {
    final discountedPrice = product.discount > 0
        ? product.price * (1 - product.discount)
        : product.price;

    return Container(
      width: isSmallScreen ? screenWidth * 0.42 : screenWidth * 0.44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // الصورة مع ارتفاع ثابت
              Container(
                height:
                    isSmallScreen ? screenHeight * 0.18 : screenHeight * 0.20,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(product.category),
                          size: isSmallScreen
                              ? screenWidth * 0.08
                              : screenWidth * 0.09,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(product.category),
                          size: isSmallScreen
                              ? screenWidth * 0.08
                              : screenWidth * 0.09,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (product.discount > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen
                          ? screenWidth * 0.025
                          : screenWidth * 0.03,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4757),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(product.discount * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen
                            ? screenWidth * 0.028
                            : screenWidth * 0.032,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
            ],
          ),

          // المحتوى النصي
          Padding(
            // ** تم تقليل قيمة الـ padding الرأسي قليلاً هنا **
            padding: EdgeInsets.symmetric(
              horizontal:
                  isSmallScreen ? screenWidth * 0.03 : screenWidth * 0.035,
              vertical: isSmallScreen
                  ? screenHeight * 0.01
                  : screenHeight * 0.012, // تم تعديل القيمة الرأسية
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? screenWidth * 0.032
                        : screenWidth * 0.036,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005), // تم تقليل الارتفاع
                Row(
                  children: [
                    Text(
                      '\$${discountedPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? screenWidth * 0.036
                            : screenWidth * 0.040,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFB800),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (product.discount > 0) ...[
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? screenWidth * 0.026
                              : screenWidth * 0.030,
                          color: const Color(0xFF909090),
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: screenHeight * 0.008), // تم تقليل الارتفاع
                SizedBox(
                  width: double.infinity,
                  // ** تم تقليل ارتفاع الزر قليلاً **
                  height: isSmallScreen
                      ? screenHeight * 0.032 // تم تعديل القيمة من 0.035
                      : screenHeight * 0.038, // تم تعديل القيمة من 0.040
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _navigateToOrderConfirmation(context, product);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB800).withOpacity(0.3),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'شراء الآن',
                            style: TextStyle(
                              fontSize: isSmallScreen
                                  ? screenWidth * 0.030
                                  : screenWidth * 0.034,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFFB800),
        unselectedItemColor: const Color(0xFF6C757D),
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: isSmallScreen ? 9 : 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: isSmallScreen ? 9 : 10,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                _currentBottomNavIndex == 0
                    ? Icons.home_rounded
                    : Icons.home_outlined,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                _currentBottomNavIndex == 1
                    ? Icons.shopping_bag_rounded
                    : Icons.shopping_bag_outlined,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            label: 'المشتريات',
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'هواتف':
        return Icons.phone_iphone_rounded;
      case 'إكسسوارات':
        return Icons.headset_rounded;
      case 'ساعات':
        return Icons.watch_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }
}
