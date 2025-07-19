// lib/services/billplz_payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/payment_models.dart';

class BillplzPaymentService {
  // Production vs Sandbox URLs
  static const String _sandboxUrl = 'https://www.billplz-sandbox.com/api/v3';
  static const String _productionUrl = 'https://www.billplz.com/api/v3';
  
  // Configuration - Move to environment variables in production
  static const String _apiKey = 'your_billplz_api_key'; // Get from Billplz dashboard
  static const String _xSignatureKey = 'your_x_signature_key'; // For webhook validation
  static const String _collectionId = 'your_collection_id'; // Pre-created collection for gold purchases
  
  final bool _isProduction;
  late final String _baseUrl;
  
  BillplzPaymentService({bool isProduction = false}) : _isProduction = isProduction {
    _baseUrl = _isProduction ? _productionUrl : _sandboxUrl;
  }

  /// Create a new FPX payment bill
  Future<BillplzBillResponse> createFPXBill({
    required String userEmail,
    required String userName,
    required double amount,
    required String description,
    required String goldQuantity,
    required String userPhone,
    String? preferredBank, // Optional: Pre-select bank
  }) async {
    try {
      final String billId = _generateBillId();
      final Map<String, dynamic> billData = {
        'collection_id': _collectionId,
        'email': userEmail,
        'mobile': userPhone,
        'name': userName,
        'amount': (amount * 100).toInt(), // Convert to cents
        'description': description,
        'callback_url': '${_getCallbackUrl()}/payment/callback',
        'redirect_url': '${_getCallbackUrl()}/payment/redirect',
        'reference_1_label': 'Gold Purchase',
        'reference_1': goldQuantity,
        'reference_2_label': 'User ID',
        'reference_2': userEmail, // Using email as user identifier
      };

      // Add bank preselection if specified
      if (preferredBank != null) {
        billData['fpx'] = _getBankCode(preferredBank);
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/bills'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: billData.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return BillplzBillResponse.fromJson(responseData);
      } else {
        throw BillplzException('Failed to create bill: ${response.body}');
      }
    } catch (e) {
      throw BillplzException('Error creating FPX bill: $e');
    }
  }

  /// Check payment status
  Future<BillplzBillStatus> checkPaymentStatus(String billId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bills/$billId'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return BillplzBillStatus.fromJson(responseData);
      } else {
        throw BillplzException('Failed to check status: ${response.body}');
      }
    } catch (e) {
      throw BillplzException('Error checking payment status: $e');
    }
  }

  /// Get FPX bank list
  List<FPXBank> getFPXBanks() {
    return [
      FPXBank(code: 'MB2U0227', name: 'Maybank2U', displayName: 'Maybank'),
      FPXBank(code: 'CIB2U01', name: 'CIMB Clicks', displayName: 'CIMB Bank'),
      FPXBank(code: 'PBB0233', name: 'Public Bank', displayName: 'Public Bank'),
      FPXBank(code: 'RHB0218', name: 'RHB Bank', displayName: 'RHB Bank'),
      FPXBank(code: 'HLB0224', name: 'Hong Leong Bank', displayName: 'Hong Leong Bank'),
      FPXBank(code: 'AMBB0209', name: 'AmBank', displayName: 'AmBank'),
      FPXBank(code: 'UOB0226', name: 'UOB Bank', displayName: 'UOB Bank'),
      FPXBank(code: 'BOCM01', name: 'Bank of China', displayName: 'Bank of China'),
      FPXBank(code: 'BSN0601', name: 'BSN', displayName: 'Bank Simpanan Nasional'),
      FPXBank(code: 'KFH0346', name: 'KFH', displayName: 'Kuwait Finance House'),
      FPXBank(code: 'ISLAM01', name: 'Bank Islam', displayName: 'Bank Islam'),
      FPXBank(code: 'MUIB0227', name: 'Muamalat', displayName: 'Bank Muamalat'),
      FPXBank(code: 'RAIZ01', name: 'Rakyat', displayName: 'Bank Rakyat'),
      FPXBank(code: 'BIMB0340', name: 'Bank Islam', displayName: 'Bank Islam Malaysia'),
    ];
  }

  /// Validate webhook signature
  bool validateWebhookSignature(String body, String signature) {
    final computedSignature = _computeSignature(body);
    return computedSignature == signature;
  }

  /// Process webhook callback
  PaymentWebhookData processWebhook(Map<String, dynamic> webhookData) {
    return PaymentWebhookData.fromJson(webhookData);
  }

  // Private helper methods
  String _generateBillId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'RMS-GOLD-$timestamp';
  }

  String _getCallbackUrl() {
    // Replace with your actual domain
    return _isProduction 
        ? 'https://rmsgold.vercel.app' 
        : 'https://rmsgold-dev.vercel.app';
  }

  String _getBankCode(String bankName) {
    final bankMap = {
      'Maybank': 'MB2U0227',
      'CIMB': 'CIB2U01',
      'Public Bank': 'PBB0233',
      'RHB Bank': 'RHB0218',
      'Hong Leong Bank': 'HLB0224',
      'AmBank': 'AMBB0209',
      'UOB Bank': 'UOB0226',
      'Bank of China': 'BOCM01',
      'BSN': 'BSN0601',
      'Kuwait Finance House': 'KFH0346',
      'Bank Islam': 'ISLAM01',
      'Bank Muamalat': 'MUIB0227',
      'Bank Rakyat': 'RAIZ01',
    };
    return bankMap[bankName] ?? 'MB2U0227';
  }

  String _computeSignature(String body) {
    final key = utf8.encode(_xSignatureKey);
    final bytes = utf8.encode(body);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }
}

