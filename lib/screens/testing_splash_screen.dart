import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/simple_auth_service.dart';
import 'home/home_screen.dart';
import 'auth/login_screen.dart';

class TestingSplashScreen extends StatefulWidget {
  const TestingSplashScreen({super.key});

  @override
  State<TestingSplashScreen> createState() => _TestingSplashScreenState();
}

class _TestingSplashScreenState extends State<TestingSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Show testing options
      _showTestingOptions();
    }
  }

  void _showTestingOptions() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🌾 Rice Disease Detection App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose how to start testing:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            // Guest Mode Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _continueAsGuest,
                icon: const Icon(Icons.agriculture),
                label: const Text('Continue as Guest (Skip Login)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _goToLogin,
                icon: const Icon(Icons.login),
                label: const Text('Login/Signup (Test Mode)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            const Text(
              '🔧 Testing Mode: Authentication is bypassed for easy testing',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continueAsGuest() async {
    // Use guest mode
    final result = await SimpleAuthService.continueAsGuest();
    
    if (result['success'] && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.agriculture,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // App Name
            const Text(
              '🌾 Rice Disease Detection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 10),
            
            const Text(
              'AI-Powered Disease Detection for Farmers',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Initializing testing mode...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
