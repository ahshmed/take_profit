// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import 'package:take_profit/utils/sliderightroute.dart';
import 'package:take_profit/utils/theme_const.dart';
import 'package:take_profit/utils/widgets/common_button.dart';
import 'package:take_profit/utils/widgets/round_button.dart';

import '../ui/auth/helper/get_started_screen.dart';
import '../ui/drawer/drawer_menu.dart';


/// Constant Values
int maxMobileLength = 15;
int otpLength = 6;
int maxEmailLength = 40;
int maxTextLength6 = 6;
int maxPasswordLength = 15;
int maxTextLength30 = 30;
int maxTextLength60 = 40;
int maxAboutUsLength = 200;
int maxPriceLength = 8;
int maxOfferClaimLength = 3;
int maxOfferDiscountLength = 2;
int maxPinCodeLength = 6;
int maxAboutUsLength500 = 4000;
int maxIbanNoLength = 37;
int maxAccountNumberLength = 13;
int maxNameLength = 30;
int searchDurationInMilliSeconds = 750;
int maxDecimalPointsRange = 14;

/// IOS APP Version For InAppPurchase
int appleVersion = 5; //TODO Increase on every ios update
String appPlatform = Platform.isIOS ? "IOS" : "Android";

/// Real Time Pricing Variable
int secondsDelayForRealTimeAPICall = 1000;

/// Active Signal Api Call Duration
int activeSignalTimeAPICall = 1000;

/// Hive Object
var userBox = Hive.box('userBox');

String currency = "KWD";

/// Hive Data Keys
const String KEY_APP_LANGUAGE = "key_application_language";
const String KEY_IS_ONBOARDING_SHOWED = "key_is_onboarding_showed";
const String KEY_USER_DATA = "key_user_data";
const String KEY_USER_ACCESS_TOKEN = 'key_user_access_token';
const String KEY_DEVICE_ID = "key_device_id";
const String KEY_USER_REFRESH_TOKEN = 'key_user_refresh_token';
const String KEY_FCM_DEVICE_TOKEN = 'key_fcm_device_token';
const String KEY_USER_ENTITY_ID = 'key_user_entity_id';
const String KEY_APP_THEME_DARK = 'key_app_theme_dark';
const String KEY_USER_STATUS = 'key_user_status';
const String KEY_USER_LOGIN = 'key_user_login';
const String KEY_USER_IMAGE = 'key_user_image';
const String KEY_SKIP_VERSION = 'key_skip_version';
const String KEY_FIRST_TIME_USER = 'first_time_user';
const String KEY_SELECTED_MARKET = 'selected_market';

/// Twitter Data
const String apikey_twitter = "rNJw0zn5tvG2RuqAmTxPPgXrs";
const String secretkey_twitter =
    "SJaX8oUdeKl5FHBYalSgsAt26rTMj1QprDxTOy2lML5E1XEL3D";
const String redirectionUrl_twitter = "takeproftsocialauth://";

String recommender = "recommender";
String trader = "trader";
String guest = "guest";
String signIn = "sign in";
String signUp = "sign up";

///recommender list type for home page
String all = "all";
String matched = "matched";
String subscribed = "subscribed";

/// Hive Data
String getAppLanguage() => (userBox.get(KEY_APP_LANGUAGE) ?? "ar");

bool getIsOnBoardingShowed() =>
    (userBox.get(KEY_IS_ONBOARDING_SHOWED) ?? false);

String getDeviceID() => (userBox.get(KEY_DEVICE_ID) ?? "");

String getDeviceFCMToken() => (userBox.get(KEY_FCM_DEVICE_TOKEN) ?? "123456");

String getUserData() => (userBox.get(KEY_USER_DATA) ?? "");

String getUserAccessToken() => (userBox.get(KEY_USER_ACCESS_TOKEN) ?? "");

String getUserStatus() => (userBox.get(KEY_USER_STATUS) ?? "");

String getUserEntityId() => (userBox.get(KEY_USER_ENTITY_ID) ?? "");

