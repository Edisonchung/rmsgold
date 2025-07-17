// ===== lib/screens/purchase_screen.dart =====
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gold_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'dart:async';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isAmountMode = true; // true = amount, false = weight
  PaymentMethod _selectedPaymentMethod = PaymentMethod.fpx;
  String? _selectedBank;
  bool _isPriceLocked = false;
  double? _lockedPrice;
  Timer? _lockTimer;
  int _lockTimeRemaining = 30;

  final List<String> _fpxBanks = [
    'Maybank',
    'CIMB Bank',
    'Public Bank',
    'RHB Bank',
    'Hong Leong Bank',
    'AmBank',
    'Bank Islam',
    'OCBC Bank',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Gold'),
        actions: [
          if (_isPriceLocked)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_clock, color: Colors.red.shade700, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Locked: ${_lockTimeRemaining}s',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Gold Price
              _buildPriceCard(),
              const SizedBox(height: 16),
              
              // Purchase Amount/Weight
              _buildPurchaseInput(),
              const SizedBox(height: 16),
              
              // Calculation Summary
              _buildCalculationSummary(),
              const SizedBox(height: 16),
              
              // Payment Method
              _buildPaymentMethodSelection(),
              const SizedBox(height: 24),
              
              // Purchase Button
              _buildPurchaseButton(),
              const SizedBox(height: 16),
              
              // Important Notes
              _buildImportantNotes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Consumer<GoldProvider>(
      builder: (context, goldProvider, _) {
        final price = goldProvider.currentPrice;
        final displayPrice = _isPriceLocked ? _lockedPrice! : price?.buyPrice ?? 0;
        
        return Card(
          color: _isPriceLocked ? Colors.red.shade50 : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Buy Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isPriceLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PRICE LOCKED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'RM ${NumberFormat('#,##0.00').format(displayPrice)} per gram',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isPriceLocked ? Colors.red.shade700 : Colors.amber.shade700,
                  ),
                ),
                if (price != null)
                  Text(
                    'Last updated: ${DateFormat('HH:mm:ss').format(price.timestamp)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPurchaseInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Purchase',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Amount (RM)')),
                    ButtonSegment(value: false, label: Text('Weight (g)')),
                  ],
                  selected: {_isAmountMode},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _isAmountMode = selection.first;
                      _amountController.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: _isAmountMode ? 'Amount (RM)' : 'Weight (grams)',
                prefixText: _isAmountMode ? 'RM ' : '',
                suffixText: _isAmountMode ? '' : 'g',
                hintText: _isAmountMode ? '10.00' : '0.0210',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return _isAmountMode 
                    ? 'Please enter purchase amount'
                    : 'Please enter gold weight';
                }
                
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                
                if (_isAmountMode && amount < 10) {
                  return 'Minimum purchase amount is RM 10.00';
                }
                
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to update calculation
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Minimum purchase: RM 10.00',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationSummary() {
    return Consumer<GoldProvider>(
      builder: (context, goldProvider, _) {
        final price = goldProvider.currentPrice;
        final inputValue = double.tryParse(_amountController.text);
        
        if (price == null || inputValue == null || inputValue <= 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Purchase Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter amount to see calculation',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final buyPrice = _isPriceLocked ? _lockedPrice! : price.buyPrice;
        double totalAmount;
        double goldWeight;
        
        if (_isAmountMode) {
          totalAmount = inputValue;
          goldWeight = totalAmount / buyPrice;
        } else {
          goldWeight = inputValue;
          totalAmount = goldWeight * buyPrice;
        }
        
        final fee = totalAmount * 0.015; // 1.5% fee
        final finalAmount = totalAmount + fee;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Purchase Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Gold Weight:', '${goldWeight.toStringAsFixed(4)}g'),
                _buildSummaryRow('Gold Price:', 'RM ${NumberFormat('#,##0.00').format(buyPrice)}/g'),
                _buildSummaryRow('Subtotal:', 'RM ${NumberFormat('#,##0.00').format(totalAmount)}'),
                _buildSummaryRow('Transaction Fee (1.5%):', 'RM ${NumberFormat('#,##0.00').format(fee)}'),
                const Divider(),
                _buildSummaryRow(
                  'Total Amount:',
                  'RM ${NumberFormat('#,##0.00').format(finalAmount)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.amber.shade700 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment Method Selector
            DropdownButtonFormField<PaymentMethod>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Select Payment Method',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: PaymentMethod.fpx,
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text('FPX Online Banking'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: PaymentMethod.card,
                  child: Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text('Credit/Debit Card'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                  _selectedBank = null;
                });
              },
            ),
            
            if (_selectedPaymentMethod == PaymentMethod.fpx) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBank,
                decoration: const InputDecoration(
                  labelText: 'Select Bank',
                  border: OutlineInputBorder(),
                ),
                items: _fpxBanks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value;
                  });
                },
                validator: (value) {
                  if (_selectedPaymentMethod == PaymentMethod.fpx && value == null) {
                    return 'Please select your bank';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'FPX limit: RM 30,000 per transaction. For higher amounts, multiple payments may be required.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return Consumer<GoldProvider>(
      builder: (context, goldProvider, _) {
        final price = goldProvider.currentPrice;
        final inputValue = double.tryParse(_amountController.text);
        
        bool canProceed = price != null && 
                         inputValue != null && 
                         inputValue > 0 &&
                         (_selectedPaymentMethod != PaymentMethod.fpx || _selectedBank != null);
        
        if (_isAmountMode && inputValue != null && inputValue < 10) {
          canProceed = false;
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canProceed ? _handlePurchase : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _isPriceLocked ? Colors.red.shade600 : null,
            ),
            child: Text(
              _isPriceLocked ? 'Complete Purchase (Price Locked)' : 'Lock Price & Continue',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImportantNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Important Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNoteItem('First-time purchase must be completed within 24 hours'),
            _buildNoteItem('Minimum purchase amount: RM 10.00'),
            _buildNoteItem('T+0 settlement - Gold credited immediately after payment'),
            _buildNoteItem('Digital certificate of ownership will be issued'),
            _buildNoteItem('Transaction confirmation sent via email'),
            _buildNoteItem('Price locked for 30 seconds during checkout'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePurchase() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPriceLocked) {
      _lockPrice();
    } else {
      _processPurchase();
    }
  }

  void _lockPrice() {
    final goldProvider = Provider.of<GoldProvider>(context, listen: false);
    final price = goldProvider.currentPrice;
    
    if (price == null) return;

    setState(() {
      _isPriceLocked = true;
      _lockedPrice = price.buyPrice;
      _lockTimeRemaining = 30;
    });

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lockTimeRemaining--;
      });

      if (_lockTimeRemaining <= 0) {
        _unlockPrice();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Price locked at RM ${NumberFormat('#,##0.00').format(_lockedPrice!)} for 30 seconds'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _unlockPrice() {
    _lockTimer?.cancel();
    setState(() {
      _isPriceLocked = false;
      _lockedPrice = null;
      _lockTimeRemaining = 30;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Price lock expired. Please lock price again to continue.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _processPurchase() {
    _showPaymentDialog();
  }

  void _showPaymentDialog() {
    final inputValue = double.tryParse(_amountController.text)!;
    final buyPrice = _lockedPrice!;
    
    double totalAmount;
    double goldWeight;
    
    if (_isAmountMode) {
      totalAmount = inputValue;
      goldWeight = totalAmount / buyPrice;
    } else {
      goldWeight = inputValue;
      totalAmount = goldWeight * buyPrice;
    }
    
    final fee = totalAmount * 0.015;
    final finalAmount = totalAmount + fee;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please confirm your gold purchase:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildConfirmationRow('Gold Weight:', '${goldWeight.toStringAsFixed(4)}g'),
              _buildConfirmationRow('Gold Price:', 'RM ${NumberFormat('#,##0.00').format(buyPrice)}/g'),
              _buildConfirmationRow('Subtotal:', 'RM ${NumberFormat('#,##0.00').format(totalAmount)}'),
              _buildConfirmationRow('Transaction Fee:', 'RM ${NumberFormat('#,##0.00').format(fee)}'),
              const Divider(),
              _buildConfirmationRow('Total Amount:', 'RM ${NumberFormat('#,##0.00').format(finalAmount)}', isTotal: true),
              const SizedBox(height: 16),
              _buildConfirmationRow('Payment Method:', _selectedPaymentMethod == PaymentMethod.fpx ? 'FPX' : 'Card'),
              if (_selectedBank != null)
                _buildConfirmationRow('Bank:', _selectedBank!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(finalAmount, goldWeight, buyPrice);
            },
            child: const Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.amber.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(double amount, double goldWeight, double goldPrice) {
    // Simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing payment...'),
            Text('Please do not close this screen.'),
          ],
        ),
      ),
    );

    // Simulate payment processing delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close processing dialog
      
      // Create transaction
      final transaction = Transaction(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo-user-001',
        type: TransactionType.buy,
        amount: amount,
        goldQuantity: goldWeight,
        goldPrice: goldPrice,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
        paymentMethod: _selectedPaymentMethod,
        bankName: _selectedBank,
        fee: amount * 0.015,
        referenceNumber: 'REF-${DateTime.now().millisecondsSinceEpoch}',
        certificateUrl: 'https://certificates.rmsgold.com/cert-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      // Add transaction to provider
      Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);

      // Show success dialog
      _showSuccessDialog(transaction);
    });
  }

  void _showSuccessDialog(Transaction transaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 64,
        ),
        title: const Text('Purchase Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have successfully purchased ${transaction.goldQuantity.toStringAsFixed(4)}g of gold.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Transaction ID: ${transaction.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reference: ${transaction.referenceNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Digital certificate and confirmation email will be sent shortly.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('View Portfolio'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/transactions');
            },
            child: const Text('View Transaction'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }
}
