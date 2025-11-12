import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../contract/payment_repository.dart';
import '../model/paymet_response_model.dart';


class PaymentApiRepository extends PaymentRepository{
  @override
  Future paymentForRequestAnalysisAPI(BuildContext context, Map<String, dynamic> req) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.initiatePaymentForRequestAnalysis, req);
      PaymentResponseModel responseModel = paymentResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future paymentForSubscriptionAPI(BuildContext context, Map<String, dynamic> req) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.initiatePaymentForSubscription, req);
      PaymentResponseModel responseModel = paymentResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

}