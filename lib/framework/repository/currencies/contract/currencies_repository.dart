import 'package:flutter/material.dart';

abstract class CurrenciesRepository {

  ///Currency List Api
  Future currencyListApi(BuildContext context, Map<String, dynamic> request);

  Future searchCurrencyListApi(BuildContext context, Map<String, dynamic> request);
  ///Currency Detail Api
  Future currencyDetailApi(BuildContext context, Map<String, dynamic> request);

}