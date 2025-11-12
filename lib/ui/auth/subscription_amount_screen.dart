import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/auth/request_analysis_screen_signup.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/duration_controller.dart';
import '../../framework/data_provider/auth/sign_up_subscription_amount_screen_controller.dart';
import '../../framework/data_provider/master/master_controller.dart';
import '../../framework/data_provider/master/master_provider.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/custom_textfield.dart';
import 'duration_screen.dart';


class SubscriptionAmountScreen extends ConsumerStatefulWidget {
  final bool isRecommender;
  final String userId;
  final ScreenName? screenName;

  const SubscriptionAmountScreen(
      {Key? key,
      required this.isRecommender,
      this.screenName,
      required this.userId})
      : super(key: key);

  @override
  ConsumerState<SubscriptionAmountScreen> createState() =>
      _SubscriptionAmountScreenState();
}

class _SubscriptionAmountScreenState
    extends ConsumerState<SubscriptionAmountScreen>  {
  Timer? timer;
  int priceTextLength = 0;

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final signUpSubscriptionAmountWatch =
          ref.watch(signUpSubscriptionAmountProvider);
      final durationWatch = ref.watch(durationProvider);
      signUpSubscriptionAmountWatch.clearProvider();

      durationWatch.clearProvider();
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final durationWatch = ref.watch(durationProvider);
    final signUpSubscriptionAmountWatch =
        ref.watch(signUpSubscriptionAmountProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          body: NoInternetBuilder(
            child: bodyWidget(signUpSubscriptionAmountWatch, durationWatch),
          ),
          bottomNavigationBar:
              bottomWidget(signUpSubscriptionAmountWatch, durationWatch),
        ),
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(
      SignUpSubscriptionAmountScreenController signUpSubscriptionAmountWatch,
      DurationController durationWatch) {
    // final signInWatch = ref.watch(signInProvider);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70.h,
            ),
            InkWell(
              onTap: () {
                // if (widget.screenName == ScreenName.LoginScreen) {
                // signInWatch.clearProvider(false);
                // }
                Navigator.of(context).pop();
              },
              child: Transform.rotate(
                angle: getAppLanguage() == 'ar' ? pi : 0,
                child: CommonImageAsset(
                  strIcon: Constant.icBack,
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Text(
              getLocalValue("Key_SignUp"),
              style: TextStyles.txtMedium24(context).copyWith(color: Constant.clrPrimary),
            ),
            SizedBox(
              height: 25.h,
            ),
            Container(
              height: 2.h,
              width: !widget.isRecommender
                  ? double.infinity
                  : MediaQuery.of(context).size.width * 0.5,
              color: Constant.clrPrimary,
            ),
            SizedBox(
              height: 22.h,
            ),
            Text(
              getLocalValue("Key_SubscriptionAmount"),
              style: TextStyles.txtMedium18(context).copyWith(
                color: Constant.clrTextByTheme(context),
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            Text(
              "${getLocalValue("Key_SubscriptionMsg")} ${(durationWatch.selectedPlanList?.isNotEmpty == true)
                      ? getLocalValue('Key_AddMorePlanButtonMSG')
                      : getLocalValue('Key_SubscriptionPlanButtonMSG')}",
              style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrBlackNew),
            ),
            SizedBox(
              height: 15.h,
            ),
            selectedPlanListWidget(
                durationWatch, signUpSubscriptionAmountWatch),
            Visibility(
              visible: durationWatch.selectedPlanList!.isNotEmpty,
              child: SizedBox(
                height: 30.h,
              ),
            ),
            Visibility(
              visible: durationWatch.selectedPlanList?.isNotEmpty == true,
              child: InkWell(
                onTap: () {
                  Route route = SlideRightPageRoute(
                    builder: (context) => const DurationScreen(
                        screenName: ScreenName.SubscriptionAmountScreen),
                    settings: const RouteSettings(),
                  );
                  Navigator.of(context).push(route);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Constant.clrPrimary,
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      "Key_AddMore".localized,
                      style: TextStyles.txtMedium16(context).copyWith(color: Constant.clrPrimary),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            )
          ],
        ),
      ),
    );
  }

  Widget selectedPlanListWidget(DurationController durationWatch,
      SignUpSubscriptionAmountScreenController signUpSubscriptionAmountWatch) {
    return Flexible(
      child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, i) {
            final item = durationWatch.selectedPlanList?[i];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Constant.clrScaffoldBGByTheme(context),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Constant.clrLightPurple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: item?.packageName.toString(),
                          style: TextStyles.txtMedium12(context),
                          children: [
                            const TextSpan(text: "  "),
                            TextSpan(
                              text:
                                  "${item?.packageDuration} ${"Key_days".localized}",
                              style: TextStyles.txtRegular10
                                  (context).copyWith(color: Constant.clrGreyNew),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          durationWatch.removeItemAtIndex(i, item!);
                        },
                        child: Image.asset(Constant.icCross),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    "Key_EnterAmount".localized,
                    style: TextStyles.txtRegular10(context).copyWith(color: Constant.clrGreyNew),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  CustomTextField(
                    autoFocus: true,
                    context: context,
                    myController: durationWatch.amountCTR[i],
                    myFocus: durationWatch.amountFocus[i],
                    bgColor: Constant.clrDarkByScaffoldTheme(context),
                    textInputType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (str) {
                      durationWatch.priceList[i].price =
                          (durationWatch.amountCTR[i].text != '')
                              ? durationWatch.amountCTR[i].text
                              : "";
                      durationWatch.priceList[i].subscriptionPackageId =
                          item?.subscriptionPackageId;
                      durationWatch.checkValidationForPriceList();
                      durationWatch.updateWidget();
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]'),
                      ),
                    ],
                    textInputAction: TextInputAction.done,
                    suffix: Padding(
                      padding: EdgeInsets.only(
                          right: 15.w,
                          top: 12.h,
                          left: getAppLanguage() == "ar" ? 20.w : 0),
                      child: Text(
                        currency,
                        style:
                            TextStyles.txtMedium12(context).copyWith(color: Constant.clrGreyNew),
                      ),
                    ),
                    marginNeed: false,
                    paddingNeed: false,
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, i) {
            return SizedBox(
              height: 10.h,
            );
          },
          itemCount: durationWatch.selectedPlanList!.length),
    );
  }

  ///bottom widget
  Widget bottomWidget(
      SignUpSubscriptionAmountScreenController signUpSubscriptionAmountWatch,
      DurationController durationWatch) {
    final masterWatch = ref.watch(masterProvider);
    return Padding(
      padding: EdgeInsets.only(
          left: 20.w, right: 20.w, bottom: getIsIOSPlatform() ? 20.h : 10.h),
      child: durationWatch.selectedPlanList?.isEmpty == true
          ? CommonButton(
              label: getLocalValue("Key_AddSubscriptionPlan"),
              textSize: 16.sp,
              onTap: () {
                if (durationWatch.selectedPlanList?.isEmpty == true) {
                  durationWatch.clearProvider();
                  // apiGetSubscriptionPackagesList(masterWatch, durationWatch);
                  Route route = SlideRightPageRoute(
                    builder: (context) => const DurationScreen(
                      screenName: ScreenName.SubscriptionAmountScreen,
                    ),
                    settings: const RouteSettings(),
                  );
                  Navigator.of(context).push(route);
                }
              },
              isEnable: durationWatch.selectedPlanList!.isEmpty,
              height: 50.h,
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              borderColor: Constant.clrPrimary,
            )
          : CommonButton(
              label: getLocalValue("Key_Next"),
              textSize: 16.sp,
              onTap: () {
                Route route = SlideRightPageRoute(
                    builder: (context) => RequestAnalysisScreenSignUp(
                          userID: widget.userId,
                          fromScreen: ScreenName.RegisterScreen,
                          selectedPlanList: durationWatch.priceList,
                        ),
                    settings: const RouteSettings());
                Navigator.of(context).push(route);
              },
              isEnable: durationWatch.checkValidationForPriceList(),
              height: 50.h,
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              borderColor: Constant.clrPrimary,
            ),
    );
  }

  /// Get Subscription Package List APi Call
  apiGetSubscriptionPackagesList(
      MasterController masterWatch, DurationController durationWatch) async {
    if (isInternetConnectionOn) {
      durationWatch.updateIsLoading(true);

      await masterWatch.apiGetSubscriptionPackageList(context);
      if (masterWatch.getSubscriptionPackageList?.status ==
          ApiEndPoints.apiStatus_200) {
        durationWatch.planList?.clear();
        // durationWatch.priceList.clear();
        durationWatch.planList?.addAll(masterWatch.packageList);
        durationWatch.updateIsLoading(false);
      }
    }
  }
}