// Payment Models
class BillplzBillResponse {
  final String id;
  final String url;
  final String state;
  final double amount;
  final String description;
  final String email;
  final String mobile;
  final String name;

  BillplzBillResponse({
    required this.id,
    required this.url,
    required this.state,
    required this.amount,
    required this.description,
    required this.email,
    required this.mobile,
    required this.name,
  });

  factory BillplzBillResponse.fromJson(Map<String, dynamic> json) {
    return BillplzBillResponse(
      id: json['id'],
      url: json['url'],
      state: json['state'],
      amount: (json['amount'] as int) / 100.0, // Convert from cents
      description: json['description'],
      email: json['email'],
      mobile: json['mobile'] ?? '',
      name: json['name'],
    );
  }
}

class BillplzBillStatus {
  final String id;
  final String state;
  final bool paid;
  final DateTime? paidAt;
  final double amount;
  final String? transactionId;
  final String? fpxTransactionId;

  BillplzBillStatus({
    required this.id,
    required this.state,
    required this.paid,
    this.paidAt,
    required this.amount,
    this.transactionId,
    this.fpxTransactionId,
  });

  factory BillplzBillStatus.fromJson(Map<String, dynamic> json) {
    return BillplzBillStatus(
      id: json['id'],
      state: json['state'],
      paid: json['paid'] == true,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      amount: (json['amount'] as int) / 100.0,
      transactionId: json['transaction_id'],
      fpxTransactionId: json['fpx_transaction_id'],
    );
  }
}

class FPXBank {
  final String code;
  final String name;
  final String displayName;

  FPXBank({
    required this.code,
    required this.name,
    required this.displayName,
  });
}

class PaymentWebhookData {
  final String id;
  final String state;
  final bool paid;
  final DateTime? paidAt;
  final double amount;

  PaymentWebhookData({
    required this.id,
    required this.state,
    required this.paid,
    this.paidAt,
    required this.amount,
  });

  factory PaymentWebhookData.fromJson(Map<String, dynamic> json) {
    return PaymentWebhookData(
      id: json['id'],
      state: json['state'],
      paid: json['paid'] == true,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      amount: (json['amount'] as int) / 100.0,
    );
  }
}

class BillplzException implements Exception {
  final String message;
  BillplzException(this.message);
  
  @override
  String toString() => 'BillplzException: $message';
}
