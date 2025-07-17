// Update lib/main.dart to include admin portal routing

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/gold_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
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
      ],
      child: MaterialApp(
        title: 'RMS Gold Account-i',
        theme: AppTheme.goldTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const AppRouter(),
          '/admin': (context) => const AdminApp(),
        },
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the current route is for admin
    final currentUrl = Uri.base.toString();
    if (currentUrl.contains('/admin')) {
      return const AdminApp();
    }

    // Regular user app routing
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

// Update lib/screens/login_screen.dart to include admin access
// Add this to the existing LoginScreen build method, after the demo credentials card:

Widget _buildAdminAccessCard() {
  return Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      border: Border.all(color: Colors.red.shade200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.admin_panel_settings, 
                 color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'Administrator Access',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Bank administrators can access the admin portal at:',
          style: TextStyle(color: Colors.red.shade700),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            // Navigate to admin portal
            Navigator.pushNamed(context, '/admin');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${Uri.base.origin}/admin',
              style: TextStyle(
                color: Colors.red.shade800,
                fontFamily: 'monospace',
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// User Management Screen for Admin Portal
// lib/admin/screens/user_management_screen.dart

import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  
  final List<String> _filterOptions = [
    'All', 'Active', 'Pending KYC', 'Suspended', 'Rejected'
  ];

  // Demo user data
  final List<Map<String, dynamic>> _users = [
    {
      'id': '001',
      'name': 'John Doe',
      'email': 'john.doe@email.com',
      'phone': '+60123456789',
      'kycStatus': 'Approved',
      'accountStatus': 'Active',
      'goldHoldings': '5.25g',
      'totalValue': 'RM 2,498.13',
      'joinDate': '2025-01-15',
      'lastLogin': '2 hours ago',
    },
    {
      'id': '002',
      'name': 'Jane Smith',
      'email': 'jane.smith@email.com',
      'phone': '+60198765432',
      'kycStatus': 'Pending',
      'accountStatus': 'Pending',
      'goldHoldings': '0g',
      'totalValue': 'RM 0.00',
      'joinDate': '2025-07-18',
      'lastLogin': 'Never',
    },
    {
      'id': '003',
      'name': 'Ahmad Rahman',
      'email': 'ahmad.rahman@email.com',
      'phone': '+60177788999',
      'kycStatus': 'Approved',
      'accountStatus': 'Active',
      'goldHoldings': '12.50g',
      'totalValue': 'RM 5,943.75',
      'joinDate': '2024-12-20',
      'lastLogin': '1 day ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            children: [
              const Text(
                'User Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  _showExportDialog();
                },
                icon: const Icon(Icons.download),
                label: const Text('Export Users'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _showBulkActionsDialog();
                },
                icon: const Icon(Icons.batch_prediction),
                label: const Text('Bulk Actions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Search and filters
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search users by name, email, or phone...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedFilter,
                items: _filterOptions.map((filter) {
                  return DropdownMenuItem(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Users table
          Expanded(
            child: Card(
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${filteredUsers.length} users found',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            // Refresh data
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                  
                  // Table content
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return _buildUserRow(user);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // User info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user['phone'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // KYC Status
          Expanded(
            child: _buildStatusChip(
              user['kycStatus'],
              user['kycStatus'] == 'Approved' ? Colors.green : 
              user['kycStatus'] == 'Pending' ? Colors.orange : Colors.red,
            ),
          ),
          
          // Account Status
          Expanded(
            child: _buildStatusChip(
              user['accountStatus'],
              user['accountStatus'] == 'Active' ? Colors.blue : Colors.grey,
            ),
          ),
          
          // Gold Holdings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['goldHoldings'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user['totalValue'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Join Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['joinDate']),
                Text(
                  'Last: ${user['lastLogin']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'kyc',
                child: Row(
                  children: [
                    Icon(Icons.verified_user),
                    SizedBox(width: 8),
                    Text('Review KYC'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'suspend',
                child: Row(
                  children: [
                    Icon(Icons.block),
                    SizedBox(width: 8),
                    Text('Suspend Account'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'message',
                child: Row(
                  children: [
                    Icon(Icons.message),
                    SizedBox(width: 8),
                    Text('Send Message'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              _handleUserAction(value.toString(), user);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    List<Map<String, dynamic>> filtered = _users;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user['phone'].contains(_searchQuery);
      }).toList();
    }
    
    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((user) {
        switch (_selectedFilter) {
          case 'Active':
            return user['accountStatus'] == 'Active';
          case 'Pending KYC':
            return user['kycStatus'] == 'Pending';
          case 'Suspended':
            return user['accountStatus'] == 'Suspended';
          case 'Rejected':
            return user['kycStatus'] == 'Rejected';
          default:
            return true;
        }
      }).toList();
    }
    
    return filtered;
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'kyc':
        _showKYCReview(user);
        break;
      case 'suspend':
        _showSuspendDialog(user);
        break;
      case 'message':
        _showMessageDialog(user);
        break;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user['name']}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('User ID', user['id']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Phone', user['phone']),
              _buildDetailRow('KYC Status', user['kycStatus']),
              _buildDetailRow('Account Status', user['accountStatus']),
              _buildDetailRow('Gold Holdings', user['goldHoldings']),
              _buildDetailRow('Total Value', user['totalValue']),
              _buildDetailRow('Join Date', user['joinDate']),
              _buildDetailRow('Last Login', user['lastLogin']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showKYCReview(Map<String, dynamic> user) {
    // Placeholder for KYC review dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening KYC review for ${user['name']}'),
      ),
    );
  }

  void _showSuspendDialog(Map<String, dynamic> user) {
    // Placeholder for suspend account dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suspend account option for ${user['name']}'),
      ),
    );
  }

  void _showMessageDialog(Map<String, dynamic> user) {
    // Placeholder for send message dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Send message to ${user['name']}'),
      ),
    );
  }

  void _showExportDialog() {
    // Placeholder for export dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon'),
      ),
    );
  }

  void _showBulkActionsDialog() {
    // Placeholder for bulk actions dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk actions functionality coming soon'),
      ),
    );
  }
}
