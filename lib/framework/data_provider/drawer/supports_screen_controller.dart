import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/common/model/country_list_response_model.dart';
import '../../repository/support/contract/support_repository.dart';
import '../../repository/support/repository/support_repository_builder.dart';


class SupportsScreenController extends ChangeNotifier {
  String strName = "";
  String strNameError = "";
  CountryData? countryData;
  String strMobileNumber = "";
  String strMobileNumberError = "";
  String strEmail = "";
  String strEmailError = "";
  String strMessage = "";
  String strMessageError = "";
  bool isValidate = false;

  ///Check Name Validation
  void checkNameValidation(BuildContext context, String value) {
    strName = value;
    strNameError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strNameError = getLocalValue("Key_PleaseEnterName");
    }

    checkValidation();
    notifyListeners();
  }

  void updateSelectedCode(CountryData code) {
    countryData = code;
    checkValidation();
    notifyListeners();
  }

  ///Check Mobile number validation
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

  ///Check Email Validation
  void checkEmailValidation(BuildContext context, String value) {
    strEmail = value;
    strEmailError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strEmailError = getLocalValue("Key_PleaseEnterEmailAddress");
    } else if (!isEmailValid(value)) {
      strEmailError = getLocalValue("Key_EmailIsInvalid");
    }
    checkValidation();
    notifyListeners();
  }

  ///Check Message validation
  void checkMessageValidation(BuildContext context, String value) {
    strMessage = value;
    strMessageError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");

    if (removeWhiteSpace.isEmpty) {
      strMessageError = getLocalValue("Key_PleaseEnterMessage");
    }
    checkValidation();
    notifyListeners();
  }

  void checkValidation() {
    isValidate = (strName != "" &&
        strNameError == "" &&
        countryData != null &&
        strMobileNumber != "" &&
        strMobileNumberError == "" &&
        strEmail != "" &&
        strEmailError == "" &&
        strMessage != "" &&
        strMessageError == "");
  }

  void clearProvider() {
    isValidate = false;
    strName = "";
    strNameError = "";
    strMobileNumber = "";
    strMobileNumberError = "";
    strEmail = "";
    strEmailError = "";
    strMessage = "";
    strMessageError = "";
    countryData = null;

    isLoading = false;
    isError = false;

    supportResponseModel = null;

    notifyListeners();
  }

  ///------------------------------Api Properties-----------------------------///
  bool isLoading = false;
  bool isError = false;

  ///Update Is Loading
  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  ///Update Is Error
  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  List<CountryData> arrCountry = [];

  void fillCountryList(List<CountryData>? list) {
    arrCountry = list ?? [];
    notifyListeners();
  }

  final SupportRepository _supportRepository =
      SupportRepositoryBuilder.repository();

  CommonResponseModel? supportResponseModel;

  ///Support Api
  Future<void> supportApi(BuildContext context, String userId) async {
    supportResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> _request = {
      "user_id": userId,
      "name": strName,
      "email": strEmail,
      "country_id": countryData?.id ?? "",
      "mobile_number": strMobileNumber,
      "message": strMessage
    };

    ApiResult apiResult =
        await _supportRepository.supportApi(context, _request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      supportResponseModel = data as CommonResponseModel;

      if (supportResponseModel?.status == ApiEndPoints.apiStatus_200) {
      } else {
        updateIsError(true);
        showMessageDialog(context, supportResponseModel?.message ?? "", null);
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
