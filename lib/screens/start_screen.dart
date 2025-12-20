import 'package:flutter/material.dart';
import 'dart:math' as math; // إضافة استيراد مكتبة math
import 'welcome_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _leftSlideAnimation;
  late Animation<Offset> _rightSlideAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _leftSlideAnimation = Tween<Offset>(
      begin: Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _rightSlideAnimation = Tween<Offset>(
      begin: Offset(2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFFFBC02D), // Yellow 700
      end: const Color(0xFFFFD700),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(Duration(milliseconds: 500), () {
      _animationController.forward();
    });

    Future.delayed(Duration(seconds: 4), () {
      _navigateToHome();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColorAnimation.value,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              // خلفية متحركة مع تأثيرات
              _buildAnimatedBackground(),

              // المحتوى الرئيسي
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // الشعار الرئيسي مع تأثيرات قوية
                        _buildMainLogo(),

                        SizedBox(height: 50),

                        // النص الرئيسي
                        _buildMainText(),

                        SizedBox(height: 20),

                        // النص الثانوي
                        _buildSubText(),

                        SizedBox(height: 50),

                        // شريط التقدم
                        _buildProgressBar(),
                      ],
                    );
                  },
                ),
              ),

              // الأيقونات العائمة
              _buildFloatingIcons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // دوائر خلفية متحركة
            Positioned(
              top: -100 + (_animationController.value * 50),
              right: -50 + (_animationController.value * 20),
              child: Transform.rotate(
                angle: _animationController.value * 0.5,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -150 - (_animationController.value * 30),
              left: -50 - (_animationController.value * 15),
              child: Transform.rotate(
                angle: -_animationController.value * 0.3,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // خطوط متقاطعة
            Positioned(
              top: 100,
              left: 50,
              child: Opacity(
                opacity: _opacityAnimation.value * 0.1,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Container(
                    width: 200,
                    height: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 100,
              right: 50,
              child: Opacity(
                opacity: _opacityAnimation.value * 0.1,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: 200,
                    height: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // هالة حول الشعار
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
            shape: BoxShape.circle,
          ),
        ),

        // الدائرة المقسمة
        Transform.rotate(
          angle: _rotationAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // النصف الأيسر
              Transform.translate(
                offset: _leftSlideAnimation.value * 80,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF030E40), Color(0xFF1a237e)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipPath(
                        clipper: HalfCircleClipper(isLeft: true),
                        child: Icon(
                          Icons.build_circle,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // النصف الأيمن
              Transform.translate(
                offset: _rightSlideAnimation.value * 80,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Colors.white, Color(0xFFf5f5f5)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipPath(
                        clipper: HalfCircleClipper(isLeft: false),
                        child: Icon(
                          Icons.engineering,
                          size: 70,
                          color: Color(0xFF030E40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // دائرة مركزية
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainText() {
    return Transform.translate(
      offset: _textSlideAnimation.value * 100,
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Color(0xFF030E40), Color(0xFF1a237e)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ).createShader(bounds);
          },
          child: Text(
            'خدمة صيانة',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              fontFamily: 'Tajawal',
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubText() {
    return Transform.translate(
      offset: _textSlideAnimation.value * 80,
      child: Opacity(
        opacity: _opacityAnimation.value,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'نظام متكامل لخدمات الصيانة المنزلية والكهربائية والسباكة\nبجودة عالية وسرعة في الأداء',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF030E40).withOpacity(0.9),
              fontFamily: 'Tajawal',
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Container(
        width: 200,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: Duration(seconds: 4),
              width: 200 * _animationController.value,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF030E40), Color(0xFF1a237e)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF030E40).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcons() {
    return Stack(
      children: [
        // أيقونات عائمة مع تأثيرات مختلفة
        _buildFloatingIcon(
          icon: Icons.settings,
          top: 80,
          left: 30,
          delay: 0,
          size: 35,
        ),
        _buildFloatingIcon(
          icon: Icons.electrical_services,
          top: 180,
          right: 40,
          delay: 200,
          size: 30,
        ),
        _buildFloatingIcon(
          icon: Icons.plumbing,
          bottom: 120,
          left: 40,
          delay: 400,
          size: 40,
        ),
        _buildFloatingIcon(
          icon: Icons.home_repair_service,
          bottom: 200,
          right: 30,
          delay: 600,
          size: 32,
        ),
        _buildFloatingIcon(
          icon: Icons.construction,
          top: 120,
          right: 80,
          delay: 800,
          size: 28,
        ),
      ],
    );
  }

  Widget _buildFloatingIcon({
    required IconData icon,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required int delay,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
        transform: Matrix4.translationValues(
          0,
          _animationController.value * (20 * (1 + delay / 1000)),
          0,
        )..rotateZ(_animationController.value * 0.5),
        child: Opacity(
          opacity: _opacityAnimation.value * 0.4,
          child: Icon(
            icon,
            size: size,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  final bool isLeft;

  HalfCircleClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    final path = Path();

    if (isLeft) {
      path.moveTo(size.width / 2, 0);
      path.arcTo(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ),
        -1.57,
        3.14,
        false,
      );
      path.close();
    } else {
      path.moveTo(size.width / 2, 0);
      path.arcTo(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ),
        1.57,
        3.14,
        false,
      );
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
