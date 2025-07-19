// lib/admin/screens/admin_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../providers/admin_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  @override
  _AdminSettingsScreenState createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Settings'),
        backgroundColor: Color(0xFF1B4332),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'System'),
            Tab(text: 'Security'),
            Tab(text: 'Users'),
            Tab(text: 'Backup'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSystemTab(),
          _buildSecurityTab(),
          _buildUsersTab(),
          _buildBackupTab(),
        ],
      ),
    );
  }

  Widget _buildRoleItem(String role, String description, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBackupStatusCard(),
          SizedBox(height: 16),
          _buildBackupScheduleCard(),
          SizedBox(height: 16),
          _buildDataExportCard(),
        ],
      ),
    );
  }

  Widget _buildBackupStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildBackupItem('Last Backup', '2025-07-20 02:00 AM', Colors.green, Icons.check_circle),
            _buildBackupItem('Backup Size', '2.3 GB', Colors.blue, Icons.storage),
            _buildBackupItem('Next Scheduled', '2025-07-21 02:00 AM', Colors.orange, Icons.schedule),
            _buildBackupItem('Retention Period', '30 days', Colors.purple, Icons.history),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runBackupNow,
                    icon: Icon(Icons.backup),
                    label: Text('Backup Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1B4332),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _restoreBackup,
                    icon: Icon(Icons.restore),
                    label: Text('Restore'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupItem(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupScheduleCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Automatic Backups'),
              subtitle: Text('Enable scheduled backups'),
              value: true,
              onChanged: (value) {
                // TODO: Implement auto backup toggle
              },
            ),
            ListTile(
              title: Text('Frequency'),
              subtitle: Text('Daily at 2:00 AM'),
              trailing: Icon(Icons.edit),
              onTap: _editBackupSchedule,
            ),
            ListTile(
              title: Text('Retention Policy'),
              subtitle: Text('Keep backups for 30 days'),
              trailing: Icon(Icons.edit),
              onTap: _editRetentionPolicy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataExportCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Export',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Export specific data for analysis or migration',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildExportButton('User Data', Icons.people),
                _buildExportButton('Transactions', Icons.swap_horiz),
                _buildExportButton('KYC Records', Icons.verified_user),
                _buildExportButton('Audit Logs', Icons.security),
                _buildExportButton('System Config', Icons.settings),
                _buildExportButton('Price History', Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _exportData(label),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
      ),
    );
  }

  // Event handlers
  void _checkSystemHealth() {
    context.read<AdminProvider>().checkSystemHealth();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('System health check completed')),
    );
  }

  void _editSystemConfig() {
    // TODO: Implement system configuration editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('System configuration editor coming soon')),
    );
  }

  void _enableMaintenanceMode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Maintenance Mode'),
        content: Text('This will temporarily disable the app for all users. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Maintenance mode enabled')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _scheduleDowntime() {
    // TODO: Implement downtime scheduling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downtime scheduling coming soon')),
    );
  }

  void _changePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AdminAuthProvider>().changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password changed successfully')),
    );
  }

  void _manageIPWhitelist() {
    // TODO: Implement IP whitelist management
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('IP whitelist management coming soon')),
    );
  }

  void _viewFullAuditLog() {
    // TODO: Navigate to full audit log screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Full audit log view coming soon')),
    );
  }

  void _addAdminUser() {
    // TODO: Implement add admin user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add admin user functionality coming soon')),
    );
  }

  void _handleAdminAction(String action, Map<String, String> admin) {
    switch (action) {
      case 'edit':
        // TODO: Implement edit admin
        break;
      case 'permissions':
        // TODO: Implement permissions management
        break;
      case 'deactivate':
        _deactivateAdmin(admin);
        break;
    }
  }

  void _deactivateAdmin(Map<String, String> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deactivate Admin'),
        content: Text('Are you sure you want to deactivate ${admin['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${admin['name']} deactivated')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _manageRoles() {
    // TODO: Implement role management
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Role management coming soon')),
    );
  }

  void _runBackupNow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Run Backup Now'),
        content: Text('This will create a full system backup. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Backup started successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1B4332)),
            child: Text('Start Backup'),
          ),
        ],
      ),
    );
  }

  void _restoreBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restore from Backup'),
        content: Text('WARNING: This will overwrite current data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Restore functionality coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _editBackupSchedule() {
    // TODO: Implement backup schedule editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup schedule editing coming soon')),
    );
  }

  void _editRetentionPolicy() {
    // TODO: Implement retention policy editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Retention policy editing coming soon')),
    );
  }

  void _exportData(String dataType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting $dataType...')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSystemHealthCard(),
          SizedBox(height: 16),
          _buildSystemConfigCard(),
          SizedBox(height: 16),
          _buildMaintenanceCard(),
        ],
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildHealthItem('Database', 'Healthy', Colors.green, Icons.storage),
            _buildHealthItem('API Services', 'Healthy', Colors.green, Icons.cloud),
            _buildHealthItem('Payment Gateway', 'Healthy', Colors.green, Icons.payment),
            _buildHealthItem('Gold Price Feed', 'Warning', Colors.orange, Icons.trending_up),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _checkSystemHealth,
              icon: Icon(Icons.refresh),
              label: Text('Refresh Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1B4332),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(String service, String status, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(child: Text(service)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemConfigCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildConfigItem('Minimum Purchase', 'RM 10.00'),
            _buildConfigItem('Maximum Purchase', 'RM 50,000.00'),
            _buildConfigItem('Transaction Fee', '0.5%'),
            _buildConfigItem('KYC Required', 'Yes'),
            _buildConfigItem('Price Update Interval', '5 minutes'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _editSystemConfig,
              child: Text('Edit Configuration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Enable maintenance mode to perform system updates',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _enableMaintenanceMode,
                    icon: Icon(Icons.build),
                    label: Text('Enable Maintenance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _scheduleDowntime,
                    icon: Icon(Icons.schedule),
                    label: Text('Schedule Downtime'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPasswordChangeCard(),
          SizedBox(height: 16),
          _buildSecuritySettingsCard(),
          SizedBox(height: 16),
          _buildAuditLogCard(),
        ],
      ),
    );
  }

  Widget _buildPasswordChangeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1B4332),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettingsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Require MFA for Admin Login'),
              subtitle: Text('Multi-factor authentication'),
              value: true,
              onChanged: (value) {
                // TODO: Implement MFA toggle
              },
            ),
            SwitchListTile(
              title: Text('Session Timeout'),
              subtitle: Text('Auto-logout after 30 minutes'),
              value: true,
              onChanged: (value) {
                // TODO: Implement session timeout toggle
              },
            ),
            SwitchListTile(
              title: Text('IP Whitelist'),
              subtitle: Text('Restrict admin access by IP'),
              value: false,
              onChanged: (value) {
                // TODO: Implement IP whitelist toggle
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _manageIPWhitelist,
              child: Text('Manage IP Whitelist'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Admin Activities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _viewFullAuditLog,
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                final activities = [
                  'User management access - admin@rmsgold.com',
                  'Price override applied - admin@rmsgold.com',
                  'KYC approval - kyc@rmsgold.com',
                ];
                final times = ['2 minutes ago', '15 minutes ago', '1 hour ago'];
                
                return ListTile(
                  leading: Icon(Icons.security, color: Color(0xFF1B4332)),
                  title: Text(activities[index]),
                  subtitle: Text(times[index]),
                  dense: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAdminUsersCard(),
          SizedBox(height: 16),
          _buildRolesPermissionsCard(),
        ],
      ),
    );
  }

  Widget _buildAdminUsersCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin Users',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addAdminUser,
                  icon: Icon(Icons.add),
                  label: Text('Add Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B4332),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                final admins = [
                  {'name': 'John Admin', 'email': 'admin@rmsgold.com', 'role': 'Super Admin', 'status': 'Active'},
                  {'name': 'Jane KYC', 'email': 'kyc@rmsgold.com', 'role': 'KYC Officer', 'status': 'Active'},
                  {'name': 'Bob Support', 'email': 'support@rmsgold.com', 'role': 'Support', 'status': 'Inactive'},
                ];
                final admin = admins[index];
                
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: admin['status'] == 'Active' ? Colors.green : Colors.grey,
                      child: Text(admin['name']![0]),
                    ),
                    title: Text(admin['name']!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(admin['email']!),
                        Text('Role: ${admin['role']}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) => _handleAdminAction(value, admin),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'permissions', child: Text('Permissions')),
                        PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesPermissionsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Roles & Permissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildRoleItem('Super Admin', 'Full system access', Colors.red),
            _buildRoleItem('KYC Officer', 'User verification & approval', Colors.blue),
            _buildRoleItem('Inventory Manager', 'Gold inventory & pricing', Colors.orange),
            _buildRoleItem('Support', 'Customer support & basic reports', Colors.green),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _manageRoles,
              child: Text('Manage Roles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
