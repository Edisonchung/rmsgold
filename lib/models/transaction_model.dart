// ===== lib/models/transaction_model.dart =====
enum TransactionType { buy, sell, convert, transfer, withdrawal }
enum TransactionStatus { completed, pending, failed, cancelled }
enum PaymentMethod { fpx, bankTransfer, card, wallet }

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final double goldQuantity;
  final double goldPrice;
  final TransactionStatus status;
  final DateTime timestamp;
  final PaymentMethod paymentMethod;
  final String? bankName;
  final double fee;
  final String? notes;
  final String? referenceNumber;
  final String? certificateUrl;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.goldQuantity,
    required this.goldPrice,
    required this.status,
    required this.timestamp,
    required this.paymentMethod,
    this.bankName,
    required this.fee,
    this.notes,
    this.referenceNumber,
    this.certificateUrl,
  });

  String get typeDisplayName {
    switch (type) {
      case TransactionType.buy:
        return 'Purchase';
      case TransactionType.sell:
        return 'Sale';
      case TransactionType.convert:
        return 'Physical Conversion';
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      amount: json['amount'].toDouble(),
      goldQuantity: json['goldQuantity'].toDouble(),
      goldPrice: json['goldPrice'].toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
      ),
      bankName: json['bankName'],
      fee: json['fee'].toDouble(),
      notes: json['notes'],
      referenceNumber: json['referenceNumber'],
      certificateUrl: json['certificateUrl'],
    );
  }
}
