import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:take_profit/framework/repository/auth/repository/auth_api_repository.dart';
import '../../../ui/auth/sign_in_screen.dart';
import '../../../ui/auth/sign_up_screen.dart';
import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/extension/string_extension.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../../utils/sliderightroute.dart';
import '../../repository/auth/model/signup_response_model.dart';
import '../../repository/auth/repository/auth_repository_builder.dart';
import '../../repository/common/model/country_list_response_model.dart';

class SignUpScreenController extends ChangeNotifier {
  String strTraderName = "";
  String strTraderNameError = "";
  String strMobileNumber = "";
  String strMobileNumberError = "";
  String strEmail = "";
  String strEmailError = "";
  String strNewPassword = "";
  String strNewPasswordError = "";
  String strConfirmPassword = "";
  String strConfirmPasswordError = "";
  bool isValidate = false;
  CountryData? countryData;
  List<CountryData> arrCountry = [];
  bool isNewPasswordObscure = true;
  bool isConfirmPasswordObscure = true;
  bool isChecked = false;
  String language = getAppLanguage();

  void updateSelectedCode(CountryData code) {
    countryData = code;
    checkValidation();
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

  void updateTermsAndConditionStatus() {
    isChecked = !isChecked;
    checkValidation();
    notifyListeners();
  }

  ///Check Trader Name Validation
  void checkTraderNameValidation(BuildContext context, String value) {
    strTraderName = value;
    strTraderNameError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strTraderNameError = getLocalValue("Key_PleaseEnterName");
    }

    checkValidation();
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

  /// NEW: Check Email Validation
  void checkEmailValidation(BuildContext context, String value) {
    strEmail = value;
    strEmailError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strEmailError = getLocalValue("Key_PleaseEnterEmailAddress");
    } else if (!value.isEmailValid()) {
      strEmailError = getLocalValue("Key_EmailIsInvalid");
    }

    checkValidation();
    notifyListeners();
  }

  ///Check New Password validation
  checkNewPasswordValidation(BuildContext context, String value) {
    strNewPassword = value;
    strNewPasswordError = "";

    strNewPasswordError =
        validatePassword(value, forNewPass: true, isConPass: false) ?? "";

    if (strConfirmPassword.isNotEmpty && strConfirmPassword != value) {
      strConfirmPasswordError = getLocalValue("Key_PasswordDoesNotMatch");
    } else {
      strConfirmPasswordError = "";
    }
    checkValidation();
    notifyListeners();
  }

  ///Check Confirm Password validation
  checkConfirmPasswordValidation(BuildContext context, String value) {
    strConfirmPassword = value;
    strConfirmPasswordError = "";

    strConfirmPasswordError =
        validatePassword(value, forNewPass: false, isConPass: true) ?? "";
    if (strNewPassword.isNotEmpty && strNewPassword != value) {
      strConfirmPasswordError = getLocalValue("Key_PasswordDoesNotMatch");
    }
    checkValidation();
    notifyListeners();
  }

  void fillCountryList(List<CountryData>? list) {
    arrCountry = list ?? [];
    notifyListeners();
  }

  void checkValidation() {
    isValidate = (strTraderName != "" &&
        strTraderNameError == "" &&
        strEmail != "" &&
        strEmailError == "" &&
        strNewPassword != "" &&
        strNewPasswordError == "" &&
        strConfirmPassword != "" &&
        strConfirmPasswordError == "" &&
        isChecked
        //&& countryData != null
        );
  }

  void clearProvider() {
    isValidate = false;
    strTraderName = "";
    strTraderNameError = "";
    strMobileNumber = "";
    strMobileNumberError = "";
    strEmail = "";
    strEmailError = "";
    strNewPassword = "";
    strNewPasswordError = "";
    strConfirmPassword = "";
    strConfirmPasswordError = "";
    countryData = null;
    isNewPasswordObscure = true;
    isConfirmPasswordObscure = true;
    isChecked = false;
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

  SignupResponseModel? signupResponseModel;

  ///Sign Up API
  Future<void> signUpApi(BuildContext context) async {
    signupResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "user_type": trader,
      "name": strTraderName,
      "email": strEmail,
      // "country_id": countryData?.id,
      // "mobile_number": strMobileNumber,
      "password": strNewPassword,
      "device_type": getDeviceType(),
      "device_token": getDeviceFCMToken()
    };

    ApiResult apiResult = await _authRepository.signupApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      signupResponseModel = data as SignupResponseModel;

      if (signupResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(context, signupResponseModel?.message ?? "", () {
          if (signupResponseModel?.status == ApiEndPoints.apiStatus_201) {
            Route route = SlideRightPageRoute(
                builder: (context) => SignInScreen(
                       getUserStatus(),
                          strEmail,
                      //mobileNumber: strMobileNumber,
                    ),
                settings: const RouteSettings());
            Navigator.pushAndRemoveUntil(context, route, (route) => true);
          }
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

  Future<void> updateLanguage(String lang, BuildContext context) async {
    language = lang;
    notifyListeners();
    await saveLocalData(KEY_APP_LANGUAGE, lang);
    await context.setLocale(Locale(lang));
    Route route = SlideRightPageRoute(
        builder: (context) => const SignUpScreen(isRecommender: false),
        settings: const RouteSettings());
    Navigator.of(context).pushReplacement(route);
  }
}
