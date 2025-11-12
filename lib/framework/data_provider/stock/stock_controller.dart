import 'package:flutter/material.dart';
import '../../../framework/repository/stock/model/stock_model.dart';

class StockController extends ChangeNotifier {
  List<StockModel> _stockList = [];
  List<StockModel> _filteredStockList = [];
  bool _isLoading = false;
  String _searchQuery = "";

  List<StockModel> get stockList => _stockList;
  List<StockModel> get filteredStockList => _filteredStockList;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Initialize with mock data
  void initializeStockData() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _stockList = StockModel.getMockStockList();
      _filteredStockList = _stockList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Search functionality
  void searchStocks(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredStockList = _stockList;
    } else {
      _filteredStockList = _stockList.where((stock) {
        final tickerMatch = stock.ticker.toLowerCase().contains(query.toLowerCase());
        final companyMatch = stock.companyName.toLowerCase().contains(query.toLowerCase());
        return tickerMatch || companyMatch;
      }).toList();
    }
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = "";
    _filteredStockList = _stockList;
    notifyListeners();
  }

  // Toggle favorite (placeholder - won't be used but keeping structure)
  void toggleFavorite(String ticker) {
    final index = _stockList.indexWhere((stock) => stock.ticker == ticker);
    if (index != -1) {
      _stockList[index] = _stockList[index].copyWith(
        isFavorite: !_stockList[index].isFavorite,
      );
      // Update filtered list as well
      searchStocks(_searchQuery);
    }
  }

  // Clear provider
  void clearProvider() {
    _stockList = [];
    _filteredStockList = [];
    _searchQuery = "";
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    clearProvider();
    super.dispose();
  }
}