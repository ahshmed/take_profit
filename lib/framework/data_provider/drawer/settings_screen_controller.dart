import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/update_setting_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';


class SettingsScreenController extends ChangeNotifier {
  String isPushNotificationStatus = "0";
  String isEmailNotificationStatus = "0";
  String isSMSNotificationStatus = "0";
  String isRequestAnalysisStatus = "0";

  String strAmount = "";

  void updateAmountWidget(String value) {
    strAmount = value;
    notifyListeners();
  }

  ///Update Push Notification
  void updatePushNotificationStatus(String val) {
    isPushNotificationStatus = val;
    notifyListeners();
  }

  /// request Analysis Status
  void updateRequestAnalysisStatus(String val) {
    isRequestAnalysisStatus = val;
    notifyListeners();
  }

  ///Update Email Notification
  void updateEmailNotificationStatus(String val) {
    isEmailNotificationStatus = val;
    notifyListeners();
  }

  ///Update SMS Notification
  void updateSMSNotificationStatus(String val) {
    isSMSNotificationStatus = val;
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

  final ProfileRepository _profileRepository =
      ProfileRepositoryBuilder.repository();

  UpdateSettingResponseModel? updateSettingResponseModel;

  ///Update Settings  Api
  Future<void> updateSettingsApi(BuildContext context,
      {bool isLanguageChange = false,
      bool isPushNotification = false,
      bool isEmailNotification = false,
      bool isSmsNotification = false,
      bool isRequestAnalysis = false,
      bool? isEngEnableToggle}) async {
    updateSettingResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    /// language change req
    Map<String, dynamic> languageChangeReq = {
      "language": isEngEnableToggle == true ? "en" : "ar",
    };

    /// push notification change req
    Map<String, dynamic> requestForPushNotification = {
      "enable_notification": isPushNotificationStatus,
    };

    /// email Notification change req
    Map<String, dynamic> requestForEmailNotification = {
      "enable_email": isEmailNotificationStatus,
    };

    /// sms Notification change req
    Map<String, dynamic> requestForSmsNotification = {
      "enable_sms": isSMSNotificationStatus,
    };

    /// request analysis Change red
    Map<String, dynamic> requestAnalysisChangeReq = {
      "enable_request_analysis": isRequestAnalysisStatus,
      "request_analysis_amount":
          isRequestAnalysisStatus == "1" ? strAmount : "0"
    };

    /// Request analysis change for false
    Map<String, dynamic> requestAnalysisChangeReqWithoutAmountForFalse = {
      "enable_request_analysis": isRequestAnalysisStatus,
    };

    /// Empty Request
    Map<String, dynamic> emptyReq = {};

    ApiResult apiResult = await _profileRepository.updateSettingsAPI(
        context,
        isLanguageChange
            ? languageChangeReq
            : isPushNotification
                ? requestForPushNotification
                : isEmailNotification
                    ? requestForEmailNotification
                    : isSmsNotification
                        ? requestForSmsNotification
                        : isRequestAnalysis
                            ? isRequestAnalysisStatus == "0"
                                ? requestAnalysisChangeReqWithoutAmountForFalse
                                : requestAnalysisChangeReq
                            : emptyReq);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      updateSettingResponseModel = data as UpdateSettingResponseModel;

      if (updateSettingResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, updateSettingResponseModel?.message ?? "", () {});
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  CommonResponseModel? deleteAccountResponseModel;

  ///Delete Account Api
  Future<void> deleteAccountApi(BuildContext context) async {
    deleteAccountResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    ApiResult apiResult = await _profileRepository.deleteAccountAPI(context);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      deleteAccountResponseModel = data as CommonResponseModel;

      if (deleteAccountResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, deleteAccountResponseModel?.message ?? "", () {});
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
