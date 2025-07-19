// lib/admin/providers/admin_auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminRole { 
  superAdmin, 
  kycOfficer, 
  inventoryManager,
  support 
}

class AdminUser {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<String> permissions;
  final bool mfaEnabled;
  final DateTime lastLogin;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.mfaEnabled,
    required this.lastLogin,
    this.isActive = true,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => AdminRole.support,
      ),
      permissions: List<String>.from(json['permissions'] ?? []),
      mfaEnabled: json['mfaEnabled'] ?? false,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
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
      'isActive': isActive,
    };
  }

  String get roleDisplayName {
    switch (role) {
      case AdminRole.superAdmin:
        return 'Super Administrator';
      case AdminRole.kycOfficer:
        return 'KYC Officer';
      case AdminRole.inventoryManager:
        return 'Inventory Manager';
      case AdminRole.support:
        return 'Support Staff';
    }
  }

  List<String> get defaultPermissions {
    switch (role) {
      case AdminRole.superAdmin:
        return [
          'user_management',
          'transaction_oversight',
          'system_config',
          'kyc_approval',
          'reports',
          'announcements',
          'pricing_control',
          'inventory_management',
          'admin_management'
        ];
      case AdminRole.kycOfficer:
        return [
          'kyc_approval',
          'user_management',
          'transaction_oversight'
        ];
      case AdminRole.inventoryManager:
        return [
          'inventory_management',
          'pricing_control',
          'transaction_oversight',
          'reports'
        ];
      case AdminRole.support:
        return [
          'user_management',
          'transaction_oversight',
          'customer_support'
        ];
    }
  }
}

class AdminAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  AdminUser? _currentAdmin;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  AdminUser? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _currentAdmin != null;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  AdminAuthProvider() {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadAdminProfile(user.uid);
      } else {
        _currentAdmin = null;
        notifyListeners();
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _hasError = false;
    notifyListeners();

    try {
      // First, try Firebase authentication
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (credential.user != null) {
          // Load admin profile from Firestore
          await _loadAdminProfile(credential.user!.uid);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } on FirebaseAuthException catch (e) {
        // If Firebase auth fails, fall back to demo mode for specific emails
        if (_isDemoEmail(email)) {
          return await _signInDemoMode(email, password);
        }
        
        // Handle Firebase auth errors
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No admin account found with this email.';
            break;
          case 'wrong-password':
            _errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            _errorMessage = 'Invalid email format.';
            break;
          case 'too-many-requests':
            _errorMessage = 'Too many failed attempts. Try again later.';
            break;
          case 'network-request-failed':
            // If network fails, try demo mode
            if (_isDemoEmail(email)) {
              return await _signInDemoMode(email, password);
            }
            _errorMessage = 'Network error. Please check your connection.';
            break;
          default:
            _errorMessage = 'Login failed: ${e.message}';
        }
      }

      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool _isDemoEmail(String email) {
    const demoEmails = [
      'admin@rmsgold.com',
      'kyc@rmsgold.com',
      'inventory@rmsgold.com',
      'support@rmsgold.com'
    ];
    return demoEmails.contains(email.toLowerCase());
  }

  Future<bool> _signInDemoMode(String email, String password) async {
    // Demo authentication for development/presentation
    await Future.delayed(const Duration(seconds: 1));

    final Map<String, Map<String, dynamic>> demoUsers = {
      'admin@rmsgold.com': {
        'password': 'admin123456',
        'user': AdminUser(
          id: 'admin-001',
          email: email,
          name: 'System Administrator',
          role: AdminRole.superAdmin,
          permissions: AdminRole.superAdmin.name == 'superAdmin' ? _getAllPermissions() : [],
          mfaEnabled: false,
          lastLogin: DateTime.now(),
        )
      },
      'kyc@rmsgold.com': {
        'password': 'kyc123456',
        'user': AdminUser(
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
        )
      },
      'inventory@rmsgold.com': {
        'password': 'inventory123456',
        'user': AdminUser(
          id: 'inventory-001',
          email: email,
          name: 'Inventory Manager',
          role: AdminRole.inventoryManager,
          permissions: [
            'inventory_management',
            'pricing_control',
            'transaction_oversight',
            'reports'
          ],
          mfaEnabled: false,
          lastLogin: DateTime.now(),
        )
      },
      'support@rmsgold.com': {
        'password': 'support123456',
        'user': AdminUser(
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
        )
      },
    };

    final demoUser = demoUsers[email.toLowerCase()];
    if (demoUser != null && demoUser['password'] == password) {
      _currentAdmin = demoUser['user'] as AdminUser;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Invalid demo credentials';
    _hasError = true;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  List<String> _getAllPermissions() {
    return [
      'user_management',
      'transaction_oversight',
      'system_config',
      'kyc_approval',
      'reports',
      'announcements',
      'pricing_control',
      'inventory_management',
      'admin_management',
      'customer_support'
    ];
  }

  Future<void> _loadAdminProfile(String uid) async {
    try {
      final doc = await _firestore.collection('admin_users').doc(uid).get();
      
      if (doc.exists) {
        _currentAdmin = AdminUser.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
        
        // Update last login
        await _firestore.collection('admin_users').doc(uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });
      } else {
        // Create admin profile if it doesn't exist (for new Firebase users)
        await _createAdminProfile(uid);
      }
    } catch (e) {
      print('Error loading admin profile: $e');
    }
  }

  Future<void> _createAdminProfile(String uid) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Determine role based on email domain
    AdminRole role = AdminRole.support;
    if (user.email?.contains('admin@') == true) {
      role = AdminRole.superAdmin;
    } else if (user.email?.contains('kyc@') == true) {
      role = AdminRole.kycOfficer;
    } else if (user.email?.contains('inventory@') == true) {
      role = AdminRole.inventoryManager;
    }

    final adminUser = AdminUser(
      id: uid,
      email: user.email!,
      name: user.displayName ?? 'Admin User',
      role: role,
      permissions: _getDefaultPermissionsForRole(role),
      mfaEnabled: false,
      lastLogin: DateTime.now(),
    );

    await _firestore.collection('admin_users').doc(uid).set(adminUser.toJson());
    _currentAdmin = adminUser;
  }

  List<String> _getDefaultPermissionsForRole(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return _getAllPermissions();
      case AdminRole.kycOfficer:
        return ['kyc_approval', 'user_management', 'transaction_oversight'];
      case AdminRole.inventoryManager:
        return ['inventory_management', 'pricing_control', 'transaction_oversight', 'reports'];
      case AdminRole.support:
        return ['user_management', 'transaction_oversight', 'customer_support'];
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
    
    _currentAdmin = null;
    _errorMessage = null;
    _hasError = false;
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
      case 'users':
        return hasPermission('user_management');
      case 'transactions':
      case 'transaction_monitoring':
        return hasPermission('transaction_oversight');
      case 'kyc':
      case 'kyc_approvals':
        return hasPermission('kyc_approval');
      case 'inventory':
      case 'gold_inventory':
        return hasPermission('inventory_management');
      case 'pricing':
      case 'price_management':
        return hasPermission('pricing_control');
      case 'reports':
      case 'analytics':
        return hasPermission('reports');
      case 'announcements':
        return hasPermission('announcements');
      case 'settings':
      case 'system_config':
        return hasPermission('system_config');
      case 'admin_management':
        return hasPermission('admin_management');
      default:
        return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    _hasError = false;
    notifyListeners();
  }

  // Password change with Firebase
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentAdmin == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user before changing password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Password change failed: $e';
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // MFA setup
  Future<bool> setupMFA() async {
    if (_currentAdmin == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // Update admin profile with MFA enabled
      await _firestore.collection('admin_users').doc(_currentAdmin!.id).update({
        'mfaEnabled': true,
      });
      
      _currentAdmin = AdminUser(
        id: _currentAdmin!.id,
        email: _currentAdmin!.email,
        name: _currentAdmin!.name,
        role: _currentAdmin!.role,
        permissions: _currentAdmin!.permissions,
        mfaEnabled: true,
        lastLogin: _currentAdmin!.lastLogin,
        isActive: _currentAdmin!.isActive,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'MFA setup failed: $e';
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Log admin actions
  Future<void> logAction(String action, String description, {String? targetId}) async {
    if (_currentAdmin == null) return;

    try {
      await _firestore.collection('admin_actions').add({
        'adminId': _currentAdmin!.id,
        'adminEmail': _currentAdmin!.email,
        'action': action,
        'description': description,
        'targetId': targetId,
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': 'N/A', // Would be captured from request in real app
      });
    } catch (e) {
      print('Error logging admin action: $e');
    }
  }

  // Get admin activity log (from Firestore or demo data)
  Future<List<Map<String, dynamic>>> getAdminActivityLog() async {
    if (_currentAdmin == null) return [];

    try {
      final snapshot = await _firestore
          .collection('admin_actions')
          .where('adminId', isEqualTo: _currentAdmin!.id)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      // Return demo data if Firestore fails
      return _getDemoActivityLog();
    }
  }

  List<Map<String, dynamic>> _getDemoActivityLog() {
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
      'admin_role': _currentAdmin?.roleDisplayName ?? 'Unknown',
      'admin_permissions': _currentAdmin?.permissions.length ?? 0,
    };
  }

  // Check if admin session is valid
  bool isSessionValid() {
    if (_currentAdmin == null) return false;
    
    // Check if last login was within 24 hours (for demo)
    final hoursSinceLogin = DateTime.now().difference(_currentAdmin!.lastLogin).inHours;
    return hoursSinceLogin < 24;
  }

  // Refresh admin session
  Future<void> refreshSession() async {
    if (_auth.currentUser != null) {
      await _loadAdminProfile(_auth.currentUser!.uid);
    }
  }
}
