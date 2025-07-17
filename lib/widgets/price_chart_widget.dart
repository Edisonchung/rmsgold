// lib/widgets/price_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _getBottomInterval(),
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 50,
          ),
        ),
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
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return LineTooltipItem(
                'RM ${barSpot.y.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  List<FlSpot> _generatePriceData() {
    final basePrice = 475.5;
    final random = Random();
    final dataPoints = _getDataPointsForPeriod();
    
    List<FlSpot> spots = [];
    double currentPrice = basePrice;
    
    for (int i = 0; i < dataPoints; i++) {
      // Simulate price movement
      final change = (random.nextDouble() - 0.5) * 4; // ±2 range
      currentPrice += change;
      currentPrice = currentPrice.clamp(basePrice - 10, basePrice + 10);
      
      spots.add(FlSpot(i.toDouble(), currentPrice));
    }
    
    return spots;
  }

  int _getDataPointsForPeriod() {
    switch (_selectedPeriod) {
      case '1D':
        return 24; // 24 hours
      case '1W':
        return 7; // 7 days
      case '1M':
        return 30; // 30 days
      case '3M':
        return 90; // 90 days
      case '1Y':
        return 52; // 52 weeks
      default:
        return 24;
    }
  }

  double _getBottomInterval() {
    switch (_selectedPeriod) {
      case '1D':
        return 6; // Every 6 hours
      case '1W':
        return 1; // Every day
      case '1M':
        return 7; // Every week
      case '3M':
        return 30; // Every month
      case '1Y':
        return 13; // Every quarter
      default:
        return 6;
    }
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      color: Colors.grey,
    );

    String text = '';
    switch (_selectedPeriod) {
      case '1D':
        text = '${(value * 1).toInt()}h';
        break;
      case '1W':
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        if (value.toInt() < days.length) {
          text = days[value.toInt()];
        }
        break;
      case '1M':
        text = '${(value + 1).toInt()}';
        break;
      case '3M':
        text = 'W${(value / 7 + 1).toInt()}';
        break;
      case '1Y':
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        if ((value / 4).toInt() < months.length) {
          text = months[(value / 4).toInt()];
        }
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      color: Colors.grey,
    );

    return Text(
      value.toInt().toString(),
      style: style,
      textAlign: TextAlign.left,
    );
  }
}