String getUserImage() => (userBox.get(KEY_USER_IMAGE) ?? "");

bool? getIsAppThemeDark() => (userBox.get(KEY_APP_THEME_DARK));

/// Device Details
bool getIsAppleSignInSupport() => (iosVersion >= 13);
int iosVersion = 11;

bool getIsIOSPlatform() => Platform.isIOS;

String getDeviceType() => getIsIOSPlatform() ? "ios" : "android";

int getSkipVersion() => (userBox.get(KEY_SKIP_VERSION) ?? 0);

bool isDarkMode = false;

///Select Market Type
// NEW: First Time User Helpers
bool isFirstTimeUser() => (userBox.get(KEY_FIRST_TIME_USER) ?? true);
void setFirstTimeUser(bool isFirstTime) {
  saveLocalData(KEY_FIRST_TIME_USER, isFirstTime);
}

// NEW: Market Selection Helpers
String? getSelectedMarket() => userBox.get(KEY_SELECTED_MARKET);
void setSelectedMarket(String marketId) {
  saveLocalData(KEY_SELECTED_MARKET, marketId);
}

// const String userType = "CUSTOMER";
// const String sendingTypeBOTH = "BOTH";
// const String sendingTypeOTP = "OTP";
// const String typeEmail = "EMAIL";
// const String typeSMS = "SMS";

///Regex Validation
RegExp RegXMobile = RegExp(r'[0-9]');
RegExp RegXAmount = RegExp(r'^[0-9]*(\.[0-9]{0,2})?$');

//Common Data

/*
  * -- Validations
  * */

///Get Localize Text
String getLocalValue(String key) {
  return key.tr();
}

/// Compress Image
Future<File> compressImageFile(File file) async {
  final bytes = await file.readAsBytes();
  final originalImage = img.decodeImage(bytes);
  if(originalImage == null) throw Exception('Could not decode the image');
  final resizedImage = img.copyResize(originalImage,
      width: (originalImage.width * 0.4).round(),
      height: (originalImage.height * 0.4).round()) ;
  final compressedBytes = img.encodeJpg(resizedImage);
  final newPath = file.path.replaceAll(file.path.split('/').last, 'compressed.jpg');
  final compressedFile = File(newPath)..writeAsBytesSync(compressedBytes);
  return compressedFile;
}

//Save Local Data
saveLocalData(String key, value) {
  userBox.put(key, value);
  showLog(
      "Saved new data into your local Key - $key Value - ${userBox.get(key)}");
}

saveIsLogin({required bool isLogin}) {
  saveLocalData(KEY_USER_LOGIN, isLogin);
  showLog("isLogin : $isLogin");
}

showLog(String str) {
  if (kDebugMode) {
    debugPrint("-> $str", wrapWidth: 600);
  }
}

