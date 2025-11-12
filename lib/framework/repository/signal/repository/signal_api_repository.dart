import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../../common/model/common_response_model.dart';
import '../contract/signal_repository.dart';
import '../model/all_signal_list_response_model.dart';
import '../model/signal_details_response_model.dart';
import '../model/signal_list_response_model.dart';


class SignalApiRepository implements SignalRepository {
  /// create signal api
  @override
  Future createSignalApi(BuildContext context, FormData request) async {
    try {
      Response? response = await RestClient.postForm(
          context, ApiEndPoints.createSignalApi, request);
      CommonResponseModel responseModel =
          commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Signal list api
  @override
  Future signalListApi(
      BuildContext context, Map<String, dynamic> request) async {
    try {
      Response? response = await RestClient.postData(
          context, ApiEndPoints.signalListApi, request);
      SignalListResponseModel responseModel =
          signalListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Close signal api
  @override
  Future closeSignalApi(
      BuildContext context, Map<String, dynamic> request) async {
    try {
      Response? response = await RestClient.postData(
          context, ApiEndPoints.closeSignalApi, request);
      CommonResponseModel responseModel =
          commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Edit signal api
  @override
  Future editSignalApi(BuildContext context, FormData request) async {
    try {
      Response? response = await RestClient.postForm(
          context, ApiEndPoints.editSignalApi, request);
      CommonResponseModel responseModel =
          commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Signal Details
  @override
  Future signalDetailsAPI(
      BuildContext context, Map<String, dynamic> request) async {
    try {
      Response? response = await RestClient.postData(
          context, ApiEndPoints.signalDetails, request);
      SignalDetailsResponseModel responseModel =
          signalDetailsResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// All Signal list api
  @override
  Future allSignalListAPI(
      BuildContext context, Map<String, dynamic> request) async {
    try {
      Response? response = await RestClient.postDataForCurrency(
          context, ApiEndPoints.allSignalListApi, request);
      AllSignalListResponseModel responseModel =
          allSignalListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// close All Signal api
  @override
  Future closedAllSignalApi(BuildContext context) async {
    try {
      Response? response =
          await RestClient.getData(context, ApiEndPoints.closeAllSignal);
      CommonResponseModel responseModel =
          commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future enableSignalNotification(BuildContext context, Map<String, dynamic> request) async {
    try {
      Response? response = await RestClient.postData(
          context, ApiEndPoints.enableSignalNotification, request);
      CommonResponseModel responseModel =
      commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }
}
