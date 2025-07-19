// lib/main.dart
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
import 'screens/portfolio_screen.dart'; // ADDED THIS MISSING IMPORT

// Import admin components (corrected paths)
import 'admin/admin_main.dart';
import 'admin/screens/admin_dashboard.dart';
import 'admin/screens/admin_login_screen.dart';

// Global variable to track Firebase initialization status
bool _firebaseInitialized = false;
String? _firebaseError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to initialize Firebase, but don't let it block the app
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseInitialized = true;
    print('✅ Firebase initialized successfully');
  } catch (e) {
    _firebaseInitialized = false;
    _firebaseError = e.toString();
    print('⚠️ Firebase initialization failed: $e');
    print('📱 Running in demo mode - Firebase features disabled');
  }
  
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
          '/user/portfolio': (context) => PortfolioScreen(), // NOW THIS WILL WORK
          
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

// Enhanced Auth Gateway with Admin Detection and Firebase Status
class AuthGateway extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check current route to determine if it's an admin route
    final route = ModalRoute.of(context)?.settings.name ?? '';
    final currentPath = Uri.base.path;
    
    // If it's an admin route, show AdminApp
    if (route.startsWith('/admin') || currentPath.startsWith('/admin')) {
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

// Enhanced Login Screen with Admin Access and Firebase Status
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
              // Firebase Status Banner
              if (!_firebaseInitialized) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo Mode: Firebase unavailable',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
              
              // App Logo/Title
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'RMS Gold Account-i',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Digital Gold Trading Platform',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Admin/User Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Customer Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isAdminLogin ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w600,
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
                            color: _isAdminLogin ? Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Admin Portal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isAdminLogin ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Login Form
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: _isAdminLogin ? 'admin@rmsgold.com' : 'demo@rmsgold.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              
              SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: _isAdminLogin ? 'admin123456' : 'demo123456',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD4AF37),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isAdminLogin ? 'Login to Admin Portal' : 'Login to Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Demo Credentials
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 Demo Credentials',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isAdminLogin
                          ? 'Admin: admin@rmsgold.com / admin123456'
                          : 'Customer: demo@rmsgold.com / demo123456',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (_isAdminLogin) {
      // Navigate to admin portal
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      // Handle customer login
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(email, password);
      
      if (success) {
        Navigator.pushReplacementNamed(context, '/user/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }
}