String? validatePassword(String? value,
    {required forNewPass, required bool isConPass, bool currentPass = false}) {
  String removeWhiteSpace = value!.replaceAll(" ", "");

  bool hasUppercase = removeWhiteSpace.contains(RegExp(r'[A-Z]'));
  bool hasDigits = removeWhiteSpace.contains(RegExp(r'[0-9]'));
  bool hasLowercase = removeWhiteSpace.contains(RegExp(r'[a-z]'));
  bool hasSpecialCharacters =
      removeWhiteSpace.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  if (value == "" || value.removeWhiteSpace.isEmpty) {
    return forNewPass
        ? 'Key_requiredNewPassword'.localized
        : isConPass
            ? 'Key_requiredConfirmPassword'.localized
            : currentPass
                ? 'Key_requiredCurrentPassword'.localized
                : 'Key_requiredPassword'.localized;
  } else if (value.removeWhiteSpace.length > 16 ||
      value.removeWhiteSpace.length < 8) {
    return forNewPass
        ? 'Key_validRangeNewPassword'.localized
        : isConPass
            ? 'Key_validRangeConfirmPassword'.localized
            : currentPass
                ? 'Key_validRangeCurrentPassword'.localized
                : 'Key_validRangePassword'.localized;
  } else if (!hasUppercase) {
    return forNewPass
        ? 'Key_requiredUppercaseCharForNewPass'.localized
        : isConPass
            ? 'Key_requiredUppercaseCharForConfirmPass'.localized
            : currentPass
                ? 'Key_requiredUppercaseCharForCurrentPass'.localized
                : 'Key_requiredUppercaseChar'.localized;
  } else if (!hasLowercase) {
    return forNewPass
        ? 'Key_requiredLowercaseCharForNewPass'.localized
        : isConPass
            ? 'Key_requiredLowercaseCharForConfirmPass'.localized
            : currentPass
                ? 'Key_requiredLowercaseCharForCurrentPass'.localized
                : 'Key_requiredLowercaseChar'.localized;
  } else if (!hasDigits) {
    return forNewPass
        ? 'Key_requiredNumberCharForNewPass'.localized
        : isConPass
            ? 'Key_requiredNumberCharForConfirmPass'.localized
            : currentPass
                ? 'Key_requiredNumberCharForCurrentPass'.localized
                : 'Key_requiredNumberChar'.localized;
  } else if (!hasSpecialCharacters) {
    return forNewPass
        ? 'Key_requiredSpecialCharForNewPass'.localized
        : isConPass
            ? 'Key_requiredSpecialCharForConfirmPass'.localized
            : currentPass
                ? 'Key_requiredSpecialCharForCurrentPass'.localized
                : 'Key_requiredSpecialChar'.localized;
  } else {
    return null;
  }
}

isPasswordValid(String str) {
  if (str.length >= 8 && str.length <= 15) {
    return true;
  } else {
    return false;
  }
}

isAccountNumberValid(String str) {
  if (str.length == 13 && str.isNotEmpty) {
    return true;
  } else {
    return false;
  }
}

isPhoneNumberValid(String str) {
  if (str.isNotEmpty && str.length <= 15 && str.length >= 6) {
    return true;
  } else {
    return false;
  }
}

bool isKeyBoardOpen(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom > 0;
}

///Is URL valid
isURLValid(String str) {
  Pattern pattern =
      r'(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?';
  // RegExp regex = new RegExp(pattern.toString());
  var regex = RegExp(pattern.toString(), caseSensitive: false);
  if (!(regex.hasMatch(str))) {
    return false;
  } else {
    return true;
  }
}

bool isIbanValid(String str) {
  Pattern pattern = r'KW[0-9]{2}[A-Z]{4}[0-9]{22}';
  var regex = RegExp(pattern.toString(), caseSensitive: false);
  if (!(regex.hasMatch(str))) {
    return false;
  } else {
    return true;
  }
}

isEmailValid(String str) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  // RegExp regex = new RegExp(pattern);
  RegExp regex = RegExp(pattern.toString());
  if (!(regex.hasMatch(str))) {
    return false;
  } else {
    return true;
  }
}

isValidPattern(String str, Pattern valuePattern) {
  RegExp regex = RegExp(valuePattern.toString());
  if (!(regex.hasMatch(str))) {
    return false;
  } else {
    return true;
  }
}

//-- Date Convert---
String getCustomFormatDateFromDateTime(DateTime dateTime, String outputFormat) {
  return DateFormat(outputFormat, getAppLanguage()).format(dateTime);
}

String getCustomFormatDateFromStringDate(
    String date, String inputFormat, String outputFormat) {
  DateTime dateTime = DateFormat(inputFormat, getAppLanguage()).parse(date);
  return DateFormat(outputFormat, getAppLanguage()).format(dateTime);
}

DateTime getDateFromStringDate(String date, String inputFormat) {
  return DateFormat(inputFormat, getAppLanguage()).parse(date);
}

showSnackBar(var _scaffoldKey, String value) {
  _scaffoldKey.currentState.showSnackBar(SnackBar(
    content: Text(
      value,
      style: TextStyle(
        color: Colors.white,
        fontSize: ScreenUtil().setSp(14),
      ),
    ),
    backgroundColor: Colors.black,
    duration: const Duration(seconds: 1),
  ));
}

