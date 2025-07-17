// ===== lib/main.dart =====
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/gold_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/purchase_screen.dart';
import 'screens/sell_screen.dart';
import 'screens/conversion_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'utils/theme.dart';
import 'admin/admin_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GoldProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'RMS Gold Account-i',
        theme: AppTheme.goldTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const AppRouter(),
          '/admin': (context) => const AdminApp(),
          '/register': (context) => const RegistrationScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/purchase': (context) => const PurchaseScreen(),
          '/sell': (context) => const SellScreen(),
          '/conversion': (context) => const ConversionScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/transactions': (context) => const TransactionHistoryScreen(),
        },
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUrl = Uri.base.toString();
    if (currentUrl.contains('/admin')) {
      return const AdminApp();
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
