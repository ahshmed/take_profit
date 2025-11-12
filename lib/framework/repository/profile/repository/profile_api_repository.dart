import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../../common/model/common_response_model.dart';
import '../contract/profile_repository.dart';
import '../model/change_password_response_model.dart';
import '../model/profile_details_response_model.dart';
import '../model/update_setting_response_model.dart';


class ProfileApiRepository extends ProfileRepository{

  /// Profile Detail API
  @override
  Future getProfileDetailAPI(BuildContext context) async{
    try{
      Response? response = await RestClient.getData(context, ApiEndPoints.profile);
      ProfileDetailResponseModel responseModel = profileDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future updatePersonalDetailAPI(BuildContext context,FormData formData) async{
    try{
      Response? response = await RestClient.postForm(context, ApiEndPoints.updateProfile, formData);
      ProfileDetailResponseModel responseModel = profileDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future updateEmailAddressAPI(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.updateEmail, request);
      ProfileDetailResponseModel responseModel = profileDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future verifyEmailAddressAPI(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.verifyEmail, request);
      ProfileDetailResponseModel responseModel = profileDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future resendEmailOTPAPI(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.resendEmailOtp, request);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future updateMobileAPI(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.updateMobileNumber, request);
      ProfileDetailResponseModel responseModel = profileDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future verifyMobileNumberAPI(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.verifyMobileNumber, request);
      ProfileDetailResponseModel responseModel = profileDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Change Password
  @override
  Future changePasswordAPI(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.changePassword, request);
      ChangePasswordResponseModel responseModel = changePasswordResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Delete Account
  @override
  Future deleteAccountAPI(BuildContext context) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.deleteAccount, '');
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future updateSettingsAPI(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.updateSettings, request);
      UpdateSettingResponseModel responseModel = updateSettingResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future updateSocialLinksAPI(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.updateProfile, request);
      ProfileDetailResponseModel responseModel = profileDetailResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

}