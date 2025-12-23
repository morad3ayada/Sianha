import 'package:flutter/material.dart';
import '../auth/client_login_screen.dart';
import 'technician_trader_screen.dart';
//'اختار نوع الحساب',
import '/technician_Trader/technician_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية
          Positioned.fill(
            child: Image.network(
              'https://img.freepik.com/free-vector/handyman-concept-illustration_114360-2851.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // طبقة شفافة فوق الخلفية
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),

          // زر الرجوع
          // Positioned(
          //   top: 40,
          //   left: 16,
          //   child: IconButton(
          //     icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //   ),
          // ),

          // محتوى الشاشة
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'اختار نوع الحساب',
                    style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // زر عميل
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientLoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'عميل',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // زر فني / تاجر
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TechnicianLoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.yellow[700]!),
                        ),
                      ),
                      child: const Text(
                        'فني / تاجر',
                        style: TextStyle(
                          color: Color(0xff111111),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
