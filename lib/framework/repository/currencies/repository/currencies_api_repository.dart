import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../contract/currencies_repository.dart';
import '../model/currencies_detail_response_model.dart';
import '../model/currencies_response_model.dart';
import '../model/currency_search_response_model.dart';


class CurrenciesApiRepository implements CurrenciesRepository {

  ///Currency List Api
  @override
  Future currencyListApi(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.currencyListApi, request);
      CurrencyListResponseModel responseModel = currencyListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  ///Currency List Api
  @override
  Future searchCurrencyListApi(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.searchCurrencyApi, request);
      CurrencySearchResponseModel responseModel = currencySearchResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  ///Currency detail  Api
  @override
  Future currencyDetailApi(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.currencyDetailApi, request);
      CurrencyDetailResponseModel responseModel = currencyDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

}