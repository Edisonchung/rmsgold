// Fix lib/admin/admin_main.dart - Clean file structure
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

// Fix lib/admin/screens/kyc_approval_screen.dart - Complete the missing parts
// lib/admin/screens/kyc_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KYCApprovalScreen extends StatefulWidget {
  const KYCApprovalScreen({super.key});

  @override
  State<KYCApprovalScreen> createState() => _KYCApprovalScreenState();
}

class _KYCApprovalScreenState extends State<KYCApprovalScreen> {
  String _selectedStatus = 'Pending';
  String _selectedPriority = 'All';
  String _searchQuery = '';

  final List<String> _statusOptions = ['All', 'Pending', 'In Review', 'Approved', 'Rejected', 'Incomplete'];
  final List<String> _priorityOptions = ['All', 'High', 'Medium', 'Low'];

  // Demo KYC applications
  final List<Map<String, dynamic>> _kycApplications = [
    {
      'id': 'KYC-2025071801',
      'userId': 'USR-001',
      'userName': 'John Doe',
      'userEmail': 'john.doe@email.com',
      'phone': '+60123456789',
      'submissionDate': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Pending',
      'priority': 'High',
      'assignedTo': null,
      'completionPercentage': 100,
    },
    {
      'id': 'KYC-2025071802',
      'userId': 'USR-002',
      'userName': 'Jane Smith',
      'userEmail': 'jane.smith@email.com',
      'phone': '+60198765432',
      'submissionDate': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'In Review',
      'priority': 'Medium',
      'assignedTo': 'KYC Officer - Sarah',
      'completionPercentage': 95,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'KYC Approval System',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showBulkApprovalDialog,
                icon: const Icon(Icons.approval),
                label: const Text('Bulk Approval'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _exportKYCReport,
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KYC applications list
          Expanded(
            child: ListView.builder(
              itemCount: _kycApplications.length,
              itemBuilder: (context, index) {
                final application = _kycApplications[index];
                return _buildKYCApplicationRow(application);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCApplicationRow(Map<String, dynamic> application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(application['userName']),
        subtitle: Text('ID: ${application['id']}'),
        trailing: Text(application['status']),
        onTap: () => _showKYCReviewDialog(application),
      ),
    );
  }

  void _showKYCReviewDialog(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('KYC Review: ${application['userName']}'),
        content: const Text('KYC review functionality - Coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBulkApprovalDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk approval feature - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportKYCReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export KYC report - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _approveKYC(Map<String, dynamic> application) {
    setState(() {
      application['status'] = 'Approved';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('KYC ${application['id']} approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectKYC(Map<String, dynamic> application) {
    setState(() {
      application['status'] = 'Rejected';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('KYC ${application['id']} rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _requestMoreDocuments(Map<String, dynamic> application) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document request sent'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _assignToOfficer(Map<String, dynamic> application) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Officer assignment feature - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
