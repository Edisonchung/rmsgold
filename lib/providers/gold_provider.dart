// lib/providers/gold_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';

class GoldPrice {
  final double buyPrice;
  final double sellPrice;
  final double spread;
  final DateTime timestamp;
  final String currency;
  final String source;

  GoldPrice({
    required this.buyPrice,
    required this.sellPrice,
    required this.spread,
    required this.timestamp,
    this.currency = 'MYR',
    this.source = 'Bloomberg',
  });

  // Add a price getter for compatibility
  double get price => buyPrice;
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

class GoldProvider extends ChangeNotifier {
  GoldPrice? _currentPrice;
  Portfolio? _portfolio;
  Timer? _priceUpdateTimer;
  bool _isLoading = false;
  String? _errorMessage;
  
  double _demoGoldHoldings = 2.41;
  double _demoPurchaseAverage = 472.50;
  
  // Fixed getters - added price value getters for compatibility
  GoldPrice? get currentPrice => _currentPrice;
  double get currentPriceValue => _currentPrice?.buyPrice ?? 0.0;
  double get currentBuyPrice => _currentPrice?.buyPrice ?? 0.0;
  double get currentSellPrice => _currentPrice?.sellPrice ?? 0.0;
  
  Portfolio? get portfolio => _portfolio;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  GoldProvider() {
    _initializeDemoData();
    _startPriceUpdates();
  }

  void _initializeDemoData() {
    _updateDemoPrice();
    _updatePortfolio();
  }

  void _startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _updateDemoPrice();
      _updatePortfolio();
    });
  }

  void _updateDemoPrice() {
    final random = Random();
    final basePrice = 475.50;
    
    final fluctuation = (random.nextDouble() - 0.5) * 2 * 0.02 * basePrice;
    final currentBuyPrice = basePrice + fluctuation;
    
    const spreadPercentage = 3.6;
    final spread = currentBuyPrice * (spreadPercentage / 100);
    final sellPrice = currentBuyPrice - spread;

    _currentPrice = GoldPrice(
      buyPrice: double.parse(currentBuyPrice.toStringAsFixed(2)),
      sellPrice: double.parse(sellPrice.toStringAsFixed(2)),
      spread: spreadPercentage,
      timestamp: DateTime.now(),
      source: 'Bloomberg',
    );
    
    notifyListeners();
  }

  void _updatePortfolio() {
    if (_currentPrice == null) return;

    final currentValue = _demoGoldHoldings * _currentPrice!.sellPrice;
    final purchaseValue = _demoGoldHoldings * _demoPurchaseAverage;
    final profitLoss = currentValue - purchaseValue;
    final profitLossPercentage = (profitLoss / purchaseValue) * 100;

    _portfolio = Portfolio(
      goldHoldings: _demoGoldHoldings,
      totalValue: double.parse(currentValue.toStringAsFixed(2)),
      profitLoss: double.parse(profitLoss.toStringAsFixed(2)),
      profitLossPercentage: double.parse(profitLossPercentage.toStringAsFixed(2)),
      averagePurchasePrice: _demoPurchaseAverage,
      lastUpdated: DateTime.now(),
    );
    
    notifyListeners();
  }

  // Add methods for purchasing and selling gold
  Future<bool> buyGold(double amount, double pricePerGram) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate purchase processing
      await Future.delayed(Duration(seconds: 2));
      
      // Update holdings
      _demoGoldHoldings += amount;
      
      // Recalculate average purchase price
      final totalValue = (_demoPurchaseAverage * (_demoGoldHoldings - amount)) + (pricePerGram * amount);
      _demoPurchaseAverage = totalValue / _demoGoldHoldings;
      
      _updatePortfolio();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Purchase failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sellGold(double amount, double pricePerGram) async {
    try {
      if (amount > _demoGoldHoldings) {
        _errorMessage = 'Insufficient gold holdings';
        notifyListeners();
        return false;
      }
      
      _isLoading = true;
      notifyListeners();
      
      // Simulate sale processing
      await Future.delayed(Duration(seconds: 2));
      
      // Update holdings
      _demoGoldHoldings -= amount;
      
      _updatePortfolio();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sale failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _priceUpdateTimer?.cancel();
    super.dispose();
  }
}