showCommonBottomSheet(BuildContext context, Widget child) {
  return showModalBottomSheet(
      isDismissible: false,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(35.h),
        topRight: Radius.circular(35.h),
      )),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => child);
}

bool isInternetConnectionOn = true;

Future<bool> checkInternet(BuildContext context,
    {bool showAlert = true}) async {
  if (!isInternetConnectionOn && showAlert) {
    showMessageDialog(context, "Key_NoInternetConnection".tr(), () => null);
  }
  showLog("Status $isInternetConnectionOn");
  return isInternetConnectionOn;
  // try {
  //   final result = await InternetAddress.lookup('google.com');
  //
  //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //     return true;
  //   } else {
  //     showLog('--------------TRY ELSE----------------');
  //     showLog('--> ${result.isNotEmpty.toString()}');
  //     showMessageDialog(context, "Please check your internet connection", () => null);
  //     // showSnackBar(_scaffoldKey, "Please check your internet connection");
  //     return false;
  //   }
  // } on SocketException catch (_) {
  //   showMessageDialog(context, "Please check your internet connection", () => null);
  //   // showSnackBar(_scaffoldKey, "Please check your internet connection");
  //   return false;
  // }
}

hideKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}

//-- Date Convert---
String generateFileName() {
  return DateFormat("yyyy_MM_dd_HH_mm_ss_SSS").format(DateTime.now());
}

logout(BuildContext context) async {
  String appLanguage = getAppLanguage();
  bool isOnBoarding = getIsOnBoardingShowed();
  String deviceToken = getDeviceFCMToken();

  await userBox.clear();

  saveLocalData(KEY_APP_LANGUAGE, appLanguage);
  saveLocalData(KEY_IS_ONBOARDING_SHOWED, isOnBoarding);
  saveLocalData(KEY_FCM_DEVICE_TOKEN, deviceToken);
}

logoutAction(BuildContext context) async {
  String appLanguage = getAppLanguage();
  String deviceToken = getDeviceFCMToken();

  await userBox.clear();

  saveLocalData(KEY_APP_LANGUAGE, appLanguage);
  saveLocalData(KEY_USER_STATUS, guest);
  saveLocalData(KEY_FCM_DEVICE_TOKEN, deviceToken);

  // /// navigate to login screen
  // Route route = SlideRightPageRoute(builder: (context) => RoleSelectionScreen(status: signIn ), settings: const RouteSettings());
  // Navigator.of(context).pushAndRemoveUntil(route,(route) => false);
}

///Auth Dialog
getStartedDialog(BuildContext context,
    {bool canPop = true, Function(bool val)? callBack}) {
  return showWidgetDialog(
      context,
      Wrap(
        children: [
          GetStartedScreen(
            canPop: canPop,
            callBack: callBack,
          ),
        ],
      ),
      () {},
      false,
      16.r);
}

logoutDialog(BuildContext context, Function(bool isPositive) didTakeAction) {
  return showDialog(
      barrierDismissible: true,
      context: context,
      // barrierColor: Constant.clrDialogBGByTheme(),
      builder: (context) => Dialog(
            backgroundColor: Constant.clrScaffoldBGByTheme(context),
            insetPadding: EdgeInsets.all(16.sp),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30))),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 25.w, right: 25.w, top: 30.h, bottom: 15.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("KeyLogoutMSG".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: Constant.clrTextByTheme(context),
                              fontWeight: Constant.fwMedium,
                              fontFamily: Constant.fontFamily)),
                      SizedBox(
                        height: 30.h,
                      ),
                      CommonButton(
                          label: "Key_Logout".tr().toUpperCase(),
                          onTap: () {
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 80),
                                () {
                              didTakeAction(true);
                            });
                          },
                          borderColor: Constant.clrPrimary,
                          bgColor: Constant.clrPrimary,
                          labelColor: Constant.clrWhite),
                      SizedBox(
                        width: 15.w,
                      ),
                      CommonButton(
                          label: "Key_Cancel".tr().toUpperCase(),
                          onTap: () {
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 80),
                                () {
                              didTakeAction(false);
                            });
                          },
                          borderColor: Constant.clrScaffoldBGByTheme(context),
                          bgColor: Constant.clrScaffoldBGByTheme(context),
                          labelColor: Constant.clrTextByTheme(context)),
                    ],
                  ),
                ),
              ],
            ),
          ));
}

