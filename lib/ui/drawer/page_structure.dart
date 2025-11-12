import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:take_profit/ui/drawer/revenue_screen.dart';
import 'package:take_profit/ui/drawer/setting_screen.dart';
import 'package:take_profit/ui/drawer/supports_screen.dart';
// import 'package:take_profit/ui/profile/edit_profile_screen.dart'; // replaced by ProfileScreen (kept for history)
// import '../../framework/data_provider/profile/profile_provider.dart'; // not needed when opening ProfileScreen directly
import '../profile/profile_screen.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../utils/const.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../cms/cms_screen.dart';
import '../home/dashboard_screen.dart';
import '../notification/notification_screen.dart';
import '../request_analysis/request_analysis_screen.dart';
import 'drawer_menu.dart';


class PageStructure extends ConsumerStatefulWidget {
  final String? title;
  final Widget? child;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;

  const PageStructure({
    Key? key,
    this.title,
    this.child,
    this.actions,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  ConsumerState<PageStructure> createState() => _PageStructureState();
}

class _PageStructureState extends ConsumerState<PageStructure>  {
  int currentPos = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final drawerWatch = ref.watch(drawerProvider);
    // final profileWatch = ref.watch(profileProvider); // replaced by ProfileScreen, not needed here
    currentPos = drawerWatch.drawerPosition;
    Widget? screenCurrent;
    if (getUserStatus() == trader) {
      switch (currentPos) {
        case 0:
          screenCurrent = const DashboardScreen();
          break;
        /*case 1:
          screenCurrent = const FavoriteScreen();
          break;*/
        case 1:
          screenCurrent = const RequestAnalysisScreen();
          break;
        case 2:
          screenCurrent = const NotificationScreen(isFromDrawer: true);
          break;
        case 3:
          screenCurrent = const SettingsScreen();
          break;
        case 4:
          screenCurrent = const CmsScreen(
            isFromDrawer: true,
          );
          break;
        case 5:
          // screenCurrent = const SupportsScreen(); // Support hidden as requested
          // screenCurrent = EditProfileScreen(
          //   profileData: profileWatch.profileDetailResponseModel?.data,
          // );
          screenCurrent = const ProfileScreen();
          break;
        case 1000:
          screenCurrent = const DashboardScreen();
          break;
      }
    } else if (getUserStatus() == recommender) {
      switch (currentPos) {
        case 0:
          screenCurrent = const DashboardScreen();
          break;
        case 1:
          screenCurrent = const MyRevenue(
            isFromDrawer: true,
          );
          break;
        case 2:
          screenCurrent = const RequestAnalysisScreen();
          break;
       /* case 3:
          screenCurrent = const FavoriteScreen();
          break;*/
        case 3:
          screenCurrent = const SettingsScreen();
          break;
        case 4:
          screenCurrent = const CmsScreen(
            isFromDrawer: true,
          );
          break;
        case 5:
          // screenCurrent = const SupportsScreen(); // Support hidden as requested
          // screenCurrent = EditProfileScreen(
          //   profileData: profileWatch.profileDetailResponseModel?.data,
          // );
          screenCurrent = const ProfileScreen();
          break;
        case 1000:
          screenCurrent = const DashboardScreen();
          break;
      }
    } else {
      switch (currentPos) {
        case 0:
          screenCurrent = const DashboardScreen();
          break;
        case 1:
          screenCurrent = const SettingsScreen();
          break;
        case 2:
          screenCurrent = const CmsScreen(
            isFromDrawer: true,
          );
          break;
        case 3:
          // screenCurrent = const SupportsScreen(); // Support hidden as requested
          // screenCurrent = EditProfileScreen(
          //   profileData: profileWatch.profileDetailResponseModel?.data,
          // );
          screenCurrent = const ProfileScreen();
          break;
        case 1000:
          screenCurrent = const DashboardScreen();
          break;
      }
    }

    return WillPopScope(
      onWillPop: () async {
        showLog(".........currentPos....$currentPos");
        if (ZoomDrawer.of(context)!.isOpen()) {
          ZoomDrawer.of(context)!.close();
          return false;
        } else {
          showLog("currentPos $currentPos");
          if (currentPos > 0) {
            showLog("currentPos $currentPos");
            _updatePage(0);
            drawerWatch.updateUi();
            return false;
          }

          /// Showing Exit Dialog Box if Its in Home Page
          if (currentPos == 0) {
            showLog("currentPos if $currentPos");
            final value = await showExitDialog();
            return value == true;
          } else {
            showLog("currentPos else $currentPos");
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const DrawerMenu()),
                (Route<dynamic> route) => false);
            return false;
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Constant.clrScaffoldBGDarkMode,
        body: screenCurrent,
      ),
    );
  }

  void _updatePage(int index) {
    final drawerWatch = ref.watch(drawerProvider);
    drawerWatch.updateDrawerPosition(index);
  }

  /// Exit dialog
  showExitDialog() {
    return showDialog<bool>(
      barrierDismissible: true,
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Constant.clrScaffoldBGByTheme(context),
        insetPadding: EdgeInsets.all(16.sp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScreenUtil().setWidth(5),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
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
                    getLocalValue("Key_ExitMSG"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: Constant.clrTextMainFontByTheme(context),
                        fontWeight: Constant.fwMedium,
                        fontFamily: Constant.fontFamily),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommonButton(
                        width: 130.w,
                        borderRadius: 15.r,
                        label: getLocalValue("Key_YES"),
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        borderColor: Constant.clrPrimary,
                        bgColor: Constant.clrWhite,
                        labelColor: Constant.clrDarkBlue,
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      CommonButton(
                        labelColor: Constant.clrWhite,
                        label: getLocalValue("Key_No"),
                        width: 130.w,
                        borderRadius: 15.r,
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        borderColor: Constant.clrPrimary,
                        bgColor: Constant.clrPrimary,
                      ),
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
}
