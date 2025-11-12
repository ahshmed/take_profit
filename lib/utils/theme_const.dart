// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'const.dart';

enum CMSType {
  None,
  AboutUs,
  TermsOfServices,
  PrivacyPolicy,
  FAQ,
}

enum SeeAllScreen {
  fromCurrencyScreen,
  fromSearchScreen,
  fromMyRecommenderSignalActive,
  fromMyRecommenderSignalClosed,
  fromMyRecommenderSignalPending,
  fromRecommenderDetailsActive,
  fromRecommenderDetailsClosed,
  fromRecommenderDetailsPending
}

class Constant {
  static String appName = "TakeProfit";

  /*
  * -- Dimen
  * */
  static double infiniteSize = double.infinity;

  /*
  * -- Time Formate
  * */
  static String str12Hr = "hh:mm a";
  static String str24Hr = "hh:mm:ss";

  /*
  * ------------------------ Colors ----------------------------------------- *
  * */
  static MaterialColor colorPrimary = MaterialColor(0xff6A71CE, colorSwathes);

  static Map<int, Color> colorSwathes = {
    50: const Color.fromRGBO(106, 113, 206, .1),
    100: const Color.fromRGBO(106, 113, 206, .2),
    200: const Color.fromRGBO(106, 113, 206, .3),
    300: const Color.fromRGBO(106, 113, 206, .4),
    400: const Color.fromRGBO(106, 113, 206, .5),
    500: const Color.fromRGBO(106, 113, 206, .6),
    600: const Color.fromRGBO(106, 113, 206, .7),
    700: const Color.fromRGBO(106, 113, 206, .8),
    800: const Color.fromRGBO(106, 113, 206, .9),
    900: const Color.fromRGBO(106, 113, 206, 1),
  };

