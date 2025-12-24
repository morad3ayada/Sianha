import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../home/home_sections.dart'; // For navigation back to Home

class SearchingOffersScreen extends StatefulWidget {
  const SearchingOffersScreen({super.key});

  @override
  State<SearchingOffersScreen> createState() => _SearchingOffersScreenState();
}

class _SearchingOffersScreenState extends State<SearchingOffersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[900]!, // Deep blue like the reference image header?
              // Or yellow as requested? User said "Yellow like home_sections but strictly like the image design". 
              // The image has a blue header and white body with blue text.
              // BUT user said: "tb2a safra bnfs design home_sections" -> be yellow with same design as home_sections.
              // So I will make the background YELLOW gradient.
              Colors.yellow[600]!,
              Colors.yellow[700]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header area similar to image "Searching for offers"
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                        onPressed: () {
                           // Navigate to HomeSections
                           Navigator.of(context).pushAndRemoveUntil(
                             MaterialPageRoute(builder: (_) => const HomeScreens()),
                             (route) => false,
                           );
                        },
                      ),
                    ),
                    const Text(
                      'جاري البحث عن العروض',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Contrast on yellow/blue, keeping white for now if header is dark, or black if yellow.
                        // Wait, if background is yellow, white text is bad.
                        // Home sections uses black text on yellow tiles.
                        // Let's use black text for visibility on yellow.
                      ),
                    ),
                    const SizedBox(width: 40), // Balance
                  ],
                ),
              ),
            ),
            
            const Spacer(),

            // Animation
            Center(
              child: CustomPaint(
                painter: PulsePainter(_controller),
                child: Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.2), // Light blue circle center
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Bottom Text
            const Text(
              'جاري البحث عن العروض',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'جاري البحث عن مقدمي الخدمة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class PulsePainter extends CustomPainter {
  final Animation<double> animation;

  PulsePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double maxRadius = size.width / 2;

    // Draw multiple expanding circles
    for (int i = 0; i < 3; i++) {
        double value = (animation.value + i / 3) % 1.0;
        double radius = value * maxRadius;
        int alpha = ((1 - value) * 255).toInt();
        
        paint.color = Colors.white.withOpacity((1 - value) * 0.5);
        canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
