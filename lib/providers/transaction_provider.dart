// lib/providers/transaction_provider.dart
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

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
        userId: 'demo-user-001',
        type: TransactionType.buy,
        amount: 1000.00,
        goldQuantity: 2.10,
        goldPrice: 475.00,
        status: TransactionStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: PaymentMethod.fpx,
        bankName: 'Maybank',
        fee: 15.00,
        notes: 'First gold purchase',
        referenceNumber: 'REF-001',
        certificateUrl: 'https://certificates.rmsgold.com/cert-001.pdf',
      ),
      Transaction(
        id: 'TXN-2025071601',
        userId: 'demo-user-001',
        type: TransactionType.buy,
        amount: 500.00,
        goldQuantity: 1.05,
        goldPrice: 476.20,
        status: TransactionStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        paymentMethod: PaymentMethod.fpx,
        bankName: 'CIMB',
        fee: 7.50,
        notes: 'Additional investment',
        referenceNumber: 'REF-002',
        certificateUrl: 'https://certificates.rmsgold.com/cert-002.pdf',
      ),
      Transaction(
        id: 'TXN-2025071401',
        userId: 'demo-user-001',
        type: TransactionType.sell,
        amount: 475.00,
        goldQuantity: 1.00,
        goldPrice: 475.00,
        status: TransactionStatus.completed,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        paymentMethod: PaymentMethod.bankTransfer,
        fee: 7.12,
        notes: 'Partial liquidation',
        referenceNumber: 'REF-003',
      ),
    ];
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
