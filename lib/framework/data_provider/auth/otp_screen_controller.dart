import 'package:flutter/material.dart';
import 'package:take_profit/framework/repository/auth/repository/auth_api_repository.dart';
import 'package:take_profit/utils/apis/network_exceptions.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/const.dart';
import '../../repository/auth/contract/auth_repository.dart';
import '../../repository/auth/model/verify_otp_response_model.dart';
import '../../repository/auth/repository/auth_repository_builder.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/profile_details_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';


class OTPScreenController extends ChangeNotifier {
  String strOTP = "";
  bool isValidate = false;
  bool isWrongOTP = false;

  void checkOTPValidation(BuildContext context, String value) {
    strOTP = value;
    if (strOTP.length == otpLength) {
      isValidate = true;
    } else {
      isValidate = false;
    }

    notifyListeners();
  }

  ///Clear Provider
  void clearProvider() {
    strOTP = "";
    isValidate = false;
  }

  /// ---------------------------- Api Integration ---------------------------------///

  bool isLoading = false;
  bool isError = false;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  final AuthApiRepository _authRepository = AuthRepositoryBuilder.repository();

  VerifyOtpResponseModel? verifyOtpResponseModel;

  ///verify OTP Api
  Future<void> verifyOTPApi(
      BuildContext context, String? userId, String phoneNumber) async {
    verifyOtpResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "otp": strOTP,
      "user_id": userId,
      "mobile_number": phoneNumber
    };

    ApiResult apiResult = await _authRepository.verifyOTPApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      verifyOtpResponseModel = data as VerifyOtpResponseModel;

      if (verifyOtpResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        saveLocalData(KEY_USER_STATUS, verifyOtpResponseModel?.data?.userType);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  CommonResponseModel? resendOtpResponseModel;

  ///Resend OTP Api
  Future<void> resendOTPApi(
      BuildContext context, String phoneNumber, String countryId) async {
    resendOtpResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "country_id": countryId,
      "mobile_number": phoneNumber
    };

    ApiResult apiResult = await _authRepository.resendOTPApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      resendOtpResponseModel = data as CommonResponseModel;

      if (resendOtpResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        // saveLocalData(KEY_USER_DATA, loginResponseModel?.data);
      } else {
        showMessageDialog(
            context, resendOtpResponseModel?.message ?? "", () {});
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  final ProfileRepository _profileRepository =
      ProfileRepositoryBuilder.repository();

  ProfileDetailResponseModel? verifyEmailOtpResponseModel;

  ///verify Email OTP Api
  Future<void> verifyEmailOTPApi(BuildContext context, String email) async {
    verifyOtpResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {"otp": strOTP, "email": email};

    ApiResult apiResult =
        await _profileRepository.verifyEmailAddressAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      verifyEmailOtpResponseModel = data as ProfileDetailResponseModel;

      if (verifyEmailOtpResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        saveLocalData(
            KEY_USER_STATUS, verifyEmailOtpResponseModel?.data?.userType);
      } else {
        showMessageDialog(
            context, verifyEmailOtpResponseModel?.message ?? "", () {});
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  CommonResponseModel? resendEmailOtpResponseModel;

  ///Resend Email OTP Api
  Future<void> resendEmailOTPApi(BuildContext context, String email) async {
    resendEmailOtpResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {"email": email};

    ApiResult apiResult =
        await _profileRepository.resendEmailOTPAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      resendEmailOtpResponseModel = data as CommonResponseModel;

      if (resendEmailOtpResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        // saveLocalData(KEY_USER_DATA, loginResponseModel?.data);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  ProfileDetailResponseModel? updateMobileResponseModel;

  ///Verify Update Mobile
  Future<void> verifyUpdateMobileApi(
      BuildContext context, String mobileNumber, String countryId) async {
    updateMobileResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "otp": strOTP,
      "mobile_number": mobileNumber,
      "country_id": countryId,
    };

    ApiResult apiResult =
        await _profileRepository.verifyMobileNumberAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      updateMobileResponseModel = data as ProfileDetailResponseModel;

      if (updateMobileResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }
}
