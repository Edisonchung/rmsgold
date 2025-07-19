// lib/admin/screens/gold_inventory_screen.dart
import 'package:flutter/material.dart';

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
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/admin/screens/price_management_screen.dart
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
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/admin/screens/reports_analytics_screen.dart
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
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/admin/screens/announcements_screen.dart
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
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/admin/screens/admin_settings_screen.dart
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
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
