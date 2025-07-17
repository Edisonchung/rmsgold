// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'admin/admin_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RMS Gold Account-i',
      theme: AppTheme.goldTheme,
      home: const AppRouter(),
      routes: {
        '/': (context) => const AppRouter(),
        '/dashboard': (context) => const DashboardScreen(),
        '/admin': (context) => const AdminApp(),
      },
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Check URL for admin route
    final uri = Uri.base;
    final path = uri.path;
    final fragment = uri.fragment;
    
    // Check if accessing admin
    if (path.contains('admin') || fragment.contains('admin') || 
        uri.toString().contains('admin')) {
      return const AdminApp();
    }
    
    // Default to user login
    return const LoginScreen();
  }
}
