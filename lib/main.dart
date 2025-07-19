import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Import your existing providers
import 'providers/auth_provider.dart';
import 'providers/gold_provider.dart';
import 'providers/transaction_provider.dart';

// Import admin providers (corrected paths)
import 'admin/providers/admin_auth_provider.dart';
import 'admin/providers/admin_provider.dart';

// Import your existing screens
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/portfolio_screen.dart';

// Import admin components (corrected paths)
import 'admin/admin_main.dart';
import 'admin/screens/admin_dashboard.dart';
import 'admin/screens/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Your existing providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GoldProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        
        // Admin providers (corrected)
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'RMS Gold Account-i',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFFD4AF37, {
            50: Color(0xFFFFF8E1),
            100: Color(0xFFFFECB3),
            200: Color(0xFFFFE082),
            300: Color(0xFFFFD54F),
            400: Color(0xFFFFCA28),
            500: Color(0xFFD4AF37),
            600: Color(0xFFFFB300),
            700: Color(0xFFFFA000),
            800: Color(0xFFFF8F00),
            900: Color(0xFFFF6F00),
          }),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthGateway(),
          
          // User routes (your existing ones)
          '/user/dashboard': (context) => DashboardScreen(),
          '/user/portfolio': (context) => PortfolioScreen(),
          
          // Admin routes - Use AdminApp as the main entry point
          '/admin': (context) => AdminApp(),
          '/admin/login': (context) => AdminApp(),
          '/admin/dashboard': (context) => AdminApp(),
        },
        onGenerateRoute: (settings) {
          // Handle all admin routes through AdminApp
          if (settings.name?.startsWith('/admin') == true) {
            return MaterialPageRoute(
              builder: (context) => AdminApp(),
              settings: settings,
            );
          }
          
          return null;
        },
      ),
    );
  }
}

// Enhanced Auth Gateway with Admin Detection
class AuthGateway extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check current route to determine if it's an admin route
    final route = ModalRoute.of(context)?.settings.name ?? '';
    
    // If it's an admin route, show AdminApp
    if (route.startsWith('/admin') || Uri.base.path.startsWith('/admin')) {
      return AdminApp();
    }
    
    // Otherwise, show user authentication flow
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return DashboardScreen();
        }
        return EnhancedLoginScreen();
      },
    );
  }
}

// Enhanced Login Screen with Admin Access
class EnhancedLoginScreen extends StatefulWidget {
  @override
  _EnhancedLoginScreenState createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdminLogin = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo and title
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _isAdminLogin ? Icons.admin_panel_settings : Icons.account_balance,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'RMS Gold Account-i',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              SizedBox(height: 8),
              Text(
                _isAdminLogin ? 'Administrator Portal' : 'Digital Gold Investment Platform',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32),
              
              // Toggle between user and admin login
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAdminLogin = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isAdminLogin ? Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'User Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isAdminLogin ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAdminLogin = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isAdminLogin ? Color(0xFF1B5E20) : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Admin Portal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isAdminLogin ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              
              // Email field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAdminLogin ? Color(0xFF1B5E20) : Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isAdminLogin ? 'Access Admin Portal' : 'Login to Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              SizedBox(height: 16),
              
              // Demo credentials info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Demo Credentials',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    if (_isAdminLogin) ...[
                      Text('Super Admin: admin@rmsgold.com / admin123456', style: TextStyle(fontSize: 11)),
                      Text('KYC Officer: kyc@rmsgold.com / kyc123456', style: TextStyle(fontSize: 11)),
                      Text('Inventory: inventory@rmsgold.com / inventory123456', style: TextStyle(fontSize: 11)),
                    ] else ...[
                      Text('User: demo@rmsgold.com', style: TextStyle(fontSize: 12)),
                      Text('Password: demo123456', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ),
              
              // Quick access buttons
              if (_isAdminLogin) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _quickLogin('admin@rmsgold.com', 'admin123456'),
                        child: Text('Admin', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _quickLogin('kyc@rmsgold.com', 'kyc123456'),
                        child: Text('KYC', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _quickLogin('inventory@rmsgold.com', 'inventory123456'),
                        child: Text('Inventory', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _quickLogin('demo@rmsgold.com', 'demo123456'),
                  child: Text('Quick Demo Login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _quickLogin(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _handleLogin();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    try {
      if (_isAdminLogin) {
        // Navigate to admin portal
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        // User login
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.login(email, password);
        
        if (success) {
          Navigator.pushReplacementNamed(context, '/user/dashboard');
        } else {
          _showErrorDialog('Invalid user credentials');
        }
      }
    } catch (e) {
      _showErrorDialog('Login failed. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
