import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOTP(_phoneController.text.trim());

    if (mounted) {
      if (success) {
        setState(() {
          _otpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOTP(_otpController.text.trim());

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Invalid OTP'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.phone,
                size: 40,
                color: AppTheme.primaryGreen,
              ),
            ),
            
            const SizedBox(height: 30),
            
            Text(
              _otpSent ? 'Verify OTP' : 'Enter Phone Number',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _otpSent 
                  ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                  : 'We\'ll send you a verification code',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            
            const SizedBox(height: 40),
            
            if (!_otpSent) ...[
              // Phone Number Input
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: '+1234567890',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 30),
              
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: 'Send OTP',
                    onPressed: authProvider.isLoading ? null : _sendOTP,
                    isLoading: authProvider.isLoading,
                  );
                },
              ),
            ] else ...[
              // OTP Input
              CustomTextField(
                controller: _otpController,
                label: 'Verification Code',
                hintText: '123456',
                prefixIcon: Icons.security,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 20),
              
              // Resend OTP
              TextButton(
                onPressed: _sendOTP,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(color: AppTheme.primaryGreen),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: 'Verify OTP',
                    onPressed: authProvider.isLoading ? null : _verifyOTP,
                    isLoading: authProvider.isLoading,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}