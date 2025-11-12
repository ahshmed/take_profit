
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../../common/model/common_response_model.dart';
import '../contract/request_analysis_repository.dart';
import '../model/new_request_analysis_response_model.dart';
import '../model/request_analysis_details_response_model.dart';
import '../model/request_analysis_list_resopnse_model.dart';


class RequestAnalysisApiRepository extends RequestAnalysisRepository{



  @override
  Future getRequestAnalysisListAPI(BuildContext context, Map<String, dynamic> requestData) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.requestAnalysisList, requestData);
      RequestAnalysisListResponseModel responseModel = requestAnalysisListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future newRequestAnalysisAPI(BuildContext context, FormData formData) async{
    try{
      Response? response = await RestClient.postForm(context, ApiEndPoints.newRequestAnalysis, formData);
      NewRequestAnalysisResponseModel responseModel = newRequestAnalysisResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future completeRequestAnalysis(BuildContext context, Map<String, dynamic> requestData) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.completeRequestAnalysis, requestData);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future requestAnalysisDetails(BuildContext context, Map<String, dynamic> requestData) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.requestAnalysisDetails, requestData);
      RequestAnalysisDetailsResponseModel responseModel = requestAnalysisDetailsResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }


}