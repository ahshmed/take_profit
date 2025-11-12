import 'package:flutter/material.dart';
import '../../repository/portfolio/model/portfolio_item_model.dart';

class PortfolioController extends ChangeNotifier {
  List<PortfolioItemModel> _portfolioItems = [];
  bool _isLoading = false;

  List<PortfolioItemModel> get portfolioItems => _portfolioItems;
  bool get isLoading => _isLoading;

  // Calculate total portfolio value
  double get totalPortfolioValue {
    double total = 0;
    for (var item in _portfolioItems) {
      final currentPrice = double.parse(item.currentPrice.replaceAll(RegExp(r'[^\d.]'), ''));
      total += currentPrice;
    }
    return total;
  }

  // Calculate total profit/loss
  double get totalProfitLoss {
    double total = 0;
    for (var item in _portfolioItems) {
      final currentPrice = double.parse(item.currentPrice.replaceAll(RegExp(r'[^\d.]'), ''));
      final buyPrice = item.buyPrice;
      total += (currentPrice - buyPrice);
    }
    return total;
  }

  // Calculate total profit/loss percentage
  double get totalProfitLossPercent {
    if (_portfolioItems.isEmpty) return 0;

    double totalBuyValue = 0;
    for (var item in _portfolioItems) {
      totalBuyValue += item.buyPrice;
    }

    if (totalBuyValue == 0) return 0;
    return (totalProfitLoss / totalBuyValue) * 100;
  }

  // Count winners (stocks with profit)
  int get winnersCount {
    int count = 0;
    for (var item in _portfolioItems) {
      final currentPrice = double.parse(item.currentPrice.replaceAll(RegExp(r'[^\d.]'), ''));
      final buyPrice = item.buyPrice;
      if (currentPrice > buyPrice) count++;
    }
    return count;
  }

  // Count losers (stocks with loss)
  int get losersCount {
    int count = 0;
    for (var item in _portfolioItems) {
      final currentPrice = double.parse(item.currentPrice.replaceAll(RegExp(r'[^\d.]'), ''));
      final buyPrice = item.buyPrice;
      if (currentPrice < buyPrice) count++;
    }
    return count;
  }

  // Load portfolio (from local storage or API)
  Future<void> loadPortfolio() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Load from SharedPreferences or API
    // For now, keep existing items

    _isLoading = false;
    notifyListeners();
  }

  // Add stock to portfolio
  void addToPortfolio({
    required String ticker,
    required String companyName,
    required String currentPrice,
    required double buyPrice,
    required String buyStatus,
    required String complianceStatus,
    required String dateTime,
  }) {
    // Check if already exists
    final existingIndex = _portfolioItems.indexWhere((item) => item.ticker == ticker);

    if (existingIndex != -1) {
      // Update existing item
      _portfolioItems[existingIndex] = PortfolioItemModel(
        ticker: ticker,
        companyName: companyName,
        currentPrice: currentPrice,
        buyPrice: buyPrice,
        buyStatus: buyStatus,
        complianceStatus: complianceStatus,
        dateTime: dateTime,
      );
    } else {
      // Add new item
      _portfolioItems.add(
        PortfolioItemModel(
          ticker: ticker,
          companyName: companyName,
          currentPrice: currentPrice,
          buyPrice: buyPrice,
          buyStatus: buyStatus,
          complianceStatus: complianceStatus,
          dateTime: dateTime,
        ),
      );
    }

    // TODO: Save to SharedPreferences or API
    notifyListeners();
  }

  // Remove stock from portfolio
  void removeFromPortfolio(String ticker) {
    _portfolioItems.removeWhere((item) => item.ticker == ticker);

    // TODO: Save to SharedPreferences or API
    notifyListeners();
  }

  // Check if stock is in portfolio
  bool isInPortfolio(String ticker) {
    return _portfolioItems.any((item) => item.ticker == ticker);
  }

  // Clear portfolio
  void clearPortfolio() {
    _portfolioItems.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clearPortfolio();
    super.dispose();
  }
}
