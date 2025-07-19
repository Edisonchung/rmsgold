// lib/admin/screens/user_management.dart - Fixed Version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/admin_models.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  UserStatus? _selectedStatusFilter;
  KYCStatus? _selectedKYCFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Color(0xFF1B4332),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _refreshUsers(),
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportUsersList,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _refreshUsers();
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => _refreshUsers(),
          ),
          SizedBox(height: 12),
          
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<UserStatus>(
                  value: _selectedStatusFilter,
                  decoration: InputDecoration(
                    labelText: 'Status Filter',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
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
                    _refreshUsers();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<KYCStatus>(
                  value: _selectedKYCFilter,
                  decoration: InputDecoration(
                    labelText: 'KYC Filter',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('All KYC')),
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
                    _refreshUsers();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Consumer<AdminProvider>(
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
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    adminProvider.clearError();
                    _refreshUsers();
                  },
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
                Text(
                  'No users found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
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
    );
  }

  String _getStatusDisplayName(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.blocked:
        return 'Blocked';
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
      case KYCStatus.underReview:
        return 'Under Review';
      case KYCStatus.incomplete:
        return 'Incomplete';
    }
  }

  void _refreshUsers() {
    context.read<AdminProvider>().loadUsers(
      searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      statusFilter: _selectedStatusFilter,
      kycStatusFilter: _selectedKYCFilter,
    );
  }

  void _viewUserDetails(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }

  void _suspendUser(UserProfile user) {
    final _reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to suspend ${user.name}?'),
            SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for suspension',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                context.read<AdminProvider>().suspendUser(user.id, _reasonController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User suspended successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Suspend'),
          ),
        ],
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
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(),
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        user.phoneNumber ?? 'No phone',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusDisplayName(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getKYCStatusColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getKYCStatusDisplayName(),
                        style: TextStyle(
                          color: _getKYCStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // User stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Gold Holdings', '${user.goldHoldings.toStringAsFixed(3)}g'),
                ),
                Expanded(
                  child: _buildStatItem('Total Value', 'RM ${(user.goldHoldings * 475).toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildStatItem('Transactions', '${user.totalTransactions}'),
                ),
                Expanded(
                  child: _buildStatItem('Last Active', _getLastActiveText()),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: Icon(Icons.info_outline, size: 16),
                    label: Text('Details'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewTransactions,
                    icon: Icon(Icons.history, size: 16),
                    label: Text('Transactions'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: user.status == UserStatus.active
                      ? ElevatedButton.icon(
                          onPressed: onSuspend,
                          icon: Icon(Icons.block, size: 16),
                          label: Text('Suspend'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        )
                      : ElevatedButton.icon(
                          onPressed: onActivate,
                          icon: Icon(Icons.check_circle, size: 16),
                          label: Text('Activate'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (user.status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.inactive:
        return Colors.grey;
      case UserStatus.blocked:
        return Colors.red;
      case UserStatus.suspended:
        return Colors.orange;
      case UserStatus.banned:
        return Colors.red;
      case UserStatus.pending:
        return Colors.blue;
    }
  }

  Color _getKYCStatusColor() {
    switch (user.kycStatus) {
      case KYCStatus.approved:
        return Colors.green;
      case KYCStatus.pending:
        return Colors.orange;
      case KYCStatus.rejected:
        return Colors.red;
      case KYCStatus.underReview:
        return Colors.blue;
      case KYCStatus.incomplete:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName() {
    switch (user.status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.blocked:
        return 'Blocked';
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
      case KYCStatus.pending:
        return 'Pending';
      case KYCStatus.rejected:
        return 'Rejected';
      case KYCStatus.underReview:
        return 'Under Review';
      case KYCStatus.incomplete:
        return 'Incomplete';
    }
  }

  String _getLastActiveText() {
    final now = DateTime.now();
    final difference = now.difference(user.lastActive);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class UserDetailsDialog extends StatelessWidget {
  final UserProfile user;

  const UserDetailsDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            _buildDetailRow('Name', user.name),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Phone', user.phoneNumber ?? 'Not provided'),
            _buildDetailRow('Status', user.status.toString().split('.').last),
            _buildDetailRow('KYC Status', user.kycStatus.toString().split('.').last),
            _buildDetailRow('Gold Holdings', '${user.goldHoldings.toStringAsFixed(4)}g'),
            _buildDetailRow('Total Transactions', '${user.totalTransactions}'),
            _buildDetailRow('Join Date', user.joinDate.toString().split(' ')[0]),
            _buildDetailRow('Last Active', user.lastActive.toString()),
            
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
