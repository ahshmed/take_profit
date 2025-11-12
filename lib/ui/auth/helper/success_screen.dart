import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../../framework/data_provider/auth/auth_provider.dart';
import '../../../framework/data_provider/home/home_provider.dart';
import '../../../framework/data_provider/profile/profile_provider.dart';
import '../../../framework/data_provider/profile/profile_screen_controller.dart';
import '../../../utils/apis/api_end_points.dart';
import '../../../utils/const.dart';
import '../../../utils/sliderightroute.dart';
import '../../../utils/theme_const.dart';
import '../../drawer/drawer_menu.dart';
import '../subscription_amount_screen.dart';


class SuccessScreen extends ConsumerStatefulWidget {
  final String content;
  final bool isFromProfile;
  final bool isChangePassword;
  final ScreenName? fromScreen;
  final String userID;
  final String emailContent;
  final bool isLive;

  const SuccessScreen(
      {Key? key,
      required this.content,
      this.isFromProfile = false,
      this.isChangePassword = false,
      required this.userID,
      this.fromScreen,
      this.emailContent = "",
      this.isLive = true})
      : super(key: key);

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen>  {
  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final profileWatch = ref.watch(profileProvider);
      Future.delayed(const Duration(seconds: 2), () async {
        if (widget.isFromProfile == false && widget.isChangePassword == false) {
          if (getUserStatus() == recommender) {
            showLog(getUserStatus());
            Route route = SlideRightPageRoute(
                builder: (context) => SubscriptionAmountScreen(
                    isRecommender: true, userId: widget.userID),
                settings: const RouteSettings());
            Navigator.of(context).pushReplacement(route);
          }
          if (getUserStatus() == trader) {
            showLog(getUserStatus());
            final completeProfileWatch = ref.watch(signUpBankDetailScreenProvider);
            if (isInternetConnectionOn) {
              await completeProfileWatch.completeProfileApi(context, widget.userID, "",
                  currencyList: []);
              if (completeProfileWatch.completeProfileModel?.status ==
                  ApiEndPoints.apiStatus_200.toString()) {
                saveLocalData(KEY_USER_ENTITY_ID, widget.userID);

                showLog(
                    "token ${completeProfileWatch.completeProfileModel?.data?.token}");
                showLog(
                    completeProfileWatch.completeProfileModel?.data?.token.toString() ??
                        "");
                final dashboardWatch = ref.watch(dashboardProvider);
                dashboardWatch.clearProvider();

                /// For Displaying Profile Data in Drawer
                final profileWatch = ref.watch(profileProvider);
                await profileWatch.profileAPI(context);
                saveLocalData(KEY_USER_STATUS,
                    profileWatch.profileDetailResponseModel?.data?.userType);
                saveLocalData(KEY_USER_ACCESS_TOKEN,
                    completeProfileWatch.completeProfileModel?.data?.token);

                Route route = SlideRightPageRoute(
                    builder: (context) => const DrawerMenu(),
                    settings: const RouteSettings());
                Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
              }
            }
          }
        }
        if (widget.fromScreen == ScreenName.FromPaymentScreen) {
          showLog("From Payment Screen");
          if(widget.isLive) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pop(true);
          // Navigator.of(context).pop();
        }
        if (widget.fromScreen == ScreenName.RecommenderDetailsScreen) {
          showLog("From Recommender Details Screen");
          if (mounted) {
            if(widget.isLive) {
              Navigator.of(context).pop();
            }
            Navigator.of(context).pop(true);
          }
        }
        if (widget.fromScreen == ScreenName.RecommenderBioScreen) {
          showLog("From Recommender Bio Screen");
          if (mounted) {
            if(widget.isLive) {
              Navigator.of(context).pop();
            }
            Navigator.of(context).pop();
            Navigator.of(context).pop(true);
          }
        }
        if (widget.isFromProfile == true && widget.isChangePassword == true) {
          showLog(getUserStatus());
          showLog("is change password from profile");
          Navigator.of(context).pop();
        }
        if (widget.isFromProfile == false && widget.isChangePassword == true) {
          showLog(getUserStatus());
          showLog("is change password from sign in");
          if(widget.isLive) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pop();
        }
        if (widget.emailContent == "" &&
            widget.isFromProfile == true &&
            widget.isChangePassword == false) {
          showLog("is from profile update mobile number");
          if(widget.isLive) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pop();
          profileAPI(profileWatch);
        }
        if (widget.emailContent != "" && widget.isFromProfile == true) {
          showLog("is from profile update email");
          if(widget.isLive) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pop();
          profileAPI(profileWatch);
        }
      });
    });
  }

  ///Main build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyWidget(),
    );
  }

  ///body widget
  Widget bodyWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: SizedBox(
        height: Constant.infiniteSize,
        width: Constant.infiniteSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(Constant.icSuccess, height: 234.h, width: 234.h),
            SizedBox(
              height: 26.h,
            ),
            Text(
              !widget.isFromProfile
                  ? widget.fromScreen == ScreenName.FromPaymentScreen
                      ? ("Key_PaymentSuccessful".localized + "!")
                      : "${getLocalValue("Key_Success")}!"
                  : widget.isChangePassword
                      ? "${getLocalValue("Key_PasswordChanged")}!"
                      : widget.emailContent == ""
                          ? getLocalValue("Key_MobileNumberUpdated")
                          : getLocalValue(widget.emailContent),
              style: TextStyles.txtSemiBold26(context),
            ),
            SizedBox(
              height: 12.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Text(
                getLocalValue(widget.content),
                style: TextStyles.txtRegular12(context),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Profile API Call
  Future<void> profileAPI(ProfileScreenController profileWatch) async {
    if (isInternetConnectionOn) {
      await profileWatch.profileAPI(context);
    }
  }
}
