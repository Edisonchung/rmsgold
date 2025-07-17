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
      'documents': {
        'ic_front': 'https://example.com/ic_front.jpg',
        'ic_back': 'https://example.com/ic_back.jpg',
        'selfie': 'https://example.com/selfie.jpg',
        'utility_bill': 'https://example.com/bill.pdf',
      },
      'personalInfo': {
        'fullName': 'John Doe',
        'icNumber': '901234-05-6789',
        'dateOfBirth': '1990-12-34',
        'nationality': 'Malaysian',
        'address': '123 Jalan ABC, Kuala Lumpur',
        'occupation': 'Software Engineer',
        'monthlyIncome': 'RM 8,000 - RM 12,000',
      },
      'verificationNotes': [],
      'riskScore': 2,
      'lastReviewDate': null,
      'reviewerComments': null,
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
      'documents': {
        'ic_front': 'https://example.com/ic_front2.jpg',
        'ic_back': 'https://example.com/ic_back2.jpg',
        'selfie': 'https://example.com/selfie2.jpg',
        'utility_bill': null, // Missing document
      },
      'personalInfo': {
        'fullName': 'Jane Smith',
        'icNumber': '851234-08-9876',
        'dateOfBirth': '1985-12-34',
        'nationality': 'Malaysian',
        'address': '456 Jalan DEF, Johor Bahru',
        'occupation': 'Teacher',
        'monthlyIncome': 'RM 4,000 - RM 6,000',
      },
      'verificationNotes': ['IC verification completed', 'Waiting for utility bill'],
      'riskScore': 3,
      'lastReviewDate': DateTime.now().subtract(const Duration(hours: 6)),
      'reviewerComments': 'Documents mostly complete, waiting for address proof.',
    },
    {
      'id': 'KYC-2025071803',
      'userId': 'USR-003',
      'userName': 'Ahmad Rahman',
      'userEmail': 'ahmad.rahman@email.com',
      'phone': '+60177788999',
      'submissionDate': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Approved',
      'priority': 'Low',
      'assignedTo': 'KYC Officer - John',
      'completionPercentage': 100,
      'documents': {
        'ic_front': 'https://example.com/ic_front3.jpg',
        'ic_back': 'https://example.com/ic_back3.jpg',
        'selfie': 'https://example.com/selfie3.jpg',
        'utility_bill': 'https://example.com/bill3.pdf',
      },
      'personalInfo': {
        'fullName': 'Ahmad Rahman bin Abdullah',
        'icNumber': '801234-07-5555',
        'dateOfBirth': '1980-12-34',
        'nationality': 'Malaysian',
        'address': '789 Jalan GHI, Penang',
        'occupation': 'Business Owner',
        'monthlyIncome': 'RM 15,000+',
      },
      'verificationNotes': ['All documents verified', 'Identity confirmed', 'Address verified'],
      'riskScore': 1,
      'lastReviewDate': DateTime.now().subtract(const Duration(days: 2)),
      'reviewerComments': 'All documents complete and verified. Low risk profile.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredApplications = _getFilteredApplications();
    final pendingCount = _kycApplications.where((app) => app['status'] == 'Pending').length;
    final inReviewCount = _kycApplications.where((app) => app['status'] == 'In Review').length;
    final todayApprovals = _kycApplications.where((app) => 
      app['status'] == 'Approved' && 
      app['lastReviewDate'] != null &&
      DateTime.now().difference(app['lastReviewDate']).inDays == 0
    ).length;

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

          // KYC metrics
          Row(
            children: [
              Expanded(
                child: _buildKYCMetricCard(
                  'Pending Review',
                  pendingCount.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                  'Requires immediate attention',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKYCMetricCard(
                  'In Review',
                  inReviewCount.toString(),
                  Icons.rate_review,
                  Colors.blue,
                  'Currently being processed',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKYCMetricCard(
                  'Approved Today',
                  todayApprovals.toString(),
                  Icons.check_circle,
                  Colors.green,
                  'Completed approvals',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKYCMetricCard(
                  'Average Processing',
                  '2.5 days',
                  Icons.timer,
                  Colors.purple,
                  'Time to completion',
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
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedPriority,
                    items: _priorityOptions.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // KYC applications table
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

  Widget _buildKYCMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
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

  Widget _buildKYCApplicationRow(Map<String, dynamic> application) {
    final isHighPriority = application['priority'] == 'High';
    final completionPercentage = application['completionPercentage'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
          left: isHighPriority 
            ? const BorderSide(color: Colors.red, width: 4)
            : BorderSide.none,
        ),
        color: isHighPriority ? Colors.red.shade50 : null,
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
                Text(
                  application['phone'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Status and priority
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusChip(application['status']),
                const SizedBox(height: 4),
                _buildPriorityChip(application['priority']),
              ],
            ),
          ),

          // Completion progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${completionPercentage}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completionPercentage == 100 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Assigned to
          Expanded(
            child: Text(
              application['assignedTo'] ?? 'Unassigned',
              style: TextStyle(
                color: application['assignedTo'] != null 
                  ? Colors.grey.shade700
                  : Colors.red.shade600,
                fontSize: 12,
              ),
            ),
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
                const PopupMenuItem(
                  value: 'request_documents',
                  child: Row(
                    children: [
                      Icon(Icons.file_upload),
                      SizedBox(width: 8),
                      Text('Request More Documents'),
                    ],
                  ),
                ),
              ],
              const PopupMenuItem(
                value: 'assign',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Assign to Officer'),
                  ],
                ),
              ),
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
      case 'incomplete':
        color = Colors.grey;
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

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
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
               app['personalInfo']['icNumber'].contains(_searchQuery) ||
               app['id'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filtered = filtered.where((app) => app['status'] == _selectedStatus).toList();
    }

    // Apply priority filter
    if (_selectedPriority != 'All') {
      filtered = filtered.where((app) => app['priority'] == _selectedPriority).toList();
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
      case 'request_documents':
        _requestMoreDocuments(application);
        break;
      case 'assign':
        _assignToOfficer(application);
        break;
    }
  }

  void _showKYCReviewDialog(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'KYC Review: ${application['userName']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal information
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow('Full Name', application['personalInfo']['fullName']),
                              _buildDetailRow('IC Number', application['personalInfo']['icNumber']),
                              _buildDetailRow('Date of Birth', application['personalInfo']['dateOfBirth']),
                              _buildDetailRow('Nationality', application['personalInfo']['nationality']),
                              _buildDetailRow('Address', application['personalInfo']['address']),
                              _buildDetailRow('Occupation', application['personalInfo']['occupation']),
                              _buildDetailRow('Monthly Income', application['personalInfo']['monthlyIncome']),
                              const SizedBox(height: 16),
                              const Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow('Email', application['userEmail']),
                              _buildDetailRow('Phone', application['phone']),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Documents
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Submitted Documents',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDocumentItem('IC Front', application['documents']['ic_front']),
                              _buildDocumentItem('IC Back', application['documents']['ic_back']),
                              _buildDocumentItem('Selfie Photo', application['documents']['selfie']),
                              _buildDocumentItem('Utility Bill', application['documents']['utility_bill']),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Review notes and actions
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Review Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (application['verificationNotes'].isNotEmpty)
                                ...application['verificationNotes'].map<Widget>((note) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check, color: Colors.green, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(note, style: const TextStyle(fontSize: 12))),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              const SizedBox(height: 16),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Add Review Note',
                                  border
