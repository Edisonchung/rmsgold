// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeDemoUser();
  }

  void _initializeDemoUser() {
    // Initialize with demo user for presentation
    _currentUser = User(
      id: 'demo-user-001',
      email: 'demo@rmsgold.com',
      name: 'Demo User',
      phone: '+60123456789',
      icNumber: '123456-12-1234',
      address: 'Demo Address, Kuala Lumpur',
      bankAccount: 'Maybank - ****1234',
      kycApproved: true,
      mfaEnabled: false,
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
      kycStatus: KYCStatus.approved,
    );
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate sign in delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo credentials
      if (email == 'demo@rmsgold.com' && password == 'demo123456') {
        _currentUser = User(
          id: 'demo-user-001',
          email: email,
          name: 'Demo User',
          phone: '+60123456789',
          icNumber: '123456-12-1234',
          address: 'Demo Address, Kuala Lumpur',
          bankAccount: 'Maybank - ****1234',
          kycApproved: true,
          mfaEnabled: false,
          joinDate: DateTime.now().subtract(const Duration(days: 30)),
          kycStatus: KYCStatus.approved,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Invalid credentials';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String icNumber,
    required String address,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate registration delay
      await Future.delayed(const Duration(seconds: 2));

      // Create new user (demo)
      _currentUser = User(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phone: phone,
        icNumber: icNumber,
        address: address,
        kycApproved: false,
        mfaEnabled: false,
        joinDate: DateTime.now(),
        kycStatus: KYCStatus.pending,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void signOut() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate password reset
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Password reset failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate update delay
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        icNumber: _currentUser!.icNumber,
        address: address ?? _currentUser!.address,
        bankAccount: _currentUser!.bankAccount,
        kycApproved: _currentUser!.kycApproved,
        mfaEnabled: _currentUser!.mfaEnabled,
        joinDate: _currentUser!.joinDate,
        profileImageUrl: _currentUser!.profileImageUrl,
        kycStatus: _currentUser!.kycStatus,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> enableMFA() async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: _currentUser!.name,
        phone: _currentUser!.phone,
        icNumber: _currentUser!.icNumber,
        address: _currentUser!.address,
        bankAccount: _currentUser!.bankAccount,
        kycApproved: _currentUser!.kycApproved,
        mfaEnabled: true,
        joinDate: _currentUser!.joinDate,
        profileImageUrl: _currentUser!.profileImageUrl,
        kycStatus: _currentUser!.kycStatus,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'MFA enable failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