  static Color clrScaffoldBG = const Color(0xffF5F6F9);
  static Color clrScaffoldBGDarkMode = const Color(0xff191919);
  static Color clrPrimary = const Color(0xff7063BF);
  static Color clrPrimaryLight = const Color(0xffD5CEFF);
  static Color clrPrimaryExtraLight = const Color(0xffF8F6FF);
  static Color clrLightPurple = const Color(0xffF5F4F9);
  static Color clr3A0360 = const Color(0xff3A0360);
  static Color clrBlackOrigin = const Color(0xff111111);
  static Color clrWhite = const Color(0xffFFFFFF);
  static Color clrBGLightGrey = const Color(0xffF5F6F9);
  static Color clrSearchFont = const Color(0xff858585);
  static Color clrMainFont = const Color(0xff4A4949);
  static Color clrTextGrey = const Color(0xff979797);
  static Color clrDarkGrey = const Color(0xff4E4E4E);
  static Color clrLightGrey = const Color(0xff979797);
  static Color clrDarkRed = const Color(0xffFF3B3B);
  static Color clrHintText = const Color(0xffB8B8B8);
  static Color clrTransparent = const Color(0x00000000);
  static Color clrGreyCardBg = const Color(0xffDCDCDC);
  static Color clrDarkBlue = const Color(0xff1D0330);
  static Color clrRed = const Color(0xffF35353);
  static Color clrYellow = const Color(0xffFFBD19);
  static Color clrDarkPurple = const Color(0xff6622BD);
  static Color clrDarkGreen = const Color(0xff009C4D);
  static Color clrDarkGreenNew = const Color(0xff00994B);
  static Color clrLightRed = const Color(0xffF85757);
  static Color clrGrey = const Color(0xffE8E8EC);
  static Color clrGreyNew = const Color(0xffCFCFCF);
  static Color clrGreyNewDark = const Color(0xffC8C8C8);
  static Color clrWhiteNew = const Color(0xffFCFCFC);
  static Color clrBlackNew = const Color(0xff5B5B5B);
  static Color clrSwithcInActive = const Color(0xfff5f5f6);
  static Color clrGrey2 = const Color(0xff707070);
  static Color clrGreyShadow = const Color(0xff707070);
  static Color clrBlue = const Color(0xff007AFF);
  static Color clrWhatsapp = const Color(0xff25d366);
  static Color clrCalenderBtn = const Color(0xffD0D3DD);
  static Color clrBoxBorderD = const Color(0x0ff2f2f2);
  static Color clrBoxBorderN = const Color(0x0f252525);
  static Color clrGreen = const Color(0x0f0F9F57);
  static Color clrCheckMark = const Color(0xfb2c2c2c);
  static Color clrHint = const Color(0xff757575);
  static Color clrTitle = const Color(0x0f323232);
  static Color clrRedF = const Color(0xffee5a5a);
  static Color clrSecColor = const Color(0xff0F9F57);
  static Color clrMarketColor = const Color(0xff060606);
  static Color clrMarketSelectColor = const Color(0xff4CD964);
  static Color clrPageBackColor = const Color(0xffF9F9F9);
  static Color clrNotSelectNavColor = const Color(0xffA9A9A9);
  static Color clrSignOutRColor = const Color(0xffE23D3D);
  static Color clrSubTitleGColor = const Color(0xff9198A4);
  static Color clrNotifDeleteRColor = const Color(0xffEC3333);
  static Color clrNotifSelectBColor = const Color(0xff3558E5);
  static Color clrCardCurrGColor = const Color(0xffF3F5F9);
  static Color clrHintGColor = const Color(0xff767676);
  static Color clrTextBorderGColor = const Color(0xffF0F0F0);
  static Color clrTextUploadBColor = const Color(0xff007BFA);
  static Color clrTitleUploadBColor = const Color(0xff111220);
  static Color clrSubTitleUploadGColor = const Color(0xff70727E);
  static Color clrIconUploadGColor = const Color(0xffBEBEBE);
  static Color clrDetailsScreenSwitchBColor = const Color(0xff4480FF);
  static Color clrDetailsScreenTargetColor = const Color(0xffF5F7FB);
  static Color clrHeaderSignDetailsColor = const Color(0xff0F0B0B);
  static Color clrHeaderSubSignDetailsColor = const Color(0xffB2B2B2);
  static Color clrSignDetailsEntColor = const Color(0xff2D2D2D);
  static Color clrSignDetailsCopyColor = const Color(0xff617EF0);
  static Color clrSignDetailsInfColor = const Color(0xffFEAE19);
  static Color clrSignDetailsAchColor = const Color(0xff009D4E);
  static Color clrSignDetailsDividerColor = const Color(0xffE1E6F0);
  static Color clrSignDetailsDividerDColor = const Color(0xff242526);
  static Color clrSearchHintColor = const Color(0xff999393);
  static Color clrSearchHintDarkColor = const Color(0xff626262);
  static Color clrSearchBGColor =  Colors.grey.shade200;
  static Color clrSearchBGDarkColor = const Color.fromRGBO(27, 29, 30, 1);
  static Color clrGainColor = const Color(0xff727272);
  static Color clrHomeDividerColor = const Color(0xffD7D7D7);
  static Color clrHomeUnselectedColor = const Color(0xff4A4A4A);
  static Color clrHomeLabelColor = const Color(0xff3D278A);
  static Color clrSelectLabelColor = const Color(0xff666666);

  /*
  * ------------------------ FontStyle ----------------------------------------- *
  * */
  static String get fontFamily => getAppLanguage() == 'en' ? "Gilroy" : "Almarai";

  static FontWeight fwThin = FontWeight.w100;
  static FontWeight fwExtraLight = FontWeight.w200;
  static FontWeight fwLight = FontWeight.w300;
  static FontWeight fwRegular = FontWeight.w400;
  static FontWeight fwMedium = FontWeight.w500;
  static FontWeight fwSemiBold = FontWeight.w600;
  static FontWeight fwSemiBoldG = FontWeight.w400;
  static FontWeight fwBold = FontWeight.w700;
  static FontWeight fwExtraBold = FontWeight.w800;

