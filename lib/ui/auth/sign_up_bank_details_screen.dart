// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/duration_controller.dart';
import '../../framework/data_provider/auth/sign_up_bank_screen_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/repository/profile/model/profile_details_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../drawer/drawer_menu.dart';
import 'helper/common_title.dart';

// import 'package:flutter_masked_text2/flutter_masked_text2.dart';


class SignUpBankDetailScreen extends ConsumerStatefulWidget {
  final String? amount;
  final bool isRecommender;
  final String? userID;
  final ProfileData? profileData;
  final List<PriceModel>? selectedPlanList;

  const SignUpBankDetailScreen(
      {Key? key,
      required this.userID,
      required this.isRecommender,
      this.profileData,
      this.amount,
      this.selectedPlanList})
      : super(key: key);

  @override
  ConsumerState<SignUpBankDetailScreen> createState() =>
      _SignUpBankDetailScreenState();
}

class _SignUpBankDetailScreenState extends ConsumerState<SignUpBankDetailScreen>
     {
  ///Text Editing Controller
  TextEditingController bankNameCTR = TextEditingController();
  TextEditingController nameAsPerAccCTR = TextEditingController();
  TextEditingController accNumberCTR = TextEditingController();
  TextEditingController IBANCodeCTR = TextEditingController();

  ///Focus Node
  FocusNode bankNameFocus = FocusNode();
  FocusNode nameAsPerAccFocus = FocusNode();
  FocusNode accNumberFocus = FocusNode();
  FocusNode IBANCodeFocus = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final signUpBankDetailWatch = ref.watch(signUpBankDetailScreenProvider);
      signUpBankDetailWatch.clearProvider();

      if (widget.profileData != null) {
        bankNameCTR.text = widget.profileData?.bankName ?? "";
        nameAsPerAccCTR.text = widget.profileData?.accountName ?? "";
        accNumberCTR.text = widget.profileData?.accountNumber ?? "";
        IBANCodeCTR.text = widget.profileData?.ibanCode ?? "";

        signUpBankDetailWatch.checkBankNameValidation(
            context, widget.profileData?.bankName ?? "");

        signUpBankDetailWatch.checkNameAsPerAccValidation(
            context, widget.profileData?.accountName ?? "");

        signUpBankDetailWatch.checkAccNumberValidation(
            context, widget.profileData?.accountNumber ?? "");

        signUpBankDetailWatch.checkIBANCodeValidation(
            context, widget.profileData?.ibanCode ?? "");
      }
      bankNameFocus.addListener(() {
        signUpBankDetailWatch.checkBankNameValidation(
            context, bankNameCTR.text);
      });

      nameAsPerAccFocus.addListener(() {
        signUpBankDetailWatch.checkNameAsPerAccValidation(
            context, nameAsPerAccCTR.text);
      });

      accNumberFocus.addListener(() {
        signUpBankDetailWatch.checkAccNumberValidation(
            context, accNumberCTR.text);
      });

      IBANCodeFocus.addListener(() {
        signUpBankDetailWatch.checkIBANCodeValidation(
            context, IBANCodeCTR.text);
      });
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: NoInternetBuilder(child: bodyWidget()),
          bottomNavigationBar: bottomWidget(),
        ),
      ],
    );
  }

  ///body Widget
  Widget bodyWidget() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: Consumer(builder: (context, ref, child) {
        final signUpBankDetailWatch = ref.watch(signUpBankDetailScreenProvider);
        return Container(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70.h),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Transform.rotate(
                  angle: getAppLanguage() == 'ar' ? pi : 0,
                  child: CommonImageAsset(strIcon: Constant.icBack),
                ),
              ),
              SizedBox(height: 20.h),
              Visibility(
                visible: widget.profileData == null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getLocalValue("Key_SignUp"),
                      style: TextStyles.txtMedium24(context).copyWith(color: Constant.clrPrimary),
                    ),
                    SizedBox(height: 25.h),
                    Container(
                      height: 2.h,
                      width: !widget.isRecommender
                          ? double.infinity
                          : MediaQuery.of(context).size.width * 10,
                      color: Constant.clrPrimary,
                    ),
                    SizedBox(height: 22.h),
                  ],
                ),
              ),
              Text(
                getLocalValue("Key_BankDetails"),
                style: TextStyles.txtMedium18(context).copyWith(color: Constant.clrTextByTheme(context)),
              ),
              SizedBox(height: 4.h),
              Text(
                getLocalValue("Key_BankDetailsMsg"),
                style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrBlackNew),
              ),
              Expanded(
                child: ListView(
                  children: [
                    CommonTitle(
                      icon: '',
                      title: "${"Key_BankName".localized}*",
                      spaceBeforeTitle: false,
                    ),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      context: context,
                      myController: bankNameCTR,
                      myFocus: bankNameFocus,
                      bgColor: Constant.clrDarkByScaffoldTheme(context),
                      textInputType: TextInputType.text,
                      onChanged: (value) {
                        signUpBankDetailWatch.checkBankNameValidation(
                            context, value);
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[a-zA-Z0-9\s]*')),
                        LengthLimitingTextInputFormatter(maxNameLength)
                      ],
                      textInputAction: TextInputAction.next,
                      errorMessage: signUpBankDetailWatch.strBankNameError,
                      marginNeed: false,
                      paddingNeed: false,
                    ),
                    SizedBox(height: 20.h),
                    CommonTitle(
                        icon: '',
                        title: "${"Key_YourBankAccount".localized}*",
                        spaceBeforeTitle: false),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      context: context,
                      myController: nameAsPerAccCTR,
                      myFocus: nameAsPerAccFocus,
                      bgColor: Constant.clrDarkByScaffoldTheme(context),
                      //obscureText: signUpWatch.isNewPasswordObscure,
                      textInputType: TextInputType.text,
                      onChanged: (value) {
                        signUpBankDetailWatch.checkNameAsPerAccValidation(
                            context, value);
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[a-zA-Z0-9\s]*')),
                        LengthLimitingTextInputFormatter(maxNameLength)
                      ],
                      textInputAction: TextInputAction.next,
                      errorMessage: signUpBankDetailWatch.strNameAsPerAccError,
                      marginNeed: false,
                      paddingNeed: false,
                    ),
                    SizedBox(height: 20.h),
                    CommonTitle(
                      icon: '',
                      title: "${"Key_AccountNumber".localized}*",
                      spaceBeforeTitle: false,
                    ),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      context: context,
                      myController: accNumberCTR,
                      myFocus: accNumberFocus,
                      bgColor: Constant.clrDarkByScaffoldTheme(context),
                      textInputType: TextInputType.number,
                      onChanged: (value) {
                        signUpBankDetailWatch.checkAccNumberValidation(
                            context, value);
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(maxAccountNumberLength)
                      ],
                      textInputAction: TextInputAction.next,
                      errorMessage: signUpBankDetailWatch.strAccNumberError,
                      marginNeed: false,
                      paddingNeed: false,
                    ),
                    SizedBox(height: 20.h),
                    CommonTitle(
                        icon: '',
                        title: "${"Key_IBANCode".localized}*",
                        spaceBeforeTitle: false),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      context: context,
                      myController: IBANCodeCTR,
                      myFocus: IBANCodeFocus,
                      bgColor: Constant.clrDarkByScaffoldTheme(context),
                      textInputType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        signUpBankDetailWatch.checkIBANCodeValidation(
                            context, value);
                      },
                      inputFormatters: const [
                        // LengthLimitingTextInputFormatter(maxIbanNoLength),
                        // UpperCaseTextFormatter()
                      ],
                      contentPadding: getAppLanguage() == 'ar'
                          ? EdgeInsets.only(right: 20.w, left: -10.w)
                          : null,
                      textInputAction: TextInputAction.done,
                      errorMessage: signUpBankDetailWatch.strIBANCodeError,
                      marginNeed: false,
                      paddingNeed: false,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ).paddingOnly(bottom: MediaQuery.of(context).viewInsets.bottom),
        );
      }),
    );
  }

  ///bottom widget
  Widget bottomWidget() {
    return Consumer(builder: (context, ref, child) {
      final signUpBankDetailWatch = ref.watch(signUpBankDetailScreenProvider);
      return Padding(
        padding: EdgeInsets.only(
            left: 20.w, right: 20.w, bottom: getIsIOSPlatform() ? 20.h : 10.h),
        child: (signUpBankDetailWatch.isLoading)
            ? DialogProgressBar(isLoading: true, forPagination: true)
            : CommonButton(
                label: widget.profileData == null
                    ? "Key_SignUp".localized
                    : "Key_Save".localized,
                textSize: 16.sp,
                onTap: () {
                  if (widget.profileData == null) {
                    _completeProfileAPI(signUpBankDetailWatch);
                  } else {
                    updateBankDetailsApi(signUpBankDetailWatch);
                  }
                },
                height: 50.h,
                bgColor: Constant.clrPrimary,
                labelColor: Constant.clrWhite,
                borderColor: Constant.clrPrimary,
                isEnable: signUpBankDetailWatch.isValidate,
              ),
      );
    });
  }

  /// Update Bank Details API Call
  Future updateBankDetailsApi(
      SignUpBankDetailsScreenController signUpBankDetailWatch) async {
    if (isInternetConnectionOn) {
      await signUpBankDetailWatch.updateBankDetailsAPI(context);
      if (signUpBankDetailWatch.profileDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        Navigator.pop(context, true);
      }
    }
  }

  /// Login API
  Future _completeProfileAPI(
      SignUpBankDetailsScreenController signUpBankDetailWatch) async {
    if (isInternetConnectionOn) {
      await signUpBankDetailWatch.completeProfileApi(
          context, widget.userID, widget.amount,
          priceModelList: widget.selectedPlanList);
      if (signUpBankDetailWatch.completeProfileModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        saveLocalData(KEY_USER_ENTITY_ID, widget.userID);

        showLog(
            "token ${signUpBankDetailWatch.completeProfileModel?.data?.token}");
        showLog(signUpBankDetailWatch.completeProfileModel?.data?.token
                .toString() ??
            "");
        final dashboardWatch = ref.watch(dashboardProvider);
        dashboardWatch.clearProvider();

        /// For Displaying Profile Data in Drawer
        final profileWatch = ref.watch(profileProvider);
        await profileWatch.profileAPI(context);
        saveLocalData(KEY_USER_STATUS,
            profileWatch.profileDetailResponseModel?.data?.userType);
        saveLocalData(KEY_USER_ACCESS_TOKEN,
            signUpBankDetailWatch.completeProfileModel?.data?.token);

        Route route = SlideRightPageRoute(
            builder: (context) => const DrawerMenu(),
            settings: const RouteSettings());
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
      }
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