showConfirmationDialog(
  BuildContext context,
  String image,
  String title,
  String message,
  Function(bool isPositive) didTakeAction, {
  double? borderRadius,
  double? buttonRadius,
  Color? dialogBGColor,
  Color? yesBtnTextClr,
  Color? yesBtnBGClr,
  Color? yesBtnBorderClr,
  Color? noBtnTextClr,
  Color? noBtnBGClr,
  Color? noBtnBorderClr,
  TextStyle? titleTextStyle,
  double? yesBtnWidth,
  double? noBtnWidth,
  EdgeInsetsGeometry? dialogInsidePadding,
  TextStyle? messageTextStyle,
  EdgeInsetsGeometry? titleTxtPadding,
  EdgeInsetsGeometry? msgTxtPadding,
  String? warning,
  TextStyle? warningTextStyle,
  EdgeInsetsGeometry? warningTxtPadding,
}) {
  return showDialog(
    barrierDismissible: true,
    context: context,
    // barrierColor: Constant.clrDialogBGByTheme(),
    builder: (context) => Dialog(
      backgroundColor: dialogBGColor ?? Constant.clrScaffoldBGByTheme(context),
      insetPadding: EdgeInsets.all(16.sp),
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(borderRadius ?? ScreenUtil().setWidth(5))),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: dialogInsidePadding ??
                EdgeInsets.only(
                    left: 25.w, right: 25.w, top: 23.h, bottom: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: image == "" ? 0.h : 50.h,
                ),
                image == ""
                    ? const Offstage()
                    : SizedBox(
                        height: 26.h,
                      ),
                Padding(
                  padding: titleTxtPadding ?? EdgeInsets.all(0.h),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: titleTextStyle ??
                        TextStyle(
                            fontSize: 18.sp,
                            color: Constant.clrTextMainFontByTheme(context),
                            fontWeight: Constant.fwBold,
                            fontFamily: Constant.fontFamily),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: msgTxtPadding ?? EdgeInsets.all(0.h),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: messageTextStyle ??
                        TextStyle(
                            fontSize: 13.sp,
                            color: Constant.clrTextByTheme(context),
                            fontWeight: Constant.fwMedium,
                            fontFamily: Constant.fontFamily),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonButton(
                        width: yesBtnWidth ?? 100.w,
                        borderRadius: buttonRadius ?? 5.r,
                        label: "Key_YES".tr(),
                        onTap: () {
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 80), () {
                            didTakeAction(true);
                          });
                        },
                        borderColor:
                            yesBtnBorderClr ?? Constant.clrGreyCardBg,
                        bgColor: yesBtnBGClr ?? Constant.clrGreyCardBg,
                        labelColor: yesBtnTextClr ?? Constant.clrDarkBlue),
                    SizedBox(
                      width: 15.w,
                    ),
                    CommonButton(
                        label: "Key_No".tr(),
                        width: noBtnWidth ?? 100.w,
                        borderRadius: buttonRadius ?? 5.r,
                        onTap: () {
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 80), () {
                            didTakeAction(false);
                          });
                        },
                        borderColor: noBtnBorderClr ?? Constant.clrPrimary,
                        bgColor: noBtnBGClr ?? Constant.clrPrimary,
                        labelColor: noBtnTextClr ?? Constant.clrWhite),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Visibility(
                  visible: warning == null || warning.toString().isEmpty
                      ? false
                      : true,
                  child: Padding(
                    padding: warningTxtPadding ??
                        EdgeInsets.symmetric(horizontal: 15.w),
                    child: Text(
                      warning.toString(),
                      textAlign: TextAlign.center,
                      style: warningTextStyle ??
                          TextStyle(
                              fontSize: 10.sp,
                              color: Constant.clrRed,
                              fontWeight: Constant.fwRegular,
                              fontFamily: Constant.fontFamily),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

showConfirmationDialog2(BuildContext context, String message,
    Function(bool isPositive) didTakeAction) {
  return showDialog(
    barrierDismissible: true,
    context: context,
    // barrierColor: Constant.clrDialogBGByTheme(),
    builder: (context) => Dialog(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      insetPadding: EdgeInsets.all(16.sp),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ScreenUtil().setWidth(5),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: 25.w, end: 25.w, top: 23.h, bottom: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 26.h,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Constant.clrTextByTheme(context),
                      fontWeight: Constant.fwRegular,
                      fontFamily: Constant.fontFamily),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonButton(
                        label: "Key_YES".tr(),
                        width: 100.w,
                        borderRadius: 23.r,
                        onTap: () {
                          Navigator.pop(context);
                          if (didTakeAction != null) {
                            Future.delayed(const Duration(milliseconds: 80),
                                () {
                              didTakeAction(true);
                            });
                          }
                        },
                        borderColor: Constant.clrPrimary,
                        bgColor: Constant.clrPrimary,
                        labelColor: Constant.clrWhite),
                    SizedBox(
                      width: 15.w,
                    ),
                    CommonButton(
                        width: 100.w,
                        borderRadius: 23.r,
                        label: "Key_No".tr(),
                        onTap: () {
                          Navigator.pop(context);
                          if (didTakeAction != null) {
                            Future.delayed(const Duration(milliseconds: 80),
                                () {
                              didTakeAction(false);
                            });
                          }
                        },
                        borderColor: Constant.clrGreyCardBg,
                        bgColor: Constant.clrRed,
                        labelColor: Constant.clrWhite),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

///Set Navigation Redirection
setNavigationRedirection(BuildContext context) async {
  showLog("Set Navigation With Common Method");

  String accessToken = getUserAccessToken();

  // bool isLogIn = await userBox.get(KEY_USER_LOGIN) ?? false;

  late Route route;
  if (accessToken.isNotEmpty) {
    route = SlideRightPageRoute(
        builder: (context) => const DrawerMenu(),
        settings: const RouteSettings());
  } else {
    // Always skip onboarding and go to DrawerMenu
    saveLocalData(KEY_USER_STATUS, guest);
    route = SlideRightPageRoute(
        builder: (context) => const DrawerMenu(),
        settings: const RouteSettings());
  }
  // if(isLogIn && accessToken!= ''){
  //   route = SlideRightPageRoute(builder: (context) => const DrawerMenu(), settings: const RouteSettings());
  // }
  // else{
  //   route = SlideRightPageRoute(builder: (context) => const OnBoardingScreen(),
  //       settings: const RouteSettings());
  // }
  Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
}

///String URL Encode
String getEncodedURLString(String value) {
  return Uri.encodeFull(value);
}

Widget placeholderWidget(String imageURL, double width, double height) {
  return Image.network(
    getEncodedURLString(imageURL),
    fit: BoxFit.fill,
    width: width.w,
    height: height.h,
    loadingBuilder: (context, childWidget, loadingProgress) {
      if (loadingProgress == null) {
        return childWidget;
      } else {
        return Center(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: ExactAssetImage("assets/images/login_image.png"),
              ),
            ),
          ),
        );
      }
    },
  );
}

showMessageDialog(
    BuildContext context, String message, Function()? didDismiss) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Constant.clrWhite,
      insetPadding: EdgeInsets.all(16.sp),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(5))),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: ScreenUtil().setHeight(220),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 25.w, right: 25.w, top: 23.h, bottom: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Constant.clrDarkBlue,
                          fontWeight: Constant.fwMedium,
                          fontFamily: Constant.fontFamily),
                    ),
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  SizedBox(
                    height: 50.h,
                    child: RoundButton(
                      titleColor: Constant.clrWhite,
                      bgColor: Constant.clrPrimary,
                      borderColor: Constant.clrPrimary,
                      fontSize: 14.sp,
                      label: "Key_Ok".localized,
                      onTap: () {
                        Navigator.pop(context);
                        if (didDismiss != null) {
                          Future.delayed(const Duration(milliseconds: 80), () {
                            didDismiss();
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

showAnimationMessageDialog(BuildContext context, String message, String subMsg,
    Function()? didDismiss) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Constant.clrWhite,
      insetPadding: EdgeInsets.all(16.sp),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ScreenUtil().setWidth(5),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              if (didDismiss != null) {
                Future.delayed(const Duration(milliseconds: 80), () {
                  didDismiss();
                });
              }
            },
            child: SizedBox(
              width: double.infinity,
              height: ScreenUtil().setHeight(220),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.w, right: 25.w, top: 23.h, bottom: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: 70.h,
                      width: 70.h,
                      child: Lottie.asset('assets/gif/tik_animation.json'),
                    ),
                    Flexible(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: Constant.clrDarkBlue,
                            fontWeight: Constant.fwBold,
                            fontFamily: Constant.fontFamily),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Flexible(
                      child: Text(
                        subMsg,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: Constant.clrDarkBlue,
                            fontWeight: Constant.fwMedium,
                            fontFamily: Constant.fontFamily),
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

showWidgetDialog(BuildContext context, Widget? widget, Function()? didDismiss,
    bool? isDismissable, double? radius) {
  return showDialog(
    barrierDismissible: isDismissable ?? false,
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Constant.clrCardBGByTheme(context),
      insetPadding: EdgeInsets.all(16.sp),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          radius ?? ScreenUtil().setWidth(5),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[widget!],
      ),
    ),
  );
}

showCommonSuccessDialog(BuildContext context, String image, String title,
    String message, Function()? didDismiss) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Constant.clrDialogBGByTheme(context),
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
          if (didDismiss != null) {
            didDismiss();
          }
        });
        return Dialog(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          insetPadding: EdgeInsets.all(16.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ScreenUtil().setWidth(27),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: ScreenUtil().setHeight(270),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 25.w, right: 25.w, top: 23.h, bottom: 15.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        image,
                        height: 76.h,
                        width: 66.w,
                      ),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22.sp,
                            color: Constant.clrTextByTheme(context),
                            fontWeight: Constant.fwSemiBold,
                            fontFamily: Constant.fontFamily),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Flexible(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Constant.clrTextGrey,
                              fontWeight: Constant.fwRegular,
                              fontFamily: Constant.fontFamily),
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      // Container(
                      //   height: 50.h,
                      //   child: RoundButton(
                      //     titleColor: Constant.clrWhite,
                      //     bgColor: Constant.clrPrimary,
                      //     borderColor: Constant.clrPrimary,
                      //     fontSize: 14.sp,
                      //     label: getLocalValue(context, "Key_Ok"),
                      //     onTap: (){
                      //       Navigator.pop(context);
                      //       if(didDismiss != null){
                      //         Future.delayed(Duration(milliseconds: 80), () {
                      //           didDismiss();
                      //         });
                      //       }
                      //     },
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

showCommonSuccessForSVGDialog(BuildContext context, String image, String title,
    String message, Function()? didDismiss) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Constant.clrDialogBGByTheme(context),
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
          if (didDismiss != null) {
            didDismiss();
          }
        });
        return Dialog(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          insetPadding: EdgeInsets.all(16.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ScreenUtil().setWidth(27),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: ScreenUtil().setHeight(270),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 25.w, right: 25.w, top: 23.h, bottom: 15.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SvgPicture.asset(
                        image,
                        height: 76.h,
                        width: 76.w,
                      ),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22.sp,
                            color: Constant.clrTextByTheme(context),
                            fontWeight: Constant.fwSemiBold,
                            fontFamily: Constant.fontFamily),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Flexible(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Constant.clrTextGrey,
                              fontWeight: Constant.fwRegular,
                              fontFamily: Constant.fontFamily),
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

Widget widgetNoDataFound(String message) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 20.h),
    child: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: Constant.fontFamily,
            fontSize: 14.sp,
            fontWeight: Constant.fwMedium,
            color: Constant.clrDarkBlue),
      ),
    ),
  );
}

