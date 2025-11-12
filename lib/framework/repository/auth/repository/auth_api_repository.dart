

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../../common/model/common_response_model.dart';
import '../contract/auth_repository.dart';
import '../model/forgot_password_response_model.dart';
import '../model/login_response_model.dart';
import '../model/signup_response_model.dart';
import '../model/switch_account_response_model.dart';
import '../model/verify_otp_response_model.dart';


class AuthApiRepository implements AuthRepository{

  ///login API
  @override
  Future loginApi(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.login, request);
      LoginResponseModel responseModel = loginResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }
  
  


  /// Forgot Password Api
  @override
  Future forgotPasswordApi(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.forgotPassword, request);
      ForgotPasswordResponseModel responseModel = forgotPasswordResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }


  ///logout Api
  @override
  Future logoutApi(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.logout, request);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }


  /// Reset Password Api
  @override
  Future resetPasswordApi(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.resetPassword, request);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Signup Api
  @override
  Future signupApi(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.signup, request);
      SignupResponseModel responseModel = signupResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  /// Update Device Token
  @override
  Future updateDeviceTokenApi(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.updateDeviceToken, request);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }


  @override
  Future socialLoginAPI(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.socialLogin, request);
      LoginResponseModel responseModel = loginResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future resendOTPApi(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.resendOTP, request);
      CommonResponseModel responseModel = commonResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future verifyOTPApi(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.verifyOTP, request);
      VerifyOtpResponseModel responseModel = verifyOtpResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future completeProfileApi(BuildContext context, Map<String, dynamic> request) async {
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.completeProfile, request);
      LoginResponseModel responseModel = loginResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  ///Switch account Api
  @override
  Future switchAccountApi(BuildContext context, Map<String, dynamic> request) async{
    try{
      Response? response = await RestClient.postData(context, ApiEndPoints.switchAccount, request);
      SwitchAccountResponseModel responseModel = switchAccountResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    }
    catch (err){
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

}