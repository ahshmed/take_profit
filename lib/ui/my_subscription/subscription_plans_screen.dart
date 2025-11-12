import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/my_subscription/my_subscription_controller.dart';
import '../../framework/data_provider/my_subscription/my_subscription_provider.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';


class SubscriptionPlanScreen extends ConsumerStatefulWidget {
  const SubscriptionPlanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPlanScreen> createState() =>
      _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends ConsumerState<SubscriptionPlanScreen>
    {
  final ScrollController _scrollController = ScrollController();

  ///-----Init----
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final mySubscriptionWatch = ref.watch(mySubscriptionProvider);
      mySubscriptionWatch.clearProvider();

      ///here call subscription list api
      subscriptionListApi(mySubscriptionWatch, true);
    });

    _scrollController.addListener(() async {
      final mySubscriptionWatch = ref.watch(mySubscriptionProvider);
      if (mySubscriptionWatch.isHasMorePage) {
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.position.pixels) {
          if ((int.parse(mySubscriptionWatch
                      .subscriptionListResponseModel?.data?.pageNumber
                      ?.toString() ??
                  "0") !=
              int.parse(mySubscriptionWatch
                      .subscriptionListResponseModel?.data?.totalPage
                      .toString() ??
                  "0"))) {
            subscriptionListApi(mySubscriptionWatch, false);
          }
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mySubscriptionWatch = ref.watch(mySubscriptionProvider);
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CommonAppBar(
            appBar: AppBar(),
            title: "Key_SubscriptionPlans".localized,
          ),
          body: NoInternetBuilder(child: bodyWidget(mySubscriptionWatch),),
          bottomNavigationBar: SizedBox(height: 20.h,),
        ),
        DialogProgressBar(isLoading: mySubscriptionWatch.isLoading)
      ],
    );
  }

  Widget bodyWidget(MySubscriptionController mySubscriptionWatch) {
    return (mySubscriptionWatch.subscriptionList.isEmpty &&
            !mySubscriptionWatch.isLoading)
        ? EmptyStateWidget(emptyStateFor: EmptyState.noDataFound)
        : ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: EdgeInsets.all(20.sp),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 10.h,
                    );
                  },
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: mySubscriptionWatch.subscriptionList.length,
                  itemBuilder: (context, index) {
                    var item = mySubscriptionWatch.subscriptionList[index];
                    return Container(
                      padding: EdgeInsets.only(
                          left: ref.watch(drawerProvider).isEngEnable == false
                              ? 0
                              : 20.w,
                          top: 15.h,
                          bottom: 15.h,
                          right: ref.watch(drawerProvider).isEngEnable == false
                              ? 20.w
                              : 0),
                      decoration: BoxDecoration(
                        color: Constant.clrDarkByScaffoldTheme(context),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: Constant.clrGreyNew),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: CacheImage(
                              imageURL: item.userImage ?? "",
                              height: 45.h,
                              width: 45.h,
                              topLeftRadius: 10.r,
                              topRightRadius: 10.r,
                              bottomRightRadius: 10.r,
                              bottomLeftRadius: 10.r,
                            ),
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.userName ?? "",
                                        style: TextStyles.txtMedium12(context),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showConfirmationDialog(
                                          context,
                                          '',
                                          getLocalValue(
                                              "Key_AreYouSureYouWantToUnsubscribe"),
                                          getLocalValue("Key_UnsubscribeNote"),
                                          (isPositive) async {
                                            if (isPositive == true) {
                                              cancelSubscriptionApi(
                                                  mySubscriptionWatch,
                                                  item.recommenderId ?? "");
                                            }
                                          },
                                          borderRadius: 16.r,
                                          dialogInsidePadding:
                                              EdgeInsets.symmetric(
                                                  vertical: 25.h,
                                                  horizontal: 15.w),
                                          titleTextStyle: TextStyles.txtMedium24
                                              (context).copyWith(
                                                  fontSize: 22.sp,
                                                  color: Constant
                                                      .clrTextGreyByTheme(context)),
                                          messageTextStyle:
                                              TextStyles.txtMedium14(context).copyWith(
                                                  color: Constant
                                                      .clrTextGreyByTheme(context)),
                                          msgTxtPadding: EdgeInsets.only(
                                              top: 5.h,
                                              bottom: 10.h,
                                              left: 20.w,
                                              right: 20.w),
                                          buttonRadius: 30.r,
                                          yesBtnWidth: 145.w,
                                          yesBtnBGClr: Constant.clrWhite,
                                          yesBtnBorderClr: Constant.clrGreyNew,
                                          yesBtnTextClr: Constant.clrBlackNew,
                                          noBtnWidth: 145.w,
                                          noBtnBGClr: Constant.clrPrimary,
                                          noBtnBorderClr: Constant.clrPrimary,
                                          noBtnTextClr: Constant.clrWhite,
                                        );
                                      },
                                      child: Text(
                                        "Key_Unsubscribe".localized,
                                        style: TextStyles.txtMedium12(context).copyWith(
                                            color: Constant.clrYellow,
                                            decoration:
                                                TextDecoration.underline),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Plan
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Key_Plan".localized,
                                            style: TextStyles.txtMedium12(context),
                                            overflow: TextOverflow.clip,
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: item.interval ?? "",
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "  ${item.packageDuration} ${"Key_days".localized}",
                                                  style: TextStyles.txtRegular10
                                                      (context).copyWith(
                                                          color: Constant.clrGreyNew,
                                                          fontSize: 8.sp),
                                                ),
                                              ],
                                              style: TextStyles.txtMedium10(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Price
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Key_Price".localized,
                                            style: TextStyles.txtMedium12(context),
                                            overflow: TextOverflow.clip,
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "${item.amount}",
                                              children: [
                                                TextSpan(
                                                  text: " ${item.currency}",
                                                  style: TextStyles.txtRegular10
                                                      (context).copyWith(
                                                          color: Constant.clrGreyNew,
                                                          fontSize: 8.sp),
                                                ),
                                              ],
                                              style: TextStyles.txtMedium10(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Date
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Key_ExpiryDate".localized,
                                            style: TextStyles.txtMedium12(context),
                                            overflow: TextOverflow.clip,
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Text(
                                            "${item.expireOn}",
                                            overflow: TextOverflow.fade,
                                            style: TextStyles.txtMedium10(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              DialogProgressBar(
                isLoading: mySubscriptionWatch.isLoadingPagination,
                forPagination: true,
              ).paddingOnly(bottom: 40.h)
            ],
          );
  }

  ///Subscription List Api
  Future subscriptionListApi(
      MySubscriptionController mySubscriptionWatch, bool removeOldData) async {
    if (removeOldData == true) {
      mySubscriptionWatch.isHasMorePage = false;
    }
    if (isInternetConnectionOn) {
      await mySubscriptionWatch.subscriptionListApi(context);
    }
  }

  ///Cancel Subscription Api
  Future cancelSubscriptionApi(MySubscriptionController mySubscriptionWatch,
      String recommenderId) async {
    if (isInternetConnectionOn) {
      await mySubscriptionWatch.cancelSubscriptionApi(context,
          recommenderId: recommenderId);
      if (mySubscriptionWatch.cancelSubscriptionResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        showMessageDialog(context,
            mySubscriptionWatch.cancelSubscriptionResponseModel?.message ?? "",
            () {
          subscriptionListApi(mySubscriptionWatch, true);
        });
      }
    }
  }
}
