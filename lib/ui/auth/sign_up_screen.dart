import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/auth/sign_in_screen.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/sign_up_screen_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/apis/global_apis.dart';
import '../../utils/const.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/social_manager/apple_login_manager.dart';
import '../../utils/social_manager/google_login_manager.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../cms/cms_screen.dart';
import '../drawer/drawer_menu.dart';
import 'otp_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final bool isRecommender;

  const SignUpScreen({super.key, required this.isRecommender});

  @override
  ConsumerState<SignUpScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends ConsumerState<SignUpScreen> {
  ///Text Editing Controller
  TextEditingController emailCTR = TextEditingController();
  TextEditingController newPasswordCTR = TextEditingController();
  TextEditingController traderNameCTR = TextEditingController();
  TextEditingController confirmPasswordCTR = TextEditingController();

  ///Focus Node
  FocusNode emailFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode traderNameFocus = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final signUpWatch = ref.watch(signUpScreenProvider);
      signUpWatch.clearProvider();
      countryListApi(signUpWatch);
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final signUpWatch = ref.watch(signUpScreenProvider);


    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          body: bodyWidget(signUpWatch),
        ),
        DialogProgressBar(isLoading: signUpWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(SignUpScreenController signUpWatch) {
    final drawerWatch = ref.watch(drawerProvider);
    final settingsWatch = ref.watch(settingsScreenProvider);
    final dashboardWatch = ref.watch(dashboardProvider);
    // Use centralized Gilroy Medium 16 style from TextStyles
    // (defined in lib/utils/theme_const.dart as txtGilroyMedium16)
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          hideKeyboard(context);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 30.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // InkWell(
                //   onTap: () {
                //     Navigator.of(context).pop();
                //   },
                //   child: Transform.rotate(
                //     angle: getAppLanguage() == 'ar' ? pi : 0,
                //     child: CommonImageAsset(
                //       strIcon: icBack,
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: Constant.infiniteSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getLocalValue("Key_SignUp"),
                        style: TextStyles.txtSemiBoldG20(context).copyWith(
                            fontWeight: Constant.fwMedium,
                          color: Constant.clrTitlePageByTheme(context),
                        ),
                      ),
                      // const Spacer(),
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: TextButton(
                      //     onPressed: () {
                      //       saveLocalData(KEY_USER_STATUS, guest);
                      //       Route route = SlideRightPageRoute(
                      //           builder: (context) => const DrawerMenu(),
                      //           settings: const RouteSettings());
                      //       Navigator.of(context).push(route);
                      //     },
                      //     child: Text(
                      //       getLocalValue("Key_GuestUser"),
                      //       style: TextStyles.txtMedium14(context).copyWith(
                      //           color: Constant.clrPrimary,
                      //           decoration: TextDecoration.underline),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                // DropdownButtonFormField<String>(
                //   decoration: InputDecoration(
                //     labelText: "Key_Language".localized,
                //     labelStyle: TextStyle(color: Constant.clrWhiteBlackNewByTheme()),
                //     enabledBorder: UnderlineInputBorder(
                //       borderSide: BorderSide(color: Constant.clrPrimary, width: 2.0),
                //     ),
                //     focusedBorder: UnderlineInputBorder(
                //       borderSide: BorderSide(color: Constant.clrPrimary, width: 2.0),
                //     ),
                //   ),
                //   value: getAppLanguage(),
                //   items: <String>['ar', 'en']
                //       .map((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Text(value == 'en'
                //           ? "Key_EnglishLanguage".localized
                //           : "Key_ArabicLanguage".localized, style: TextStyle(color: Constant.clrBlackOrigin),),
                //     );
                //   }).toList(),
                //   selectedItemBuilder: (BuildContext context) {
                //     return <String>['ar', 'en'].map((String value) {
                //       return Text(
                //         value == 'en' ? "Key_EnglishLanguage".localized : "Key_ArabicLanguage".localized,
                //         style: TextStyle(color: Constant.clrWhiteBlackNewByTheme()), // Selected item text color
                //       );
                //     }).toList();
                //   },
                //   onChanged: (newValue) {
                //     signUpWatch.updateLanguage(newValue ?? getAppLanguage(), context);
                //   },
                // ),
                // Reworked language selector: fixed label widths + consistent base style
                //Toggle Button for Language Selection
                Container(
                  margin: EdgeInsets.only(top: 15.h),
                  padding: EdgeInsetsDirectional.only(start: 15.w, end: 15.w, top: 8.h, bottom: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFFFFFFF),
                    border: Border.all(
                      color: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),
                      width: 1.0,
                    ),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr, // Force LTR layout regardless of language
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween for consistent spacing
                      children: [
                        // Left: English block - ALWAYS ON LEFT
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                Constant.icEnglishIcon,
                                width: 34.h,
                                height: 34.h,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  "English",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left, // Explicitly left
                                  style: TextStyles.txtMedG16(context).copyWith(
                                    fontFamily: 'Gilroy',
                                    color: drawerWatch.isEngEnable
                                        ? Constant.clrGantTitleByTheme(context)
                                        : Constant.clrSelectLabelColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Center: Switch
                        Container(
                          constraints: BoxConstraints(minWidth: 44.w, maxWidth: 70.w),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(pi), // This flips the switch horizontally
                            child: Switch.adaptive(
                              activeThumbColor: Colors.white,
                              inactiveThumbColor: Colors.white,
                              activeTrackColor: Constant.clrSecColor,
                              inactiveTrackColor: Constant.clrSecColor,
                              value: drawerWatch.isEngEnable,
                              onChanged: (isEngEnable) => drawerWatch.changeLanguage(
                                context,
                                isEngEnable,
                                settingsWatch,
                                dashboardWatch,
                                recommenderDetailsCallback: () async {},
                              ),
                            ),
                          ),
                        ),
                        // Right: Arabic block - ALWAYS ON RIGHT
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  "العربية",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right, // Explicitly right
                                  style: TextStyles.txtMedG16(context).copyWith(
                                    fontFamily: 'Almarai',
                                    color: !drawerWatch.isEngEnable
                                        ? Constant.clrGantTitleByTheme(context)
                                        : Constant.clrSelectLabelColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Image.asset(
                                Constant.icArabicIcon,
                                width: 34.h,
                                height: 34.h,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 27.h,
                // ),
                // CommonTitle(
                //     icon: Constant.icProfile,
                //     title: !widget.isRecommender
                //         ? "${"Key_NameOfTrader".localized}*"
                //         : "${"Key_NameOfRecommender".localized}*"),
                SizedBox(
                  height: 15.h,
                ),
                //user name
                CustomTextField(
                  context: context,
                  myController: traderNameCTR,
                  myFocus: traderNameFocus,
                  bgColor: Constant.clrDarkByScaffoldTheme(context),
                  textInputType: TextInputType.text,
                  prefix: Image.asset(Constant.icPersonIcon,width: 20,height: 20,),
                  onChanged: (str) {
                    signUpWatch.checkTraderNameValidation(context, str);
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9\s]*')),
                    LengthLimitingTextInputFormatter(maxNameLength)
                  ],
                  hintText: getLocalValue("Key_EnterName"),
                  textInputAction: TextInputAction.next,
                  errorMessage: signUpWatch.strTraderNameError,
                  marginNeed: false,
                  paddingNeed: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  borderRadius: 15.r,
                  borderColor: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),

                ),
                // SizedBox(
                //   height: 23.h,
                // ),
                // CommonTitle(
                //     icon: Constant.icMobile,
                //     title: "Key_MobileNumber".localized + "*"),
                SizedBox(
                  height: 15.h,
                ),
                //user email
                CustomTextField(
                  context: context,
                  myController: emailCTR,
                  myFocus: emailFocus,
                  bgColor: Constant.clrDarkByScaffoldTheme(context),
                  textInputType: TextInputType.emailAddress,
                  isEmail: true,
                  onChanged: (str) {
                    signUpWatch.checkEmailValidation(context, str);
                  },
                  prefix: Image.asset(Constant.icMailIcon,width: 20,height: 20,),
                  hintText: getLocalValue("Key_Email"),
                  textInputAction: TextInputAction.next,
                  errorMessage: signUpWatch.strEmailError,
                  marginNeed: false,
                  paddingNeed: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  borderRadius: 15.r,
                  borderColor: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),

                ),
                // SizedBox(
                //   height: 23.h,
                // ),
                // CommonTitle(
                //     icon: Constant.icPassword,
                //     title: "Key_NewPassword".localized + "*"),
                SizedBox(
                  height: 15.h,
                ),
                //new password
                CustomTextField(
                  context: context,
                  myController: newPasswordCTR,
                  myFocus: newPasswordFocus,
                  bgColor: Constant.clrDarkByScaffoldTheme(context),
                  obscureText: signUpWatch.isNewPasswordObscure,
                  textInputType: TextInputType.text,
                  prefix: Image.asset(Constant.icLockIcon),
                  onChanged: (str) {
                    signUpWatch.checkNewPasswordValidation(context, str);
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(maxPasswordLength),
                  ],
                  hintText: getLocalValue("Key_Password"),
                  textInputAction: TextInputAction.next,
                  suffix: InkWell(
                    onTap: () {
                      signUpWatch.updateIsNewPasswordObscure();
                    },
                    child: Container(
                      height: 24.h,
                      width: 24.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Constant.clrPrimary,
                          BlendMode.srcIn,
                        ),
                        child: CommonImageAsset(
                          strIcon: signUpWatch.isNewPasswordObscure ? Constant.icEyeIcon : Constant.icNotVisible,
                          height: 24.h,
                          width: 24.h,
                        ),
                      ),
                    ),
                  ),
                  errorMessage: signUpWatch.strNewPasswordError,
                  marginNeed: false,
                  paddingNeed: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  borderRadius: 15.r,
                  borderColor: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),
                ),
                // SizedBox(
                //   height: 23.h,
                // ),
                // CommonTitle(
                //     icon: Constant.icPassword,
                //     title: "Key_ConfirmPassword".localized + "*"),
                SizedBox(
                  height: 15.h,
                ),
                //confirm password
                CustomTextField(
                  context: context,
                  myController: confirmPasswordCTR,
                  myFocus: confirmPasswordFocus,
                  bgColor: Constant.clrDarkByScaffoldTheme(context),
                  obscureText: signUpWatch.isConfirmPasswordObscure,
                  textInputType: TextInputType.text,
                  prefix: Image.asset(Constant.icLockIcon),
                  onChanged: (str) {
                    signUpWatch.checkConfirmPasswordValidation(context, str);
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(maxPasswordLength),
                  ],
                  hintText: getLocalValue("Key_ConfirmPassword"),
                  textInputAction: TextInputAction.done,
                  suffix: InkWell(
                    onTap: () {
                      signUpWatch.updateIsConfirmPasswordObscure();
                    },
                    child: Container(
                      height: 24.h,
                      width: 24.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Constant.clrPrimary,
                          BlendMode.srcIn,
                        ),
                        child: CommonImageAsset(
                          strIcon: signUpWatch.isConfirmPasswordObscure ? Constant.icEyeIcon : Constant.icNotVisible,
                          height: 24.h,
                          width: 24.h,
                        ),
                      ),
                    ),
                  ),
                  errorMessage: signUpWatch.strConfirmPasswordError,
                  marginNeed: false,
                  paddingNeed: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  borderRadius: 15.r,
                  borderColor: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),
                ),
                SizedBox(
                  height: 15.h,
                ),
                //accept terms and condition
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: InkWell(
                    onTap: () {
                      signUpWatch.updateTermsAndConditionStatus();
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          signUpWatch.isChecked ? Constant.icChecked : Constant.icUnChecked,
                          color: isDarkMode ? Constant.clrPrimary : null,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        //accept terms and condition
                        InkWell(
                          onTap: () {
                            Route route = SlideRightPageRoute(
                              builder: (context) => const CmsScreen(
                                isFromDrawer: false,
                              ),
                              settings: const RouteSettings(),
                            );
                            Navigator.push(context, route);
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Key_Accept".localized,
                              style: TextStyles.txtRegG14(context).copyWith(
                                color: Constant.clrWhiteBlackNewByTheme(context),
                              ),
                              children: [
                                const TextSpan(text: " "),
                                TextSpan(
                                  text: "Key_TermsAndCondition".localized,
                                  style: TextStyles.txtRegG14(context).copyWith(
                                    color: Constant.clrPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                CommonButton(
                  label: getLocalValue("Key_Signup"),
                  isEnable: signUpWatch.isValidate,
                  onTap: () {
                    _signUpApi(signUpWatch);
                  },
                  bgColor: Constant.clrPrimary,
                  labelColor: Constant.clrWhite,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2.h,
                        width: Constant.infiniteSize,
                        color: Constant.clrGrey,
                      ),
                    ),
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      child: Text(
                        getLocalValue("Key_OrContinueWith"),
                        style:
                        TextStyles.txtMedG14(context).copyWith(
                            color: Constant.clrTitlePageByTheme(context)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2.h,
                        width: Constant.infiniteSize,
                        color: Constant.clrGrey,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16.h,
                ),
                /// Social Login Buttons - Updated with full width and text
                Column(
                  children: [
                    /// Google Sign In Button
                    Container(
                      width: double.infinity, // Full width
                      height: 50.h,
                      margin: EdgeInsets.only(bottom: 15.h),
                      child: ElevatedButton(
                        onPressed: () {
                          /// API Google Sign In
                          GoogleLoginManager.instance
                              .googleLoginAPI(context, (model) {
                            ///Result Call Back
                            showLog("Google Data Model - $model");
                            apiSocialSignIn("google", googleModel: model);
                          }, (error) {
                            ///Failure Call Back
                            showLog("Error - $error");
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // White background for Google
                          foregroundColor: Colors.black, // Black text and icon
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.r),
                            side: BorderSide(
                              color: Constant.clrGrey.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              Constant.icGoogle,
                              width: 24.w,
                              height: 24.h,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              getLocalValue("Key_ContinueWithGoogle"),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: Constant.fontFamily,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Apple Sign In Button (only for iOS)
                    if (getIsIOSPlatform() && getIsAppleSignInSupport())
                      Container(
                        width: double.infinity, // Full width
                        height: 50.h,
                        margin: EdgeInsets.only(bottom: 15.h),
                        child: ElevatedButton(
                          onPressed: () {
                            AppleLoginManager.instance
                                .appleLoginAPI(context, (appleDataModel) {
                              ///Result Call Back
                              showLog("Apple Data Model - appleDataModel");
                              apiSocialSignIn("apple",
                                  appleModel: appleDataModel);
                            }, (error) {
                              ///Failure Call Back
                              showLog("Error - $error");
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Black background for Apple
                            foregroundColor: Colors.white, // White text and icon
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.r),
                              side: BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                Constant.icAppleIcon,
                                width: 24.w,
                                height: 24.h,
                                color: Colors.white, // Ensure white icon
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                getLocalValue("Key_ContinueWithApple"),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: Constant.fontFamily,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // /// Ios Side
                // getIsIOSPlatform()
                //     ? Column(
                //
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     commonContainer(
                //         InkWell(
                //           onTap: () {
                //             /// API Google Sign In
                //             GoogleLoginManager.instance
                //                 .googleLoginAPI(context, (model) {
                //               ///Result Call Back
                //               showLog("Google Data Model - $model");
                //               apiSocialSignIn("google", googleModel: model);
                //             }, (error) {
                //               ///Failure Call Back
                //               showLog("Error - $error");
                //             });
                //           },
                //           child: CommonImageAsset(
                //             strIcon: Constant.icGoogle,
                //           ),
                //         ),
                //       ).paddingOnly(right: 30.w),
                //     // commonContainer(
                //     //   InkWell(
                //     //     onTap: () {
                //     //       TwitterLoginManager.instance.signInWithTwitter(
                //     //           context, (twitterDataModel) {
                //     //         /// Result Call Back
                //     //         showLog(
                //     //             "twitter Data Model - $twitterDataModel");
                //     //         apiSocialSignIn("twitter",
                //     //             twitterModel: twitterDataModel);
                //     //       }, (error) {
                //     //         /// Failure Call Back
                //     //         showLog("Error - $error");
                //     //       });
                //     //     },
                //     //     child: CommonImageAsset(
                //     //       strIcon: icTwitter,
                //     //     ),
                //     //   ),
                //     // ),
                //     Visibility(
                //       visible:
                //       (getIsAppleSignInSupport() && getIsIOSPlatform()),
                //       replacement: const Offstage(),
                //       child: commonContainer(
                //         InkWell(
                //           onTap: () {
                //             AppleLoginManager.instance
                //                 .appleLoginAPI(context, (appleDataModel) {
                //               ///Result Call Back
                //               showLog("Apple Data Model - appleDataModel");
                //               apiSocialSignIn("apple",
                //                   appleModel: appleDataModel);
                //             }, (error) {
                //               ///Failure Call Back
                //               showLog("Error - $error");
                //             });
                //           },
                //           child: CommonImageAsset(
                //             strIcon: Constant.icAppleIcon,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // )
                //
                // /// Android Side
                //     : Column(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     commonContainer(
                //       InkWell(
                //         onTap: () {
                //           /// API Google Sign In
                //           GoogleLoginManager.instance
                //               .googleLoginAPI(context, (model) {
                //             ///Result Call Back
                //             showLog("Google Data Model - $model");
                //             apiSocialSignIn("google", googleModel: model);
                //           }, (error) {
                //             ///Failure Call Back
                //             showLog("Error - $error");
                //           });
                //         },
                //         child: CommonImageAsset(
                //           strIcon: Constant.icGoogle,
                //         ),
                //       ),
                //     ),
                    // commonContainer(
                    //   InkWell(
                    //     onTap: () {
                    //       TwitterLoginManager.instance.signInWithTwitter(
                    //           context, (twitterDataModel) {
                    //         /// Result Call Back
                    //         showLog(
                    //             "twitter Data Model - $twitterDataModel");
                    //         apiSocialSignIn("twitter",
                    //             twitterModel: twitterDataModel);
                    //       }, (error) {
                    //         /// Failure Call Back
                    //         showLog("Error - $error");
                    //       });
                    //     },
                    //     child: CommonImageAsset(
                    //       strIcon: icTwitter,
                    //     ),
                    //   ),
                    // ),

                SizedBox(
                  height: 12.h,
                ),

                /// Dont Have An Account Signup
                InkWell(
                  onTap: () {
                    Route route = SlideRightPageRoute(
                        builder: (context) =>
                            SignInScreen(
                               trader,
                               emailCTR.text,
                            ),
                        settings: const RouteSettings());
                    Navigator.push(context, route);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${getLocalValue("Key_HaveAnAccount")} ",
                        style: TextStyles.txtRegular16(context).copyWith(
                            color: Constant.clrWhiteBlackNewByTheme(context)),
                      ),
                      Text(
                        getLocalValue("Key_SignIn"),
                        style: TextStyles.txtRegular16(context).copyWith(
                            fontWeight: Constant.fwMedium,
                            color: Constant.clrPrimary),
                      ),
                    ],
                  ),
                ),


              ]
          ),
        )

            ),
          ),
        );



  }

  Widget commonContainer(Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.h),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Constant.clrGrey,
       borderRadius: BorderRadius.circular(7)
      ),
      child: child,
    );
  }

  ///Country List Api
  Future countryListApi(SignUpScreenController signUpWatch) async {
    signUpWatch.updateIsLoading(true);
    await GlobalApis.instance.getCountryListApi(context, (model, error) {
      signUpWatch.updateIsLoading(false);
      if (model != null) {
        signUpWatch.fillCountryList(model.data);
      }
    });
  }

  /// signUp API
  Future _signUpApi(SignUpScreenController signUpWatch) async {
    if (isInternetConnectionOn) {
      await signUpWatch.signUpApi(context);
      if (signUpWatch.signupResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        final dashboardWatch = ref.watch(dashboardProvider);
        dashboardWatch.clearProvider();
        saveLocalData(
            KEY_USER_STATUS, widget.isRecommender ? recommender : trader);
        saveLocalData(KEY_USER_ENTITY_ID,
            signUpWatch.signupResponseModel?.data?.id.toString());
        Route route = SlideRightPageRoute(
            builder: (context) =>
                OTPScreen(
                  mobileNumber: signUpWatch.strMobileNumber,
                  fromScreen: FromScreen.FromSignUp,
                  countryData: signUpWatch.countryData,
                  userID: signUpWatch.signupResponseModel?.data?.id ?? "",
                ),
            settings: const RouteSettings());
        Navigator.of(context).push(route);
      }
    }
  }


  /// Get Recommender Detail
  Future recommenderDetailsApiCall() async {
    final homeWatch = ref.watch(homeProvider);
    final recommenderWatch = ref.watch(recommenderProvider);
    if (isInternetConnectionOn) {
      await recommenderWatch.recommenderDetailAPI(
          context,
          homeWatch.homeRecommenderDetailsResponseModel?.data?.recommenderId ??
              '');
    }
  }

  /// API Call Social Sign in
  Future<void> apiSocialSignIn(String socialMedia,
      {GoogleDataModel? googleModel,
        AppleDataModel? appleModel,
        //TwitterDataModel? twitterModel
      }) async {
    if (isInternetConnectionOn) {
      final signInWatch = ref.watch(signInProvider);
      await signInWatch.apiSocialLogin(context, socialMedia,
          googleModel: googleModel,
          appleModel: appleModel,
          //twitterModel: twitterModel,
          ref: ref);
      if (signInWatch.socialLoginResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        final dashboardWatch = ref.watch(dashboardProvider);
        dashboardWatch.clearProvider();
        saveLocalData(
            KEY_USER_STATUS, widget.isRecommender ? recommender : trader);
        saveIsLogin(isLogin: true);

        /// Login Data Save for Settings Screens (because we get that data from only login api)
        saveLocalData(KEY_USER_ENTITY_ID,
            signInWatch.socialLoginResponseModel?.data?.id.toString());

        //appsFlyer.setCustomerUserId(signInWatch.socialLoginResponseModel?.data?.id.toString() ?? '');
        //trackEvent("af_complete_registration", {"user_id": signInWatch.socialLoginResponseModel?.data?.id.toString(), "af_registration_method": socialMedia});
        /// For Displaying Profile Data in Drawer
        final profileWatch = ref.watch(profileProvider);
        await profileWatch.profileAPI(context);

        Route route = SlideRightPageRoute(
            builder: (context) => const DrawerMenu(),
            settings: const RouteSettings());
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
      }
    }
  }
}
