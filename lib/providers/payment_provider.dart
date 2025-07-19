// lib/providers/payment_provider.dart
import 'package:flutter/foundation.dart';
import '../services/billplz_payment_service.dart';
import '../models/transaction_model.dart';
import '../models/payment_models.dart';

class PaymentProvider extends ChangeNotifier {
  final BillplzPaymentService _billplzService;
  
  bool _isLoading = false;
  String? _errorMessage;
  BillplzBillResponse? _currentBill;
  PaymentStatus _paymentStatus = PaymentStatus.idle;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BillplzBillResponse? get currentBill => _currentBill;
  PaymentStatus get paymentStatus => _paymentStatus;

  PaymentProvider({bool isProduction = false}) 
      : _billplzService = BillplzPaymentService(isProduction: isProduction);

  /// Initialize FPX payment for gold purchase
  Future<String?> initiateFPXPayment({
    required String userEmail,
    required String userName,
    required String userPhone,
    required double purchaseAmount,
    required double goldQuantity,
    required double goldPrice,
    String? preferredBank,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      _paymentStatus = PaymentStatus.initiating;
      notifyListeners();

      // Create description
      final description = 'RMS Gold Purchase - ${goldQuantity.toStringAsFixed(4)}g @ RM${goldPrice.toStringAsFixed(2)}/g';
      
      // Create bill with Billplz
      final billResponse = await _billplzService.createFPXBill(
        userEmail: userEmail,
        userName: userName,
        amount: purchaseAmount,
        description: description,
        goldQuantity: '${goldQuantity.toStringAsFixed(4)}g',
        userPhone: userPhone,
        preferredBank: preferredBank,
      );

      _currentBill = billResponse;
      _paymentStatus = PaymentStatus.pending;
      notifyListeners();

      // Return the payment URL for redirect
      return billResponse.url;

    } catch (e) {
      _setError('Failed to initiate payment: $e');
      _paymentStatus = PaymentStatus.failed;
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Check payment status (call this periodically or after redirect)
  Future<PaymentResult> checkPaymentStatus(String billId) async {
    try {
      _setLoading(true);
      _clearError();

      final status = await _billplzService.checkPaymentStatus(billId);
      
      if (status.paid) {
        _paymentStatus = PaymentStatus.completed;
        final result = PaymentResult(
          success: true,
          billId: status.id,
          transactionId: status.transactionId,
          fpxTransactionId: status.fpxTransactionId,
          amount: status.amount,
          paidAt: status.paidAt,
        );
        notifyListeners();
        return result;
      } else {
        switch (status.state) {
          case 'pending':
            _paymentStatus = PaymentStatus.pending;
            break;
          case 'failed':
            _paymentStatus = PaymentStatus.failed;
            break;
          default:
            _paymentStatus = PaymentStatus.pending;
        }
        notifyListeners();
        return PaymentResult(success: false, billId: status.id);
      }
      
    } catch (e) {
      _setError('Failed to check payment status: $e');
      _paymentStatus = PaymentStatus.failed;
      notifyListeners();
      return PaymentResult(success: false, error: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Process webhook callback from Billplz
  PaymentResult processWebhookCallback(Map<String, dynamic> webhookData, String signature) {
    try {
      // Validate signature for security
      final body = webhookData.toString();
      if (!_billplzService.validateWebhookSignature(body, signature)) {
        throw Exception('Invalid webhook signature');
      }

      final webhookPayment = _billplzService.processWebhook(webhookData);
      
      if (webhookPayment.paid) {
        _paymentStatus = PaymentStatus.completed;
        notifyListeners();
        
        return PaymentResult(
          success: true,
          billId: webhookPayment.id,
          amount: webhookPayment.amount,
          paidAt: webhookPayment.paidAt,
        );
      } else {
        _paymentStatus = PaymentStatus.failed;
        notifyListeners();
        return PaymentResult(success: false, billId: webhookPayment.id);
      }
      
    } catch (e) {
      _setError('Webhook processing failed: $e');
      return PaymentResult(success: false, error: e.toString());
    }
  }

  /// Get available FPX banks
  List<FPXBank> getFPXBanks() {
    return _billplzService.getFPXBanks();
  }

  /// Reset payment state
  void resetPayment() {
    _currentBill = null;
    _paymentStatus = PaymentStatus.idle;
    _clearError();
    notifyListeners();
  }

  /// Handle large payments (above RM 30,000 FPX limit)
  List<PaymentSplit> calculatePaymentSplits(double totalAmount, {double fpxLimit = 30000}) {
    if (totalAmount <= fpxLimit) {
      return [PaymentSplit(amount: totalAmount, method: 'FPX', sequence: 1)];
    }

    List<PaymentSplit> splits = [];
    double remainingAmount = totalAmount;
    int sequence = 1;

    while (remainingAmount > 0) {
      double splitAmount = remainingAmount > fpxLimit ? fpxLimit : remainingAmount;
      splits.add(PaymentSplit(
        amount: splitAmount,
        method: remainingAmount > fpxLimit ? 'FPX' : 'FPX_FINAL',
        sequence: sequence,
      ));
      remainingAmount -= splitAmount;
      sequence++;
    }

    return splits;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

// Supporting Models
enum PaymentStatus {
  idle,
  initiating,
  pending,
  completed,
  failed,
}

class PaymentResult {
  final bool success;
  final String? billId;
  final String? transactionId;
  final String? fpxTransactionId;
  final double? amount;
  final DateTime? paidAt;
  final String? error;

  PaymentResult({
    required this.success,
    this.billId,
    this.transactionId,
    this.fpxTransactionId,
    this.amount,
    this.paidAt,
    this.error,
  });
}

class PaymentSplit {
  final double amount;
  final String method;
  final int sequence;

  PaymentSplit({
    required this.amount,
    required this.method,
    required this.sequence,
  });
}
