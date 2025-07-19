// lib/admin/admin_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/user_management.dart';
import 'screens/kyc_approval_screen.dart';
import 'screens/gold_inventory_screen.dart';
import 'screens/price_management_screen.dart';
import 'screens/transaction_monitoring_screen.dart';
import 'screens/reports_analytics_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'providers/admin_auth_provider.dart';
import 'providers/admin_provider.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'RMS Gold Admin Portal',
        theme: AppTheme.goldTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AdminAuthProvider>(
          builder: (context, adminAuth, _) {
            if (adminAuth.isAuthenticated) {
              return AdminDashboard();
            }
            return const AdminLoginScreen();
          },
        ),
        routes: {
          // Authentication routes
          '/admin/login': (context) => const AdminLoginScreen(),
          '/admin/logout': (context) => const AdminLoginScreen(),
          
          // Main admin routes
          '/admin/dashboard': (context) => AdminDashboard(),
          '/admin/users': (context) => UserManagementScreen(),
          '/admin/kyc': (context) => KYCApprovalScreen(),
          '/admin/inventory': (context) => GoldInventoryScreen(),
          '/admin/pricing': (context) => PriceManagementScreen(),
          '/admin/transactions': (context) => TransactionMonitoringScreen(),
          '/admin/reports': (context) => ReportsAnalyticsScreen(),
          '/admin/announcements': (context) => AnnouncementsScreen(),
          '/admin/settings': (context) => AdminSettingsScreen(),
          
          // Legacy routes (for backward compatibility)
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin-dashboard': (context) => AdminDashboard(),
        },
        onGenerateRoute: (settings) {
          // Handle parameterized routes
          if (settings.name?.startsWith('/admin/user-details') == true) {
            final user = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => UserDetailsScreen(user: user),
              settings: settings,
            );
          }
          
          if (settings.name?.startsWith('/admin/kyc-details') == true) {
            final kycUser = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => KYCDetailsScreen(kycUser: kycUser),
              settings: settings,
            );
          }
          
          if (settings.name?.startsWith('/admin/transaction-details') == true) {
            final transaction = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => TransactionDetailsScreen(transaction: transaction),
              settings: settings,
            );
          }
          
          if (settings.name?.startsWith('/admin/user-transactions') == true) {
            final user = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => UserTransactionsScreen(user: user),
              settings: settings,
            );
          }
          
          // Default fallback to dashboard for unknown admin routes
          if (settings.name?.startsWith('/admin') == true) {
            return MaterialPageRoute(
              builder: (context) => AdminDashboard(),
              settings: settings,
            );
          }
          
          return null;
        },
        
        // Global error handling for admin routes
        builder: (context, child) {
          return Consumer<AdminAuthProvider>(
            builder: (context, adminAuth, _) {
              // Show loading screen during authentication check
              if (adminAuth.isLoading) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF1B4332),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Admin Portal...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // Show error screen if authentication failed
              if (adminAuth.hasError) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Authentication Error',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          adminAuth.errorMessage ?? 'Unknown error occurred',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => adminAuth.clearError(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1B4332),
                          ),
                          child: Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return child ?? Container();
            },
          );
        },
      ),
    );
  }
}

// Additional screen placeholders that need to be created
class KYCApprovalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KYC Approval'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 64, color: Color(0xFF1B4332)),
            SizedBox(height: 16),
            Text(
              'KYC Approval Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This screen will show pending KYC submissions'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class GoldInventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gold Inventory'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 64, color: Color(0xFF1B4332)),
            SizedBox(height: 16),
            Text(
              'Gold Inventory Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This screen will show gold inventory status'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Price Management'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Color(0xFF1B4332)),
            SizedBox(height: 16),
            Text(
              'Price Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This screen will show gold price controls'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionMonitoringScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Monitoring'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance, size: 64, color: Color(0xFF1B4332)),
            SizedBox(height: 16),
            Text(
              'Transaction Monitoring',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This screen will show real-time transaction monitoring'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportsAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports & Analytics'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Color(0xFF1B4332)),
            SizedBox(height: 16),
            Text(
              'Reports & Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This screen will show detailed reports and analytics'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.announcement, size: 64, color: Color(0xFF1B4332)),
            SizedBox(height: 16),
            Text(
              'Announcements',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This screen will manage customer announcements'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Settings'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Color(0xFF1B4332)),
            SizedBox(height: 16),
            Text(
              'Admin Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This screen will show system settings'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/dashboard'),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

// Detail screens that handle arguments
class UserDetailsScreen extends StatelessWidget {
  final dynamic user;
  
  const UserDetailsScreen({Key? key, required this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Text('User Details for: ${user?.toString() ?? "Unknown"}'),
      ),
    );
  }
}

class KYCDetailsScreen extends StatelessWidget {
  final dynamic kycUser;
  
  const KYCDetailsScreen({Key? key, required this.kycUser}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KYC Details'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Text('KYC Details for: ${kycUser?.toString() ?? "Unknown"}'),
      ),
    );
  }
}

class TransactionDetailsScreen extends StatelessWidget {
  final dynamic transaction;
  
  const TransactionDetailsScreen({Key? key, required this.transaction}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Text('Transaction Details for: ${transaction?.toString() ?? "Unknown"}'),
      ),
    );
  }
}

class UserTransactionsScreen extends StatelessWidget {
  final dynamic user;
  
  const UserTransactionsScreen({Key? key, required this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Transactions'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Center(
        child: Text('Transactions for: ${user?.toString() ?? "Unknown"}'),
      ),
    );
  }
}
