// lib/admin/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/admin_provider.dart';
import '../models/admin_models.dart';
import '../widgets/admin_widgets.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RMS Gold Admin Dashboard'),
        backgroundColor: Color(0xFF1B4332),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => _showAdminProfile(context),
          ),
        ],
      ),
      drawer: AdminSidebar(),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1B4332)),
                  SizedBox(height: 16),
                  Text('Loading dashboard data...'),
                ],
              ),
            );
          }

          final dashboardData = adminProvider.dashboardData;
          if (dashboardData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Failed to load dashboard data'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.loadDashboardData(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Cards
                _buildQuickStatsSection(dashboardData),
                SizedBox(height: 24),
                
                // Charts Row
                Row(
                  children: [
                    Expanded(child: _buildGoldPriceChart(dashboardData)),
                    SizedBox(width: 16),
                    Expanded(child: _buildTransactionVolumeChart(dashboardData)),
                  ],
                ),
                SizedBox(height: 24),
                
                // User Activity and Alerts
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRecentActivity(dashboardData)),
                    SizedBox(width: 16),
                    Expanded(child: _buildSystemAlerts(dashboardData)),
                  ],
                ),
                SizedBox(height: 24),
                
                // KYC Pending and Recent Transactions
                _buildKYCPendingSection(dashboardData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStatsSection(DashboardData data) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Total Users',
            value: data.totalUsers.toString(),
            icon: Icons.people,
            color: Colors.blue,
            subtitle: '+${data.newUsersToday} today',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: 'Pending KYC',
            value: data.pendingKYC.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
            subtitle: 'Needs review',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: 'Today\'s Volume',
            value: 'RM ${data.todayVolume.toStringAsFixed(0)}',
            icon: Icons.trending_up,
            color: Colors.green,
            subtitle: '${data.todayTransactions} transactions',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatsCard(
            title: 'Gold Inventory',
            value: '${data.goldInventory.toStringAsFixed(1)}g',
            icon: Icons.inventory,
            color: data.goldInventory < 100 ? Colors.red : Colors.amber,
            subtitle: data.goldInventory < 100 ? 'Low Stock!' : 'In Stock',
          ),
        ),
      ],
    );
  }

  Widget _buildGoldPriceChart(DashboardData data) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gold Price Trend (24h)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}h');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('RM${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.priceHistory.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Color(0xFFD4AF37),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionVolumeChart(DashboardData data) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Volume (7 days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(days[value.toInt() % 7]);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value / 1000).toInt()}K');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: data.weeklyVolume.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Color(0xFF1B4332),
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(DashboardData data) {
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
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/admin/activity'),
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: data.recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = data.recentActivities[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getActivityColor(activity.type),
                      child: Icon(
                        _getActivityIcon(activity.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(activity.description),
                    subtitle: Text(activity.user),
                    trailing: Text(
                      _formatTime(activity.timestamp),
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

  Widget _buildSystemAlerts(DashboardData data) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: data.systemAlerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 48),
                          SizedBox(height: 8),
                          Text('All systems operational'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: data.systemAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = data.systemAlerts[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getAlertColor(alert.severity).withOpacity(0.1),
                            border: Border(
                              left: BorderSide(
                                width: 4,
                                color: _getAlertColor(alert.severity),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(alert.message),
                              SizedBox(height: 4),
                              Text(
                                _formatTime(alert.timestamp),
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
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

  Widget _buildKYCPendingSection(DashboardData data) {
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
                  'Pending KYC Approvals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/admin/kyc'),
                  child: Text('Review All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B4332),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: data.pendingKYCUsers.isEmpty
                  ? Center(child: Text('No pending KYC submissions'))
                  : ListView.builder(
                      itemCount: data.pendingKYCUsers.length,
                      itemBuilder: (context, index) {
                        final user = data.pendingKYCUsers[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
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
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _approveKYC(user.id),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _rejectKYC(user.id),
                                ),
                                IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: () => _viewKYCDetails(user),
                                ),
                              ],
                            ),
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

  // Helper methods
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.userRegistration:
        return Colors.blue;
      case ActivityType.goldPurchase:
        return Colors.green;
      case ActivityType.goldSale:
        return Colors.orange;
      case ActivityType.kycSubmission:
        return Colors.purple;
      case ActivityType.systemAlert:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.userRegistration:
        return Icons.person_add;
      case ActivityType.goldPurchase:
        return Icons.shopping_cart;
      case ActivityType.goldSale:
        return Icons.sell;
      case ActivityType.kycSubmission:
        return Icons.upload_file;
      case ActivityType.systemAlert:
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Text('No new notifications'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAdminProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Admin Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Admin: admin@rmsgold.com'),
            Text('Role: Super Administrator'),
            Text('Last Login: ${_formatTime(DateTime.now())}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _approveKYC(String userId) {
    context.read<AdminProvider>().approveKYC(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('KYC approved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectKYC(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        String reason = '';
        return AlertDialog(
          title: Text('Reject KYC'),
          content: TextField(
            decoration: InputDecoration(
              labelText: 'Rejection Reason',
              hintText: 'Enter reason for rejection',
            ),
            onChanged: (value) => reason = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<AdminProvider>().rejectKYC(userId, reason.isEmpty ? 'Documents unclear' : reason);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('KYC rejected'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _viewKYCDetails(KYCUser user) {
    Navigator.pushNamed(context, '/admin/kyc-details', arguments: user);
  }
}
