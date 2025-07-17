// lib/screens/conversion_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gold_provider.dart';

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  final _quantityController = TextEditingController();
  String _selectedDenomination = '1g';
  String _deliveryMethod = 'pickup';
  final _addressController = TextEditingController();

  final List<String> _denominations = ['1g', '5g', '10g', '20g', '50g', '100g'];
  final Map<String, double> _conversionFees = {
    '1g': 25.00,
    '5g': 35.00,
    '10g': 50.00,
    '20g': 75.00,
    '50g': 125.00,
    '100g': 200.00,
  };

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert to Physical Gold'),
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
                    'No Digital Gold Available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You need digital gold holdings to convert to physical gold.',
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
                    child: const Text('Buy Digital Gold'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Holdings
                _buildHoldingsCard(portfolio),
                const SizedBox(height: 16),
                
                // Conversion Form
                _buildConversionForm(portfolio),
                const SizedBox(height: 16),
                
                // Delivery Options
                _buildDeliveryOptions(),
                const SizedBox(height: 16),
                
                // Conversion Summary
                _buildConversionSummary(portfolio),
                const SizedBox(height: 24),
                
                // Convert Button
                _buildConvertButton(portfolio),
                const SizedBox(height: 16),
                
                // Important Information
                _buildImportantInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHoldingsCard(Portfolio portfolio) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Your Digital Gold Holdings',
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
                      const Text('Available for Conversion', style: TextStyle(color: Colors.grey)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildConversionForm(Portfolio portfolio) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversion Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Denomination Selection
            const Text('Select Denomination:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _denominations.map((denomination) {
                final isSelected = _selectedDenomination == denomination;
                return ChoiceChip(
                  label: Text(denomination),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDenomination = denomination;
                        _quantityController.clear();
                      });
                    }
                  },
                  selectedColor: Colors.amber.shade200,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Quantity Input
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Number of $_selectedDenomination wafers',
                border: const OutlineInputBorder(),
                hintText: 'Enter quantity',
                suffixText: 'pieces',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for summary
              },
            ),
            const SizedBox(height: 8),
            
            // Available calculation
            if (_quantityController.text.isNotEmpty) ...[
              Builder(
                builder: (context) {
                  final quantity = int.tryParse(_quantityController.text) ?? 0;
                  final denomWeight = double.parse(_selectedDenomination.replaceAll('g', ''));
                  final totalGoldNeeded = quantity * denomWeight;
                  final isAvailable = totalGoldNeeded <= portfolio.goldHoldings;
                  
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAvailable ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.error,
                          color: isAvailable ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAvailable
                              ? 'Total needed: ${totalGoldNeeded.toStringAsFixed(1)}g (Available)'
                              : 'Insufficient gold! Need ${totalGoldNeeded.toStringAsFixed(1)}g, have ${portfolio.goldHoldings.toStringAsFixed(4)}g',
                            style: TextStyle(
                              color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            RadioListTile<String>(
              title: const Text('Pickup at RMS Gold HQ'),
              subtitle: const Text('No additional charges • Kuala Lumpur'),
              value: 'pickup',
              groupValue: _deliveryMethod,
              onChanged: (value) {
                setState(() {
                  _deliveryMethod = value!;
                });
              },
            ),
            
            RadioListTile<String>(
              title: const Text('Home Delivery'),
              subtitle: const Text('RM 15 delivery fee • 3-5 business days'),
              value: 'delivery',
              groupValue: _deliveryMethod,
              onChanged: (value) {
                setState(() {
                  _deliveryMethod = value!;
                });
              },
            ),
            
            if (_deliveryMethod == 'delivery') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your full delivery address',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget
