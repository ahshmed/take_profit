
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../contract/master_repository.dart';
import '../model/get_subscription_package_list.dart';


class MasterApiRepository implements MasterRepository{
  @override
  Future apiMasterSubscriptionPackageList(BuildContext context, Map<String, dynamic> req) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.subscriptionPackageList, req);
      GetSubscriptionPackageList responseModel = getSubscriptionPackageListFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

}