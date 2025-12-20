// 📝 شاشة الشكاوى والتقييمات
import 'package:flutter/material.dart';

class ComplaintsAndRatingsScreen extends StatefulWidget {
  @override
  State<ComplaintsAndRatingsScreen> createState() =>
      _ComplaintsAndRatingsScreenState();
}

class _ComplaintsAndRatingsScreenState extends State<ComplaintsAndRatingsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTab = 'التقييمات';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // بيانات فارغة تماماً
  final List<Map<String, dynamic>> _ratingsData = [];
  final List<Map<String, dynamic>> _complaintsData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _animation.value) * 30),
            child: Opacity(
              opacity: _animation.value,
              child: Column(
                children: [
                  // الهيدر مع زر الرجوع
                  _buildHeader(),

                  // التبويبات
                  _buildTabs(),

                  // المحتوى
                  _buildContent(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // الهيدر مع زر الرجوع
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFD700), Color(0xFFFFC400)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الشكاوى والتقييمات',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'عرض تقييمات العملاء والشكاوى',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // التبويبات
  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['التقييمات', 'الشكاوى'].map((tab) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = tab;
                _animationController.reset();
                _animationController.forward();
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: _selectedTab == tab
                    ? LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFC400)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                color: _selectedTab == tab ? null : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    tab == 'التقييمات' ? Icons.star : Icons.report_problem,
                    color:
                        _selectedTab == tab ? Colors.white : Colors.grey[700],
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    tab,
                    style: TextStyle(
                      color:
                          _selectedTab == tab ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // المحتوى
  Widget _buildContent() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // عنوان القسم
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[100]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedTab == 'التقييمات'
                        ? Icons.star
                        : Icons.report_problem,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _selectedTab == 'التقييمات'
                        ? 'تقييمات العملاء'
                        : 'الشكاوى المقدمة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _selectedTab == 'التقييمات'
                        ? 'لا يوجد تقييمات'
                        : 'لا يوجد شكاوى',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // رسالة عدم وجود بيانات
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedTab == 'التقييمات'
                          ? Icons.star_outline
                          : Icons.report_problem_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 20),
                    Text(
                      _selectedTab == 'التقييمات'
                          ? 'لا توجد تقييمات'
                          : 'لا توجد شكاوى',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _selectedTab == 'التقييمات'
                          ? 'سيظهر هنا تقييمات العملاء لخدماتك'
                          : 'سيظهر هنا الشكاوى المقدمة من العملاء',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    if (_selectedTab == 'التقييمات')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.grey[300], size: 16),
                          Icon(Icons.star, color: Colors.grey[300], size: 16),
                          Icon(Icons.star, color: Colors.grey[300], size: 16),
                          Icon(Icons.star, color: Colors.grey[300], size: 16),
                          Icon(Icons.star, color: Colors.grey[300], size: 16),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
