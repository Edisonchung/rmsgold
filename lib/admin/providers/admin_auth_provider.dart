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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'permissions': permissions,
      'mfaEnabled': mfaEnabled,
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  String get roleDisplayName {
    switch (role) {
      case AdminRole.superAdmin:
        return 'Super Administrator';
      case AdminRole.kycOfficer:
        return 'KYC Officer';
      case AdminRole.support:
        return 'Support Staff';
    }
  }
}

class AdminAuthProvider extends ChangeNotifier {
  AdminUser? _currentAdmin;
  bool _isLoading = false;
  String? _errorMessage;

  AdminUser? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _currentAdmin != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate authentication delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo admin credentials
      if (email == 'admin@rmsgold.com' && password == 'admin123456') {
        _currentAdmin = AdminUser(
          id: 'admin-001',
          email: email,
          name: 'System Administrator',
          role: AdminRole.superAdmin,
          permissions: [
            'user_management',
            'transaction_oversight',
            'system_config',
            'kyc_approval',
            'reports',
            'announcements',
            'pricing_control',
            'inventory_management'
          ],
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
          permissions: [
            'kyc_approval',
            'user_management',
            'transaction_oversight'
          ],
          mfaEnabled: true,
          lastLogin: DateTime.now(),
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (email == 'support@rmsgold.com' && password == 'support123456') {
        _currentAdmin = AdminUser(
          id: 'support-001',
          email: email,
          name: 'Support Staff',
          role: AdminRole.support,
          permissions: [
            'user_management',
            'transaction_oversight',
            'customer_support'
          ],
          mfaEnabled: false,
          lastLogin: DateTime.now(),
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Invalid admin credentials';
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

  void signOut() {
    _currentAdmin = null;
    _errorMessage = null;
    notifyListeners();
  }

  bool hasPermission(String permission) {
    if (_currentAdmin == null) return false;
    
    // Super admin has all permissions
    if (_currentAdmin!.role == AdminRole.superAdmin) return true;
    
    return _currentAdmin!.permissions.contains(permission);
  }

  bool canAccessModule(String module) {
    switch (module.toLowerCase()) {
      case 'dashboard':
        return isAuthenticated;
      case 'user_management':
        return hasPermission('user_management');
      case 'transactions':
        return hasPermission('transaction_oversight');
      case 'kyc_approvals':
        return hasPermission('kyc_approval');
      case 'reports':
        return hasPermission('reports');
      case 'settings':
        return hasPermission('system_config');
      default:
        return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Demo method to simulate password change
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentAdmin == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would validate the old password and update the new one
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Password change failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Demo method to simulate MFA setup
  Future<bool> setupMFA() async {
    if (_currentAdmin == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // Update admin with MFA enabled
      _currentAdmin = AdminUser(
        id: _currentAdmin!.id,
        email: _currentAdmin!.email,
        name: _currentAdmin!.name,
        role: _currentAdmin!.role,
        permissions: _currentAdmin!.permissions,
        mfaEnabled: true,
        lastLogin: _currentAdmin!.lastLogin,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'MFA setup failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get admin activity log (demo data)
  List<Map<String, dynamic>> getAdminActivityLog() {
    if (_currentAdmin == null) return [];

    return [
      {
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'action': 'User Management',
        'description': 'Approved KYC for user: john.doe@email.com',
        'module': 'KYC',
        'severity': 'normal',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        'action': 'Transaction Monitoring',
        'description': 'Flagged large transaction for review: RM 75,000',
        'module': 'Transactions',
        'severity': 'high',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'action': 'System Configuration',
        'description': 'Updated gold price spread to 3.6%',
        'module': 'Settings',
        'severity': 'normal',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'action': 'User Registration',
        'description': 'New user registration: jane.smith@email.com',
        'module': 'Users',
        'severity': 'low',
      },
    ];
  }

  // Get system stats (demo data)
  Map<String, dynamic> getSystemStats() {
    return {
      'total_users': 1247,
      'pending_kyc': 23,
      'daily_transactions': 127,
      'daily_volume': 45230.50,
      'gold_inventory': 2450.5,
      'system_uptime': '99.9%',
      'last_backup': DateTime.now().subtract(const Duration(hours: 2)),
      'active_sessions': 156,
    };
  }
}
