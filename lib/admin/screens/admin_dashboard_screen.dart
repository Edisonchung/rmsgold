// lib/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../widgets/admin_sidebar.dart';
import 'transaction_monitoring_screen.dart';
import 'kyc_approval_screen.dart';

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
        return const TransactionMonitoringScreen();
      case 3:
        return const KYCApprovalScreen();
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
