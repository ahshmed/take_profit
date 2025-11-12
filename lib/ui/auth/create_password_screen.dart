import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/create_password_screen_controller.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import 'helper/common_title.dart';
import 'helper/success_screen.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;
  final String userId;

  const CreatePasswordScreen(
      {Key? key, required this.userId, this.isFromProfile = false})
      : super(key: key);

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen>
    {
  ///Text Editing Controller
  TextEditingController currentPasswordCTR = TextEditingController();
  TextEditingController newPasswordCTR = TextEditingController();
  TextEditingController confirmPasswordCTR = TextEditingController();

  ///Focus Node
  FocusNode currentPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final createPasswordWatch = ref.watch(createPasswordScreenProvider);
      createPasswordWatch.clearProvider();
      currentPasswordFocus.addListener(() {
        createPasswordWatch.checkCurrentPasswordValidation(
            context, currentPasswordCTR.text, widget.isFromProfile);
      });

      newPasswordFocus.addListener(() {
        createPasswordWatch.checkNewPasswordValidation(
            context, newPasswordCTR.text, widget.isFromProfile);
      });

      confirmPasswordFocus.addListener(() {
        createPasswordWatch.checkConfirmPasswordValidation(
            context, confirmPasswordCTR.text, widget.isFromProfile);
      });
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final createPasswordWatch = ref.watch(createPasswordScreenProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue(!widget.isFromProfile
                ? "Key_CreatePassword"
                : "Key_ChangePassword"),
             titleTextStyle: TextStyles.txtMedG16(context),
            appBar: AppBar(),
            isTitleCenter: false,
            leading: IconButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                icon: Transform.rotate(
                  angle: (getAppLanguage() == 'ar')? pi :0,
                  child: Icon(Icons.arrow_back_ios) ,
                )
            ),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              hideKeyboard(context);
            },
            child: bodyWidget(createPasswordWatch),
          ),
        ),
        DialogProgressBar(isLoading: createPasswordWatch.isLoading),
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(CreatePasswordScreenController createPasswordWatch) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 19.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Text(
                getLocalValue(!widget.isFromProfile
                    ? "Key_CreatePasswordContent"
                    : "Key_ChangePasswordContent"),
                style: TextStyles.txtRegG12(context),
                textAlign: TextAlign.center,
              ),
            ),
            !widget.isFromProfile
                ? Column(
                    children: [
                      SizedBox(
                        height: 26.h,
                      ),
                      Lottie.asset(Constant.icCreatePassword,
                          height: 182.h, width: 182.h),
                      SizedBox(
                        height: 21.h,
                      ),
                    ],
                  )
                : const SizedBox(),
            widget.isFromProfile
                ? Column(
                    children: [
                      SizedBox(
                        height: 53.h,
                      ),
                      CommonTitle(
                        icon: Constant.icPassword,
                        title: "${"Key_CurrentPassword".localized}*",
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Constant.clrDarkByScaffoldTheme(context),
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: Constant.isDarkMode(context)
                                ? const Color(0xFF2B2B2B)
                                : const Color(0xFFF2F2F2),
                            width: 1.w,
                          ),
                        ),
                        child: CustomTextField(
                          context: context,
                          myController: currentPasswordCTR,
                          myFocus: currentPasswordFocus,
                          bgColor: Colors.transparent,
                          obscureText: createPasswordWatch.isCurrentPasswordObscure,
                          textInputType: TextInputType.text,
                          onChanged: (str) {
                            createPasswordWatch.checkCurrentPasswordValidation(
                                context, str, widget.isFromProfile);
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(maxPasswordLength),
                          ],
                          hintText: "Key_CurrentPassword".localized,
                          textInputAction: TextInputAction.next,
                          suffix: InkWell(
                            onTap: () {
                              createPasswordWatch.updateIsCurrentPasswordObscure();
                            },
                            child: Container(
                              height: 24.h,
                              width: 24.h,
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              child: CommonImageAsset(
                                strIcon: createPasswordWatch.isCurrentPasswordObscure
                                    ? Constant.icVisible
                                    : Constant.icNotVisible,
                                height: 24.h,
                                width: 24.h,
                              ),
                            ),
                          ),
                          errorMessage: createPasswordWatch.strCurrentPasswordError,
                          marginNeed: false,
                          paddingNeed: false,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                          borderRadius: 15.r,
                          borderColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(
                        height: 23.h,
                      ),
                    ],
                  )
                : const SizedBox(),
            CommonTitle(
              icon: Constant.icPassword,
              title: "${"Key_NewPassword".localized}*",
            ),
            SizedBox(
              height: 15.h,
            ),
            Container(
              decoration: BoxDecoration(
                color: Constant.clrDarkByScaffoldTheme(context),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: Constant.isDarkMode(context)
                      ? const Color(0xFF2B2B2B)
                      : const Color(0xFFF2F2F2),
                  width: 1.w,
                ),
              ),
              child: CustomTextField(
                context: context,
                myController: newPasswordCTR,
                myFocus: newPasswordFocus,
                bgColor: Colors.transparent,
                obscureText: createPasswordWatch.isNewPasswordObscure,
                textInputType: TextInputType.text,
                onChanged: (str) {
                  createPasswordWatch.checkNewPasswordValidation(
                      context, str, widget.isFromProfile);
                },
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxPasswordLength),
                ],
                hintText: getLocalValue("Key_NewPassword"),
                suffix: InkWell(
                  onTap: () {
                    createPasswordWatch.updateIsNewPasswordObscure();
                  },
                  child: Container(
                    height: 24.h,
                    width: 24.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    child: CommonImageAsset(
                      strIcon: createPasswordWatch.isNewPasswordObscure
                          ? Constant.icVisible
                          : Constant.icNotVisible,
                      height: 24.h,
                      width: 24.h,
                    ),
                  ),
                ),
                errorMessage: createPasswordWatch.strNewPasswordError,
                marginNeed: false,
                paddingNeed: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                borderRadius: 15.r,
                borderColor: Colors.transparent,
              ),
            ),
            SizedBox(
              height: 23.h,
            ),
            CommonTitle(
              icon: Constant.icPassword,
              title: "${"Key_ConfirmPassword".localized}*",
            ),
            SizedBox(
              height: 15.h,
            ),
            Container(
              decoration: BoxDecoration(
                color: Constant.clrDarkByScaffoldTheme(context),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: Constant.isDarkMode(context)
                      ? const Color(0xFF2B2B2B)
                      : const Color(0xFFF2F2F2),
                  width: 1.w,
                ),
              ),
              child: CustomTextField(
                context: context,
                myController: confirmPasswordCTR,
                myFocus: confirmPasswordFocus,
                bgColor: Colors.transparent,
                obscureText: createPasswordWatch.isConfirmPasswordObscure,
                textInputType: TextInputType.text,
                onChanged: (str) {
                  createPasswordWatch.checkConfirmPasswordValidation(
                      context, str, widget.isFromProfile);
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxPasswordLength),
                ],
                hintText: getLocalValue("Key_ConfirmPassword"),
                textInputAction: TextInputAction.done,
                suffix: InkWell(
                  onTap: () {
                    createPasswordWatch.updateIsConfirmPasswordObscure();
                  },
                  child: Container(
                    height: 24.h,
                    width: 24.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    child: CommonImageAsset(
                      strIcon: createPasswordWatch.isConfirmPasswordObscure
                          ? Constant.icVisible
                          : Constant.icNotVisible,
                      height: 24.h,
                      width: 24.h,
                    ),
                  ),
                ),
                errorMessage: createPasswordWatch.strConfirmPasswordError,
                marginNeed: false,
                paddingNeed: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                borderRadius: 15.r,
                borderColor: Colors.transparent,
              ),
            ),
            SizedBox(
              height: 65.h,
            ),
            CommonButton(
              height: 49.h,
              label: getLocalValue("Key_Update"),
              onTap: () {
                widget.isFromProfile == true
                    ? _changePasswordAPI(createPasswordWatch)
                    : _resetPasswordAPI(createPasswordWatch);
              },
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              isEnable: createPasswordWatch.isValidate,
            ),
          ],
        ),
      ),
    );
  }

  ///Reset Password API
  Future _resetPasswordAPI(
      CreatePasswordScreenController createPasswordWatch) async {
    if (isInternetConnectionOn) {
      await createPasswordWatch.resetPasswordApi(context, widget.userId);
      if (createPasswordWatch.resetPasswordResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        Route route = SlideRightPageRoute(
          builder: (context) => SuccessScreen(
            content: "Key_YourPasswordHasBeenSuccessfullyChanged",
            isFromProfile: widget.isFromProfile,
            userID: widget.userId,
            isChangePassword: true,
          ),
          settings: const RouteSettings(),
        );
        Navigator.of(context).pushReplacement(route);
      }
    }
  }

  ///Change Password API
  Future _changePasswordAPI(
      CreatePasswordScreenController createPasswordWatch) async {
    if (isInternetConnectionOn) {
      await createPasswordWatch.changePasswordApi(context);
      if (createPasswordWatch.changePasswordResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        Route route = SlideRightPageRoute(
          builder: (context) => SuccessScreen(
            content: "Key_YourPasswordHasBeenSuccessfullyChanged",
            isFromProfile: widget.isFromProfile,
            userID: widget.userId,
            isChangePassword: true,
          ),
          settings: const RouteSettings(),
        );
        Navigator.of(context).pushReplacement(route);
      }
    }
  }
}
