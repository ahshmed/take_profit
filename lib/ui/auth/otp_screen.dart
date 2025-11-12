import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/otp_screen_controller.dart';
import '../../framework/repository/common/model/country_list_response_model.dart';
import '../../main.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import 'create_password_screen.dart';
import 'helper/success_screen.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final FromScreen fromScreen;
  final String email;
  final String userID;
  final String? mobileNumber; // Keep mobile number optional for backward compatibility
  final CountryData? countryData; // Keep country data optional

  const OTPScreen({
    Key? key,
    required this.fromScreen,
    required this.userID,
    this.email = "",
    this.mobileNumber, // Make mobile number optional
    this.countryData, // Make country data optional
  }) : super(key: key);

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  int counterSeconds = 180;
  late Timer counter;

  TextEditingController otpCTR = TextEditingController();
  FocusNode otpFocus = FocusNode();

  /// Hash mobile number for display
  String _getHashedMobileNumber() {
    if (widget.mobileNumber == null || widget.mobileNumber!.isEmpty) {
      return "";
    }

    final mobile = widget.mobileNumber!;
    if (mobile.length <= 4) {
      return mobile; // Return as is if too short to hash
    }

    // Show first 2 and last 2 digits, hash the rest
    final firstTwo = mobile.substring(0, 2);
    final lastTwo = mobile.substring(mobile.length - 2);
    final middleHashed = '*' * (mobile.length - 4);

    return '$firstTwo$middleHashed$lastTwo';
  }

  /// Get display text based on whether we have email or mobile
  String _getDisplayText() {
    if (widget.email.isNotEmpty) {
      return widget.email;
    } else if (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty) {
      final hashedMobile = _getHashedMobileNumber();
      return widget.countryData?.code != null
          ? "${widget.countryData!.code} - $hashedMobile"
          : hashedMobile;
    }
    return "";
  }

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final otpWatch = ref.watch(otpScreenProvider);
      otpWatch.clearProvider();
      startCounter();
    });
  }

  Future<bool> _onWillPopScope() async {
    counter.cancel();
    Navigator.of(context).pop();
    return true;
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final otpWatch = ref.watch(otpScreenProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: widget.fromScreen == FromScreen.FromSignUp
              ? null
              : CommonAppBar(
            title: getLocalValue("Key_OTPVerify"),
            appBar: AppBar(),
            isTitleCenter: true,
            isLeading: true,
            onPress: () {
              if (widget.fromScreen == FromScreen.FromProfile) {
                _onWillPopScope();
                Navigator.of(context).pop();
              } else if (widget.fromScreen == FromScreen.FromSignUp) {
                _onWillPopScope();
              } else if (widget.fromScreen == FromScreen.FromForgotPassword) {
                _onWillPopScope();
              } else {
                _onWillPopScope();
              }
            },
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              hideKeyboard(context);
            },
            child: bodyWidget(otpWatch),
          ),
        ),
        DialogProgressBar(isLoading: otpWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(OTPScreenController otpWatch) {
    return WillPopScope(
      onWillPop: () async {
        return _onWillPopScope();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Padding(
            padding: widget.fromScreen == FromScreen.FromSignUp
                ? EdgeInsets.only(top: 26.h)
                : EdgeInsets.all(0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30.h,
                ),
                widget.fromScreen == FromScreen.FromSignUp
                    ? InkWell(
                  onTap: () {
                    counter.cancel();
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: (getAppLanguage() == 'ar')
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: CommonImageAsset(
                      strIcon: Constant.icClose,
                      height: 18.h,
                      width: 18.w,
                    ),
                  ),
                )
                    : const Offstage(),
                widget.fromScreen == FromScreen.FromSignUp
                    ? Text(
                  getLocalValue("Key_OTPVerify"),
                  style: TextStyles.txtMedium16(context).copyWith(
                    color: Constant.clrTextByTheme(context),
                  ),
                )
                    : const Offstage(),
                SizedBox(
                  height: 19.h,
                ),
                Text(
                  widget.email.isNotEmpty
                      ? getLocalValue("Key_OTPContentEmail")
                      : getLocalValue("Key_OTPContent"),
                  style: TextStyles.txtRegular12(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 17.h,
                ),
                if (_getDisplayText().isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDisplayText(),
                        style: TextStyles.txtMedium14(context),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      InkWell(
                        onTap: () {
                          setCounterSeconds(0);
                          Navigator.pop(context);
                        },
                        child: CommonImageAsset(
                          strIcon: Constant.icEdit,
                          clrImg: isDarkMode ? Constant.clrPrimary : Constant.clrDarkBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                ],
                SizedBox(
                  width: double.infinity,
                  child: PinCodeTextField(
                    appContext: context,
                    length: otpLength,
                    animationType: AnimationType.fade,
                    animationCurve: Curves.fastOutSlowIn,
                    animationDuration: const Duration(milliseconds: 750),
                    focusNode: otpFocus,
                    textInputAction: TextInputAction.done,
                    controller: otpCTR,
                    obscureText: false,
                    useHapticFeedback: true,
                    hapticFeedbackTypes: HapticFeedbackTypes.light,
                    enableActiveFill: true,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                      activeFillColor: Constant.clrPrimary,
                      inactiveColor: Constant.clrGrey,
                      disabledColor: Constant.clrWhite,
                      inactiveFillColor: Constant.clrWhite,
                      activeColor: Constant.clrWhite,
                      selectedColor: Constant.clrGreyNewDark,
                      fieldWidth: 40.w,
                      fieldHeight: 40.w,
                      selectedFillColor: Constant.clrGreyNewDark,
                      fieldOuterPadding: EdgeInsets.symmetric(horizontal: 1.w),
                      borderWidth: 2.h,
                    ),
                    cursorColor: Constant.clrPrimary,
                    cursorHeight: 20.h,
                    autoFocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegXMobile),
                    ],
                    textStyle: TextStyles.txtMedium19(context).copyWith(color: Constant.clrWhite),
                    keyboardType: TextInputType.phone,
                    onCompleted: (value) {
                      otpWatch.checkOTPValidation(context, value);
                    },
                    onChanged: (value) {
                      otpWatch.checkOTPValidation(context, value);
                      showLog("${value.length}");
                    },
                  ),
                ),
                SizedBox(
                  height: 42.h,
                ),
                Text(
                  getLocalValue("Key_ResendCodeIn"),
                  style: TextStyles.txtRegular14(context),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  getCounterString(counterSeconds),
                  style: TextStyles.txtRegular14(context),
                ),
                SizedBox(
                  height: 42.h,
                ),
                Visibility(
                  visible: (counterSeconds == 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${getLocalValue("Key_DontReceiveCode")}? ",
                        style: TextStyles.txtRegular14(context).copyWith(
                          color: Constant.clrTextByTheme(context),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          otpWatch.strOTP = '';
                          otpCTR.clear();
                          if (widget.fromScreen == FromScreen.FromProfile) {
                            if (widget.email.isNotEmpty) {
                              _resendEmailOTPAPI(otpWatch);
                            } else {
                              _resendOTPAPI(otpWatch);
                            }
                          } else {
                            if (widget.email.isNotEmpty) {
                              _resendEmailOTPAPI(otpWatch);
                            } else {
                              _resendOTPAPI(otpWatch);
                            }
                          }
                        },
                        child: Text(
                          getLocalValue("Key_RESEND"),
                          style: TextStyles.txtMedium14(context).copyWith(
                              color: Constant.clrPrimary,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 54.h,
                ),
                CommonButton(
                  height: 49.h,
                  label: getLocalValue("Key_Verify"),
                  onTap: () {
                    counter.cancel();
                    if (otpWatch.strOTP != "") {
                      if (widget.fromScreen == FromScreen.FromForgotPassword) {
                        _verifyOTPAPI(otpWatch);
                      } else if (widget.fromScreen == FromScreen.FromProfile) {
                        if (widget.email.isEmpty) {
                          _verifyMobileFromProfileOTPAPI(otpWatch, widget.countryData?.id ?? "1");
                        } else {
                          _verifyEmailOTPAPI(otpWatch);
                        }
                      } else {
                        if (widget.email.isNotEmpty) {
                          _verifyEmailOTPAPI(otpWatch);
                        } else {
                          _verifyOTPAPI(otpWatch);
                        }
                      }
                    }
                  },
                  bgColor: Constant.clrPrimary,
                  labelColor: Constant.clrWhite,
                  isEnable: otpWatch.strOTP.length == 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///---Counter Method---
  void startCounter() {
    const oneSec = Duration(seconds: 1);
    counter = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (counterSeconds == 0) {
          timer.cancel();
        } else {
          counterSeconds--;
          setCounterSeconds(counterSeconds);
        }
      },
    );
  }

  ///---- Set Counter Seconds-----
  setCounterSeconds(int seconds) {
    setState(() {
      counterSeconds = seconds;
    });

    showLog("counterSeconds $counterSeconds");
  }

  ///----- get Counter Strings-----
  String getCounterString(int seconds) {
    showLog("$seconds");
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  /// Verify OTP API
  Future _verifyOTPAPI(OTPScreenController otpWatch) async {
    if (isInternetConnectionOn) {
      await otpWatch.verifyOTPApi(context, widget.userID, widget.mobileNumber ?? "");
      if (otpWatch.verifyOtpResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        if (widget.fromScreen == FromScreen.FromForgotPassword) {
          Route route = SlideRightPageRoute(
              builder: (context) => CreatePasswordScreen(userId: widget.userID),
              settings: const RouteSettings());
          Navigator.of(context).pushReplacement(route);
        } else {
          Route route = SlideRightPageRoute(
              builder: (context) => SuccessScreen(
                  content: "Key_YourMobileNumberHasBeenVerifiedSuccessfully",
                  userID: widget.userID),
              settings: const RouteSettings());
          Navigator.of(context).pushReplacement(route);
        }
      } else {
        if (otpWatch.verifyOtpResponseModel?.status ==
            ApiEndPoints.apiStatus_201.toString()) {
          showMessageDialog(
              context, otpWatch.verifyOtpResponseModel?.message ?? "", () {
            startCounter();
          });
        }
      }
    }
  }

  /// Verify Mobile from Profile OTP API
  Future _verifyMobileFromProfileOTPAPI(OTPScreenController otpWatch, String countryId) async {
    if (isInternetConnectionOn) {
      await otpWatch.verifyUpdateMobileApi(context, widget.mobileNumber ?? "", countryId);
      if (otpWatch.updateMobileResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        Route route = SlideRightPageRoute(
            builder: (context) => SuccessScreen(
                content: "Key_YourMobileNumberHasBeenVerifiedSuccessfully",
                userID: widget.userID,
                isFromProfile: true,
                emailContent: ""),
            settings: const RouteSettings());
        Navigator.of(context).pushReplacement(route);
      } else {
        if (otpWatch.updateMobileResponseModel?.status ==
            ApiEndPoints.apiStatus_201.toString()) {
          showMessageDialog(
              context, otpWatch.updateMobileResponseModel?.message ?? "", () {
            startCounter();
          });
        }
      }
    }
  }

  /// Verify Email OTP API
  Future _verifyEmailOTPAPI(OTPScreenController otpWatch) async {
    if (isInternetConnectionOn) {
      await otpWatch.verifyEmailOTPApi(context, widget.email);
      if (otpWatch.verifyEmailOtpResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        Route route = SlideRightPageRoute(
            builder: (context) => SuccessScreen(
                emailContent: "Key_EmailAddressAdded",
                content: "Key_YourEmailAddressHasBeenAddedSuccessfully",
                isFromProfile: widget.fromScreen == FromScreen.FromProfile,
                userID: widget.userID),
            settings: const RouteSettings());
        Navigator.of(context).pushReplacement(route);
      } else {
        if (otpWatch.verifyEmailOtpResponseModel?.status ==
            ApiEndPoints.apiStatus_201.toString()) {
          showMessageDialog(
              context, otpWatch.verifyEmailOtpResponseModel?.message ?? "", () {
            startCounter();
          });
        }
      }
    }
  }

  /// Resend OTP API
  Future _resendOTPAPI(OTPScreenController otpWatch) async {
    if (isInternetConnectionOn) {
      await otpWatch.resendOTPApi(
          context, widget.mobileNumber ?? "", widget.countryData?.id ?? "");
      if (otpWatch.resendOtpResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        showMessageDialog(
            context, otpWatch.resendOtpResponseModel?.message ?? "", () {
          startCounter();
          setCounterSeconds(180);
        });
      } else {
        if (otpWatch.resendOtpResponseModel?.status ==
            ApiEndPoints.apiStatus_201.toString()) {
          showMessageDialog(
              context, otpWatch.resendOtpResponseModel?.message ?? "", () {
            startCounter();
          });
        }
      }
    }
  }

  /// Resend Email OTP API
  Future _resendEmailOTPAPI(OTPScreenController otpWatch) async {
    if (isInternetConnectionOn) {
      await otpWatch.resendEmailOTPApi(context, widget.email);
      if (otpWatch.resendEmailOtpResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        showMessageDialog(
            context, otpWatch.resendEmailOtpResponseModel?.message ?? "", () {
          startCounter();
          setCounterSeconds(180);
        });
      } else {
        if (otpWatch.resendEmailOtpResponseModel?.status ==
            ApiEndPoints.apiStatus_201.toString()) {
          showMessageDialog(
              context, otpWatch.resendEmailOtpResponseModel?.message ?? "", () {
            startCounter();
          });
        }
      }
    }
  }
}