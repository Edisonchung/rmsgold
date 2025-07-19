// lib/admin/screens/price_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class PriceManagementScreen extends StatefulWidget {
  @override
  _PriceManagementScreenState createState() => _PriceManagementScreenState();
}

class _PriceManagementScreenState extends State<PriceManagementScreen> {
  final _buySpreadController = TextEditingController();
  final _sellSpreadController = TextEditingController();
  final _overridePriceController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPriceManagement();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Price Management'),
        backgroundColor: Color(0xFF1B4332),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentPriceCard(),
                SizedBox(height: 20),
                _buildSpreadManagement(adminProvider),
                SizedBox(height: 20),
                _buildPriceOverride(adminProvider),
                SizedBox(height: 20),
                _buildPriceHistory(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPriceCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Gold Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceInfo('Market Price', 'RM 475.50/g', Colors.blue),
                _buildPriceInfo('Buy Price', 'RM 472.25/g', Colors.green),
                _buildPriceInfo('Sell Price', 'RM 478.75/g', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String price, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          price,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSpreadManagement(AdminProvider adminProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spread Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buySpreadController,
                    decoration: InputDecoration(
                      labelText: 'Buy Spread (%)',
                      border: OutlineInputBorder(),
                      hintText: '0.5',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _sellSpreadController,
                    decoration: InputDecoration(
                      labelText: 'Sell Spread (%)',
                      border: OutlineInputBorder(),
                      hintText: '0.7',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _updateSpreads(adminProvider),
              child: Text('Update Spreads'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1B4332),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOverride(AdminProvider adminProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Override',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Override market price temporarily',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _overridePriceController,
              decoration: InputDecoration(
                labelText: 'Override Price (RM/g)',
                border: OutlineInputBorder(),
                hintText: '475.50',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for Override',
                border: OutlineInputBorder(),
                hintText: 'Market volatility adjustment',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _overridePrice(adminProvider),
              child: Text('Apply Override'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceHistory() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price History (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, size: 48, color: Colors.grey),
                    Text(
                      'Price Chart Coming Soon',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSpreads(AdminProvider adminProvider) {
    final buySpread = double.tryParse(_buySpreadController.text);
    final sellSpread = double.tryParse(_sellSpreadController.text);

    if (buySpread == null || sellSpread == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid spread values')),
      );
      return;
    }

    adminProvider.updatePriceSpread(buySpread, sellSpread);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Price spreads updated successfully')),
    );
  }

  void _overridePrice(AdminProvider adminProvider) {
    final overridePrice = double.tryParse(_overridePriceController.text);
    final reason = _reasonController.text.trim();

    if (overridePrice == null || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid price and reason')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Price Override'),
        content: Text(
          'Are you sure you want to override the gold price to RM $overridePrice/g?\n\nReason: $reason',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              adminProvider.overrideGoldPrice(overridePrice, reason);
              _overridePriceController.clear();
              _reasonController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Price override applied successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Apply Override'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _buySpreadController.dispose();
    _sellSpreadController.dispose();
    _overridePriceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
