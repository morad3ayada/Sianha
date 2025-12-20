import 'package:flutter/material.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/P1.png', // Man on phone
      'title': 'احجز بسهولة و سرعة',
      'description': 'اختر الخدمة المطلوبة و حدد الوقت المناسب لك و اترك الباقي علينا',
    },
    {
      'image': 'assets/P3.png', // Handyman/Electrician
      'title': 'خدمات صيانة منزلية احترافية',
      'description': 'احصل علي خدمات الصيانة المنزلية من فنيين محترفين في مجالات السباكة والكهرباء والتجارة وغيرها',
    },
    {
      'image': 'assets/P2.png', // Welder
      'title': 'فنيين محترفين و معتمدين',
      'description': 'جميع الفنيين لدينا معتمدين و مدربين علي اعلي مستوي لتقديم خدمة متميزة',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToRoleSelection();
    }
  }

  void _navigateToRoleSelection() {
    Navigator.pushNamed(context, '/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: _onboardingData[index],
              );
            },
          ),
          
          // Navigation Controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                TextButton(
                  onPressed: _navigateToRoleSelection,
                  child: Text(
                    'تخطي',
                    style: TextStyle(
                      color: Colors.amber[900], // Darker Amber for readability
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),

                // Indicators
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.amber[700] // Active: Yellow
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Next Button
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[700], // Yellow Icon Bg
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
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
}

class OnboardingPage extends StatelessWidget {
  final Map<String, String> data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Background Image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.7, // Image takes top 70%
          child: Image.asset(
            data['image']!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.error, size: 50, color: Colors.red)),
            ),
          ),
        ),

        // Gradient Overlay on Image for better text visibility (optional, but good)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.7,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),

        // Diagonal/Curved Card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: size.height * 0.45, // Card takes bottom 45%
          child: Stack(
            children: [
               // Yellow Decorative Shape (Behind the white card)
              Positioned(
                top: 0,
                right: 0, // Align to right based on screenshot (blue shape on right)
                child: CustomPaint(
                  size: Size(size.width, 100), // Height of the decorative part
                  painter: DecorativeShapePainter(color: Colors.amber[700]!), // Yellow
                ),
              ),

              // White Content Card
              ClipPath(
                clipper: CardClipper(),
                child: Container(
                  color: Colors.white,
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 80), // Padding content to avoid overlap with cut
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data['title']!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Cairo', // Assuming Cairo font is available or fallback
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data['description']!,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Clipper for the white content card
class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Start from bottom left
    path.lineTo(0, size.height);
    // Go to bottom right
    path.lineTo(size.width, size.height);
    // Go to top right
    path.lineTo(size.width, 40); // Standard height from top
    // Diagonal to top left (but sloped)
    // Actually, looking at screenshot: Left side is lower vs Right side.
    // Wait, Image 1: White part is lower on left, higher on right? 
    // No, blue shape is on right. The WHITE part seems to go Up-Left to Down-Right?
    // Let's do a simple diagonal: Top-Left (High) to Top-Right (Low).
    
    // Let's try: Start at (0, 40), go to (Width, 80).
    path.lineTo(size.width, 40);
    path.lineTo(0, 0); // Diagonal top edge: Top Left(0,0) -> Top Right(Width, 40)?
    // Let's do: Left side starts at 0 (higher), Right side starts at 60 (lower)
    // path.moveTo(0, 0); // Top Left
    // path.lineTo(size.width, 80); // Top Right (lower)
    
    // Actually let's use the provided screenshots design logic.
    // Cut from Left-Middle to Right-Top?
    // Let's make a nice curve/diagonal.
    // Start top-left at 30, top-right at 0.
    
    path.reset();
    path.moveTo(0, 50); // Top Left start
    path.lineTo(size.width, 0); // Top Right (Peak)
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Painter for the Yellow decorative shape
class DecorativeShapePainter extends CustomPainter {
  final Color color;
  DecorativeShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();
    // Drawing a shape that peeks out from the right top of the card
    // Since the card top goes from (0, 50) to (Width, 0),
    // We want a shape ABOVE that on the right?
    // Or maybe the yellow replaces the "Dark Blue" in screenshots.
    // In screenshots, the dark blue was a triangle on the right.
    
    // Triangle on top right
    path.moveTo(size.width * 0.6, 0); // Start x% across
    path.lineTo(size.width, 0); // Top Right corner
    path.lineTo(size.width, 100); // Down right side
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
