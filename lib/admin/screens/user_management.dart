// lib/admin/screens/user_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  UserStatus? _selectedStatusFilter;
  KYCStatus? _selectedKYCFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  void _loadUsers() {
    context.read<AdminProvider>().loadUsers(
      searchQuery: _searchController.text,
      statusFilter: _selectedStatusFilter,
      kycFilter: _selectedKYCFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Color(0xFF1B4332),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _exportUsersList,
          ),
        ],
      ),
      drawer: AdminSidebar(),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadUsers();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // Debounce search
                    Future.delayed(Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _loadUsers();
                      }
                    });
                  },
                ),
                SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<UserStatus>(
                        value: _selectedStatusFilter,
                        decoration: InputDecoration(
                          labelText: 'Status Filter',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...UserStatus.values.map((status) => 
                            DropdownMenuItem(
                              value: status,
                              child: Text(_getStatusDisplayName(status)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatusFilter = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<KYCStatus>(
                        value: _selectedKYCFilter,
                        decoration: InputDecoration(
                          labelText: 'KYC Filter',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All KYC Status'),
                          ),
                          ...KYCStatus.values.map((status) => 
                            DropdownMenuItem(
                              value: status,
                              child: Text(_getKYCStatusDisplayName(status)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedKYCFilter = value;
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (adminProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error: ${adminProvider.errorMessage}',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final users = adminProvider.users;
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No users found'),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserManagementCard(
                      user: user,
                      onViewDetails: () => _viewUserDetails(user),
                      onSuspend: () => _suspendUser(user),
                      onActivate: () => _activateUser(user),
                      onViewTransactions: () => _viewUserTransactions(user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.banned:
        return 'Banned';
      case UserStatus.pending:
        return 'Pending';
    }
  }

  String _getKYCStatusDisplayName(KYCStatus status) {
    switch (status) {
      case KYCStatus.pending:
        return 'Pending';
      case KYCStatus.approved:
        return 'Approved';
      case KYCStatus.rejected:
        return 'Rejected';
      case KYCStatus.incomplete:
        return 'Incomplete';
    }
  }

  void _viewUserDetails(UserProfile user) {
    Navigator.pushNamed(
      context,
      '/admin/user-details',
      arguments: user,
    );
  }

  void _suspendUser(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => SuspendUserDialog(
        user: user,
        onConfirm: (reason) {
          context.read<AdminProvider>().suspendUser(user.id, reason);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User suspended successfully')),
          );
        },
      ),
    );
  }

  void _activateUser(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Activate User'),
        content: Text('Are you sure you want to activate ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminProvider>().activateUser(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User activated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _viewUserTransactions(UserProfile user) {
    Navigator.pushNamed(
      context,
      '/admin/user-transactions',
      arguments: user,
    );
  }

  void _exportUsersList() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class UserManagementCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onViewDetails;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;
  final VoidCallback onViewTransactions;

  const UserManagementCard({
    Key? key,
    required this.user,
    required this.onViewDetails,
    required this.onSuspend,
    required this.onActivate,
    required this.onViewTransactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _getStatusColor(),
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'transactions',
                      child: Row(
                        children: [
                          Icon(Icons.account_balance),
                          SizedBox(width: 8),
                          Text('View Transactions'),
                        ],
                      ),
                    ),
                    if (user.status == UserStatus.active)
                      PopupMenuItem(
                        value: 'suspend',
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Suspend User'),
                          ],
                        ),
                      ),
                    if (user.status == UserStatus.suspended)
                      PopupMenuItem(
                        value: 'activate',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Activate User'),
                          ],
                        ),
                      ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'details':
                        onViewDetails();
                        break;
                      case 'transactions':
                        onViewTransactions();
                        break;
                      case 'suspend':
                        onSuspend();
                        break;
                      case 'activate':
                        onActivate();
                        break;
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildStatusChip('Status', _getStatusDisplayName(), _getStatusColor()),
                SizedBox(width: 8),
                _buildStatusChip('KYC', _getKYCStatusDisplayName(), _getKYCStatusColor()),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Gold Balance',
                    '${user.goldBalance.toStringAsFixed(3)}g',
                    Icons.inventory,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Portfolio Value',
                    'RM ${user.portfolioValue.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Transactions',
                    user.totalTransactions.toString(),
                    Icons.swap_horiz,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Last Login',
                    _formatLastLogin(),
                    Icons.access_time,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (user.status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.suspended:
        return Colors.red;
      case UserStatus.banned:
        return Colors.purple;
      case UserStatus.pending:
        return Colors.orange;
    }
  }

  Color _getKYCStatusColor() {
    switch (user.kycStatus) {
      case KYCStatus.approved:
        return Colors.green;
      case KYCStatus.rejected:
        return Colors.red;
      case KYCStatus.pending:
        return Colors.orange;
      case KYCStatus.incomplete:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName() {
    switch (user.status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.banned:
        return 'Banned';
      case UserStatus.pending:
        return 'Pending';
    }
  }

  String _getKYCStatusDisplayName() {
    switch (user.kycStatus) {
      case KYCStatus.approved:
        return 'Approved';
      case KYCStatus.rejected:
        return 'Rejected';
      case KYCStatus.pending:
        return 'Pending';
      case KYCStatus.incomplete:
        return 'Incomplete';
    }
  }

  String _formatLastLogin() {
    final now = DateTime.now();
    final difference = now.difference(user.lastLogin);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class SuspendUserDialog extends StatefulWidget {
  final UserProfile user;
  final Function(String) onConfirm;

  const SuspendUserDialog({
    Key? key,
    required this.user,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _SuspendUserDialogState createState() => _SuspendUserDialogState();
}

class _SuspendUserDialogState extends State<SuspendUserDialog> {
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedReason;

  final List<String> _predefinedReasons = [
    'Suspicious activity detected',
    'Failed KYC verification',
    'Terms of service violation',
    'Requested by user',
    'Security concerns',
    'Other (specify below)',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Suspend User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suspend ${widget.user.name}?'),
          SizedBox(height: 16),
          Text('Reason for suspension:'),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select a reason',
            ),
            items: _predefinedReasons.map((reason) => 
              DropdownMenuItem(
                value: reason,
                child: Text(reason),
              ),
            ).toList(),
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
          ),
          if (_selectedReason == 'Other (specify below)') ...[
            SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter custom reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canConfirm() ? () {
            final reason = _selectedReason == 'Other (specify below)'
                ? _reasonController.text
                : _selectedReason!;
            Navigator.pop(context);
            widget.onConfirm(reason);
          } : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Suspend'),
        ),
      ],
    );
  }

  bool _canConfirm() {
    if (_selectedReason == null) return false;
    if (_selectedReason == 'Other (specify below)') {
      return _reasonController.text.isNotEmpty;
    }
    return true;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
