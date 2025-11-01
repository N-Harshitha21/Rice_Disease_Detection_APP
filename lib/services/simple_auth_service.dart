import 'package:flutter/foundation.dart';

class SimpleAuthService {
  static bool _isAuthenticated = false;
  static String _currentUserEmail = "";
  static String _currentUserName = "";
  
  // Simple login bypass for testing
  static Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));
      
      // Always succeed for testing
      _isAuthenticated = true;
      _currentUserEmail = email.isNotEmpty ? email : "test@farmer.com";
      _currentUserName = "Test Farmer";
      
      return {
        'success': true,
        'user': {
          'email': _currentUserEmail,
          'name': _currentUserName,
          'uid': 'test_user_123'
        }
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Authentication temporarily unavailable. Using guest mode.'
      };
    }
  }
  
  // Simple signup bypass for testing
  static Future<Map<String, dynamic>> signUpWithEmail(String email, String password, String name) async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));
      
      // Always succeed for testing
      _isAuthenticated = true;
      _currentUserEmail = email.isNotEmpty ? email : "test@farmer.com";
      _currentUserName = name.isNotEmpty ? name : "Test Farmer";
      
      return {
        'success': true,
        'user': {
          'email': _currentUserEmail,
          'name': _currentUserName,
          'uid': 'test_user_${DateTime.now().millisecondsSinceEpoch}'
        }
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Registration temporarily unavailable. Using guest mode.'
      };
    }
  }
  
  // Guest mode - skip authentication entirely
  static Future<Map<String, dynamic>> continueAsGuest() async {
    _isAuthenticated = true;
    _currentUserEmail = "guest@farmer.com";
    _currentUserName = "Guest Farmer";
    
    return {
      'success': true,
      'user': {
        'email': _currentUserEmail,
        'name': _currentUserName,
        'uid': 'guest_user'
      }
    };
  }
  
  // Check authentication status
  static bool get isAuthenticated => _isAuthenticated;
  
  // Get current user
  static Map<String, String> get currentUser => {
    'email': _currentUserEmail,
    'name': _currentUserName,
    'uid': _isAuthenticated ? 'authenticated_user' : 'guest'
  };
  
  // Logout
  static Future<void> logout() async {
    _isAuthenticated = false;
    _currentUserEmail = "";
    _currentUserName = "";
  }
  
  // Phone authentication bypass
  static Future<Map<String, dynamic>> signInWithPhone(String phoneNumber) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      _isAuthenticated = true;
      _currentUserEmail = "phone@farmer.com";
      _currentUserName = "Phone User";
      
      return {
        'success': true,
        'user': {
          'email': _currentUserEmail,
          'name': _currentUserName,
          'phone': phoneNumber,
          'uid': 'phone_user_123'
        }
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Phone authentication unavailable. Using guest mode.'
      };
    }
  }
}
