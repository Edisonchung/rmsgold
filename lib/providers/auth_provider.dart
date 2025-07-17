// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final bool kycApproved;
  final DateTime joinDate;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.kycApproved,
    required this.joinDate,
  });
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (email == 'demo@rmsgold.com' && password == 'demo123456') {
        _currentUser = User(
          id: 'demo-user-001',
          email: email,
          name: 'Demo User',
          phone: '+60123456789',
          kycApproved: true,
          joinDate: DateTime.now().subtract(const Duration(days: 30)),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
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
}
