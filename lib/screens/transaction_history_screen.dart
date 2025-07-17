// lib/screens/transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'All';
  DateTimeRange? _selectedDateRange;

  final List<String> _filterOptions = ['All', 'Purchase', 'Sale', 'Transfer', 'Withdrawal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportTransactions,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          final transactions = _getFilteredTransactions(transactionProvider.transactions);
          
          if (transactionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Transactions Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start trading to see your transaction history here.',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/purchase');
                    },
                    child: const Text('Buy Gold'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Summary Card
              _buildSummaryCard(transactions),
              
              // Transactions List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshTransactions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Transaction> transactions) {
    final totalBuy = transactions
        .where((t) => t.type == TransactionType.buy)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalSell = transactions
        .where((t) => t.type == TransactionType.sell)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalFees = transactions
        .fold(0.0, (sum, t) => sum + t.fee);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Purchases',
                    'RM ${NumberFormat('#,##0.00').format(totalBuy)}',
                    Icons.add_shopping_cart,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Sales',
                    'RM ${NumberFormat('#,##0.00').format(totalSell)}',
                    Icons.sell,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Transactions',
                    transactions.length.toString(),
                    Icons.receipt,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Fees',
                    'RM ${NumberFormat('#,##0.00').format(totalFees)}',
                    Icons.account_balance_wallet,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isPositive = transaction.type == TransactionType.buy;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(transaction.type).withOpacity(0.1),
          child: Icon(
            _getTypeIcon(transaction.type),
            color: _getTypeColor(transaction.type),
          ),
        ),
        title: Row(
          children: [
            Text(
              transaction.typeDisplayName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(transaction.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                transaction.statusDisplayName,
                style: TextStyle(
                  color: _getStatusColor(transaction.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(transaction.timestamp),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ID: ${transaction.id}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'RM ${NumberFormat('#,##0.00').format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _getTypeColor(transaction.type),
              ),
            ),
            Text(
              '${transaction.goldQuantity.toStringAsFixed(4)}g',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icons.add_shopping_cart;
      case TransactionType.sell:
        return Icons.sell;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.withdrawal:
        return Icons.money_off;
    }
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Colors.green;
      case TransactionType.sell:
        return Colors.blue;
      case TransactionType.transfer:
        return Colors.orange;
      case TransactionType.withdrawal:
        return Colors.red;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    List<Transaction> filtered = transactions;

    // Filter by type
    if (_selectedFilter != 'All') {
      filtered = filtered.where((t) {
        switch (_selectedFilter) {
          case 'Purchase':
            return t.type == TransactionType.buy;
          case 'Sale':
            return t.type == TransactionType.sell;
          case 'Transfer':
            return t.type == TransactionType.transfer;
          case 'Withdrawal':
            return t.type == TransactionType.withdrawal;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((t) {
        return t.timestamp.isAfter(_selectedDateRange!.start) &&
               t.timestamp.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction Type:'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: _filterOptions.map((filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Date Range:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _selectDateRange,
                    child: Text(
                      _selectedDateRange == null
                        ? 'Select Range'
                        : '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
                    ),
                  ),
                ),
                if (_selectedDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {}); // Refresh the list
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (range != null) {
      setState(() {
        _selectedDateRange = range;
      });
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Transaction ID', transaction.id),
              _buildDetailRow('Type', transaction.typeDisplayName),
              _buildDetailRow('Status', transaction.statusDisplayName),
              _buildDetailRow('Date', DateFormat('dd/MM/yyyy HH:mm:ss').format(transaction.timestamp)),
              _buildDetailRow('Amount', 'RM ${NumberFormat('#,##0.00').format(transaction.amount)}'),
              _buildDetailRow('Gold Quantity', '${transaction.goldQuantity.toStringAsFixed(4)}g'),
              _buildDetailRow('Gold Price', 'RM ${NumberFormat('#,##0.00').format(transaction.goldPrice)}/g'),
              _buildDetailRow('Transaction Fee', 'RM ${NumberFormat('#,##0.00').format(transaction.fee)}'),
              _buildDetailRow('Payment Method', transaction.paymentMethod.toString().split('.').last.toUpperCase()),
              if (transaction.notes?.isNotEmpty == true)
                _buildDetailRow('Notes', transaction.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (transaction.status == TransactionStatus.completed)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _downloadReceipt(transaction);
              },
              child: const Text('Download Receipt'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  void _downloadReceipt(Transaction transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt download started...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _refreshTransactions() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transactions refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _exportTransactions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Transactions'),
        content: const Text(
          'Would you like to export your transaction history as a PDF or CSV file?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performExport('CSV');
            },
            child: const Text('CSV'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performExport('PDF');
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _performExport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting transactions as $format...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
