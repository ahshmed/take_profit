// ignore_for_file: unused_local_variable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/drawer/drawer_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/drawer/settings_screen_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'drawer_menu.dart';


class CustomDrawer extends ConsumerStatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends ConsumerState<CustomDrawer>  {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static ZoomDrawerController controller = ZoomDrawerController();

  ///Init
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      showLog("current user in custom drawer screen ${getUserStatus()}");
      final drawerWatch = ref.watch(drawerProvider);
      final dashboardWatch = ref.watch(dashboardProvider);
      if (getUserStatus() == trader) {
        drawerWatch.setMenuItemsForTraders();
      } else if (getUserStatus() == recommender) {
        drawerWatch.setMenuItemsForRecommender();
      } else {
        drawerWatch.setMenuItems();
      }

      drawerWatch.updateLanguageToggle(getAppLanguage() == "en" ? true : false);
      dashboardWatch.clearProvider();
      dashboardWatch.bottomTabInit();
      dashboardWatch.tabBody = const HomeScreen();
      dashboardWatch.updateWidget();
    });
  }

  ///Build
  @override
  Widget build(BuildContext context) {
    final drawerWatch = ref.watch(drawerProvider);
    final darkModeWatch = ref.watch(darkProvider);
    final settingsWatch = ref.watch(settingsScreenProvider);
    final dashboardWatch = ref.watch(dashboardProvider);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      body: Container(
        padding: EdgeInsets.only(top: 30.h),
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: [
            ListView(
              children: <Widget>[
                /// Drawer Profile Widget
                widgetUserProfile().paddingOnly(bottom: 20.h),

                /// Switch to trader or Recommender
                Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CommonButton(
                      //   width: 154.w,
                      //   height: 37.h,
                      //   padding: 6.w,
                      //   textSize: 10.sp,
                      //   bgColor: clrPrimary,
                      //   labelColor: clrWhite,
                      //   label: getUserStatus() == trader
                      //       ? "Key_SwitchToRecommender".localized
                      //       : getUserStatus() == recommender
                      //           ? "Key_SwitchToTrader".localized
                      //           : "Key_Login".localized,
                      //   onTap: () {
                      //     // if (getUserStatus() == guest) {
                      //     //   Route route = SlideRightPageRoute(
                      //     //     builder: (context) =>
                      //     //         SignInScreen(role: trader),
                      //     //     settings: const RouteSettings(),
                      //     //   );
                      //     //   Navigator.pushAndRemoveUntil(
                      //     //       context, route, (route) => false);
                      //     // } else {
                      //     //   apiSwitchAccount();
                      //     // }
                      //   },
                      // ),
                      // SizedBox(
                      //   height: 20.h,
                      // ),

                      /// Dark Mode Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Key_DarkMode".localized,
                            style: TextStyles.txtMedium12(context).copyWith(
                              color: Constant.clrWhiteBlackByTheme(context),
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Switch(
                            activeColor: (Constant.clrPrimary),
                            value: darkModeWatch.darkTheme,
                            inactiveTrackColor: Constant.clrBlackNew,
                            onChanged: (isDarkModeEnable) {
                              showLog("switch val: $isDarkModeEnable");
                              darkModeWatch.updateIsDarkMode(
                                  true, isDarkModeEnable);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// menu list
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: drawerWatch.menuOptions.length,
                  itemBuilder: (context, pos) {
                    return InkWell(
                      onTap: () {
                        controller.stateNotifier?.value;
                        ZoomDrawer.of(context)!.toggle();
                        final titleKey = drawerWatch.menuOptions[pos]['title']?.toString() ?? "";
                        final isAuthRequiredItem = titleKey == "Key_Settings" || titleKey == "Key_Profile";

                        if(getUserStatus() == guest && isAuthRequiredItem) {
                          //show sign in /signup and prevent navigation to screen
                          getStartedDialog(context);
                          return; //IMPORTANT: don't update drawer position
                        }
                        // if (getUserStatus() == guest && pos == 1) {
                        //   getStartedDialog(context);
                        // } else {
                        //   drawerWatch.updateDrawerPosition(pos);
                        // }
                        //proceed normally for allowed items
                        drawerWatch.updateDrawerPosition(pos);

                        if (drawerWatch.drawerPosition == 0) {
                          final dashboardWatch = ref.watch(dashboardProvider);
                          dashboardWatch.clearProvider();
                          dashboardWatch.updateHome(true);
                           dashboardWatch.bottomTabInit();
                          dashboardWatch.tabBody = const HomeScreen();
                          drawerWatch.updateDrawerPosition(1000);
                        }
                      },
                      child: widgetText(
                          drawerWatch.menuOptions[pos]["title"]
                              .toString()
                              .localized,
                          drawerWatch.menuOptions[pos]["icon"],
                          pos,
                          drawerWatch),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: getAppLanguage() == 'ar' ? 15.w : 0,
                      left: getAppLanguage() == 'ar' ? 0 : 15.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        Constant.icLanguage,
                        width: 20.h,
                        height: 20.h,
                        color: Constant.clrWhiteBlackByTheme(context),
                      ),
                      SizedBox(
                        width: 11.w,
                      ),
                      Text(
                        !drawerWatch.isEngEnable
                            ? "Key_EnglishLanguage".localized
                            : "Key_ArabicLanguage".localized,
                        style: TextStyles.txtMedium12(context).copyWith(
                          color: Constant.clrWhiteBlackByTheme(context),
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Switch(
                        activeColor: (Constant.clrPrimary),
                        value: drawerWatch.isEngEnable,
                        inactiveTrackColor: Constant.clrBlackNew,
                        onChanged: (isEngEnable) async {
                          drawerWatch.updateLanguageToggle(isEngEnable);
                          showLog("switch val: $isEngEnable");

                          // Update server settings if logged in
                          if (getUserStatus() != guest) {
                            _updateSettingsApi(
                                settingsWatch, true, isEngEnable);
                          }

                          // Save language preference
                          await saveLocalData(KEY_APP_LANGUAGE,
                              drawerWatch.isEngEnable == true ? "en" : "ar");

                          // Update locale - this will trigger MaterialApp to rebuild
                          await context.setLocale(Locale(
                              drawerWatch.isEngEnable == true ? "en" : "ar"));

                          // Close drawer
                          ZoomDrawer.of(context)!.close();

                          // Wait a bit for the locale change to propagate
                          await Future.delayed(const Duration(milliseconds: 500));

                          // Force rebuild of the entire widget tree without navigation
                          if (mounted) {
                            // Reset dashboard state
                            dashboardWatch.clearProvider();
                            dashboardWatch.bottomTabInit();
                            dashboardWatch.tabBody = const HomeScreen();
                            dashboardWatch.updateWidget();
                            drawerWatch.updateUi();

                            // Pop to root if not already there
                            while (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 20.w, top: 10.h, bottom: 10.h, right: 170.w),
                  child: Container(
                    color: Constant.clrGrey,
                    width: 2.w,
                    height: 2.h,
                  ),
                ),

                InkWell(
                  onTap: () {
                    if (getUserStatus() == guest) {
                      getStartedDialog(context);
                    } else {
                      logoutDialog(context, (action) async {
                        if (action) {
                          await apiLogout();
                        }
                      });
                    }
                  },
                  child: widgetText(
                      getUserStatus() == guest
                          ? "Key_LoginSignUp".localized
                          : "Key_Logout".localized,
                      Constant.icLogout,
                      1,
                      drawerWatch),
                ),

                InkWell(
                    splashColor: Constant.clrTransparent,
                    highlightColor: Constant.clrTransparent,
                    onTap: () {
                      showLog('getDeviceFCMToken() ${getDeviceFCMToken()}');
                      Clipboard.setData(
                          ClipboardData(text: getDeviceFCMToken()));
                    },
                    child: const SizedBox(
                      height: 30,
                      width: 30,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// open Drawer
  static void openDrawer(BuildContext context) {
    controller.open;
  }

  /// Widget Icon With Text
  Widget widgetText(String str, String strIcon, int index,
      CustomDrawerController drawerWatch) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          start: 15.w, end: 0, top: 15.h, bottom: 15.h),
      child: Row(
        children: <Widget>[
          strIcon == ""
              ? const SizedBox()
              : Image.asset(
                  strIcon,
                  color: Constant.clrWhiteBlackByTheme(context),
                  width: 20.h,
                  height: 20.h,
                ),
          SizedBox(
            width: 11.w,
          ),
          str == ""
              ? const SizedBox()
              : Text(
                  str,
                  style: TextStyles.txtMedium12(context).copyWith(
                    color: Constant.clrWhiteBlackByTheme(context),
                  ),
                ),
        ],
      ),
    );
  }

  /// widget User Profile
  Widget widgetUserProfile() {
    final drawerWatch = ref.watch(drawerProvider);
    final profileWatch = ref.watch(profileProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  showLog("Tap Profile");
                  if (getUserStatus() != guest) {
                    final dashboardWatch = ref.watch(dashboardProvider);
                    dashboardWatch.clearProvider();
                    dashboardWatch.updateProfile(true);
                    dashboardWatch.bottomTabInit();
                    dashboardWatch.tabBody = const ProfileScreen();
                    drawerWatch.updateDrawerPosition(1000);
                    ZoomDrawer.of(context)!.toggle();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    // border: Border.all(width: 2, color: clrGrey)
                  ),
                  // padding: EdgeInsets.all(10.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      10.r,
                    ),
                    child: (){
                      final isGuest = getUserStatus() == guest;
                      final imageUrl = profileWatch.profileDetailResponseModel?.data?.profileImage;
                      final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

                      if(!isGuest && hasImage) {
                        return CacheImage(
                          imageURL: imageUrl,
                          isProfileImg: true,
                          height: 40.h,
                          width: 40.h,
                          contentMode: BoxFit.cover);
                      }else {
                        //Guest Or Logged in user without image
                        return CommonImageAsset(
                          strIcon: Constant.icGuestN,
                          height: 40.h,
                          width: 40.h,
                          boxFit: BoxFit.cover,
                        );
                      }
                      }(),
                  ),

                ),
              ),
              SizedBox(
                width: 20.w,
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: getUserStatus() != guest,
                      child: Text(
                        getAppLanguage() == 'ar'
                            ? (profileWatch
                                    .profileDetailResponseModel?.data?.nameAr ??
                                "")
                            : (profileWatch
                                    .profileDetailResponseModel?.data?.nameEn ??
                                ""),
                        style: TextStyles.txtMedium16(context).copyWith(
                          color: Constant.clrWhiteBlackByTheme(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      getUserStatus() == trader
                          ? "Key_Trader".localized
                          : getUserStatus() == recommender
                              ? "Key_Recommender".localized
                              : "Key_guest".localized,
                      style: (getUserStatus() == guest)
                          ? TextStyles.txtMedium16
                              (context).copyWith(color: Constant.clrWhiteBlackByTheme(context))
                          : TextStyles.txtRegular12(context).copyWith(
                              color: Constant.clrBlackNew,
                            ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  ZoomDrawer.of(context)!.toggle();
                },
                child: Image.asset(Constant.icCancel),
              ),
              SizedBox(width: 20.w),
            ],
          ),
        ],
      ),
    );
  }

  ///APi For Logout
  Future<void> apiLogout() async {
    final loginWatch = ref.watch(signInProvider);
    final dashboardWatch = ref.watch(dashboardProvider);
    final profileWatch = ref.watch(profileProvider);
    final drawerWatch = ref.watch(drawerProvider);
    if (isInternetConnectionOn) {
      await loginWatch.logoutApi(context);

      loginWatch.updateWidget();

      if (loginWatch.commonResponseModel?.status ==
              ApiEndPoints.apiStatus_200.toString() ||
          loginWatch.commonResponseModel?.status ==
              ApiEndPoints.apiStatus_401.toString()) {
        await logoutAction(context);
        dashboardWatch.updateProfile(false);
        dashboardWatch.bottomTabInit();
        dashboardWatch.updateWidget();
        drawerWatch.updateDrawerPosition(0);
        await drawerWatch.updateDrawerPosition(0);

        profileWatch.profileDetailResponseModel = null;
        await loginWatch.updateWidget();
        Route route = SlideRightPageRoute(
            builder: (context) => const DrawerMenu(),
            settings: const RouteSettings());
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
        getStartedDialog(context, canPop: false);
        dashboardWatch.updateWidget();
        ZoomDrawer.of(context)!.toggle();
      }
    }
  }

  // /// Switch account
  // Future apiSwitchAccount() async {
  //   final loginWatch = ref.watch(signInProvider);
  //   final dashboardWatch = ref.watch(dashboardProvider);
  //   final drawerWatch = ref.watch(drawerProvider);
  //   dashboardWatch.clearProvider();
  //   dashboardWatch.updateProfile(false);
  //   dashboardWatch.bottomTabInit();
  //   dashboardWatch.updateWidget();
  //   drawerWatch.updateDrawerPosition(0);
  //
  //   if (isInternetConnectionOn) {
  //     await loginWatch.switchAccountApi(context);
  //     if (loginWatch.switchAccountResponseModel?.status ==
  //         ApiEndPoints.apiStatus_200) {
  //       if (getUserStatus() != guest) {
  //         showLog("Current User Type:- ${getUserStatus()}");
  //         Route route = SlideRightPageRoute(
  //             builder: (context) => const DrawerMenu(),
  //             settings: const RouteSettings());
  //         Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  //       } else {
  //         Route route = SlideRightPageRoute(
  //             builder: (context) => SignInScreen(role: trader),
  //             settings: const RouteSettings());
  //         Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  //       }
  //     }
  //   }
  // }

  // /// Get Trending List
  // Future _getTrendingList() async {
  //   final trendingWatch = ref.watch(trendingViewAllProvider);
  //   if (isInternetConnectionOn) {
  //     await trendingWatch.trendingListAPI(context, "");
  //   }
  // }

  /// Get Recommender Detail
  Future recommenderDetailsApiCall() async {
    final homeWatch = ref.watch(homeProvider);
    final recommenderWatch = ref.watch(recommenderProvider);
    final recommenderId = homeWatch.homeRecommenderDetailsResponseModel?.data?.recommenderId;

    // Only call API if we have a valid recommender ID
    if (isInternetConnectionOn && recommenderId != null && recommenderId.trim().isNotEmpty) {
      await recommenderWatch.recommenderDetailAPI(context, recommenderId);
    }
  }

  /// Update Settings API
  Future _updateSettingsApi(SettingsScreenController settingsWatch,
      bool languageChange, bool isEngEnable) async {
    if (isInternetConnectionOn) {
      await settingsWatch.updateSettingsApi(context,
          isLanguageChange: languageChange, isEngEnableToggle: isEngEnable);
      if (settingsWatch.updateSettingResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {}
    }
  }
}
