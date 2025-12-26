import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/start_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/client_names_screen.dart';
import 'screens/technician_trader_screen.dart';

// استيراد صفحات العميل
import 'auth/client_login_screen.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/client_register_screen.dart';

// استيراد صفحات الفني
import 'technician_Trader/technician_login_screen.dart';
import 'technician_Trader/technician_register_screen.dart';
import 'technician_Trader/Technician/technician_home_screen.dart';
import 'technician_Trader/Merchant/trader_home_screen.dart';

// استيراد شاشة الأقسام + ملف البروفايل
import 'home/home_sections.dart';
import 'home/profile_screen.dart'; // ✅ شاشة البروفايل الجديدة

import 'core/widgets/connectivity_wrapper.dart'; // Added

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khidma',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.white,
      ),
      builder: (context, child) {
        return ConnectivityWrapper(child: child!);
      },
      home: const SplashScreen(), // Changed to SplashScreen for auth check
      routes: {
        // شاشات البداية
        '/start': (context) => const WelcomeScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/client-names': (context) => const ClientNamesScreen(),
        '/technician-trader': (context) => const TechnicianTraderScreen(),

        // شاشات العميل
        '/loginClient': (context) => const ClientLoginScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/registerClient': (context) => const RegisterCustomerScreen(),

        // شاشات الفني
        '/loginTechnician': (context) => const TechnicianLoginScreen(),
        '/registerTechnician': (context) => const TechnicianRegisterScreen(),

        // شاشات عامة
        '/homeSections': (context) => const HomeScreens(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

// Splash screen to check authentication status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');
    
    if (!mounted) return;
    
    if (token != null && token.isNotEmpty) {
      final roleLower = role?.toLowerCase() ?? '';
      
      if (roleLower == 'technician') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TechnicianHomeScreen()),
        );
      } else if (roleLower == 'trader' || roleLower == 'merchant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TraderHomeScreen()),
        );
      } else {
        // Default to Client Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreens()),
        );
      }
    } else {
      // User is not logged in, show welcome screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.engineering,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Khidma',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
