// ===== lib/models/gold_model.dart =====
class GoldPrice {
  final double buyPrice;
  final double sellPrice;
  final double spotPrice;
  final double spread;
  final DateTime timestamp;
  final String currency;
  final String source;

  GoldPrice({
    required this.buyPrice,
    required this.sellPrice,
    required this.spotPrice,
    required this.spread,
    required this.timestamp,
    this.currency = 'MYR',
    this.source = 'Bloomberg',
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      buyPrice: json['buyPrice'].toDouble(),
      sellPrice: json['sellPrice'].toDouble(),
      spotPrice: json['spotPrice'].toDouble(),
      spread: json['spread'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      currency: json['currency'] ?? 'MYR',
      source: json['source'] ?? 'Bloomberg',
    );
  }
}

class Portfolio {
  final double goldHoldings;
  final double totalValue;
  final double profitLoss;
  final double profitLossPercentage;
  final double averagePurchasePrice;
  final DateTime lastUpdated;

  Portfolio({
    required this.goldHoldings,
    required this.totalValue,
    required this.profitLoss,
    required this.profitLossPercentage,
    required this.averagePurchasePrice,
    required this.lastUpdated,
  });
}
