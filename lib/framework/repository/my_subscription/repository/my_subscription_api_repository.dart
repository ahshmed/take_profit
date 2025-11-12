import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../../common/model/common_response_model.dart';
import '../contract/my_subscription_repository.dart';
import '../model/recommender_subscription_packages_response_model.dart';
import '../model/revenue_chart_response_model.dart';
import '../model/subscription_list_response_model.dart';


class MySubscriptionApiRepository extends MySubscriptionRepository
{
  ///Subscription List API
  @override
  Future subscriptionListAPI(BuildContext context, int pageNo) async{
    try{
      Response? response = await RestClient.getData(context, ApiEndPoints.subscriptionList(pageNo));
      SubscriptionListResponseModel responseModel = subscriptionListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  ///Cancel Subscription API
  @override
  Future cancelSubscriptionAPI(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.cancelSubscription, request);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  ///Recommender Subscription Packages
  @override
  Future recommenderSubscriptionPackagesAPI(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.recommenderSubscriptionPackages, request);
      GetRecommenderSubscriptionPackagesResponseModel responseModel = getRecommenderSubscriptionPackagesResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }


  ///Revenue Chart API
  @override
  Future revenueChartAPI(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.revenue, request);
      RevenueChartResponseModel responseModel = revenueChartResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

}