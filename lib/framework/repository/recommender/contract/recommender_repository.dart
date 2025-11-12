import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class RecommenderRepository {
  ///BTC Scenarios List Api
  Future btcScenariosListApi(BuildContext context, Map<String, dynamic> request);

  ///New BTC Scenarios Api
  Future newBTCScenariosApi(BuildContext context,FormData formData);

  ///Edit BTC Scenarios Api
  Future editBTCScenariosApi(BuildContext context, FormData formData);

}