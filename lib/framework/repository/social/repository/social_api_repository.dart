import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../../common/model/common_response_model.dart';
import '../contract/social_repository.dart';
import '../model/social_list_response_model.dart';



class SocialApiRepository implements SocialRepository {

  @override
  Future socialListApi(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.socialList, request);
      SocialListResponseModel responseModel = socialListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }


  @override
  Future addNewSocialApi(BuildContext context, FormData request) async{
    try{
      Response? response = await RestClient.postForm(context, ApiEndPoints.addNewSocialApi, request);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future editSocialApi(BuildContext context, FormData request) async{
    try{
      Response? response = await RestClient.postForm(context, ApiEndPoints.editSocialApi, request);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

}
