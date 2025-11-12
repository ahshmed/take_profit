import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/const.dart';
import '../../../utils/theme_const.dart';
import '../../repository/select_market/market_model.dart';

// State class
class SelectMarketState {
  final List<Market> markets;
  final Market? selectedMarket;
  final bool isLoading;

  const SelectMarketState({
    required this.markets,
    this.selectedMarket,
    this.isLoading = false,
  });

  SelectMarketState copyWith({
    List<Market>? markets,
    Market? selectedMarket,
    bool? isLoading,
  }) {
    return SelectMarketState(
      markets: markets ?? this.markets,
      selectedMarket: selectedMarket ?? this.selectedMarket,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Controller
class ChooseMarketController extends StateNotifier<SelectMarketState> {
  ChooseMarketController() : super(const SelectMarketState(markets: [])) {
    _initializeMarkets();
  }

  void _initializeMarkets() {
    final markets = [
      Market(
        id: 'us_market',
        title: getLocalValue("Key_UsMarketTitle"),
        description: getLocalValue("Key_UsMarketBody"),
        imagePath: Constant.icUsMarketLogo, // You'll need to add these images
      ),
      Market(
        id: 'crypto_signals',
        title: getLocalValue("Key_CryptoMarketTitle"),
        description: getLocalValue("Key_CryptoMarketBody"),
        imagePath: Constant.icCryptoLogo,
      ),
    ];

    state = state.copyWith(markets: markets);
  }

  void selectMarket(Market market) {
    final updatedMarkets = state.markets.map((m) {
      return m.copyWith(isSelected: m.id == market.id);
    }).toList();

    final selected = updatedMarkets.firstWhere((m) => m.isSelected);

    // Save selection to local storage
    setSelectedMarket(market.id);

    state = state.copyWith(
      markets: updatedMarkets,
      selectedMarket: selected,
    );
  }

  // Load saved market selection
  Market? loadSavedMarket() {
    final savedMarketId = getSelectedMarket();
    if (savedMarketId != null && savedMarketId.isNotEmpty) {
      try {
        return state.markets.firstWhere((m) => m.id == savedMarketId);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void clearSelection() {
    final updatedMarkets = state.markets.map((m) {
      return m.copyWith(isSelected: false);
    }).toList();

    state = state.copyWith(
      markets: updatedMarkets,
      selectedMarket: null,
    );
  }
}