  // Helper method to get dark mode
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color clrTextByTheme(BuildContext context) => isDarkMode(context) ? clrPrimary : clrMainFont;
  static Color clrPrimaryClr3A0360(BuildContext context) => isDarkMode(context) ? clrPrimary : clr3A0360;
  static Color clrTextGreyByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrMainFont;
  static Color clrButtonByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrWhite;
  static Color clrSearchFontByTheme(BuildContext context) => isDarkMode(context) ? clrPrimary : clrSearchFont;
  static Color clrButtonBGGreyByTheme(BuildContext context) => isDarkMode(context) ? clrPrimary : clrMainFont;
  static Color clrImageColorByTheme(BuildContext context) => isDarkMode(context) ? clrPrimary : clrMainFont;
  static Color clrDrawerBgByTheme(BuildContext context) => isDarkMode(context) ? clrScaffoldBGDarkMode : clrWhiteNew;
  static Color clrTextMainFontByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrMainFont;
  static Color clrWhiteBlackByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrDarkBlue;
  static Color clrTextLightGreyByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrTextGrey;
  static Color clrDarkByScaffoldTheme(BuildContext context) => isDarkMode(context) ? clrBlackOrigin : clrCardCurrGColor;
  static Color clrScaffoldBGByTheme(BuildContext context) => isDarkMode(context) ? clrScaffoldBGDarkMode : clrPageBackColor;
  static Color clrTextDarkGreyByTheme(BuildContext context) => isDarkMode(context) ? clrGreyNew : clrDarkPurple;
  static Color clrCardBGByTheme(BuildContext context) => isDarkMode(context) ? clrDarkGrey : clrWhite;
  static Color clrTitlePageByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrBlackOrigin;
  static Color clrNavByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrNotSelectNavColor;
  static Color clrHintByTheme(BuildContext context) => isDarkMode(context) ? clrHint :clrWhite ;
  static Color clrBoxTheme(BuildContext context) => isDarkMode(context) ? clrBoxBorderN : clrBoxBorderD;
  static Color clrScaffoldSearchByTheme(BuildContext context) => isDarkMode(context) ? clrScaffoldBGDarkMode : clrWhite;
  static Color clrDCardSearchByTheme(BuildContext context) => isDarkMode(context) ? clrBlackOrigin : clrCardCurrGColor;
  static Color clrBasicByTheme(BuildContext context) => isDarkMode(context) ? clrBlackOrigin : clrWhite;
  static Color clrSigDetByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrHeaderSignDetailsColor;
  static Color clrTitleUploadByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrTitleUploadBColor;
  static Color clrSigDetEntByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrSignDetailsEntColor;
  static Color clrSigDetDividerByTheme(BuildContext context) => isDarkMode(context) ? clrSignDetailsDividerDColor : clrSignDetailsDividerColor;
  static Color clrSearchByTheme(BuildContext context) => isDarkMode(context) ? clrSearchBGDarkColor : clrSearchBGColor;
  static Color clrGainByTheme(BuildContext context) => isDarkMode(context) ? clrSearchBGDarkColor : clrWhite;
  static Color clrHomeCardByTheme(BuildContext context) => isDarkMode(context) ? clrSearchBGDarkColor : clrWhite;
  static Color clrSearchHintByTheme(BuildContext context) => isDarkMode(context) ? clrSearchHintDarkColor : clrSearchHintColor;
  static Color clrGantTitleByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrBlackOrigin;
  static Color clrHomeScreenByTheme(BuildContext context) => isDarkMode(context) ? clrBlackOrigin : clrPageBackColor;
  static Color clrSelectMarketByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrSelectLabelColor;

  static Color clrButtonFGByTheme(BuildContext context, bool isOn) => isOn
      ? clrWhite
      : isDarkMode(context)
      ? clrWhite
      : clrDarkBlue;

  static Color clrButtonBGByTheme(BuildContext context, bool isOn) => isOn
      ? isDarkMode(context)
      ? clrPrimary
      : clrMainFont
      : isDarkMode(context)
      ? clrPrimary
      : clrHintText;

  static Color clrButtonBorderByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrMainFont;
  static Color clrDividerByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrTextGrey;
  static Color clrDialogBGByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrBlackNew;
  static Color clrTextFieldTextByTheme(BuildContext context) => isDarkMode(context) ? clrPrimary : clrMainFont;
  static Color clrPrimaryWhiteByTheme(BuildContext context) => isDarkMode(context) ? clrPrimary : clrWhite;
  static Color clrTextFieldBorderColorByTheme(BuildContext context) => isDarkMode(context) ? clrPrimary : clrHintText;
  static Color clrTextFieldDisableBorderColorByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrTransparent;
  static Color clrSuggestionTextByTheme(BuildContext context) => isDarkMode(context) ? clrPrimary : clrTextGrey;
  static Color clrWhiteBlackNewByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrBlackNew;
  static Color clrDarkBlueClrWhiteByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrDarkBlue;
  static Color clrBlackWhiteByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrDarkBlue;
  static Color clrBlackNewLightPurpleByTheme(BuildContext context) => isDarkMode(context) ? clrBlackNew : clrLightPurple;
  static Color clrDarkPurpleWhiteByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrDarkPurple;
  static Color clrWhitePrimaryByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrPrimary;
  static Color clrWhiteGreyNewByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrBlackNew;
  static Color clrGreyTransparentByTheme(BuildContext context) => isDarkMode(context) ? clrTransparent : clrGrey;
  static Color clrGreyNewWhiteByTheme(BuildContext context) => isDarkMode(context) ? clrWhite : clrGreyNew;
  static Color clrGreyDarkBlackBtTheme(BuildContext context) => isDarkMode(context) ? clrBlackOrigin : clrGrey;

