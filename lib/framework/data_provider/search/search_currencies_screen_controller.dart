import 'package:flutter/material.dart';

import '../../repository/currencies/model/currencies_response_model.dart';

class SearchCurrenciesScreenController extends ChangeNotifier {
  List<CurrencyList>? currencyList = [];

  clearProvider() {
    currencyList = [];
    notifyListeners();
  }

  void fillCurrencyList(CurrencyListResponseModel? model) {
    currencyList?.addAll(model?.data?.currencyList as List<CurrencyList>);
    notifyListeners();
  }
}
