import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;

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

      final userCredential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        _user = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          isEmailVerified: userCredential.user!.emailVerified,
          createdAt: DateTime.now(),
        );

        await _saveUserToPreferences();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
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

      final userCredential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        await _loadUserData(userCredential.user!);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      _setLoading(true);
      _setError(null);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _loadUserData(FirebaseAuth.instance.currentUser!);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError('OTP verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_verificationId == null) {
        _setError('Verification ID not found. Please request OTP again.');
        return false;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _loadUserData(userCredential.user!);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Invalid OTP. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;
        if (updatedUser != null && updatedUser.emailVerified) {
          if (_user != null) {
            _user = _user!.copyWith(isEmailVerified: true);
            await _saveUserToPreferences();
            notifyListeners();
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      await _clearUserFromPreferences();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load user data from Firebase user
  Future<void> _loadUserData(User firebaseUser) async {
    _user = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? '',
      phoneNumber: firebaseUser.phoneNumber ?? '',
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
    await _saveUserToPreferences();
    notifyListeners();
  }

  // Save user to SharedPreferences
  Future<void> _saveUserToPreferences() async {
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', _user!.toJson());
    }
  }

  // Load user from SharedPreferences
  Future<void> loadUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        _user = UserModel.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Clear user from SharedPreferences
  Future<void> _clearUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Check if user is already signed in
  Future<void> checkAuthState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _loadUserData(user);
      } else {
        await loadUserFromPreferences();
      }
    } catch (e) {
      // Handle error silently
    }
  }
}