  // Consistent field/border color to be used by input fields and small containers
  static Color clrFieldBorderByTheme(BuildContext context) => isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2);

  /*
  * ------------------------ Texts ----------------------------------------- *
  * */

  /*
  * ----------------------------- Images---------------------------------------- *
  */

  static String assets = 'assets/images/';

  static String icLogoDark = '${assets}ic_dark_logo.png';
  static String icLogoLight = '${assets}ic_light_logo.png';
  static String icBack = '${assets}ic_back_new.png';
  static String icAppIcon = '${assets}ic_bitcoin.png';
  static String icDrawerMenu = '${assets}ic_drawer.png';
  static String icBackPrimary = '${assets}ic_back_primary.png';
  static String icWhiteBack = '${assets}ic_back_white.png';
  static String icSearch = '${assets}ic_search.png';
  static String icIntroSlider1 = '${assets}ic_intro_slider1.jpg';
  static String icIntroSlider2 = '${assets}ic_intro_slider2.jpg';
  static String icIntroSlider3 = '${assets}ic_intro_slider3.jpg';
  static String icRecommender = '${assets}ic_recommender.png';
  static String icTrader = '${assets}ic_trader.png';
  static String icClose = '${assets}ic_close.png';
  static String icUnChecked = '${assets}ic_unchecked.png';
  static String icChecked = '${assets}ic_checked.png';
  static String icBlueChecked = '${assets}ic_checked_blue.png';
  static String icBlueUnChecked = '${assets}ic_unchecked_blue.png';
  static String icCross = '${assets}ic_cross.png';
  static String icBinanceCoin = '${assets}ic_binance_coin.png';
  static String icBitcoin = '${assets}ic_bitcoin.png';
  static String icDrawer = '${assets}ic_drawer.png';
  static String icEthereum = '${assets}ic_ethereum.png';
  static String icBackWardWithBack = '${assets}ic_backward_with_back.png';
  static String icLanguage = '${assets}ic_language.png';
  static String icMatched = '${assets}ic_matched.png';
  static String icNotification = '${assets}ic_notification.png';
  static String icNotificationSVG = "assets/svgs/ic_notification_svg.svg";
  static String icUpdate = "assets/svgs/ic_update.svg";
  static String icSubscribed = '${assets}ic_subscribed.png';
  static String icSelectSubscribed = '${assets}ic_select_subscribe.png';
  static String icUserGuide = '${assets}ic_user_guide.png';
  static String icSelectUserGuide = '${assets}ic_select_user_guide.png';
  static String icWhatsappFab = '${assets}whatsapp_fab.png';
  static String icTether = '${assets}ic_tether.png';
  static String icState = '${assets}ic_currencies.png';
  static String icSelectState = '${assets}ic_select_state.png';
  static String icUser = '${assets}ic_user.png';
  static String icSelectUser = '${assets}ic_select_user.png';
  static String icHome = '${assets}ic_home.png';
  static String icDrawerHome = '${assets}ic_drawerHome.png';
  static String icSub = '${assets}ic_sub.png';
  static String icSelectHome = '${assets}ic_select_home.png';
  static String icMobile = '${assets}ic_mobile.png';
  static String icPassword = '${assets}ic_password.png';
  static String icGoogle = '${assets}ic_google.png';
  static String icTwitter = '${assets}ic_twitter.png';
  static String icTwitterPrimary = '${assets}ic_twitter_primary.png';
  static String icAppleIcon = '${assets}ic_apple.png';
  static String icVisible = '${assets}ic_visible.png';
  static String icNotVisible = '${assets}ic_not_visible.png';
  static String icRightArrow = '${assets}ic_right_arrow.png';
  static String icSplashTriangle = '${assets}ic_triangle_splash.png';
  static String icEdit = '${assets}ic_edit.png';
  static String icProfile = '${assets}ic_profile.png';
  static String icEmail = '${assets}ic_email.png';
  static String icSearchIcon = '${assets}ic_search_icon.png';
  static String icSelected = '${assets}ic_selected.png';
  static String icBitcoinIcon = '${assets}ic_bitcoin_icon.png';
  static String icEthereumIcon = '${assets}ic_ethereum_icon.png';
  static String icProfileImage = '${assets}ic_profile_image.png';
  static String icEditProfile = '${assets}ic_edit_profile.png';
  static String icFlagIndia = '${assets}ic_flag_india.png';
  static String icFacebook = '${assets}ic_facebook.png';
  static String icInstagram = '${assets}ic_instagram.png';
  static String icStar = '${assets}ic_star.png';
  static String icWeb = '${assets}ic_web.png';
  static String icUser1 = '${assets}ic_user1.png';
  static String icUser2 = '${assets}ic_user2.png';
  static String icUser3 = '${assets}ic_user3.png';
  static String icUser4 = '${assets}ic_user4.png';
  static String icUser5 = '${assets}ic_user5.png';
  static String icUser6 = '${assets}ic_user6.png';
  static String icUser7 = '${assets}ic_user7.png';
  static String icUser8 = '${assets}ic_user8.png';
  static String icProfit = '${assets}ic_profit.png';
  static String icBtcImg1 = '${assets}ic_btc_img1.png';
  static String icBtcImg2 = '${assets}ic_btc_img2.png';
  static String icBtcImg3 = '${assets}ic_btc_img3.png';
  static String icLoss = '${assets}ic_loss.png';
  static String icChartScreenShot = '${assets}ic_chart_screen_shot.png';
  static String icFillStar = '${assets}ic_fill_star.png';
  static String icCalender = '${assets}ic_calender.png';
  static String icRecommenderBottomIcon = '${assets}ic_recommenderBottomIcon.png';
  static String icLike = '${assets}ic_like.png';
  static String icUnLike = '${assets}ic_un_like.png';
  static String icArrowForWardIcon = '${assets}ic_arrow_forward.png';
  static String icCalenderDropDown = '${assets}ic_calenderDropDown.png';
  static String icDelete = '${assets}ic_delete.png';
  static String icRadioSelected = '${assets}ic_radioSelected.png';
  static String icRadioUnSelected = '${assets}ic_radioUnSelected.png';
  static String icAddImage = '${assets}ic_addImage.png';
  static String icSubscriptionAmountBGImage = '${assets}ic_subscription_amount_bg_image.png';
  static String icArabicIcon = '${assets}ic_arabic.png';
  static String icEnglishIcon = '${assets}ic_english.png';
  static String icPersonIcon = '${assets}ic_person.png';
  static String icMailIcon = '${assets}ic_mail.png';
  static String icLockIcon = '${assets}ic_lock.png';
  static String icEyeIcon = '${assets}ic_eye.png';
  static String icCryptoLogo = '${assets}ic_crypto_logo.png';
  static String icUsMarketLogo = '${assets}ic_us_market_logo.png';
  static String icSelectMarketMain = '${assets}ic_select_market_main.png';
  static String icSelectMarketSub = '${assets}ic_select_market_sub.png';
  static String icHomeN = '${assets}ic_home_n.png';
  static String icCurrenciesN = '${assets}ic_currencies_n.png';
  static String icAiN = '${assets}ic_ai_n.png';
  static String icCoursesN = '${assets}ic_courses_n.png';
  static String icUsMarketN = '${assets}ic_us_market_n.png';
  static String icCryptoN = '${assets}ic_crypto_n.png';
  static String icSearchN = '${assets}ic_search_new.png';
  static String icNotificationN = '${assets}ic_notification_new.png';
  static String icNotificationNoBorderN = '${assets}ic_notification_d_new.png';
  static String icNotifSignDetN = '${assets}Ic_notification_Sign_new.png';
  static String icCrownN = '${assets}ic_crown.png';
  static String icGuestN = '${assets}ic_guest_new.png';
  static String icAdvertiseN = '${assets}ic_advertise1.png';
  static String icSearchBarN = '${assets}ic_search_bar_new.png';
  static String icFavN = '${assets}ic_fav_new.png';
  static String icUnFavN = '${assets}ic_unfav_new.png';
  static  String icXpengLogo = '${assets}ic_xpeng_logo.png';
  static  String icAppleLogo = '${assets}ic_apple_logo.png';
  static  String icTeslaLogo = '${assets}ic_tesla_logo.png';
  static  String icAmazonLogo = '${assets}ic_amzn_logo.png';
  static  String icNIOLogo = '${assets}ic_nio_logo.png';
  static  String icPLTRLogo = '${assets}ic_pltr_logo.png';
  static  String icDISLogo = '${assets}ic_dis_logo.png';
  static  String icAPDDLogo = '${assets}ic_pdd_logo.png';

  ///Drawer icons
  static String icLogout = '${assets}ic_logout.png';
  static String icSupport = '${assets}ic_support.png';
  static String icTermsAndService = '${assets}ic_t&s.png';
  static String icSetting = '${assets}ic_setting.png';
  static String icCancel = '${assets}ic_cancel.png';
  static String icFavourite = '${assets}ic_favourite.png';
  static String icRequestAnalysis = '${assets}ic_request_analysis.png';
  static String icRequestAnalysisDetails = '${assets}ic_receipt_text.png';
  static String icAddScreenshot = '${assets}ic_add_screenshot.png';
  static String icMenuNotification = '${assets}ic_menuNotification.png';
  static String icRevenue = '${assets}ic_revenue.png';
  static String icRecommendations = '${assets}ic_recommendations.png';
  static String icUnselectedRecommendations = '${assets}ic_unselected_recommendations.png';
  static String icSelectedRecommendations = '${assets}ic_selected_recommendations.png';
  static String icWallet = '${assets}ic_wallet.png';
  static String icSubscribers = '${assets}ic_subscribers.png';
  static String icProfileTabIcon = '${assets}ic_profileTabIcon.png';
  static String icHomeDN = '${assets}ic_home_D_new.png';
  static String icProfileDN = '${assets}ic_profile.png';
  static String icSettingsDN = '${assets}ic_settings_d_new.png';
  static String icTermsDN = '${assets}ic_terms_d_new.png';
  static String icNotifDN = '${assets}ic_notification_d_new.png';
  static String icConsDN = '${assets}ic_consult_d_new.png';

  /// Empty State Images
  static String icNoRecommender = "assets/svgs/ic_empty_no_recommender_found.svg";
  static String icNoActiveSignals = "assets/svgs/ic_no_active_signal.svg";
  static String icNoBTCScenario = "assets/svgs/ic_no_btc_scenario.svg";
  static String icNoCurrency = "assets/svgs/ic_no_currency.svg";
  static String icNoFavourites = "assets/svgs/ic_no_favourite.svg";
  static String icNoInternet = "assets/svgs/ic_no_internet.svg";
  static String icNoMatchedRecommenderFound = "assets/svgs/ic_no_matched_recommender.svg";
  static String icNoNotifications = "assets/svgs/ic_no_notification.svg";
  static String icNoSearchData = "assets/svgs/ic_no_search_data.svg";
  static String icNoSocial = "assets/svgs/ic_no_social.svg";
  static String icNoSubscribeRecommenderFound = "assets/svgs/ic_no_subscribe_recommender_found.svg";
  static String icNoTermsAndCondition = "assets/svgs/ic_no_terms_conditions.svg";
  static String icPaymentFailed = "assets/svgs/ic_payment_failed.svg";
  static String icSomethingWentWrong = "assets/svgs/ic_something_went_wrong.svg";
  static String icNoPlans = "assets/svgs/ic_no_plans.svg";
  static String icNoResultFound = "assets/svgs/ic_no_result_found.svg";

  static String icProfileSvg = 'assets/svgs/ic_profile_svg.svg';
  static String svgForward = 'assets/svgs/svg_forward_arrow_with_bg.svg';
  static String svgAllProfile = 'assets/svgs/svg_all_profile.svg';
  static String svgPremiumUser = 'assets/svgs/svg_premium_user.svg';
  static String svgEmptyFavouriteCurerncy = 'assets/svgs/ic_empty_favourite.svg';


  /*
  * -----------------------------Mock Images---------------------------------------- *
  */

  ///temp Profile img
  static String profileImage = 'https://images.unsplash.com/photo-1607746882042-944635dfe10e?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTZ8fHByb2ZpbGUlMjBwaWN0dXJlfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60';

  /// Animation
  static String icCreatePassword = 'assets/json/create_password.json';
  static String icSuccess = 'assets/json/success.json';
}

