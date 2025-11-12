import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/auth/sign_up_bank_details_screen.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/duration_controller.dart';
import '../../framework/data_provider/auth/sign_up_subscription_amount_screen_controller.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';


class RequestAnalysisScreenSignUp extends ConsumerStatefulWidget {
  final String userID;
  final String? amount;
  final ScreenName fromScreen;
  final List<PriceModel>? selectedPlanList;

  const RequestAnalysisScreenSignUp(
      {Key? key,
      required this.userID,
      required this.fromScreen,
      this.selectedPlanList,
      this.amount})
      : super(key: key);

  @override
  ConsumerState<RequestAnalysisScreenSignUp> createState() =>
      _RequestAnalysisScreenSignUpState();
}

class _RequestAnalysisScreenSignUpState
    extends ConsumerState<RequestAnalysisScreenSignUp> {
  TextEditingController amountCtr = TextEditingController();
  FocusNode amountFocus = FocusNode();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final signUpSubscriptionAmountWatch =
          ref.watch(signUpSubscriptionAmountProvider);
      signUpSubscriptionAmountWatch.clearProvider();
      if (widget.amount != "") {
        amountCtr.text = widget.amount ?? "";
        signUpSubscriptionAmountWatch.checkAmountValidation(
            context, amountCtr.text);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final signUpSubscriptionAmountWatch =
        ref.watch(signUpSubscriptionAmountProvider);
    return (widget.fromScreen == ScreenName.RegisterScreen)
        ? Scaffold(
            body: NoInternetBuilder(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  hideKeyboard(context);
                },
                child: bodyWidget(context, signUpSubscriptionAmountWatch),
              ),
            ),
            bottomNavigationBar: bottomWidget(signUpSubscriptionAmountWatch),
          )
        : Scaffold(
            appBar: CommonAppBar(
              appBar: AppBar(),
              title: "Key_RequestedAnalysis".localized,
              onPress: () {
                Navigator.pop(context, false);
              },
            ),
            body: NoInternetBuilder(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  hideKeyboard(context);
                },
                child: bodyWidget(context, signUpSubscriptionAmountWatch),
              ),
            ),
            bottomNavigationBar: bottomWidget(signUpSubscriptionAmountWatch),
          );
  }

  Widget bodyWidget(BuildContext context,
      SignUpSubscriptionAmountScreenController signUpSubscriptionAmountWatch) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.fromScreen == ScreenName.RegisterScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40.h,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Transform.rotate(
                    angle: getAppLanguage() == "ar" ? pi : 0,
                    child: CommonImageAsset(
                      strIcon: Constant.icBack,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                SizedBox(
                  height: 33.h,
                  width: Constant.infiniteSize,
                  child: Text(
                    getLocalValue("Key_SignUp"),
                    style: TextStyles.txtMedium20(context).copyWith(color: Constant.clrPrimary),
                  ),
                ),
                SizedBox(
                  height: 7.h,
                ),
                Container(
                  height: 2.h,
                  width: MediaQuery.of(context).size.width * 0.6,
                  color: Constant.clrPrimary,
                ),
                SizedBox(
                  height: 27.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Key_RequestedAnalysis".localized,
                        style: TextStyles.txtMedium18(context)),
                    InkWell(
                        onTap: () {
                          Route route = SlideRightPageRoute(
                              builder: (context) => SignUpBankDetailScreen(
                                    isRecommender: true,
                                    userID: widget.userID,
                                    amount: "",
                                    selectedPlanList: widget.selectedPlanList,
                                  ),
                              settings: const RouteSettings());
                          Navigator.of(context).push(route);
                        },
                        child: Text("Key_Skip".localized,
                            style: TextStyles.txtMedium12(context))),
                  ],
                ),
                SizedBox(
                  height: 4.h,
                ),
              ],
            ),
          ),
          Visibility(
            visible: widget.fromScreen != ScreenName.RegisterScreen,
            child: SizedBox(
              height: 20.h,
            ),
          ),
          Text(
            "Key_RequestedAnalysisNote".localized,
            style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrBlackNew),
          ),
          SizedBox(
            height: 17.h,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
                color: Constant.clrScaffoldBGByTheme(context),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Constant.clrLightPurple)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fromScreen == ScreenName.RegisterScreen
                      ? "Key_EnterAmount".localized
                      : "${"Key_EnterAmount".localized}*",
                  style: TextStyles.txtRegular10(context).copyWith(color: Constant.clrGreyNew),
                ),
                SizedBox(
                  height: 15.h,
                ),
                CustomTextField(
                  context: context,
                  myController: amountCtr,
                  myFocus: amountFocus,
                  bgColor: Constant.clrDarkByScaffoldTheme(context),
                  textInputType: TextInputType.number,
                  onChanged: (str) {
                    signUpSubscriptionAmountWatch.checkAmountValidation(
                        context, str);
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  textInputAction: TextInputAction.done,
                  suffix: Padding(
                    padding: EdgeInsets.only(
                        right: 15.w,
                        top: 10.h,
                        left: getAppLanguage() == 'ar' ? 20.w : 0),
                    child: Text(
                      "in $currency",
                      style: TextStyles.txtMedium12(context).copyWith(color: Constant.clrGreyNew),
                    ),
                  ),
                  marginNeed: false,
                  paddingNeed: false,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///bottom widget
  Widget bottomWidget(
      SignUpSubscriptionAmountScreenController signUpSubscriptionAmountWatch) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20.w, right: 20.w, bottom: getIsIOSPlatform() ? 20.h : 10.h),
      child: CommonButton(
        label: widget.fromScreen == ScreenName.RegisterScreen
            ? getLocalValue("Key_Next")
            : getLocalValue("Key_Save"),
        textSize: 16.sp,
        onTap: () {
          if (widget.fromScreen == ScreenName.RegisterScreen) {
            Route route = SlideRightPageRoute(
                builder: (context) => SignUpBankDetailScreen(
                      isRecommender: true,
                      userID: widget.userID,
                      amount: signUpSubscriptionAmountWatch.strAmount,
                      selectedPlanList: widget.selectedPlanList,
                    ),
                settings: const RouteSettings());
            Navigator.of(context).push(route);
          } else {
            Navigator.of(context).pop(true);
          }
        },
        isEnable: signUpSubscriptionAmountWatch.isValidate,
        height: 50.h,
        bgColor: Constant.clrPrimary,
        labelColor: Constant.clrWhite,
        borderColor: Constant.clrPrimary,
      ),
    );
  }
}
