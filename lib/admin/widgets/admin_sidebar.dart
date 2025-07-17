// lib/admin/widgets/admin_sidebar.dart
import 'package:flutter/material.dart';
import '../providers/admin_auth_provider.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final AdminUser adminUser;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.adminUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo and branding
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'RMS Gold Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Admin user info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amber.shade700,
                  child: Text(
                    adminUser.name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminUser.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getRoleDisplayName(adminUser.role),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  0,
                  Icons.dashboard,
                  'Dashboard',
                  true,
                ),
                _buildNavItem(
                  1,
                  Icons.people,
                  'User Management',
                  _hasPermission('user_management'),
                ),
                _buildNavItem(
                  2,
                  Icons.account_balance_wallet,
                  'Transactions',
                  _hasPermission('transaction_oversight'),
                ),
                _buildNavItem(
                  3,
                  Icons.verified_user,
                  'KYC Approvals',
                  _hasPermission('kyc_approval'),
                ),
                _buildNavItem(
                  4,
                  Icons.bar_chart,
                  'Reports',
                  _hasPermission('reports'),
                ),
                if (adminUser.role == AdminRole.superAdmin) ...[
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'SYSTEM',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    5,
                    Icons.settings,
                    'Settings',
                    _hasPermission('system_config'),
                  ),
                ],
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 8),
                Text(
                  'System Online',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title, bool hasAccess) {
    if (!hasAccess) {
      return const SizedBox.shrink();
    }

    final isSelected = selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Colors.amber.shade50,
        leading: Icon(
          icon,
          color: isSelected ? Colors.amber.shade700 : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.amber.shade700 : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () => onItemSelected(index),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  bool _hasPermission(String permission) {
    return adminUser.permissions.contains(permission) || 
           adminUser.role == AdminRole.superAdmin;
  }

  String _getRoleDisplayName(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return 'Super Administrator';
      case AdminRole.kycOfficer:
        return 'KYC Officer';
      case AdminRole.support:
        return 'Support Staff';
    }
  }
}
