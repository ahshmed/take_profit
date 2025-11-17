import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../../utils/theme_const.dart';
import '../../../utils/const.dart';
import '../../data_provider/drawer/settings_screen_controller.dart';
import '../../data_provider/home/dashboard_screen_controller.dart';
import 'package:easy_localization/easy_localization.dart';


class CustomDrawerController extends ChangeNotifier  {
  int drawerPosition = 0;
  bool _forTrader = false;

  bool isEngEnable = true;
  bool isChangingLanguage = false;

   updateLanguageToggle(bool value) {
    isEngEnable = value;

    notifyListeners();
  }

   updateUi() {
    notifyListeners();
  }

  /// Centralized language change flow.
  ///
  /// Parameters:
  /// - [context]: required for locale change and UI feedback.
  /// - [value]: new language toggle (true => English).
  /// - [settingsWatch]: controller to call settings API when user is logged in.
  /// - [dashboardWatch]: controller to reset dashboard state.
  /// - [recommenderDetailsCallback]: callback to refresh recommender details.
  Future<void> changeLanguage(BuildContext context, bool value,
      SettingsScreenController settingsWatch,
      DashboardScreenController dashboardWatch,
      {required Future<void> Function() recommenderDetailsCallback}) async {
    if (isChangingLanguage) return;
    isChangingLanguage = true;
    // immediately update UI toggle
    isEngEnable = value;
    notifyListeners();
    try {
      // update server-side settings if user is not guest
      if (getUserStatus() != guest) {
        await settingsWatch.updateSettingsApi(context,
            isLanguageChange: true, isEngEnableToggle: value);
      }

      // persist locally
      await saveLocalData(KEY_APP_LANGUAGE, value ? 'en' : 'ar');

      // update locale
      await context.setLocale(Locale(value ? 'en' : 'ar'));

      // reset dashboard and related data
      dashboardWatch.clearProvider();
      dashboardWatch.bottomTabInit();

      // refresh recommender details via provided callback
      await recommenderDetailsCallback();

      dashboardWatch.updateWidget();
      updateUi();

      // close drawer if open
      ZoomDrawer.of(context)?.toggle();
    } catch (e, st) {
      showLog('Language switch error: $e\n$st');
      // revert toggle on failure and notify UI
      isEngEnable = !value;
      notifyListeners();
      // show error to user
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(getLocalValue("Key_FailedToChangeLanguage"))),
        );
      } catch (_) {
        // ignore if context is invalid
      }
    } finally {
      isChangingLanguage = false;
      notifyListeners();
    }
  }

  bool get darkTheme => _forTrader;

   updateUserType(bool trader, recommender) {
    // saveLocalDataForUserType(false,trader,recommender);
    _forTrader = trader;
    notifyListeners();
  }

  var menuOptions = [];

   setMenuItems() {
    menuOptions = [
      {"icon": Constant.icHomeDN, "title": "Key_Home"},
      {"icon": Constant.icSettingsDN, "title": "Key_Settings"},
      {"icon": Constant.icTermsDN, "title": "Key_TermsOfService"},
      // {"icon": Constant.icSupport, "title": "Key_Support"}, // Support hidden as requested
      // {"icon": Constant.icEditProfile, "title": "Key_EditProfile"}, // Replaced by Profile (kept for history)
      {"icon": Constant.icProfileDN, "title": "Key_Profile"}, // Added Profile in drawer
    ];
    notifyListeners();
  }

   setMenuItemsForTraders() {
    menuOptions = [
      {"icon": Constant.icHomeDN, "title": "Key_Home"},
      // {"icon": icFavourite, "title": "Key_MyFavorite"},
      {"icon": Constant.icConsDN, "title": "Key_RequestAnalysis"},
      {"icon": Constant.icNotifDN, "title": "Key_Notification"},
      {"icon": Constant.icSettingsDN, "title": "Key_Settings"},
      {"icon": Constant.icTermsDN, "title": "Key_TermsOfService"},
      // {"icon": Constant.icSupport, "title": "Key_Support"}, // Support hidden as requested
      // {"icon": Constant.icEditProfile, "title": "Key_EditProfile"}, // Replaced by Profile (kept for history)
      {"icon": Constant.icProfileDN, "title": "Key_Profile"}, // Added Profile in drawer
    ];
    notifyListeners();
  }

  setMenuItemsForRecommender() {
    menuOptions = [
      {"icon": Constant.icHomeDN, "title": "Key_Home"},
      // {"icon": Constant.icRevenue, "title": "Key_MyRevenue"}, // Hidden for recommender users
      {"icon": Constant.icConsDN, "title": "Key_RequestAnalysis"},
      // {"icon": icFavourite, "title": "Key_MyFavorite"},
      // {"icon": icMenuNotification, "title": "Key_Notification"},
      {"icon": Constant.icSettingsDN, "title": "Key_Settings"},
      {"icon": Constant.icTermsDN, "title": "Key_TermsOfService"},
      // {"icon": Constant.icSupport, "title": "Key_Support"}, // Support hidden as requested
      // {"icon": Constant.icEditProfile, "title": "Key_EditProfile"}, // Replaced by Profile (kept for history)
      {"icon": Constant.icProfileDN, "title": "Key_Profile"}, // Added Profile in drawer
    ];
    notifyListeners();
  }

  ///update drawer
   updateDrawerPosition(int value) {
    drawerPosition = value;
    notifyListeners();
  }
}
