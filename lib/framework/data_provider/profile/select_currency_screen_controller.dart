import 'package:flutter/material.dart';
import '../../repository/currencies/model/currencies_response_model.dart';

class SelectCurrencyScreenController extends ChangeNotifier {
  List<CurrencyList> sItemList = [];

  removeFromList(int index) {
    sItemList.removeAt(index);
    notifyListeners();
  }

  bool isLoading = false;
  bool isError = false;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  updateWidget() {
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  List<CurrencyList>? currencyList = [];

  void fillCurrencyList(CurrencyListResponseModel? model) {
    currencyList?.addAll(model?.data?.currencyList as List<CurrencyList>);
    notifyListeners();
  }

  clearProvider() {
    currencyList?.clear();
    sItemList.clear();
    notifyListeners();
  }
}
