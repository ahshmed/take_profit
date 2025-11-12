import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/repository/auth/repository/auth_api_repository.dart';
import '../../../ui/auth/otp_screen.dart';
import '../../../ui/auth/sign_in_screen.dart';
import '../../../ui/auth/subscription_amount_screen.dart';
import '../../../ui/drawer/drawer_menu.dart';
import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../../utils/extension/string_extension.dart';
import '../../../utils/sliderightroute.dart';
import '../../../utils/social_manager/apple_login_manager.dart';
import '../../../utils/social_manager/google_login_manager.dart';
import '../../../utils/social_manager/twitter_login_manager.dart';
import '../../repository/auth/contract/auth_repository.dart';
import '../../repository/auth/model/login_response_model.dart';
import '../../repository/auth/model/switch_account_response_model.dart';
import '../../repository/auth/repository/auth_repository_builder.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/common/model/country_list_response_model.dart';
import '../home/home_provider.dart';
import '../profile/profile_provider.dart';

class SignInScreenController extends ChangeNotifier {
  String strMobileNumber = "";
  String strMobileNumberError = "";
  String strEmail = "";
  String strEmailError = "";
  String strPassword = "";
  String strPasswordError = "";
  bool isValidate = false;
  bool isObscure = true;
  CountryData? countryData;
  List<CountryData> arrCountry = [];
  String language = getAppLanguage();

  void updateSelectedCode(CountryData code) {
    countryData = code;
    checkValidation();
    notifyListeners();
  }

