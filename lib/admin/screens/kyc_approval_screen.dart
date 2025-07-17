// lib/admin/screens/kyc_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KYCApprovalScreen extends StatefulWidget {
  const KYCApprovalScreen({super.key});

  @override
  State<KYCApprovalScreen> createState() => _KYCApprovalScreenState();
}

class _KYCApprovalScreenState extends State<KYCApprovalScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';

  final List<String> _statusOptions = ['All', 'Pending', 'In Review', 'Approved', 'Rejected'];

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
    final filteredApplications = _getFilteredApplications();
    
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

          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name, email, IC number...',
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
                    value: _selectedStatus,
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // KYC applications list
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
                          '${filteredApplications.length} KYC applications',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              // Refresh data
                            });
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
                      itemCount: filteredApplications.length,
                      itemBuilder: (context, index) {
                        final application = filteredApplications[index];
                        return _buildKYCApplicationRow(application);
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

  Widget _buildKYCApplicationRow(Map<String, dynamic> application) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Application info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application['id'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(application['submissionDate']),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // User information
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application['userName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  application['userEmail'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Status
          Expanded(
            child: _buildStatusChip(application['status']),
          ),

          // Actions
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'review',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('Review Application'),
                  ],
                ),
              ),
              if (application['status'] == 'Pending' || application['status'] == 'In Review') ...[
                const PopupMenuItem(
                  value: 'approve',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Approve'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reject'),
                    ],
                  ),
                ),
              ],
            ],
            onSelected: (value) {
              _handleKYCAction(value.toString(), application);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'in review':
        color = Colors.blue;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

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

  List<Map<String, dynamic>> _getFilteredApplications() {
    List<Map<String, dynamic>> filtered = List.from(_kycApplications);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((app) {
        return app['userName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               app['userEmail'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               app['id'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filtered = filtered.where((app) => app['status'] == _selectedStatus).toList();
    }

    return filtered;
  }

  void _handleKYCAction(String action, Map<String, dynamic> application) {
    switch (action) {
      case 'review':
        _showKYCReviewDialog(application);
        break;
      case 'approve':
        _approveKYC(application);
        break;
      case 'reject':
        _rejectKYC(application);
        break;
    }
  }

  void _showKYCReviewDialog(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('KYC Review: ${application['userName']}'),
        content: const Text('KYC review functionality - Details would be shown here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveKYC(application);
            },
            child: const Text('Approve'),
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
}
