// lib/admin/admin_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'providers/admin_auth_provider.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
      ],
      child: MaterialApp(
        title: 'RMS Gold Admin Portal',
        theme: AppTheme.goldTheme,
        home: Consumer<AdminAuthProvider>(
          builder: (context, adminAuth, _) {
            if (adminAuth.isAuthenticated) {
              return const AdminDashboardScreen();
            }
            return const AdminLoginScreen();
          },
        ),
        routes: {
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}

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

// lib/admin/screens/admin_login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final adminAuth = Provider.of<AdminAuthProvider>(context, listen: false);
    final success = await adminAuth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid admin credentials'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.amber.shade100,
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            elevation: 8,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 64,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'RMS Gold Admin Portal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Administrator Access Only',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Admin Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your admin email';
                        }
                        if (!value!.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Consumer<AdminAuthProvider>(
                      builder: (context, adminAuth, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: adminAuth.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: adminAuth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Sign In'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Admin Credentials:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Super Admin: admin@rmsgold.com / admin123456',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                          Text(
                            'KYC Officer: kyc@rmsgold.com / kyc123456',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// lib/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../widgets/admin_sidebar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _tabTitles = [
    'Dashboard',
    'User Management',
    'Transactions',
    'KYC Approvals',
    'Reports',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final adminAuth = Provider.of<AdminAuthProvider>(context);
    
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            adminUser: adminAuth.currentAdmin!,
          ),
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          _tabTitles[_selectedIndex],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            // Show notifications
                          },
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.amber.shade700,
                                child: Text(
                                  adminAuth.currentAdmin!.name.substring(0, 1),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(adminAuth.currentAdmin!.name),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.person),
                                  SizedBox(width: 8),
                                  Text('Profile'),
                                ],
                              ),
                              onTap: () {
                                // Navigate to profile
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.logout),
                                  SizedBox(width: 8),
                                  Text('Logout'),
                                ],
                              ),
                              onTap: () {
                                adminAuth.signOut();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Main content area
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildUserManagementContent();
      case 2:
        return _buildTransactionsContent();
      case 3:
        return _buildKYCContent();
      case 4:
        return _buildReportsContent();
      case 5:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Users',
                  '1,247',
                  Icons.people,
                  Colors.blue,
                  '+12% from last month',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Pending KYC',
                  '23',
                  Icons.pending_actions,
                  Colors.orange,
                  '5 require attention',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Today\'s Transactions',
                  'RM 45,230',
                  Icons.trending_up,
                  Colors.green,
                  '127 transactions',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Gold Inventory',
                  '2,450.5g',
                  Icons.inventory,
                  Colors.amber,
                  '85% capacity',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Activity
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Admin Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildActivityItem(
                            'KYC Approved',
                            'John Doe\'s KYC application approved',
                            '2 minutes ago',
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildActivityItem(
                            'Transaction Flagged',
                            'Large transaction flagged for review: RM 25,000',
                            '15 minutes ago',
                            Icons.flag,
                            Colors.red,
                          ),
                          _buildActivityItem(
                            'User Registered',
                            'New user registration: jane.smith@email.com',
                            '1 hour ago',
                            Icons.person_add,
                            Colors.blue,
                          ),
                          _buildActivityItem(
                            'Price Updated',
                            'Gold price updated to RM 475.50/g',
                            '2 hours ago',
                            Icons.update,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String description, String time, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(description),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildUserManagementContent() {
    return const Center(
      child: Text('User Management Content - Coming Next'),
    );
  }

  Widget _buildTransactionsContent() {
    return const TransactionMonitoringScreen();
  }

  Widget _buildKYCContent() {
    return const Center(
      child: Text('KYC Approval Content - Coming Next'),
    );
  }

  Widget _buildReportsContent() {
    return const Center(
      child: Text('Reports Content - Coming Next'),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text('Settings Content - Coming Next'),
    );
  }
}
