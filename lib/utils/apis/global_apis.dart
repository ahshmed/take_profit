import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:take_profit/utils/apis/rest_client.dart';

import '../../framework/repository/common/model/country_list_response_model.dart';
import '../const.dart';
import 'api_end_points.dart';
import 'api_result.dart';
import 'network_exceptions.dart';


class GlobalApis {

  GlobalApis._privateConstructor();
  static final GlobalApis instance = GlobalApis._privateConstructor();

  ///Get Country List Api
  ///Usage -> GlobalApis.instance.getCountryListApi(context, (model, error) {});

  Future getCountryListApi(BuildContext context, Function(CountryResponseModel? model, NetworkExceptions? error) callBackBlock) async {

    late ApiResult apiResult;
    try{
      Response? response = await RestClient.getData(context, ApiEndPoints.countryList);
      CountryResponseModel responseModel = countryResponseModelFromJson(response.toString());
      apiResult = ApiResult.success(data: responseModel);
    }
    catch (err){
      apiResult = ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }

    apiResult.when(success: (data) async {
      callBackBlock(data as CountryResponseModel, null);
    }, failure: (NetworkExceptions error) {
      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
      callBackBlock(null, error);
    });
  }



}