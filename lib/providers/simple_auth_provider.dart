import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/simple_auth_service.dart';

class SimpleAuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await SimpleAuthService.signUpWithEmail(email, password, fullName);
      
      if (result['success']) {
        final userData = result['user'];
        _user = UserModel(
          uid: userData['uid'],
          email: userData['email'],
          fullName: fullName,
          phoneNumber: phoneNumber,
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );
        _setLoading(false);
        return true;
      } else {
        _setError(result['error']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await SimpleAuthService.loginWithEmail(email, password);
      
      if (result['success']) {
        final userData = result['user'];
        _user = UserModel(
          uid: userData['uid'],
          email: userData['email'],
          fullName: userData['name'],
          phoneNumber: '',
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );
        _setLoading(false);
        return true;
      } else {
        _setError(result['error']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Continue as guest
  Future<bool> continueAsGuest() async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await SimpleAuthService.continueAsGuest();
      
      if (result['success']) {
        final userData = result['user'];
        _user = UserModel(
          uid: userData['uid'],
          email: userData['email'],
          fullName: userData['name'],
          phoneNumber: '',
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );
        _setLoading(false);
        return true;
      } else {
        _setError('Guest mode failed.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Guest mode failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Sign in with phone
  Future<bool> signInWithPhone({required String phoneNumber}) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await SimpleAuthService.signInWithPhone(phoneNumber);
      
      if (result['success']) {
        final userData = result['user'];
        _user = UserModel(
          uid: userData['uid'],
          email: userData['email'],
          fullName: userData['name'],
          phoneNumber: phoneNumber,
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );
        _setLoading(false);
        return true;
      } else {
        _setError(result['error']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Phone authentication failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await SimpleAuthService.logout();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
      _setLoading(false);
    }
  }

  // Send password reset email (mock)
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Simulate sending password reset email
      await Future.delayed(Duration(milliseconds: 500));
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send password reset email. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Phone verification methods (mock)
  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Mock verification
      await Future.delayed(Duration(milliseconds: 500));
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Phone verification failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOTP(String otp) async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Mock OTP verification - always succeed for testing
      await Future.delayed(Duration(milliseconds: 500));
      
      _user = UserModel(
        uid: 'phone_verified_user',
        email: 'phone@farmer.com',
        fullName: 'Phone User',
        phoneNumber: '+1234567890',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('OTP verification failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    try {
      _setLoading(true);
      
      // Check if user was previously authenticated
      if (SimpleAuthService.isAuthenticated) {
        final userData = SimpleAuthService.currentUser;
        _user = UserModel(
          uid: userData['uid']!,
          email: userData['email']!,
          fullName: userData['name']!,
          phoneNumber: '',
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );
      }
      
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
    }
  }
}