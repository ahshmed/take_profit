import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stock_controller.dart';

final stockProvider = ChangeNotifierProvider<StockController>((ref) {
  return StockController();
});