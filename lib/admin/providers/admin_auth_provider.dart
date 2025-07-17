// lib/admin/providers/admin_auth_provider.dart
import 'package:flutter/foundation.dart';

enum AdminRole { superAdmin, kycOfficer, support }

class AdminUser {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<String> permissions;
  final bool mfaEnabled;
  final DateTime lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.mfaEnabled,
    required this.lastLogin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      permissions: List<String>.from(json['permissions'] ?? []),
      mfaEnabled: json['mfaEnabled'] ?? false,
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }
}

class AdminAuthProvider extends ChangeNotifier {
  AdminUser? _currentAdmin;
  bool _isLoading = false;

  AdminUser? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _currentAdmin != null;
  bool get isLoading => _isLoading;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Demo admin credentials
      if (email == 'admin@rmsgold.com' && password == 'admin123456') {
        _currentAdmin = AdminUser(
          id: 'admin-001',
          email: email,
          name: 'System Administrator',
          role: AdminRole.superAdmin,
          permissions: ['user_management', 'transaction_oversight', 'system_config'],
          mfaEnabled: false,
          lastLogin: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (email == 'kyc@rmsgold.com' && password == 'kyc123456') {
        _currentAdmin = AdminUser(
          id: 'kyc-001',
          email: email,
          name: 'KYC Officer',
          role: AdminRole.kycOfficer,
          permissions: ['kyc_approval', 'user_management'],
          mfaEnabled: true,
          lastLogin: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void signOut() {
    _currentAdmin = null;
    notifyListeners();
  }

  bool hasPermission(String permission) {
    return _currentAdmin?.permissions.contains(permission) ?? false;
  }
}
