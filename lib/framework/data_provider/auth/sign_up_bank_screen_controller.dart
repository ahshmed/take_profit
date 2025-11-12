import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:take_profit/framework/repository/auth/repository/auth_api_repository.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/auth/contract/auth_repository.dart';
import '../../repository/auth/model/login_response_model.dart';
import '../../repository/auth/repository/auth_repository_builder.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/profile_details_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';
import 'duration_controller.dart';


class SignUpBankDetailsScreenController extends ChangeNotifier {
  String strBankName = "";
  String strBankNameError = "";
  String strNameAsPerAcc = "";
  String strNameAsPerAccError = "";
  String strAccNumber = "";
  String strAccNumberError = "";
  String strIBANCode = "";
  String strIBANCodeError = "";
  bool isValidate = false;

  void checkValidation() {


    isValidate = (strBankName != "" &&
        strBankNameError == "" &&
        strNameAsPerAcc != "" &&
        strNameAsPerAccError == "" &&
        strAccNumber != "" &&
        strAccNumberError == "" &&
        strIBANCode != "" &&
        strIBANCodeError == "");

    print('strBankName $strBankName');
    print('strBankNameError $strBankNameError');
    print('strNameAsPerAcc $strNameAsPerAcc');
    print('strNameAsPerAccError $strNameAsPerAccError');
    print('strAccNumber $strAccNumber');
    print('strAccNumberError $strAccNumberError');
    print('strIBANCode $strIBANCode');
    print('strIBANCodeError $strIBANCodeError');
    print('isValidateBankDetails $isValidate');
    notifyListeners();
  }

  void clearProvider() {
    isValidate = false;
    strBankName = "";
    strBankNameError = "";
    strNameAsPerAcc = "";
    strNameAsPerAccError = "";
    strAccNumber = "";
    strAccNumberError = "";
    strIBANCode = "";
    strIBANCodeError = "";
    notifyListeners();
  }

  ///Check BankName validation
  void checkBankNameValidation(BuildContext context, String value) {
    strBankName = value;
    strBankNameError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strBankNameError = getLocalValue("Key_PleaseEnterBankName");
    } else if (removeWhiteSpace.length < 3) {
      strBankNameError = getLocalValue("Key_BankNameLengthValidation");
    }

    checkValidation();
    notifyListeners();
  }

  ///Check Name As Per Acc validation
  void checkNameAsPerAccValidation(BuildContext context, String value) {
    strNameAsPerAcc = value;
    strNameAsPerAccError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strNameAsPerAccError = getLocalValue("Key_PleaseEnterNameAsPerAcc");
    } else if (removeWhiteSpace.length < 3) {
      strNameAsPerAccError = getLocalValue("Key_NameRangeValidation");
    }

    checkValidation();
    notifyListeners();
  }

  ///Check Acc Number validation
  void checkAccNumberValidation(BuildContext context, String value) {
    strAccNumber = value;
    strAccNumberError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strAccNumberError = getLocalValue("Key_PleaseEnterAccNumber");
    } else if (!isAccountNumberValid(value)) {
      strAccNumberError = getLocalValue("Key_AccountNumberRangeValidation");
    }
    checkValidation();
    notifyListeners();
  }

  ///Check IBAN Code validation
  void checkIBANCodeValidation(BuildContext context, String value) {
    strIBANCode = value;
    strIBANCodeError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strIBANCodeError = getLocalValue("Key_PleaseEnterIBANCode");
      strIBANCodeError = "";
    }
    checkValidation();
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

  LoginResponseModel? completeProfileModel;

  ///Complete Profile  Api
  Future<void> completeProfileApi(
      BuildContext context, String? userId, String? amount,
      {List<String>? currencyList, List<PriceModel>? priceModelList}) async {
    completeProfileModel = null;
    updateIsLoading(true);
    updateIsError(false);
    final List<Map<String, dynamic>> packageData = [];

    for (int i = 0; i < (priceModelList?.length ?? 0); i++) {
      packageData.add({
        "subscription_package_id": priceModelList?[i].subscriptionPackageId,
        "price": priceModelList?[i].price
      });
    }

    Map<String, dynamic> requestForTrader = {
      "user_id": userId,
      "currencies": currencyList,
      "bank_name": strBankName,
      "account_name": strNameAsPerAcc,
      "account_number": strAccNumber,
      "iban_code": strIBANCode,
    };

    Map<String, dynamic> requestForRecommender = {
      "user_id": userId,
      "bank_name": strBankName,
      "account_name": strNameAsPerAcc,
      "account_number": strAccNumber,
      "iban_code": strIBANCode,
      "enable_request_analysis": amount != "" ? "1" : "0",
      "request_analysis_amount": amount,
      "packages": packageData
    };

    Map<String, dynamic> requestForRecommenderWithOutAmount = {
      "user_id": userId,
      "bank_name": strBankName,
      "account_name": strNameAsPerAcc,
      "account_number": strAccNumber,
      "iban_code": strIBANCode,
      "enable_request_analysis": "0",
      "packages": packageData
    };

    ApiResult apiResult = await _authRepository.completeProfileApi(
        context,
        packageData.isEmpty
            ? requestForTrader
            : (amount != "")
                ? requestForRecommender
                : requestForRecommenderWithOutAmount);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      completeProfileModel = data as LoginResponseModel;

      if (completeProfileModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        // saveLocalData(KEY_USER_DATA, loginResponseModel?.data);
        saveLocalData(KEY_USER_ACCESS_TOKEN, completeProfileModel?.data?.token);
        saveLocalData(KEY_USER_STATUS, completeProfileModel?.data?.userType);
      } else {
        updateIsError(true);
        showMessageDialog(context, completeProfileModel?.message ?? "", () {
          Navigator.of(context).pop;
        });
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

  ProfileDetailResponseModel? profileDetailResponseModel;

  ///Update Bank Details Api
  Future<void> updateBankDetailsAPI(BuildContext context) async {
    updateIsLoading(true);
    updateIsError(false);

    FormData formData;

    formData = FormData.fromMap({
      "bank_name": strBankName,
      "account_name": strNameAsPerAcc,
      "account_number": strAccNumber,
      "iban_code": strIBANCode,
    });

    ApiResult apiResult =
        await _profileRepository.updatePersonalDetailAPI(context, formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      profileDetailResponseModel = data as ProfileDetailResponseModel;

      if (profileDetailResponseModel?.status ==
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
