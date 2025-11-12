import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/auth/sign_up_screen.dart';
import 'package:take_profit/utils/extension/extension.dart';
import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/sign_in_screen_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/repository/common/model/country_list_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/apis/global_apis.dart';
import '../../utils/const.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/social_manager/apple_login_manager.dart';
import '../../utils/social_manager/google_login_manager.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/common_text.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/flag_phone_widget.dart';
import '../drawer/drawer_menu.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final String role;
  final String? mobileNumber;
  final String email;

  const SignInScreen(this.role, this.email, {super.key, this.mobileNumber});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  ///Text Editing Controller
  TextEditingController emailCTR = TextEditingController();
  TextEditingController mobileNumberCTR = TextEditingController();
  TextEditingController passwordCTR = TextEditingController();

  ///Focus Node
  FocusNode emailFocus = FocusNode();
  FocusNode mobileNumberFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  /// State for phone/email toggle
  bool _isPhoneLogin = true;

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final signInScreenWatch = ref.watch(signInProvider);
      showLog(widget.role);
      signInScreenWatch.clearProvider(true);
      countryListApi(signInScreenWatch);
      mobileNumberFocus.addListener(() {
        signInScreenWatch.checkMobileNumberValidation(
            context, mobileNumberCTR.text);
      });

      if (widget.mobileNumber != null) {
        mobileNumberCTR.text = widget.mobileNumber ?? "";
        signInScreenWatch.checkMobileNumberValidation(
            context, mobileNumberCTR.text);
      }

      emailFocus.addListener(() {
        signInScreenWatch.checkEmailValidation(context, emailCTR.text);
      });

      if (widget.email.isNotEmpty) {
        emailCTR.text = widget.email;
        signInScreenWatch.checkEmailValidation(context, emailCTR.text);
      }

      passwordFocus.addListener(() {
        signInScreenWatch.checkPasswordValidation(context, passwordCTR.text);
      });
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final signInScreenWatch = ref.watch(signInProvider);
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          body: bodyWidget(signInScreenWatch),
        ),
        DialogProgressBar(isLoading: signInScreenWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(SignInScreenController signInScreenWatch) {
    final drawerWatch = ref.watch(drawerProvider);
    final settingsWatch = ref.watch(settingsScreenProvider);
    final dashboardWatch = ref.watch(dashboardProvider);

    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          hideKeyboard(context);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Single Centered Sign In Text
                SizedBox(
                  width: Constant.infiniteSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getLocalValue("Key_SignIn"),
                        style: TextStyles.txtSemiBoldG20(context).copyWith(
                          color: Constant.clrTitlePageByTheme(context),
                          fontWeight: Constant.fwMedium
                        ),
                      ),
                    ],
                  ),
                ),
                // Language Toggle
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
                SizedBox(height: 12.h),
                //login with
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(getLocalValue("Key_LoginWith"),
                      style: TextStyles.txtRegG14(context).copyWith(color: Constant.clrSelectMarketByTheme(context))),
                  ],
                ),
                // Phone/Email Toggle
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  padding: EdgeInsetsDirectional.only(start: 15.w, end: 15.w, top: 8.h, bottom: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFFFFFFF),
                    border: Border.all(
                      color: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Left: Email login option
                      Flexible(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                getLocalValue("Key_EmailAddress"), // Make sure this key exists
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: TextStyles.txtRegular14(context).copyWith(
                                  color: !_isPhoneLogin
                                      ? Constant.clrGantTitleByTheme(context)
                                      : Constant.clrSelectLabelColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Semantics(
                              label: 'Email',
                              child: null
                            ),
                          ],
                        ),
                      ),
                      // Center: toggle switch
                      SizedBox(width: 6.w),
                      ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 44.w, maxWidth: 70.w),
                        child: Center(
                          child: Switch.adaptive(
                            activeThumbColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: Constant.clrPrimary,
                            inactiveTrackColor: Constant.clrPrimary,
                            value: _isPhoneLogin,
                            onChanged: (isPhoneLogin) {
                              setState(() {
                                _isPhoneLogin = isPhoneLogin;
                                // Clear validation errors when switching
                                if (isPhoneLogin) {
                                  signInScreenWatch.strEmailError = "";
                                  signInScreenWatch.strEmail = ""; //clear email field when toggle to phone
                                } else {
                                  signInScreenWatch.strMobileNumberError = "";
                                  signInScreenWatch.strMobileNumber = ""; //clear mobile number field when toggle to email
                                }
                                // Re-validate
                                signInScreenWatch.checkValidation();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),

                      // Right: Phone login option
                      Flexible(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Semantics(
                              label: 'Phone',
                              child: null
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                getLocalValue("Key_PhoneNo"), // Make sure this key exists
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyles.txtRegular14(context).copyWith(
                                  color: _isPhoneLogin
                                      ? (Constant.isDarkMode(context) ? Constant.clrWhite : Constant.clrDarkBlue)
                                      : const Color(0xFFBEBEBE),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Conditional rendering based on toggle
                if (_isPhoneLogin) ...[
                  // Mobile Number Field
                  CustomTextField(
                    context: context,
                    myController: mobileNumberCTR,
                    myFocus: mobileNumberFocus,
                    bgColor: Constant.clrDarkByScaffoldTheme(context),
                    prefix: Container(
                      width: 115.w,
                      padding: EdgeInsets.only(
                          right: getAppLanguage() == 'ar' ? 20.w : 0,
                          left: getAppLanguage() == 'ar' ? 0 : 20.w),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CountryData>(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 25,
                            color: Constant.clrWhiteBlackByTheme(context),
                          ),
                          hint: Align(
                            alignment: Alignment.centerLeft,
                            child: CommonText(
                              title: getLocalValue("Key_Code"),
                              fontSize: 14.sp,
                              clrFont: Constant.clrHintText,
                            ),
                          ),
                          value: signInScreenWatch.countryData,
                          dropdownColor: Constant.clrCardBGByTheme(context),
                          items: signInScreenWatch.arrCountry.map((value) {
                            return DropdownMenuItem<CountryData>(
                              value: value,
                              child: Row(
                                children: [
                                  // ClipOval(
                                  //   child: CacheImage(
                                  //     imageURL: value.flag ?? "",
                                  //     height: 20.h,
                                  //     width: 20.h,
                                  //     contentMode: BoxFit.cover,
                                  //   ),
                                  // ),
                                  // Temporary test - replace your flag widget with this:
                                  FlagPhoneWidget(flagUrl: value.flag,
                                    size: 20.h,),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Text(
                                    value.code ?? "",
                                    style: TextStyles.txtRegG12(context).copyWith(
                                      color: Constant.clrHint,
                                    ),
                                  ),
                                ],
                              ).paddingOnly(
                                  left: ref.watch(drawerProvider).isEngEnable == false
                                      ? 10.w
                                      : 0.w),
                            );
                          }).toList(),
                          isExpanded: true,
                          underline: Divider(
                            color: Constant.clrPrimary,
                          ),
                          onTap: () {},
                          enableFeedback: false,
                          borderRadius: BorderRadius.circular(10.r),
                          onChanged: (newValue) {
                            signInScreenWatch.updateSelectedCode(newValue!);
                          },
                        ),
                      ),
                    ),
                    textInputType: TextInputType.number,
                    onChanged: (str) {
                      signInScreenWatch.checkMobileNumberValidation(context, str);
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(maxMobileLength),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    hintText: getLocalValue("Key_MobileNumber"),
                    textInputAction: TextInputAction.next,
                    errorMessage: signInScreenWatch.strMobileNumberError,
                    marginNeed: false,
                    paddingNeed: false,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    borderRadius: 15.r,
                    borderColor: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),
                  ),
                ] else ...[
                  // Email Field
                  CustomTextField(
                    context: context,
                    myController: emailCTR,
                    myFocus: emailFocus,
                    bgColor: Constant.clrDarkByScaffoldTheme(context),
                    textInputType: TextInputType.emailAddress,
                    isEmail: true,
                    prefix: Image.asset(Constant.icMailIcon, width: 20, height: 20),
                    onChanged: (str) {
                      signInScreenWatch.checkEmailValidation(context, str);
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    hintText: getLocalValue("Key_Email"),
                    textInputAction: TextInputAction.next,
                    errorMessage: signInScreenWatch.strEmailError,
                    marginNeed: false,
                    paddingNeed: false,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    borderRadius: 15.r,
                    borderColor: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),
                  ),
                ],

                SizedBox(height: 12.h),

                // Password Field 
                CustomTextField(
                  context: context,
                  myController: passwordCTR,
                  myFocus: passwordFocus,
                  //isPassword: true,
                  bgColor: Constant.clrDarkByScaffoldTheme(context),
                  obscureText: signInScreenWatch.isObscure,
                  textInputType: TextInputType.text,
                  prefix: Image.asset(Constant.icLockIcon),
                  onChanged: (str) {
                    signInScreenWatch.checkPasswordValidation(context, str);
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(maxPasswordLength),
                  ],
                  hintText: getLocalValue("Key_Password"),
                  textInputAction: TextInputAction.done,
                  suffix: InkWell(
                    onTap: () {
                      signInScreenWatch.updateIsObscure();
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
                          strIcon: signInScreenWatch.isObscure ? Constant.icEyeIcon : Constant.icNotVisible,
                          height: 24.h,
                          width: 24.h,
                        ),
                      ),
                    ),
                  ),
                  errorMessage: signInScreenWatch.strPasswordError,
                  marginNeed: false,
                  paddingNeed: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  borderRadius: 15.r,
                  borderColor: Constant.isDarkMode(context) ? const Color(0xFF2B2B2B) : const Color(0xFFF2F2F2),
                ),

                SizedBox(height: 10.h),
                 //Container for Guest User and Forgot Password aligned in a single row
                 Row(children: [
                   // Guest user button - kept but positioned differently
                   Align(
                     alignment: Alignment.center,
                     child: TextButton(
                       onPressed: () {
                         saveLocalData(KEY_USER_STATUS, guest);
                         Route route = SlideRightPageRoute(
                             builder: (context) => const DrawerMenu(),
                             settings: const RouteSettings());
                         Navigator.of(context).push(route);
                       },
                       child: Text(
                         getLocalValue("Key_GuestUser"),
                         style: TextStyles.txtSemiBoldG14(context).copyWith(
                             color: Constant.clrPrimary,),
                       ),
                     ),
                   ),
                    const Spacer(),
                   // Forgot Password
                   Align(
                     alignment: Alignment.center,
                     child: InkWell(
                       onTap: () {
                         Route route = SlideRightPageRoute(
                             builder: (context) => const ForgotPasswordScreen(
                               isFromProfile: false,
                             ),
                             settings: const RouteSettings());
                         Navigator.of(context).push(route);
                       },
                       child: Text(
                         getLocalValue("Key_ForgotPassword"),
                         style: TextStyles.txtSemiBoldG14(context).copyWith
                           (color: Constant.clrRedF),
                       ),
                     ),
                   ),
                 ],),


                SizedBox(height: 12.h),

                // Sign In Button
                CommonButton(
                  label: getLocalValue("Key_SignIn"),
                  isEnable: signInScreenWatch.isValidate,
                  onTap: () {
                    _loginAPI(signInScreenWatch);
                  },
                  bgColor: Constant.clrPrimary,
                  labelColor: Constant.clrWhite,
                ),

                SizedBox(height: 12.h),

                // Or Continue With divider
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      child: Text(
                        getLocalValue("Key_OrContinueWith"),
                        style: TextStyles.txtMedG14(context).copyWith(color: Constant.clrTitlePageByTheme(context)),
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

                SizedBox(height: 12.h),

                /// Social Login Buttons - Same as SignUpScreen
                Column(
                  children: [
                    /// Google Sign In Button
                    Container(
                      width: double.infinity, // Full width
                      height: 50.h,
                      margin: EdgeInsets.only(bottom: 12.h),
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
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                        margin: EdgeInsets.only(bottom: 12.h),
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

                SizedBox(height: 12.h),

                /// Don't Have An Account Sign Up
                InkWell(
                  onTap: () {
                    Route route = SlideRightPageRoute(
                        builder: (context) => const SignUpScreen(isRecommender: false),
                        settings: const RouteSettings());
                    Navigator.pushReplacement(context, route);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${getLocalValue("Key_DontHaveAnAccount")} ",
                        style: TextStyles.txtRegular16(context).copyWith(
                          color: Constant.clrWhiteBlackNewByTheme(context),
                        ),
                      ),
                      Text(
                        getLocalValue("Key_SignUp"),
                        style: TextStyles.txtRegular16(context).copyWith(
                          fontWeight: Constant.fwMedium,
                          color: Constant.clrPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Keep the old commonContainer method commented as requested
  /*
  Widget commonContainer(Widget child) {
    return Container(
      height: 41.h,
      width: 41.h,
      padding: EdgeInsets.only(left: 7.w, top: 7.w, right: 6.w, bottom: 6.w),
      decoration: BoxDecoration(
        color: Constant.clrGrey,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
  */

  ///Country List Api
  Future countryListApi(SignInScreenController signInWatch) async {
    signInWatch.updateIsLoading(true);
    await GlobalApis.instance.getCountryListApi(context, (model, error) {
      signInWatch.updateIsLoading(false);
      if (model != null) {
        signInWatch.fillCountryList(model.data);
      }
    });
  }

  /// Login API
  Future _loginAPI(SignInScreenController signInWatch) async {
    if (isInternetConnectionOn) {
      saveLocalData(KEY_USER_STATUS, widget.role);
      await signInWatch.loginApi(context, ref, isPhoneLogin: _isPhoneLogin);
      if (signInWatch.loginResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        final dashboardWatch = ref.watch(dashboardProvider);
        dashboardWatch.clearProvider();
        print('widget.role${widget.role}');

        saveIsLogin(isLogin: true);

        /// Login Data Save for Settings Screens (because we get that data from only login api)
        saveLocalData(KEY_USER_ENTITY_ID,
            signInWatch.loginResponseModel?.data?.id.toString());

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

  /// API Call Social Sign in
  Future<void> apiSocialSignIn(String socialMedia,
      {GoogleDataModel? googleModel,
        AppleDataModel? appleModel,}
      ) async {
    if (isInternetConnectionOn) {
      final signInWatch = ref.watch(signInProvider);
      await signInWatch.apiSocialLogin(context, socialMedia,
          googleModel: googleModel,
          appleModel: appleModel,
          ref: ref);
      if (signInWatch.socialLoginResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        final dashboardWatch = ref.watch(dashboardProvider);
        dashboardWatch.clearProvider();
        saveLocalData(KEY_USER_STATUS, widget.role);
        saveIsLogin(isLogin: true);

        /// Login Data Save for Settings Screens (because we get that data from only login api)
        saveLocalData(KEY_USER_ENTITY_ID,
            signInWatch.socialLoginResponseModel?.data?.id.toString());

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
