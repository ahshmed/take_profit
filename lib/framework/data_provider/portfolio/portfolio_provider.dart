import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'portfolio_controller.dart';

final portfolioProvider = ChangeNotifierProvider<PortfolioController>((ref) {
  return PortfolioController();
});
