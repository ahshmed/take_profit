import 'package:flutter/material.dart';
import 'package:take_profit/framework/repository/auth/repository/auth_api_repository.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/auth/repository/auth_repository_builder.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/change_password_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';


class CreatePasswordScreenController extends ChangeNotifier {
  String strCurrentPassword = "";
  String strCurrentPasswordError = "";
  String strNewPassword = "";
  String strNewPasswordError = "";
  String strConfirmPassword = "";
  String strConfirmPasswordError = "";
  bool isValidate = false;
  bool isCurrentPasswordObscure = true;
  bool isNewPasswordObscure = true;
  bool isConfirmPasswordObscure = true;

  void updateIsCurrentPasswordObscure() {
    isCurrentPasswordObscure = !isCurrentPasswordObscure;
    notifyListeners();
  }

  void updateIsNewPasswordObscure() {
    isNewPasswordObscure = !isNewPasswordObscure;
    notifyListeners();
  }

  void updateIsConfirmPasswordObscure() {
    isConfirmPasswordObscure = !isConfirmPasswordObscure;
    notifyListeners();
  }

  ///Check Current Password validation
  void checkCurrentPasswordValidation(
      BuildContext context, String value, bool isFromProfile) {
    strCurrentPassword = value;
    strCurrentPasswordError = "";
    strCurrentPasswordError = validatePassword(value,
            forNewPass: false, isConPass: false, currentPass: true) ??
        "";

    if (strNewPassword != "" && strNewPassword == value) {
      strNewPasswordError =
          getLocalValue("Key_CurrentPasswordAndNewPasswordMustBeDifferent");
    }
    checkValidation(isFromProfile);
    notifyListeners();
  }

  ///Check Password validation
  void checkNewPasswordValidation(
      BuildContext context, String value, bool isFromProfile) {
    strNewPassword = value;
    strNewPasswordError = "";

    strNewPasswordError =
        validatePassword(value, forNewPass: true, isConPass: false) ?? "";

    if (isFromProfile) {
      if (strCurrentPassword != "" && strCurrentPassword == value) {
        strNewPasswordError =
            getLocalValue("Key_CurrentPasswordAndNewPasswordMustBeDifferent");
      } else if (strConfirmPassword.isNotEmpty && strConfirmPassword != value) {
        strConfirmPasswordError = getLocalValue("Key_PasswordDoesNotMatch");
      }
    } else {
      if (strConfirmPassword.isNotEmpty && strConfirmPassword != value) {
        strNewPasswordError = getLocalValue("Key_PasswordDoesNotMatch");
      }
    }

    checkValidation(isFromProfile);
    notifyListeners();
  }

  ///Check Confirm Password validation
  void checkConfirmPasswordValidation(
      BuildContext context, String value, bool isFromProfile) {
    strConfirmPassword = value;
    strConfirmPasswordError = "";

    strConfirmPasswordError =
        validatePassword(value, forNewPass: false, isConPass: true) ?? "";
    if (strNewPassword.isNotEmpty && strNewPassword != value) {
      strConfirmPasswordError = getLocalValue("Key_PasswordDoesNotMatch");
    }
    checkValidation(isFromProfile);
    notifyListeners();
  }

  void checkValidation(bool isFromProfile) {
    isValidate = isFromProfile
        ? (strNewPassword != "" &&
            strNewPasswordError == "" &&
            strConfirmPassword != "" &&
            strConfirmPasswordError == "" &&
            strCurrentPassword != "" &&
            strConfirmPasswordError == "")
        : (strNewPassword != "" &&
            strNewPasswordError == "" &&
            strConfirmPassword != "" &&
            strConfirmPasswordError == "");
  }

  void clearProvider() {
    isValidate = false;
    strNewPassword = "";
    strNewPasswordError = "";
    strConfirmPassword = "";
    strConfirmPasswordError = "";
    strCurrentPassword = "";
    strCurrentPasswordError = "";
    isNewPasswordObscure = true;
    isConfirmPasswordObscure = true;
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

  CommonResponseModel? resetPasswordResponseModel;

  ///Reset Password API
  Future<void> resetPasswordApi(BuildContext context, String userID) async {
    resetPasswordResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "user_id": userID,
      "password": strNewPassword,
      "password_confirmation": strConfirmPassword
    };

    ApiResult apiResult =
        await _authRepository.resetPasswordApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      resetPasswordResponseModel = data as CommonResponseModel;

      if (resetPasswordResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, resetPasswordResponseModel?.message ?? "", () {});
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

  ChangePasswordResponseModel? changePasswordResponseModel;

  ///Change Password API
  Future<void> changePasswordApi(
    BuildContext context,
  ) async {
    changePasswordResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "old_password": strCurrentPassword,
      "new_password": strNewPassword,
      "confirm_password": strConfirmPassword
    };

    ApiResult apiResult =
        await _profileRepository.changePasswordAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      changePasswordResponseModel = data as ChangePasswordResponseModel;

      if (changePasswordResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        showLog("In Else Pase ");
        updateIsError(true);
        showMessageDialog(
            context, changePasswordResponseModel?.message ?? "", () {});
      }
    }, failure: (NetworkExceptions error) {
      showLog("In Error Pase ");
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }
}
