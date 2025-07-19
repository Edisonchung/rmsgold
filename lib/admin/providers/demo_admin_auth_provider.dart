// lib/admin/providers/demo_admin_auth_provider.dart
import 'package:flutter/material.dart';

class DemoAdminAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    
    // Demo credentials
    if ((email == 'admin@rmsgold.com' && password == 'admin123456') ||
        (email == 'kyc@rmsgold.com' && password == 'kyc123456') ||
        (email == 'super@rmsgold.com' && password == 'super123456')) {
      _isAuthenticated = true;
    } else {
      _errorMessage = 'Invalid email or password';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
