// lib/admin/widgets/admin_widgets.dart
import 'package:flutter/material.dart';
import '../models/admin_models.dart';

class AdminSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF1B4332),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 35,
                    color: Color(0xFF1B4332),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'RMS Gold Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administrator Panel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/admin/dashboard',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.people,
                  title: 'User Management',
                  route: '/admin/users',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.verified_user,
                  title: 'KYC Approval',
                  route: '/admin/kyc',
                  badge: '15',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.inventory,
                  title: 'Gold Inventory',
                  route: '/admin/inventory',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.trending_up,
                  title: 'Price Management',
                  route: '/admin/pricing',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.account_balance,
                  title: 'Transaction Monitor',
                  route: '/admin/transactions',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.analytics,
                  title: 'Reports & Analytics',
                  route: '/admin/reports',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.announcement,
                  title: 'Announcements',
                  route: '/admin/announcements',
                ),
                Divider(),
                _buildSidebarItem(
                  context,
                  icon: Icons.settings,
                  title: 'System Settings',
                  route: '/admin/settings',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.security,
                  title: 'Security Logs',
                  route: '/admin/security',
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  route: '/admin/help',
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout'),
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    String? badge,
  }) {
    final isSelected = ModalRoute.of(context)?.settings.name == route;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Color(0xFF1B4332).withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Color(0xFF1B4332) : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Color(0xFF1B4332) : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 32),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                ],
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class KYCReviewCard extends StatelessWidget {
  final KYCUser user;
  final VoidCallback onApprove;
  final Function(String) onReject;

  const KYCReviewCard({
    Key? key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(user.name[0].toUpperCase()),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(
              'Submitted: ${_formatDate(user.submittedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documents Submitted:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _buildDocumentList(),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRejectDialog(context),
                        icon: Icon(Icons.close),
                        label: Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: Icon(Icons.check),
                        label: Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList() {
    final documents = <String>[];
    if (user.documents.icFront != null) documents.add('IC Front');
    if (user.documents.icBack != null) documents.add('IC Back');
    if (user.documents.passport != null) documents.add('Passport');
    if (user.documents.proofOfAddress != null) documents.add('Proof of Address');
    if (user.documents.bankStatement != null) documents.add('Bank Statement');

    return Column(
      children: documents.map((doc) => 
        ListTile(
          dense: true,
          leading: Icon(Icons.description, color: Colors.blue),
          title: Text(doc),
          trailing: IconButton(
            icon: Icon(Icons.visibility),
            onPressed: () {
              // TODO: Open document viewer
            },
          ),
        )
      ).toList(),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject KYC'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejection:'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
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
              if (reasonController.text.isNotEmpty) {
                Navigator.pop(context);
                onReject(reasonController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TransactionMonitorCard extends StatelessWidget {
  final TransactionData transaction;
  final VoidCallback? onFlag;
  final VoidCallback? onViewDetails;

  const TransactionMonitorCard({
    Key? key,
    required this.transaction,
    this.onFlag,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: transaction.isFlagged 
              ? Border.all(color: Colors.red, width: 2)
              : null,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getTransactionColor(),
            child: Icon(
              _getTransactionIcon(),
              color: Colors.white,
            ),
          ),
          title: Text(
            '${transaction.userName} - ${transaction.type.toUpperCase()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${transaction.goldAmount}g @ RM${transaction.pricePerGram}/g'),
              Text('Total: RM${transaction.totalAmount.toStringAsFixed(2)}'),
              Text(
                _formatDateTime(transaction.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (transaction.isFlagged)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'FLAGGED: ${transaction.flagReason}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          trailing: PopupMenuButton(
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
              if (!transaction.isFlagged)
                PopupMenuItem(
                  value: 'flag',
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Flag as Suspicious'),
                    ],
                  ),
                ),
            ],
            onSelected: (value) {
              if (value == 'details' && onViewDetails != null) {
                onViewDetails!();
              } else if (value == 'flag' && onFlag != null) {
                onFlag!();
              }
            },
          ),
        ),
      ),
    );
  }

  Color _getTransactionColor() {
    if (transaction.isFlagged) return Colors.red;
    return transaction.type == 'buy' ? Colors.green : Colors.orange;
  }

  IconData _getTransactionIcon() {
    if (transaction.isFlagged) return Icons.warning;
    return transaction.type == 'buy' ? Icons.shopping_cart : Icons.sell;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class InventoryStatusCard extends StatelessWidget {
  final GoldInventory inventory;
  final VoidCallback? onUpdateInventory;

  const InventoryStatusCard({
    Key? key,
    required this.inventory,
    this.onUpdateInventory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  'Gold Inventory Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onUpdateInventory != null)
                  ElevatedButton.icon(
                    onPressed: onUpdateInventory,
                    icon: Icon(Icons.add),
                    label: Text('Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1B4332),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInventoryStat(
                    'Total Gold',
                    '${inventory.totalGold.toStringAsFixed(1)}g',
                    Icons.inventory,
                    Colors.amber,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInventoryStat(
                    'Available',
                    '${inventory.availableGold.toStringAsFixed(1)}g',
                    Icons.check_circle,
                    inventory.isLowStock ? Colors.red : Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInventoryStat(
                    'Reserved',
                    '${inventory.reservedGold.toStringAsFixed(1)}g',
                    Icons.lock,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (inventory.isLowStock) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Low stock alert! Available gold below ${inventory.lowStockThreshold}g threshold.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),
            Text(
              'Recent Transactions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: inventory.recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = inventory.recentTransactions[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: _getTransactionTypeColor(transaction.type),
                      child: Icon(
                        _getTransactionTypeIcon(transaction.type),
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      '${transaction.type.toUpperCase()}: ${transaction.amount}g',
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      transaction.description,
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      _formatDate(transaction.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionTypeColor(String type) {
    switch (type) {
      case 'purchase':
        return Colors.green;
      case 'sale':
        return Colors.red;
      case 'adjustment':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionTypeIcon(String type) {
    switch (type) {
      case 'purchase':
        return Icons.add;
      case 'sale':
        return Icons.remove;
      case 'adjustment':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
