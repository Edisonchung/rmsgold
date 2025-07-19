// lib/admin/screens/reports_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  @override
  _ReportsAnalyticsScreenState createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports & Analytics'),
        backgroundColor: Color(0xFF1B4332),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Transactions'),
            Tab(text: 'Users'),
            Tab(text: 'Financial'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTransactionsTab(),
          _buildUsersTab(),
          _buildFinancialTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDateRangeCard(),
          SizedBox(height: 16),
          _buildKPICards(),
          SizedBox(height: 16),
          _buildChartsSection(),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Report Period',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _selectDateRange,
              icon: Icon(Icons.date_range),
              label: Text(
                '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildKPICard('Total Revenue', 'RM 1,234,567', Icons.monetization_on, Colors.green),
        _buildKPICard('Total Transactions', '5,432', Icons.swap_horiz, Colors.blue),
        _buildKPICard('Active Users', '2,891', Icons.people, Colors.orange),
        _buildKPICard('Gold Traded', '890.5 kg', Icons.account_balance, Colors.purple),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        _buildChartCard('Revenue Trend', _buildDummyChart()),
        SizedBox(height: 16),
        _buildChartCard('Transaction Volume', _buildDummyChart()),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildDummyChart() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey),
            Text(
              'Chart Coming Soon',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTransactionSummary(),
          SizedBox(height: 16),
          _buildTransactionBreakdown(),
          SizedBox(height: 16),
          _buildTopTransactions(),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Buy Orders', '3,241', Colors.green),
                _buildSummaryItem('Sell Orders', '2,191', Colors.red),
                _buildSummaryItem('Success Rate', '98.7%', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTransactionBreakdown() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildBreakdownItem('Small Orders (< 5g)', '45%', Colors.green),
            _buildBreakdownItem('Medium Orders (5-20g)', '35%', Colors.orange),
            _buildBreakdownItem('Large Orders (> 20g)', '20%', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              percentage,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTransactions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index % 2 == 0 ? Colors.green : Colors.red,
                    child: Icon(
                      index % 2 == 0 ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('Transaction #${1000 + index}'),
                  subtitle: Text('user${index + 1}@email.com'),
                  trailing: Text(
                    'RM ${(1000 + index * 500).toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserMetrics(),
          SizedBox(height: 16),
          _buildUserGrowth(),
          SizedBox(height: 16),
          _buildKYCStats(),
        ],
      ),
    );
  }

  Widget _buildUserMetrics() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMetricItem('New Users', '125', Icons.person_add),
                _buildMetricItem('Active Users', '2,891', Icons.people),
                _buildMetricItem('Verified Users', '2,456', Icons.verified_user),
                _buildMetricItem('Retention Rate', '87.5%', Icons.repeat),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Color(0xFF1B4332)),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowth() {
    return _buildChartCard('User Growth', _buildDummyChart());
  }

  Widget _buildKYCStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KYC Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildKYCItem('Pending Review', '8', Colors.orange),
            _buildKYCItem('Approved', '2,456', Colors.green),
            _buildKYCItem('Rejected', '87', Colors.red),
            _buildKYCItem('Approval Rate', '96.6%', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildKYCItem(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
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
    );
  }

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFinancialSummary(),
          SizedBox(height: 16),
          _buildRevenueBreakdown(),
          SizedBox(height: 16),
          _buildProfitability(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFinancialItem('Total Revenue', 'RM 1,234,567', Colors.green),
                _buildFinancialItem('Total Fees', 'RM 45,678', Colors.blue),
                _buildFinancialItem('Net Profit', 'RM 234,567', Colors.purple),
                _buildFinancialItem('Margin', '19.0%', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown() {
    return _buildChartCard('Revenue Breakdown', _buildDummyChart());
  }

  Widget _buildProfitability() {
    return _buildChartCard('Profitability Analysis', _buildDummyChart());
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _exportReport() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _doExport('pdf');
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                _doExport('excel');
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                _doExport('csv');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _doExport(String format) {
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting report as $format...')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
