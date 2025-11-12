import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';


import '../../framework/data_provider/payment/payment_controller.dart';
import '../../framework/data_provider/payment/payment_provider.dart';
import '../../framework/data_provider/profile/edit_subscription_amount_controller.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/subscribe/choose_plan_controller.dart';
import '../../framework/data_provider/subscribe/subscribe_provider.dart';
import '../../main.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../auth/helper/success_screen.dart';
import '../payment/in_app_purchase/app_purchase_screen.dart';
import '../payment/payment_screen.dart';

class ChoosePlanScreen extends ConsumerStatefulWidget {
  final String recommenderID;
  final ScreenName fromScreen;
  const ChoosePlanScreen(
      {Key? key, required this.recommenderID, required this.fromScreen})
      : super(key: key);

  @override
  ConsumerState<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends ConsumerState<ChoosePlanScreen>
     {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    //trackEvent("subscribe_clicked", {"user_id": getUserEntityId()});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final choosePlanWatch = ref.watch(choosePlanProvider);
      final paymentWatch = ref.watch(paymentProvider);
      final editSubscriptionAmountWatch =
          ref.watch(editSubscriptionAmountProvider);

      choosePlanWatch.clearProvider();
      paymentWatch.clearProviderData();
      getSubscriptionListAPICall(editSubscriptionAmountWatch);

      scrollController.addListener(() {
        if (editSubscriptionAmountWatch.isHasMorePage) {
          if (scrollController.position.maxScrollExtent ==
              scrollController.position.pixels) {
            if ((int.parse(editSubscriptionAmountWatch
                        .recommenderSubscriptionPackagesResponseModel
                        .data
                        ?.pageNumber
                        ?.toString() ??
                    "0") !=
                int.parse(editSubscriptionAmountWatch
                        .recommenderSubscriptionPackagesResponseModel
                        .data
                        ?.totalPage
                        .toString() ??
                    "0"))) {
              getSubscriptionListAPICall(editSubscriptionAmountWatch);
            }
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final choosePlanWatch = ref.watch(choosePlanProvider);
    final editSubscriptionAmountWatch =
        ref.watch(editSubscriptionAmountProvider);
    final paymentWatch = ref.watch(paymentProvider);
    return Stack(
      children: [
        Scaffold(
          appBar: CommonAppBar(
            appBar: AppBar(),
            title: "Key_ChoosePlan".localized,
          ),
          body: NoInternetBuilder(
            child: Column(
              children: [
                bodyWidget(choosePlanWatch, editSubscriptionAmountWatch),
                DialogProgressBar(
                  isLoading: editSubscriptionAmountWatch.isLoadingPagination,
                  forPagination: true,
                ).paddingOnly(bottom: 40.h)
              ],
            ),
          ),
          bottomNavigationBar:
              (editSubscriptionAmountWatch.subscriptionPackageList.isEmpty)
                  ? const Offstage()
                  : bottomWidget(context, choosePlanWatch, paymentWatch, editSubscriptionAmountWatch),
        ),
        DialogProgressBar(
            isLoading:
                paymentWatch.isLoading || editSubscriptionAmountWatch.isLoading)
      ],
    );
  }

  Widget bodyWidget(ChoosePlanController choosePlanWatch,
      EditSubscriptionAmountController editSubscriptionAmountWatch) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: (editSubscriptionAmountWatch.subscriptionPackageList.isEmpty &&
                !(editSubscriptionAmountWatch.isLoading))
            ? EmptyStateWidget(emptyStateFor: EmptyState.noPlanToChoose)
            : ListView.separated(
                controller: scrollController,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  final item =
                      editSubscriptionAmountWatch.subscriptionPackageList[i];
                  return InkWell(
                    onTap: () {
                      choosePlanWatch.setSelectedPlanIndex(
                          i,
                          item.profilePackageId.toString(),
                          item.price.toString());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Constant.clrPrimary),
                        color: Constant.clrDarkByScaffoldTheme(context),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: item.price,
                                  style: TextStyles.txtSemiBold16(context),
                                  children: [
                                    TextSpan(
                                        text: editSubscriptionAmountWatch.isLive ? " $currency/${item.interval}" : " USD/${item.interval}",
                                        style: TextStyles.txtMedium12(context))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                  "${"Key_For".localized} ${item.packageDuration} ${"Key_DayS".localized}",
                                  style: TextStyles.txtRegular10
                                      (context).copyWith(color: Constant.clrGreyNew))
                            ],
                          ),
                          Image.asset(
                            choosePlanWatch.selectedPlanIndex == i
                                ? Constant.icRadioSelected
                                : Constant.icRadioUnSelected,
                            height: 18.h,
                            width: 18.h,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, i) {
                  return SizedBox(
                    height: 10.h,
                  );
                },
                itemCount:
                    editSubscriptionAmountWatch.subscriptionPackageList.length),
      ),
    );
  }

