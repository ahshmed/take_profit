import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../../common/model/common_response_model.dart';
import '../contract/recommender_repository.dart';
import '../model/btc_scenarios_list_response_model.dart';


class RecommenderApiRepository implements RecommenderRepository {
  @override
  Future btcScenariosListApi(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.scenarioList, request);
      BtcScenariosListResponseModel responseModel = btcScenariosListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future newBTCScenariosApi(BuildContext context, FormData formData) async {
    try{
      Response? response = await RestClient.postForm(context, ApiEndPoints.newScenario, formData);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future editBTCScenariosApi(BuildContext context, FormData formData) async {
    try{
      Response? response = await RestClient.postForm(context, ApiEndPoints.editScenario, formData);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }
}