  void updateIsObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  Future<void> updateLanguage(String lang, BuildContext context) async {
    language = lang;
    notifyListeners();
    await saveLocalData(KEY_APP_LANGUAGE, lang);
    await context.setLocale(Locale(lang));
    Route route = SlideRightPageRoute(
        builder: (context) => SignInScreen(trader, ""),
        settings: const RouteSettings());
    Navigator.of(context).pushReplacement(route);
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

  ///Check Email validation - CHANGED: from mobile number to email
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

  ///Check Password validation
  checkPasswordValidation(BuildContext context, String value) {
    strPassword = value;
    strPasswordError = "";

    strPasswordError = validatePassword(
          value,
          forNewPass: false,
          isConPass: false,
        ) ??
        "";

    checkValidation();
    notifyListeners();
  }

  void checkValidation() {
    bool isPhoneValid = strMobileNumber != "" && strMobileNumberError == "" && countryData != null;

    bool isEmailValid = strEmail != "" && strEmailError == "";

    // Require EITHER phone OR email, but always require password
    isValidate = ((isPhoneValid || isEmailValid) && // ← Changed to OR condition
        strPassword != "" &&
        strPasswordError == "");
  }

  void fillCountryList(List<CountryData>? list) {
    arrCountry = list ?? [];
    if (arrCountry.isNotEmpty) {
      try {
        // Set Kuwait as the default country if available
        countryData = arrCountry.firstWhere(
          (country) => country.name?.toLowerCase() == "kuwait",
        );
      } catch (e) {
        // If Kuwait is not found, default to the first country in the list
        countryData = arrCountry.first;
      }
    }
    notifyListeners();
  }

  void clearProvider(bool isRemoveCountry) {
    isValidate = false;
    strMobileNumber = "";
    strMobileNumberError = "";
    strEmail = "";
    strEmailError = "";
    strPassword = "";
    strPasswordError = "";
    isObscure = true;
    if (isRemoveCountry) {
      arrCountry.clear();
      countryData = null;
    }
    notifyListeners();
  }

  ///update widget
  updateWidget() {
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

  LoginResponseModel? loginResponseModel;
  LoginResponseModel? socialLoginResponseModel;

  ///Login  Api
  Future<void> loginApi(BuildContext context, WidgetRef ref, {bool isPhoneLogin = true}) async {
    loginResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "user_type": trader,
      "password": strPassword,
      "device_type": getDeviceType(),
      "device_token": getDeviceFCMToken(),
      "country_id": countryData?.id,
    };

    // Add either phone or email based on the toggle
    if (isPhoneLogin) {
      request["mobile_number"] = strMobileNumber;
    } else {
      request["email"] = strEmail;
    }

    ApiResult apiResult = await _authRepository.loginApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      loginResponseModel = data as LoginResponseModel;

      if (loginResponseModel?.status == ApiEndPoints.apiStatus_200.toString()) {
        saveLocalData(KEY_USER_ACCESS_TOKEN, loginResponseModel?.data?.token);
        saveLocalData(KEY_USER_STATUS, loginResponseModel?.data?.userType);
      } else {
        updateIsError(true);
        if (loginResponseModel?.status == ApiEndPoints.apiStatus_201.toString()) {
          showMessageDialog(context, loginResponseModel?.message ?? "", () {});
        } else if (loginResponseModel?.status == ApiEndPoints.apiStatus_202.toString()) {
          saveLocalData(KEY_USER_STATUS, loginResponseModel?.data?.userType);
          showMessageDialog(context, loginResponseModel?.message ?? "", () {
            Route route = SlideRightPageRoute(
                builder: (context) => OTPScreen(
                      mobileNumber: loginResponseModel?.data?.mobileNumber ?? "",
                      email: loginResponseModel?.data?.email ?? "",
                      fromScreen: FromScreen.FromSignIn,
                      userID: loginResponseModel?.data?.id ?? "",
                    ),
                settings: const RouteSettings());
            Navigator.of(context).push(route);
          });
        } else if (loginResponseModel?.status == ApiEndPoints.apiStatus_203.toString()) {
          saveLocalData(KEY_USER_STATUS, loginResponseModel?.data?.userType);
          showMessageDialog(context, loginResponseModel?.message ?? "", () async {
            if (getUserStatus() == recommender) {
              Route route = SlideRightPageRoute(
                  builder: (context) => SubscriptionAmountScreen(
                        isRecommender: (getUserStatus() == recommender) ? true : false,
                        screenName: ScreenName.LoginScreen,
                        userId: loginResponseModel?.data?.id ?? "",
                      ),
                  settings: const RouteSettings());
              Navigator.of(context).push(route);
            } else {
              saveLocalData(KEY_USER_ENTITY_ID, loginResponseModel?.data?.id.toString());
              final dashboardWatch = ref.watch(dashboardProvider);
              dashboardWatch.clearProvider();

              /// For Displaying Profile Data in Drawer
              final profileWatch = ref.watch(profileProvider);
              await profileWatch.profileAPI(context);
              saveLocalData(KEY_USER_STATUS, profileWatch.profileDetailResponseModel?.data?.userType);
              saveLocalData(KEY_USER_ACCESS_TOKEN, loginResponseModel?.data?.token);
              Route route = SlideRightPageRoute(
                  builder: (context) => const DrawerMenu(),
                  settings: const RouteSettings());
              Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
            }
          });
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

  Future<void> apiSocialLogin(BuildContext context, String socialMedia, {
    GoogleDataModel? googleModel,
    AppleDataModel? appleModel,
    WidgetRef? ref,
  }) async {
    socialLoginResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "user_type": trader,
      "social_media": socialMedia,
      "social_id": socialMedia == "google" ? googleModel?.googleId : appleModel?.appleId,
      "email": socialMedia == "google" ? googleModel?.email : appleModel?.email,
      "first_name": socialMedia == "google" ? googleModel?.firstName : appleModel?.firstName,
      "last_name": socialMedia == "google" ? googleModel?.lastName : appleModel?.lastName,
      "device_type": getDeviceType(),
      "device_token": getDeviceFCMToken(),
    };

    ApiResult apiResult = await _authRepository.socialLoginAPI(context, request);

    apiResult.when(
      success: (data) async {
        updateIsLoading(false);
        socialLoginResponseModel = data as LoginResponseModel;
        if (socialLoginResponseModel?.status == ApiEndPoints.apiStatus_200.toString()) {
          final dashboardWatch = ref?.watch(dashboardProvider);
          dashboardWatch?.clearProvider();
          saveLocalData(KEY_USER_STATUS, socialLoginResponseModel?.data?.userType);
          saveIsLogin(isLogin: true);

          saveLocalData(KEY_USER_ENTITY_ID, socialLoginResponseModel?.data?.id.toString());

          final profileWatch = ref?.watch(profileProvider);
          await profileWatch?.profileAPI(context);

          Route route = SlideRightPageRoute(
              builder: (context) => const DrawerMenu(),
              settings: const RouteSettings());
          Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
        } else {
            updateIsError(true);
            showMessageDialog(context, socialLoginResponseModel?.message ?? "", null);
        }
      },
      failure: (NetworkExceptions error) {
        updateIsLoading(false);
        updateIsError(true);
        String errorMsg = NetworkExceptions.getErrorMessage(error);
        showMessageDialog(context, errorMsg, null);
      },
    );
    notifyListeners();
  }

  CommonResponseModel? commonResponseModel;

  /// Update Device Token  Api
  Future<void> updateDeviceTokenApi(BuildContext context) async {
    commonResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "device_token": getDeviceFCMToken(), //getDeviceFCMToken(),
      "device_type": getDeviceType(),
    };

    ApiResult apiResult = await _authRepository.updateDeviceTokenApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModel = data as CommonResponseModel;

      if (commonResponseModel?.status == ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(context, commonResponseModel?.message ?? "", () {});
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  ///logout  Api
  Future<void> logoutApi(BuildContext context) async {
    commonResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "device_token": getDeviceFCMToken(),
    };

    ApiResult apiResult = await _authRepository.logoutApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModel = data as CommonResponseModel;

      if (commonResponseModel?.status == ApiEndPoints.apiStatus_200.toString() ||
          commonResponseModel?.status == ApiEndPoints.apiStatus_401.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(context, commonResponseModel?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, () {
        logoutAction(context);
        Route route = SlideRightPageRoute(
            builder: (context) => SignInScreen(trader, ""),
            settings: const RouteSettings());
        Navigator.pushAndRemoveUntil(context, route, (route) => false);
      });
    });
    notifyListeners();
  }

  ///Switch Account  Api

  SwitchAccountResponseModel? switchAccountResponseModel;

  Future<void> switchAccountApi(BuildContext context, WidgetRef ref) async {
    switchAccountResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {};

    ApiResult apiResult = await _authRepository.switchAccountApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      switchAccountResponseModel = data as SwitchAccountResponseModel;

      if (switchAccountResponseModel?.status == ApiEndPoints.apiStatus_200.toString()) {
        saveLocalData(KEY_USER_STATUS, switchAccountResponseModel?.data?.userType);
        saveLocalData(KEY_USER_ENTITY_ID, switchAccountResponseModel?.data?.id.toString());
        saveLocalData(KEY_USER_ACCESS_TOKEN, switchAccountResponseModel?.data?.token);

        final profileWatch = ref.watch(profileProvider);
        await profileWatch.profileAPI(context);

        final dashboardWatch = ref.watch(dashboardProvider);
        dashboardWatch.clearProvider();

        Route route = SlideRightPageRoute(
            builder: (context) => const DrawerMenu(),
            settings: const RouteSettings());
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
      } else {
        updateIsError(true);
        showMessageDialog(context, switchAccountResponseModel?.message ?? "", null);
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


