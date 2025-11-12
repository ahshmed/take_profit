import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/data_provider/select_market/select_market_controller.dart';


final selectMarketProvider = StateNotifierProvider<ChooseMarketController, SelectMarketState>(
      (ref) => ChooseMarketController(),
);