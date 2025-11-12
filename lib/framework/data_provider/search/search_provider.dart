import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/data_provider/search/search_currencies_screen_controller.dart';

///Search Currencies Screen Provider
final searchCurrenciesProvider = ChangeNotifierProvider((ref)=> SearchCurrenciesScreenController());

///Search Screen Provider
// final searchProvider = ChangeNotifierProvider((ref)=> SearchScreenController());