//For Get last word from String
String getLastWordFromString(String txt) {
  List<String> words = txt.split(" ");
  String lastWord = words[words.length - 1];
  return lastWord;
}

//For Remove last word after text
String getRemoveLastWordAfterString(String txt) {
  List<String> words = txt.split(" ");
  String lastWord = words[words.length - 1];
  int count = lastWord.length;
  String finalTxt = txt.substring(0, txt.length - count);
  showLog("Remove after last word : $finalTxt");
  return finalTxt;
}

enum ScreenName {
  None,
  SplashScreen,
  AddConferenceHallScreen,
  AddNewEventDetailsScreen,
  LoginScreen,
  ForgotPasswordScreen,
  EditProfileScreen,
  EditEmailScreen,
  EditPhoneScreen,
  RegisterScreen,
  SettingScreen,
  FromPaymentScreen,
  NotificationScreen,
  SubscriptionAmountScreen,
  EditSubscriptionAmountScreen,
  RecommenderBioScreen,
  RecommenderDetailsScreen,
  ProfileScreen,
  RequestAnalysisScreen
}

enum CourseType { session, Training, conference, None }

enum SubCategoryType {
  FaceToFace,
  GroupCoaching,
  Talk,
  TrainingCourse,
  PeerReview,
  KnowledgeSharing,
  BrainStroming,
  WorkshopEvent,
  ConferenceEvent
}

