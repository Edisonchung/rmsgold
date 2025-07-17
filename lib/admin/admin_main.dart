// lib/admin/admin_main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
