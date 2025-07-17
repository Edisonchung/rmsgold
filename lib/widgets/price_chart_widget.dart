// lib/widgets/price_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class PriceChartWidget extends StatefulWidget {
  const PriceChartWidget({super.key});

  @override
  State<PriceChartWidget> createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  String _selectedPeriod = '1D';
  final List<String> _periods = ['1D', '1W', '1M', '3M', '1Y'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gold Price Chart',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: _periods.map((period) {
                    final isSelected = _selectedPeriod == period;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ChoiceChip(
                        label: Text(period),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          }
                        },
                        selectedColor: Colors.amber.shade200,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                _generateChartData(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('24h Change', '+2.5%', Colors.green),
                _buildStatItem('24h High', 'RM 478.20', Colors.blue),
                _buildStatItem('24h Low', 'RM 472.80', Colors.red),
                _buildStatItem('Volume', '1.2K oz', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  LineChartData _generateChartData() {
    final spots = _generatePriceData();
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: const FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2,
      maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade700,
              Colors.amber.shade400,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade200.withOpacity(0.3),
                Colors.amber.shade100.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generatePriceData() {
    final basePrice = 475.5;
    final random = Random();
    final dataPoints = 24; // 24 hours for demo
    
    List<FlSpot> spots = [];
    double currentPrice = basePrice;
    
    for (int i = 0; i < dataPoints; i++) {
      final change = (random.nextDouble() - 0.5) * 4;
      currentPrice += change;
      currentPrice = currentPrice.clamp(basePrice - 10, basePrice + 10);
      
      spots.add(FlSpot(i.toDouble(), currentPrice));
    }
    
    return spots;
  }
}