  ///bottom widget
  Widget bottomWidget(BuildContext context,
      ChoosePlanController choosePlanWatch, PaymentController paymentWatch,
      EditSubscriptionAmountController editSubscriptionAmountWatch) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20.w, right: 20.w, bottom: getIsIOSPlatform() ? 20.h : 10.h),
      child: CommonButton(
        label: getLocalValue("Key_PayNow"),
        textSize: 16.sp,
        onTap: () async {
          if(!editSubscriptionAmountWatch.isLive){
            Route route = SlideRightPageRoute(
              builder: (context) => AppPurchaseScreen(
                profilePackageID: choosePlanWatch.profilePackageID ?? "1",
              ),
              settings: const RouteSettings(),
            );
            var success = await Navigator.push(context, route);
            if(success == true){
              paymentForSubscriptionAPICall(paymentWatch, choosePlanWatch, false);
            }
          } else {
            //trackEvent("pay_now_clicked", {"user_id": getUserEntityId(), "package_id": choosePlanWatch.profilePackageID, "order_id": "0", "price": choosePlanWatch.profilePackageIdAmount, "type": "package"});
            paymentForSubscriptionAPICall(paymentWatch, choosePlanWatch, true);
          }
        },
        isEnable: choosePlanWatch.selectedPlanIndex != null,
        height: 50.h,
        bgColor: Constant.clrPrimary,
        labelColor: Constant.clrWhite,
        borderColor: Constant.clrPrimary,
      ),
    );
  }

  Future<void> getSubscriptionListAPICall(
      EditSubscriptionAmountController editSubscriptionAmountWatch) async {
    await editSubscriptionAmountWatch.recommenderSubscriptionPackageListApi(
        context,
        recommenderID: widget.recommenderID);
  }

  Future<void> paymentForSubscriptionAPICall(PaymentController paymentWatch,
      ChoosePlanController choosePlanWatch, bool isLive) async {
    await paymentWatch.paymentForSubscriptionApi(context,
        profilePackageID: choosePlanWatch.profilePackageID.toString());
    if (paymentWatch.paymentResponseModel.status ==
        ApiEndPoints.apiStatus_200) {
      if(isLive) {
        Route route = SlideRightPageRoute(
          builder: (context) =>
              PaymentScreen(
                fromScreen: widget.fromScreen,
                paymentUrl:
                paymentWatch.paymentResponseModel.data?.paymentUrl.toString(),
                paymentAmount:
                choosePlanWatch.profilePackageIdAmount.toString() +
                    "  $currency",
                packageId: choosePlanWatch.profilePackageID.toString(),
              ),
          settings: const RouteSettings(),
        );
        Navigator.push(context, route);
      } else {
        showLog('paymentStatus success');
        Route route = SlideRightPageRoute(
            builder: (context) => SuccessScreen(
              content: "Key_PaymentSuccessfulNote",
              fromScreen: widget.fromScreen,
              userID: '',
              isLive: false,
            ),
            settings: const RouteSettings());
        Navigator.of(context).pushReplacement(route);
      }
    } else {
      showLog('payment 202');
      showMessageDialog(
          context, paymentWatch.paymentResponseModel.message ?? '', () {
        if (widget.fromScreen == ScreenName.RecommenderBioScreen) {
          Navigator.pop(context);
        }
        Navigator.pop(context);

        Navigator.pop(context, true);
      });
    }
  }
}