class TextStyles {
  static TextStyle txtRegular7(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 7.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtRegular10(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 10.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtNormal12(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 12.sp,
    fontWeight: Constant.fwMedium,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtRegular12(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 12.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtNormal14(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 14.sp,
    fontWeight: Constant.fwMedium,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtRegular14(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 14.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtRegular15(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 15.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtNormal16(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 16.sp,
    fontWeight: Constant.fwMedium,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtRegular16(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 16.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: Constant.fontFamily,
  );

  // Explicit Gilroy medium 16 style (use when you want Gilroy font specifically)

  static TextStyle txtGilroyRegular16(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 16.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: 'Gilroy',
    height: 1.0,
  );

  static TextStyle txtRegular17(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 17.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtHeader25(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 25.sp,
    fontWeight: Constant.fwMedium,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtHeader18(BuildContext context) => TextStyle(
    color: Constant.clrTextMainFontByTheme(context),
    fontSize: 18.sp,
    fontWeight: Constant.fwMedium,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtNormal9(BuildContext context) => TextStyle(
    color: Constant.clrTextLightGreyByTheme(context),
    fontSize: 9.sp,
    fontWeight: Constant.fwRegular,
    fontFamily: Constant.fontFamily,
  );

  static TextStyle txtNormal8(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 8.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtBold16(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 16.sp,
      fontWeight: Constant.fwBold,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium8(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 8.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium10(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 10.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium12(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 12.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium14(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 14.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium16(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 16.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium18(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 18.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium19(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 19.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium20(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 20.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedium24(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 24.sp,
      fontWeight: Constant.fwMedium,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBold14(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 14.sp,
      fontWeight: Constant.fwSemiBold,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBold16(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 16.sp,
      fontWeight: Constant.fwSemiBold,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBold18(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 18.sp,
      fontWeight: Constant.fwSemiBold,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBoldG10(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwSemiBold,
      fontSize: 10.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBoldG14(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwRegular,
      fontSize: 14.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBoldG20(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwSemiBold,
      fontSize: 20.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBoldG12(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwSemiBold,
      fontSize: 12.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedG14(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwMedium,
      fontSize: 14.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedG16(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontSize: 16.sp,
      fontWeight:Constant.fwMedium ,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedG12(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontSize: 12.sp,
      fontWeight:Constant.fwMedium ,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedGI12(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontSize: 12.sp,
      fontStyle: FontStyle.italic,
      fontWeight:Constant.fwMedium ,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedG10(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontSize: 10.sp,
      fontWeight:Constant.fwMedium ,
      fontFamily: Constant.fontFamily);

  static TextStyle txtMedG15(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontSize: 15.sp,
      fontWeight:Constant.fwMedium ,
      fontFamily: Constant.fontFamily);

  static TextStyle txtRegG14(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwRegular,
      fontSize: 14.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtRegG12(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwRegular,
      fontSize: 12.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtRegIG11(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwRegular,
      fontStyle: FontStyle.italic,
      fontSize: 11.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiG24(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwSemiBold,
      fontSize: 24.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiG16(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwSemiBold,
      fontSize: 16.sp,
      fontFamily: getAppLanguage() == 'en' ? "Gilroy" : "Almarai");

  static TextStyle txtSemiG18(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwRegular,
      fontSize: 18.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiG18_2(BuildContext context) => TextStyle(
      color: Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwMedium,
      fontSize: 18.sp,
      fontFamily: Constant.fontFamily);

  static TextStyle txtBold22(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 22.sp,
      fontWeight: Constant.fwSemiBold,
      fontFamily: Constant.fontFamily);

  static TextStyle txtBold14(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 14.sp,
      fontWeight: Constant.fwRegular,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBold26(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 26.sp,
      fontWeight: Constant.fwSemiBold,
      fontFamily: Constant.fontFamily);

  static TextStyle txtSemiBold28(BuildContext context) => TextStyle(
      color: Constant.clrTextMainFontByTheme(context),
      fontSize: 28.sp,
      fontWeight: Constant.fwSemiBold,
      fontFamily: Constant.fontFamily);
}