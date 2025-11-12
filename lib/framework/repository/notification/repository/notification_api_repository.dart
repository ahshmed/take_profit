
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../../common/model/common_response_model.dart';
import '../contract/notification_repository.dart';
import '../model/notificaiton_count_response_model.dart';
import '../model/notification_list_response_model.dart';


class NotificationApiRepository implements NotificationRepository  {

  @override
  Future notificationListApi(BuildContext context,Map<String, dynamic> req) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.notificationList, req);
      NotificationListResponseModel responseModel = notificationListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future notificationDeleteAPI(BuildContext context, Map<String, dynamic> req) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.notificationDelete, req);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future notificationCountApi(BuildContext context) async {
    try{
      Response? response = await RestClient.getData(context, ApiEndPoints.notificationCount);
      NotificationCountResponseModel responseModel = notificationCountResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

}