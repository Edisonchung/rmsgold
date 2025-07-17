// ===== lib/widgets/portfolio_card.dart =====
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gold_provider.dart';

class PortfolioCard extends StatelessWidget {
  const PortfolioCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoldProvider>(
      builder: (context, goldProvider, _) {
        final portfolio = goldProvider.portfolio;
        
        if (portfolio == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final isPositive = portfolio.profitLoss >= 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.blue,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'My Portfolio',
                      style: TextStyle(
                        fontSize: 18,
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
                          const Text(
                            'Gold Holdings',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${portfolio.goldHoldings.toStringAsFixed(4)}g',
                            style: const TextStyle(
                              fontSize: 24,
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
                          const Text(
                            'Total Value',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'RM ${NumberFormat('#,##0.00').format(portfolio.totalValue)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPositive 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPositive 
                        ? Colors.green.shade200 
                        : Colors.red.shade200,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPositive ? 'Unrealized Gain' : 'Unrealized Loss',
                              style: TextStyle(
                                color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${isPositive ? '+' : ''}RM ${NumberFormat('#,##0.00').format(portfolio.profitLoss)}',
                                  style: TextStyle(
                                    color: isPositive ? Colors.green : Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${isPositive ? '+' : ''}${portfolio.profitLossPercentage.toStringAsFixed(2)}%)',
                                  style: TextStyle(
                                    color: isPositive ? Colors.green : Colors.red,
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
                const SizedBox(height: 12),
                
                Text(
                  'Average Purchase Price: RM ${NumberFormat('#,##0.00').format(portfolio.averagePurchasePrice)}/g',
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
}
