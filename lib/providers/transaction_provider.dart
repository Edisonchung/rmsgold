// lib/providers/transaction_provider.dart
import 'package:flutter/foundation.dart';

enum TransactionType { buy, sell, transfer, withdrawal }
enum TransactionStatus { completed, pending, failed, cancelled }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final double goldQuantity;
  final double goldPrice;
  final TransactionStatus status;
  final DateTime timestamp;
  final String paymentMethod;
  final double fee;
  final String? notes;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.goldQuantity,
    required this.goldPrice,
    required this.status,
    required this.timestamp,
    required this.paymentMethod,
    required this.fee,
    this.notes,
  });

  String get typeDisplayName {
    switch (type) {
      case TransactionType.buy:
        return 'Purchase';
      case TransactionType.sell:
        return 'Sale';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.withdrawal:
        return 'Withdrawal';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TransactionProvider() {
    _initializeDemoTransactions();
  }

  void _initializeDemoTransactions() {
    _transactions = [
      Transaction(
        id: 'TXN-2025071801',
        type: TransactionType.buy,
        amount: 1000.00,
        goldQuantity: 2.10,
        goldPrice: 475.00,
        status: TransactionStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'FPX - Maybank',
        fee: 15.00,
        notes: 'First gold purchase',
      ),
      Transaction(
        id: 'TXN-2025071601',
        type: TransactionType.buy,
        amount: 500.00,
        goldQuantity: 1.05,
        goldPrice: 476.20,
        status: TransactionStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        paymentMethod: 'FPX - CIMB',
        fee: 7.50,
        notes: 'Additional investment',
      ),
      Transaction(
        id: 'TXN-2025071401',
        type: TransactionType.sell,
        amount: 475.00,
        goldQuantity: 1.00,
        goldPrice: 475.00,
        status: TransactionStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        paymentMethod: 'Bank Transfer',
        fee: 7.12,
        notes: 'Partial liquidation',
      ),
    ];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
