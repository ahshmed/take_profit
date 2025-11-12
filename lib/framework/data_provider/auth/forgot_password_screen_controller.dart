import 'package:flutter/material.dart';
import 'package:take_profit/framework/repository/auth/repository/auth_api_repository.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/auth/model/forgot_password_response_model.dart';
import '../../repository/auth/repository/auth_repository_builder.dart';
import '../../repository/common/model/country_list_response_model.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/profile_details_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';


class ForgotPasswordScreenController extends ChangeNotifier {
  String strMobileNumber = "";
  String strMobileNumberError = "";
  bool isValidate = false;
  CountryData? countryData;
  List<CountryData> codeList = [];

  void updateSelectedCode(CountryData code) {
    countryData = code;
    checkValidation();
    notifyListeners();
  }

  void fillCountryList(List<CountryData>? list) {
    codeList = list ?? [];
    notifyListeners();
  }

  ///Check Username validation
  void checkMobileNumberValidation(BuildContext context, String value) {
    strMobileNumber = value;
    strMobileNumberError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strMobileNumberError = getLocalValue("Key_PleaseEnterMobileNumber");
    } else if (!isPhoneNumberValid(value)) {
      strMobileNumberError = getLocalValue("Key_MobileNumberIsInvalid");
    }

    checkValidation();
    notifyListeners();
  }

  void checkValidation() {
    isValidate = (strMobileNumber != "" &&
        strMobileNumberError == "" &&
        countryData != null);
  }

  void clearProvider() {
    isValidate = false;
    strMobileNumber = "";
    strMobileNumberError = "";
    countryData = null;
    codeList = [];
    notifyListeners();
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

  ForgotPasswordResponseModel? forgotPasswordResponseModel;

  ///Forgot Password API
  Future<void> forgotPasswordApi(BuildContext context) async {
    forgotPasswordResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "user_type": getUserStatus(),
      "country_id": countryData?.id,
      "mobile_number": strMobileNumber
    };

    ApiResult apiResult =
        await _authRepository.forgotPasswordApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      forgotPasswordResponseModel = data as ForgotPasswordResponseModel;

      if (forgotPasswordResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        saveLocalData(
            KEY_USER_STATUS, forgotPasswordResponseModel?.data?.userType);
      } else {
        updateIsError(true);
        showMessageDialog(
            context, forgotPasswordResponseModel?.message ?? "", () {});
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

  ProfileDetailResponseModel? updateMobileResponseModel;

  ///Update Mobile Api
  Future<void> updateMobileApi(BuildContext context) async {
    updateMobileResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "country_id": countryData?.id,
      "mobile_number": strMobileNumber
    };

    ApiResult apiResult =
        await _profileRepository.updateMobileAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      updateMobileResponseModel = data as ProfileDetailResponseModel;

      if (updateMobileResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        if (updateMobileResponseModel?.status ==
            ApiEndPoints.apiStatus_201.toString()) {
          showMessageDialog(
              context, updateMobileResponseModel?.message ?? "", () {});
        }
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
