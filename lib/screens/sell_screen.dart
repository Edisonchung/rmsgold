// ===== lib/screens/sell_screen.dart =====
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gold_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'dart:async';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isAmountMode = false; // Start with weight mode for selling
  bool _isPriceLocked = false;
  double? _lockedPrice;
  Timer? _lockTimer;
  int _lockTimeRemaining = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Gold'),
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
      body: Consumer<GoldProvider>(
        builder: (context, goldProvider, _) {
          final portfolio = goldProvider.portfolio;
          
          if (portfolio == null || portfolio.goldHoldings <= 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Gold Holdings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You don\'t have any gold to sell.\nStart by purchasing some gold first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/purchase');
                    },
                    child: const Text('Buy Gold'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Holdings
                  _buildHoldingsCard(portfolio),
                  const SizedBox(height: 16),
                  
                  // Current Sell Price
                  _buildPriceCard(),
                  const SizedBox(height: 16),
                  
                  // Sell Amount/Weight
                  _buildSellInput(portfolio),
                  const SizedBox(height: 16),
                  
                  // Calculation Summary
                  _buildCalculationSummary(portfolio),
                  const SizedBox(height: 24),
                  
                  // Sell Button
                  _buildSellButton(portfolio),
                  const SizedBox(height: 16),
                  
                  // Important Notes
                  _buildImportantNotes(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHoldingsCard(Portfolio portfolio) {
    final isPositive = portfolio.profitLoss >= 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.inventory, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Your Gold Holdings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Available Gold', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${portfolio.goldHoldings.toStringAsFixed(4)}g',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Current Value', style: TextStyle(color: Colors.grey)),
                      Text(
                        'RM ${NumberFormat('#,##0.00').format(portfolio.totalValue)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPositive ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${isPositive ? 'Unrealized Gain' : 'Unrealized Loss'}: ${isPositive ? '+' : ''}RM ${NumberFormat('#,##0.00').format(portfolio.profitLoss)} (${isPositive ? '+' : ''}${portfolio.profitLossPercentage.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Consumer<GoldProvider>(
      builder: (context, goldProvider, _) {
        final price = goldProvider.currentPrice;
        final displayPrice = _isPriceLocked ? _lockedPrice! : price?.sellPrice ?? 0;
        
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
                      'Current Sell Price',
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
                    color: _isPriceLocked ? Colors.red.shade700 : Colors.blue.shade700,
                  ),
                ),
                if (price != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Spread: ${price.spread}% • Buy: RM ${NumberFormat('#,##0.00').format(price.buyPrice)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Last updated: ${DateFormat('HH:mm:ss').format(price.timestamp)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSellInput(Portfolio portfolio) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Sell',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Weight (g)')),
                    ButtonSegment(value: true, label: Text('Amount (RM)')),
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
                labelText: _isAmountMode ? 'Amount to Receive (RM)' : 'Weight to Sell (grams)',
                prefixText: _isAmountMode ? 'RM ' : '',
                suffixText: _isAmountMode ? '' : 'g',
                hintText: _isAmountMode ? '100.00' : '0.2000',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return _isAmountMode 
                    ? 'Please enter amount to receive'
                    : 'Please enter weight to sell';
                }
                
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                
                // Check if user has enough gold
                if (!_isAmountMode && amount > portfolio.goldHoldings) {
                  return 'Insufficient gold holdings';
                }
                
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to update calculation
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available: ${portfolio.goldHoldings.toStringAsFixed(4)}g',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_isAmountMode) {
                      // Calculate max amount based on current price
                      final goldProvider = Provider.of<GoldProvider>(context, listen: false);
                      final price = goldProvider.currentPrice;
                      if (price != null) {
                        final maxAmount = portfolio.goldHoldings * price.sellPrice;
                        _amountController.text = maxAmount.toStringAsFixed(2);
                        setState(() {});
                      }
                    } else {
                      _amountController.text = portfolio.goldHoldings.toStringAsFixed(4);
                      setState(() {});
                    }
                  },
                  child: const Text('Sell All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationSummary(Portfolio portfolio) {
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
                    'Sale Summary',
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

        final sellPrice = _isPriceLocked ? _lockedPrice! : price.sellPrice;
        double goldWeight;
        double grossAmount;
        
        if (_isAmountMode) {
          grossAmount = inputValue;
          goldWeight = grossAmount / sellPrice;
        } else {
          goldWeight = inputValue;
          grossAmount = goldWeight * sellPrice;
        }
        
        // Check if user has enough gold
        if (goldWeight > portfolio.goldHoldings) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sale Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Insufficient gold holdings. You only have ${portfolio.goldHoldings.toStringAsFixed(4)}g available.',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        final fee = grossAmount * 0.01; // 1% selling fee
        final netAmount = grossAmount - fee;
        
        // Calculate profit/loss for this sale
        final avgPurchasePrice = portfolio.averagePurchasePrice;
        final purchaseCost = goldWeight * avgPurchasePrice;
        final profitLoss = grossAmount - purchaseCost;
        final profitLossPercentage = (profitLoss / purchaseCost) * 100;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sale Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Gold to Sell:', '${goldWeight.toStringAsFixed(4)}g'),
                _buildSummaryRow('Sell Price:', 'RM ${NumberFormat('#,##0.00').format(sellPrice)}/g'),
                _buildSummaryRow('Gross Amount:', 'RM ${NumberFormat('#,##0.00').format(grossAmount)}'),
                _buildSummaryRow('Transaction Fee (1%):', 'RM ${NumberFormat('#,##0.00').format(fee)}'),
                const Divider(),
                _buildSummaryRow(
                  'Net Amount:',
                  'RM ${NumberFormat('#,##0.00').format(netAmount)}',
                  isTotal: true,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: profitLoss >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: profitLoss >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profitLoss >= 0 ? 'Realized Gain' : 'Realized Loss',
                        style: TextStyle(
                          color: profitLoss >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${profitLoss >= 0 ? '+' : ''}RM ${NumberFormat('#,##0.00').format(profitLoss)}',
                            style: TextStyle(
                              color: profitLoss >= 0 ? Colors.green : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '(${profitLoss >= 0 ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%)',
                            style: TextStyle(
                              color: profitLoss >= 0 ? Colors.green : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              color: isTotal ? Colors.blue.shade700 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellButton(Portfolio portfolio) {
    return Consumer<GoldProvider>(
      builder: (context, goldProvider, _) {
        final price = goldProvider.currentPrice;
        final inputValue = double.tryParse(_amountController.text);
        
        bool canProceed = price != null && 
                         inputValue != null && 
                         inputValue > 0;
        
        // Check if user has enough gold
        if (canProceed && !_isAmountMode && inputValue > portfolio.goldHoldings) {
        canProceed = false;
        }
        
        if (canProceed && _isAmountMode) {
          final sellPrice = _isPriceLocked ? _lockedPrice! : price!.sellPrice;
          final goldWeight = inputValue! / sellPrice;
          if (goldWeight > portfolio.goldHoldings) {
            canProceed = false;
          }
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canProceed ? _handleSell : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _isPriceLocked ? Colors.red.shade600 : Colors.blue.shade600,
            ),
            child: Text(
              _isPriceLocked ? 'Complete Sale (Price Locked)' : 'Lock Price & Continue',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
            _buildNoteItem('T+0 settlement - Funds credited immediately after sale'),
            _buildNoteItem('Transaction fee: 1% of gross sale amount'),
            _buildNoteItem('Price locked for 30 seconds during checkout'),
            _buildNoteItem('Sale confirmation sent via email'),
            _buildNoteItem('Funds transferred to your registered bank account'),
            _buildNoteItem('Tax implications may apply for realized gains'),
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

  void _handleSell() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPriceLocked) {
      _lockPrice();
    } else {
      _processSale();
    }
  }

  void _lockPrice() {
    final goldProvider = Provider.of<GoldProvider>(context, listen: false);
    final price = goldProvider.currentPrice;
    
    if (price == null) return;

    setState(() {
      _isPriceLocked = true;
      _lockedPrice = price.sellPrice;
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

  void _processSale() {
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    final inputValue = double.tryParse(_amountController.text)!;
    final sellPrice = _lockedPrice!;
    
    double goldWeight;
    double grossAmount;
    
    if (_isAmountMode) {
      grossAmount = inputValue;
      goldWeight = grossAmount / sellPrice;
    } else {
      goldWeight = inputValue;
      grossAmount = goldWeight * sellPrice;
    }
    
    final fee = grossAmount * 0.01;
    final netAmount = grossAmount - fee;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sale'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please confirm your gold sale:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildConfirmationRow('Gold to Sell:', '${goldWeight.toStringAsFixed(4)}g'),
              _buildConfirmationRow('Sell Price:', 'RM ${NumberFormat('#,##0.00').format(sellPrice)}/g'),
              _buildConfirmationRow('Gross Amount:', 'RM ${NumberFormat('#,##0.00').format(grossAmount)}'),
              _buildConfirmationRow('Transaction Fee:', 'RM ${NumberFormat('#,##0.00').format(fee)}'),
              const Divider(),
              _buildConfirmationRow('Net Amount:', 'RM ${NumberFormat('#,##0.00').format(netAmount)}', isTotal: true),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone. Funds will be transferred to your registered bank account.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              _processTransaction(netAmount, goldWeight, sellPrice);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Confirm Sale', style: TextStyle(color: Colors.white)),
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
              color: isTotal ? Colors.blue.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  void _processTransaction(double amount, double goldWeight, double goldPrice) {
    // Simulate transaction processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing sale...'),
            Text('Please do not close this screen.'),
          ],
        ),
      ),
    );

    // Simulate processing delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close processing dialog
      
      // Create transaction
      final transaction = Transaction(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo-user-001',
        type: TransactionType.sell,
        amount: amount,
        goldQuantity: goldWeight,
        goldPrice: goldPrice,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
        paymentMethod: PaymentMethod.bankTransfer,
        fee: amount * 0.01,
        referenceNumber: 'REF-${DateTime.now().millisecondsSinceEpoch}',
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
        title: const Text('Sale Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have successfully sold ${transaction.goldQuantity.toStringAsFixed(4)}g of gold for RM ${NumberFormat('#,##0.00').format(transaction.amount)}.',
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
              'Funds will be transferred to your registered bank account within 1-2 business days.',
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
