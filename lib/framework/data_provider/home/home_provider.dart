
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/data_provider/home/bottom_nav_bar_controller.dart';
import 'package:take_profit/framework/data_provider/home/recommender_bio_controller.dart';
import 'package:take_profit/framework/data_provider/home/recommender_controller.dart';
import 'package:take_profit/framework/data_provider/home/trending_view_all_controller.dart';

import 'currencies_controller.dart';
import 'dashboard_screen_controller.dart';
import 'home_screen_controller.dart';

final dashboardProvider = ChangeNotifierProvider(
  (ref) => DashboardScreenController(),
);

final currenciesProvider = ChangeNotifierProvider(
  (ref) => CurrenciesScreenController(),
);

final recommenderProvider = ChangeNotifierProvider(
  (ref) => RecommenderScreenController(),
);

final homeProvider = ChangeNotifierProvider(
  (ref) => HomeScreenController(),
);

final trendingViewAllProvider = ChangeNotifierProvider(
  (ref) => TrendingViewAllScreenController(),
);

final bottomNavProvider = ChangeNotifierProvider(
  (ref) => BottomNavBarController(),
);

final chartScreenshotProvider = ChangeNotifierProvider(
  (ref) => RecommenderScreenController(),
);

final recommenderBioProvider = ChangeNotifierProvider(
  (ref) => RecommenderBioScreenController(),
);
