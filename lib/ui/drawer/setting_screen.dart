// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/drawer/common_setting_helper.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/drawer/settings_screen_controller.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/common_svg.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../auth/request_analysis_screen_signup.dart';
import '../auth/sign_in_screen.dart';
import '../my_subscription/subscription_plans_screen.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>  {
  ///init state
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      final settingScreenWatch = ref.watch(settingsScreenProvider);
      if (isInternetConnectionOn) {
        await settingScreenWatch.updateSettingsApi(context);
        settingScreenWatch.updateSMSNotificationStatus(settingScreenWatch
                .updateSettingResponseModel?.data?.enableSms
                .toString() ??
            "");
        settingScreenWatch.updateEmailNotificationStatus(settingScreenWatch
                .updateSettingResponseModel?.data?.enableEmail
                .toString() ??
            "");
        settingScreenWatch.updatePushNotificationStatus(settingScreenWatch
                .updateSettingResponseModel?.data?.enableNotification
                .toString() ??
            "");
        settingScreenWatch.updateRequestAnalysisStatus(settingScreenWatch
                .updateSettingResponseModel?.data?.enableRequestAnalysis
                .toString() ??
            "");
      }
    });

    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_)  {
      if (getUserStatus() == guest){
        getStartedDialog(context);
      //if this screen was pushed, pop it if it's embedded
        final drawerWatch = ref.read(drawerProvider);
        drawerWatch.updateDrawerPosition(0);

      }

    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final settingScreenWatch = ref.watch(settingsScreenProvider);
    final darkModeWatch = ref.watch(darkProvider);
    final drawerWatch = ref.watch(drawerProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue("Key_Setting"),
            appBar: AppBar(
              backgroundColor: Constant.clrBasicByTheme(context),
            ),
            isTitleCenter: true,
            isDrawer: true,
          ),
          body: NoInternetBuilder(child: bodyWidget(settingScreenWatch)),
        ),
        DialogProgressBar(isLoading: settingScreenWatch.isLoading)
      ],
    );
  }

  ///body widget
  Widget bodyWidget(SettingsScreenController settingScreenWatch) {
    final signUpSubscriptionAmountWatch =
        ref.watch(signUpSubscriptionAmountProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 21.h,
          ),
          Text(
            getLocalValue("Key_SettingContent"),
            style: TextStyles.txtRegular12
                (context).copyWith(color: Constant.clrWhiteBlackNewByTheme(context)),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 60.h,
          ),
          Container(
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Constant.clrDarkByScaffoldTheme(context),
            ),
            child: CommonSettingsHelper(
              title: "Key_PushNotification",
              subTitle: "Key_PushNotificationContent",
              onChanged: (val) {
                settingScreenWatch
                    .updatePushNotificationStatus(val == false ? "0" : "1");
                _updateSettingsApi(settingScreenWatch,
                    isPushNotification: true,
                    isEmailNotification: false,
                    isSmsNotification: false,
                    isRequestAnalysis: false);
              },
              status: settingScreenWatch.isPushNotificationStatus == "0"
                  ? false
                  : true,
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Container(
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Constant.clrDarkByScaffoldTheme(context),
            ),
            child: CommonSettingsHelper(
              title: "Key_EmailNotification",
              subTitle: "Key_EmailNotificationContent",
              onChanged: (val) {
                settingScreenWatch
                    .updateEmailNotificationStatus(val == false ? "0" : "1");
                _updateSettingsApi(settingScreenWatch,
                    isPushNotification: false,
                    isEmailNotification: true,
                    isSmsNotification: false,
                    isRequestAnalysis: false);
              },
              status: settingScreenWatch.isEmailNotificationStatus == "0"
                  ? false
                  : true,
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Container(
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Constant.clrDarkByScaffoldTheme(context),
            ),
            child: CommonSettingsHelper(
              title: "Key_SMSNotification",
              subTitle: "Key_SMSNotificationContent",
              onChanged: (val) {
                settingScreenWatch
                    .updateSMSNotificationStatus(val == false ? "0" : "1");
                _updateSettingsApi(settingScreenWatch,
                    isPushNotification: false,
                    isEmailNotification: false,
                    isSmsNotification: true,
                    isRequestAnalysis: false);
              },
              status: settingScreenWatch.isSMSNotificationStatus == "0"
                  ? false
                  : true,
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Visibility(
            visible: getUserStatus() == "recommender",
            child: InkWell(
              onTap: () {
                if (settingScreenWatch.isRequestAnalysisStatus == "1") {
                  Route route = SlideRightPageRoute(
                      builder: (context) => RequestAnalysisScreenSignUp(
                          amount: settingScreenWatch.updateSettingResponseModel
                              ?.data?.requestAnalysisAmount,
                          userID: '',
                          fromScreen: ScreenName.SettingScreen),
                      settings: const RouteSettings());
                  Navigator.push(context, route).then((value) {
                    if (value == true) {
                      settingScreenWatch.updateAmountWidget(
                          signUpSubscriptionAmountWatch.strAmount);
                      _updateSettingsApi(settingScreenWatch,
                          isPushNotification: false,
                          isEmailNotification: false,
                          isSmsNotification: false,
                          isRequestAnalysis: true);
                    }
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Constant.clrDarkByScaffoldTheme(context),
                ),
                child: CommonSettingsHelper(
                  title: "Key_RequestAnalysisCaps",
                  subTitle: "Key_RequestAnalysisNote",
                  onChanged: (val) {
                    settingScreenWatch
                        .updateRequestAnalysisStatus(val == false ? "0" : "1");
                    if (settingScreenWatch.isRequestAnalysisStatus == "0") {
                      _updateSettingsApi(settingScreenWatch,
                          isPushNotification: false,
                          isEmailNotification: false,
                          isSmsNotification: false,
                          isRequestAnalysis: true);
                    }
                    if (settingScreenWatch.isRequestAnalysisStatus == "1") {
                      Route route = SlideRightPageRoute(
                          builder: (context) => RequestAnalysisScreenSignUp(
                              amount: settingScreenWatch
                                  .updateSettingResponseModel
                                  ?.data
                                  ?.requestAnalysisAmount,
                              userID: '',
                              fromScreen: ScreenName.SettingScreen),
                          settings: const RouteSettings());
                      Navigator.push(context, route).then((value) {
                        if (value == true) {
                          settingScreenWatch.updateAmountWidget(
                              signUpSubscriptionAmountWatch.strAmount);
                          _updateSettingsApi(settingScreenWatch,
                              isPushNotification: false,
                              isEmailNotification: false,
                              isSmsNotification: false,
                              isRequestAnalysis: true);
                        }
                      });
                    }
                  },
                  status: settingScreenWatch.isRequestAnalysisStatus == "0"
                      ? false
                      : true,
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 15.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Constant.clrDarkByScaffoldTheme(context),
                ),
                child: InkWell(
                  onTap: () {
                    Route route = SlideRightPageRoute(
                        builder: (context) => const SubscriptionPlanScreen(),
                        settings: const RouteSettings());
                    Navigator.push(context, route);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          getLocalValue("Key_MySubscriptionPlans"),
                          style: TextStyles.txtMedium14
                              (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
                        ),
                      ),
                      Transform.rotate(
                        angle: ref.watch(drawerProvider).isEngEnable == false
                            ? pi
                            : 0,
                        child: CommonSVG(
                          strIcon: Constant.svgForward,
                          height: 30.h,
                          width: 30.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          getUserStatus() != guest
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30.h,
                    ),
                    TextButton(
                      onPressed: () {
                        showConfirmationDialog(
                          context,
                          '',
                          getLocalValue("Key_DeleteAccount"),
                          getLocalValue("Key_DeleteAccountMsg"),
                          (isPositive) async {
                            if (isPositive) {
                              //trackEvent("account_deleted", {"user_id": getUserEntityId()});
                              _deleteAccountApi(settingScreenWatch);
                            }
                          },
                          borderRadius: 16.r,
                          dialogInsidePadding: EdgeInsets.symmetric(
                              vertical: 25.h, horizontal: 15.w),
                          titleTextStyle: TextStyles.txtMedium24(context).copyWith(
                              fontSize: 22.sp,
                              color: Constant.clrTextGreyByTheme(context)),
                          messageTextStyle: TextStyles.txtMedium14
                              (context).copyWith(color: Constant.clrTextGreyByTheme(context)),
                          msgTxtPadding: EdgeInsets.only(
                              top: 5.h, bottom: 10.h, left: 41.w, right: 41.w),
                          buttonRadius: 30.r,
                          yesBtnWidth: 145.w,
                          yesBtnBGClr: Constant.clrWhite,
                          yesBtnBorderClr: Constant.clrGreyNew,
                          yesBtnTextClr: Constant.clrBlackNew,
                          noBtnWidth: 145.w,
                          noBtnBGClr: Constant.clrPrimary,
                          noBtnBorderClr: Constant.clrPrimary,
                          noBtnTextClr: Constant.clrWhite,
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonImageAsset(
                            strIcon: Constant.icDelete,
                            clrImg: Constant.clrRed,
                          ),
                          SizedBox(
                            width: 6.w,
                          ),
                          Text(
                            getLocalValue("Key_DeleteAccount"),
                            style: TextStyles.txtMedium12(context).copyWith(
                                color: Constant.clrRed,
                                decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  /// Update Settings API
  Future _updateSettingsApi(SettingsScreenController settingsWatch,
      {required bool isPushNotification,
      required bool isRequestAnalysis,
      required bool isSmsNotification,
      required bool isEmailNotification}) async {
    if (isInternetConnectionOn) {
      await settingsWatch.updateSettingsApi(context,
          isPushNotification: isPushNotification,
          isRequestAnalysis: isRequestAnalysis,
          isSmsNotification: isSmsNotification,
          isEmailNotification: isEmailNotification);
      if (settingsWatch.updateSettingResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        showLog("success");
      }
    }
  }

  ///Delete Account API
  Future _deleteAccountApi(SettingsScreenController settingsWatch) async {
    if (isInternetConnectionOn) {
      await settingsWatch.deleteAccountApi(context);
      if (settingsWatch.deleteAccountResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        showLog("success");
        showLog("Tap On Delete Yes");
        logoutAction(context);
        Route route = SlideRightPageRoute(
            builder: (context) => SignInScreen( trader,"",),
            settings: const RouteSettings());
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
      }
    }
  }
}
