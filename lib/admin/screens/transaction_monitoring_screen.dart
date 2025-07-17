// lib/admin/screens/transaction_monitoring_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionMonitoringScreen extends StatefulWidget {
  const TransactionMonitoringScreen({super.key});

  @override
  State<TransactionMonitoringScreen> createState() => _TransactionMonitoringScreenState();
}

class _TransactionMonitoringScreenState extends State<TransactionMonitoringScreen> {
  String _selectedPeriod = 'Today';
  String _selectedStatus = 'All';
  String _selectedType = 'All';
  bool _showOnlyFlagged = false;
  
  final List<String> _periodOptions = ['Today', 'This Week', 'This Month', 'Custom Range'];
  final List<String> _statusOptions = ['All', 'Completed', 'Pending', 'Failed', 'Flagged'];
  final List<String> _typeOptions = ['All', 'Buy', 'Sell', 'Transfer', 'Withdrawal'];

  // Demo transaction data with more comprehensive information
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN-2025071801',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'userId': 'USR-001',
      'userName': 'John Doe',
      'userEmail': 'john.doe@email.com',
      'type': 'Buy',
      'amount': 25000.00,
      'goldQuantity': 52.63,
      'goldPrice': 475.50,
      'status': 'Completed',
      'paymentMethod': 'FPX - Maybank',
      'fee': 187.50,
      'spread': 3.6,
      'riskScore': 2,
      'flagged': false,
      'flagReason': null,
      'location': 'Kuala Lumpur, MY',
      'deviceInfo': 'Chrome/Web',
    },
    {
      'id': 'TXN-2025071802',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'userId': 'USR-002',
      'userName': 'Jane Smith',
      'userEmail': 'jane.smith@email.com',
      'type': 'Sell',
      'amount': 15000.00,
      'goldQuantity': 31.58,
      'goldPrice': 475.00,
      'status': 'Pending',
      'paymentMethod': 'Bank Transfer',
      'fee': 112.50,
      'spread': 3.6,
      'riskScore': 1,
      'flagged': false,
      'flagReason': null,
      'location': 'Johor Bahru, MY',
      'deviceInfo': 'Mobile App/Android',
    },
    {
      'id': 'TXN-2025071803',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'userId': 'USR-003',
      'userName': 'Ahmad Rahman',
      'userEmail': 'ahmad.rahman@email.com',
      'type': 'Buy',
      'amount': 75000.00,
      'goldQuantity': 157.89,
      'goldPrice': 475.20,
      'status': 'Flagged',
      'paymentMethod': 'FPX - CIMB',
      'fee': 562.50,
      'spread': 3.6,
      'riskScore': 8,
      'flagged': true,
      'flagReason': 'Large transaction amount exceeds daily limit',
      'location': 'Penang, MY',
      'deviceInfo': 'Safari/Web',
    },
    {
      'id': 'TXN-2025071804',
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'userId': 'USR-004',
      'userName': 'Sarah Lee',
      'userEmail': 'sarah.lee@email.com',
      'type': 'Buy',
      'amount': 5000.00,
      'goldQuantity': 10.53,
      'goldPrice': 475.00,
      'status': 'Failed',
      'paymentMethod': 'FPX - Public Bank',
      'fee': 37.50,
      'spread': 3.6,
      'riskScore': 3,
      'flagged': false,
      'flagReason': 'Insufficient funds',
      'location': 'Shah Alam, MY',
      'deviceInfo': 'Mobile App/iOS',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();
    final totalVolume = _calculateTotalVolume(filteredTransactions);
    final totalFees = _calculateTotalFees(filteredTransactions);
    final flaggedCount = filteredTransactions.where((t) => t['flagged']).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with real-time status
          Row(
            children: [
              const Text(
                'Transaction Monitoring',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live Monitoring',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _exportTransactions,
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAlertSettings,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Alert Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Key metrics cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Volume',
                  'RM ${NumberFormat('#,##0.00').format(totalVolume)}',
                  Icons.trending_up,
                  Colors.blue,
                  '${filteredTransactions.length} transactions',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Total Fees',
                  'RM ${NumberFormat('#,##0.00').format(totalFees)}',
                  Icons.account_balance_wallet,
                  Colors.green,
                  'Average: RM ${(totalFees / filteredTransactions.length).toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Flagged Transactions',
                  flaggedCount.toString(),
                  Icons.flag,
                  flaggedCount > 0 ? Colors.red : Colors.orange,
                  '${((flaggedCount / filteredTransactions.length) * 100).toStringAsFixed(1)}% of total',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Average Risk Score',
                  _calculateAverageRiskScore(filteredTransactions).toStringAsFixed(1),
                  Icons.security,
                  _getRiskColor(_calculateAverageRiskScore(filteredTransactions)),
                  'Range: 1-10 (Low-High)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters and controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _showOnlyFlagged,
                        onChanged: (value) {
                          setState(() {
                            _showOnlyFlagged = value;
                          });
                        },
                      ),
                      const Text('Show only flagged'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPeriod,
                          decoration: const InputDecoration(
                            labelText: 'Time Period',
                            border: OutlineInputBorder(),
                          ),
                          items: _periodOptions.map((period) {
                            return DropdownMenuItem(
                              value: period,
                              child: Text(period),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Transaction Type',
                            border: OutlineInputBorder(),
                          ),
                          items: _typeOptions.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Transactions table
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
                          '${filteredTransactions.length} transactions',
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
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return _buildTransactionRow(transaction);
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

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
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

  Widget _buildTransactionRow(Map<String, dynamic> transaction) {
    final isHighRisk = transaction['riskScore'] >= 7;
    final isFlagged = transaction['flagged'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
          left: isFlagged 
            ? const BorderSide(color: Colors.red, width: 4)
            : isHighRisk 
              ? const BorderSide(color: Colors.orange, width: 4)
              : BorderSide.none,
        ),
        color: isFlagged ? Colors.red.shade50 : null,
      ),
      child: Row(
        children: [
          // Transaction ID and timestamp
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['id'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(transaction['timestamp']),
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
                  transaction['userName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction['userEmail'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Transaction details
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: transaction['type'] == 'Buy' 
                          ? Colors.green.shade100 
                          : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction['type'],
                        style: TextStyle(
                          color: transaction['type'] == 'Buy' 
                            ? Colors.green.shade700 
                            : Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${transaction['goldQuantity'].toStringAsFixed(2)}g',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${NumberFormat('#,##0.00').format(transaction['amount'])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Payment method
          Expanded(
            child: Text(
              transaction['paymentMethod'],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),

          // Status
          Expanded(
            child: _buildStatusChip(transaction['status']),
          ),

          // Risk score
          Expanded(
            child: _buildRiskScoreChip(transaction['riskScore']),
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
              if (transaction['status'] == 'Pending') ...[
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
              if (!transaction['flagged'])
                const PopupMenuItem(
                  value: 'flag',
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Flag Transaction'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'reverse',
                child: Row(
                  children: [
                    Icon(Icons.undo),
                    SizedBox(width: 8),
                    Text('Reverse Transaction'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              _handleTransactionAction(value.toString(), transaction);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'failed':
        color = Colors.red;
        break;
      case 'flagged':
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

  Widget _buildRiskScoreChip(int score) {
    Color color = _getRiskColor(score.toDouble());
    String level = score <= 3 ? 'Low' : score <= 6 ? 'Med' : 'High';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$score ($level)',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getRiskColor(double score) {
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    List<Map<String, dynamic>> filtered = List.from(_transactions);

    // Apply flagged filter
    if (_showOnlyFlagged) {
      filtered = filtered.where((t) => t['flagged']).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filtered = filtered.where((t) => t['status'] == _selectedStatus).toList();
    }

    // Apply type filter
    if (_selectedType != 'All') {
      filtered = filtered.where((t) => t['type'] == _selectedType).toList();
    }

    return filtered;
  }

  double _calculateTotalVolume(List<Map<String, dynamic>> transactions) {
    return transactions.fold(0.0, (sum, t) => sum + t['amount']);
  }

  double _calculateTotalFees(List<Map<String, dynamic>> transactions) {
    return transactions.fold(0.0, (sum, t) => sum + t['fee']);
  }

  double _calculateAverageRiskScore(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) return 0.0;
    return transactions.fold(0.0, (sum, t) => sum + t['riskScore']) / transactions.length;
  }

  void _handleTransactionAction(String action, Map<String, dynamic> transaction) {
    switch (action) {
      case 'view':
        _showTransactionDetails(transaction);
        break;
      case 'approve':
        _approveTransaction(transaction);
        break;
      case 'reject':
        _rejectTransaction(transaction);
        break;
      case 'flag':
        _flagTransaction(transaction);
        break;
      case 'reverse':
        _reverseTransaction(transaction);
        break;
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details: ${transaction['id']}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection('Transaction Information', [
                  _buildDetailRow('Transaction ID', transaction['id']),
                  _buildDetailRow('Timestamp', DateFormat('dd/MM/yyyy HH:mm:ss').format(transaction['timestamp'])),
                  _buildDetailRow('Type', transaction['type']),
                  _buildDetailRow('Status', transaction['status']),
                  _buildDetailRow('Risk Score', '${transaction['riskScore']}/10'),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('User Information', [
                  _buildDetailRow('User ID', transaction['userId']),
                  _buildDetailRow('Name', transaction['userName']),
                  _buildDetailRow('Email', transaction['userEmail']),
                  _buildDetailRow('Location', transaction['location']),
                  _buildDetailRow('Device', transaction['deviceInfo']),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Financial Details', [
                  _buildDetailRow('Amount', 'RM ${NumberFormat('#,##0.00').format(transaction['amount'])}'),
                  _buildDetailRow('Gold Quantity', '${transaction['goldQuantity']} grams'),
                  _buildDetailRow('Gold Price', 'RM ${transaction['goldPrice']}/g'),
                  _buildDetailRow('Spread', '${transaction['spread']}%'),
                  _buildDetailRow('Fee', 'RM ${NumberFormat('#,##0.00').format(transaction['fee'])}'),
                  _buildDetailRow('Payment Method', transaction['paymentMethod']),
                ]),
                if (transaction['flagged']) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection('Flag Information', [
                    _buildDetailRow('Flag Reason', transaction['flagReason']),
                  ]),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (transaction['status'] == 'Pending')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _approveTransaction(transaction);
              },
              child: const Text('Approve'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  void _approveTransaction(Map<String, dynamic> transaction) {
    setState(() {
      transaction['status'] = 'Completed';
      transaction['flagged'] = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction ${transaction['id']} approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectTransaction(Map<String, dynamic> transaction) {
    setState(() {
      transaction['status'] = 'Failed';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction ${transaction['id']} rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _flagTransaction(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flag Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for flagging this transaction:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter flag reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Store flag reason
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                transaction['flagged'] = true;
                transaction['status'] = 'Flagged';
                transaction['flagReason'] = 'Manual flag by admin';
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction ${transaction['id']} flagged'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Flag Transaction'),
          ),
        ],
      ),
    );
  }

  void _reverseTransaction(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reverse Transaction'),
        content: const Text(
          'Are you sure you want to reverse this transaction? This action cannot be undone and will:\n\n'
          '• Reverse the gold holdings\n'
          '• Initiate refund process\n'
          '• Create audit trail entry\n'
          '• Send notification to customer',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction ${transaction['id']} reversal initiated'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Reversal'),
          ),
        ],
      ),
    );
  }

  void _exportTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality - generating CSV report...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAlertSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Settings'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Configure transaction monitoring alerts:'),
              SizedBox(height: 16),
              // Alert configuration options would go here
              Text('• Large transaction alerts (>RM 50,000)'),
              Text('• High risk score alerts (>7)'),
              Text('• Suspicious pattern detection'),
              Text('• Multiple failed attempts'),
              Text('• Cross-border transactions'),
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
}