enum ConferenceTableType { Rectangle, RectangleWithRadius, Square, Circle }

enum SeatStatus { None, Available, Booked, Selected }

enum RoleStatus { SignIn, SignUp }

enum FromScreen { FromSignUp, FromSignIn, FromProfile, FromForgotPassword }

enum StatusWiseTabs { FromGuest, FromRecommender, FromTrader }

enum NotificationSlugTrader {
  // signal_update,
  // signal_close,
  // all_signal_close,
  // new_scenario,
  // sub_stop_loss_signal,
  // tp_target_trader_alert,
  // tp_target_sub_trader_alert,
  // request_completed,
  // request_refunded


  signal_update,
  all_signal_close,
  signal_close,
  new_scenario,
  sub_stop_loss_signal,
  tp_target_sub_trader_alert,
  tp_target_trader_alert,
  request_completed,
  request_refunded,

  signal_create,
  signal_activate,
  update_social_post,
  tp_target_trader_achieve_alert,
  new_social_post
}

enum NotificationSlugRecommender {
  // stop_loss_signal,
  // tp_target_alert,
  // signal_update,
  // signal_close,
  // all_signal_close,
  // new_scenario,
  // sub_stop_loss_signal,
  // tp_target_trader_alert,
  // tp_target_sub_trader_alert,
  // new_request,
  // request_completed,
  // request_refunded,
  // payment_recieved

  stop_loss_signal,
  tp_target_alert,
  new_request,
  request_completed,
  request_refunded,
  payment_recieved,
  new_scenario,
  signal_close,

  tp_target_achieve_alert,
  new_trader_sub,
  all_signal_close_recommender,
  all_signal_close_failed,


}

// enum UserRoleInApp{
//   guest, recommender, trader
// }
//
// Map<UserRoleInApp,String> UserRoleInAppValue = {
//   UserRoleInApp.guest : "GUEST",
//   UserRoleInApp.recommender : recommender,
//   UserRoleInApp.trader : "TRADER"
// };
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

enum VersionUpdateStatus {
  required,
  optional,
  none,
}

copyToClipboard(context, text) async {
  await Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Key_Copied".localized),
  ));
}