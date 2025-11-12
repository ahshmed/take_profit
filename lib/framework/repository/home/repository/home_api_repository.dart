import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../contract/home_repository.dart';
import '../model/home_recommender_details_response_model.dart';
import '../model/recommender_details_response_model.dart';
import '../model/recommender_list_response_model.dart';
import '../model/trending_list_response_model.dart';


class HomeApiRepository implements HomeRepository {
  ///Trending List Api
  @override
  Future trendingListApi(
      BuildContext context, Map<String, dynamic> request) async {
    try {
      Response? response = await RestClient.postData(
          context, ApiEndPoints.trendingListApi, request);
      TrendingListResponseModel responseModel =
          trendingListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  ///Recommender detail Api
  @override
  Future recommenderDetailApi(
      BuildContext context, Map<String, dynamic> request) async {
    try {
      Response? response = await RestClient.postData(
          context, ApiEndPoints.recommenderDetailApi, request);
      RecommenderDetailResponseModel responseModel =
          recommenderDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  ///Recommender List Api
  @override
  Future recommenderListApi(
      BuildContext context, Map<String, dynamic> request) async {
    try {
      Response? response = await RestClient.postData(
          context, ApiEndPoints.recommenderListApi, request);
      RecommenderListResponseModel responseModel =
          recommenderListResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Home Recommender Details Api
  @override
  Future homeRecommenderDetailsApi(BuildContext context) async {
    try {
      Response? response = await RestClient.getData(
          context, ApiEndPoints.homeRecommenderDetails);
      HomeRecommenderDetailsResponseModel responseModel =
          homeRecommenderDetailsResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }
}
