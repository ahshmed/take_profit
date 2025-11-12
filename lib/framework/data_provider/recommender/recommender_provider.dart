import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'create_signal_controller.dart';
import 'edit_signal_controller.dart';
import 'my_recommendation_controller.dart';
import 'new_btc_scenarios_controller.dart';
import 'new_social_controller.dart';

final myRecommendationProvider = ChangeNotifierProvider((ref) => MyRecommendationScreenController());
final createSignalProvider = ChangeNotifierProvider((ref) => CreateSignalController());
final newBTCScenariosProvider = ChangeNotifierProvider((ref) => NewBTCScenariosController());
final newSocialProvider = ChangeNotifierProvider((ref) => NewSocialController());
final editSignalProvider = ChangeNotifierProvider((ref) => EditSignalScreenController());

