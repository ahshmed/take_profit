import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/duration_controller.dart';
import '../../framework/data_provider/master/master_controller.dart';
import '../../framework/data_provider/master/master_provider.dart';
import '../../framework/repository/master/model/get_subscription_package_list.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';


class DurationScreen extends ConsumerStatefulWidget {
  final ScreenName screenName;
  final List<String>? subscriptionID;

  const DurationScreen(
      {Key? key, required this.screenName, this.subscriptionID})
      : super(key: key);

  @override
  ConsumerState<DurationScreen> createState() => _DurationScreenState();
}

class _DurationScreenState extends ConsumerState<DurationScreen>  {
  TextEditingController searchCTR = TextEditingController();
  FocusNode searchFocus = FocusNode();

  ScrollController scrollController = ScrollController();

  Timer? timer;
  int searchLength = 0;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final masterWatch = ref.watch(masterProvider);
      final durationWatch = ref.watch(durationProvider);

      if (widget.screenName == ScreenName.EditSubscriptionAmountScreen) {
        durationWatch.clearProvider();
      } else {
        apiGetSubscriptionPackagesList(masterWatch, durationWatch);
      }

      scrollController.addListener(() {
        if (masterWatch.isHasMorePage) {
          if (scrollController.position.maxScrollExtent ==
              scrollController.position.pixels) {
            if ((int.parse(masterWatch
                        .getSubscriptionPackageList?.data?.pageNumber
                        ?.toString() ??
                    "0") !=
                int.parse(
                  masterWatch.getSubscriptionPackageList?.data?.totalPage
                          .toString() ??
                      "0",
                ))) {
              apiGetSubscriptionPackagesList(masterWatch, durationWatch);
            }
          }
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final durationWatch = ref.watch(durationProvider);
    final masterWatch = ref.watch(masterProvider);
    return Stack(
      children: [
        Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              hideKeyboard(context);
            },
            child: NoInternetBuilder(
              child: bodyWidget(context, durationWatch, masterWatch),
            ),
          ),
          bottomNavigationBar: bottomWidget(durationWatch),
        ),
        DialogProgressBar(
            isLoading: durationWatch.isLoading || masterWatch.isLoading),
      ],
    );
  }

  Widget bodyWidget(BuildContext context, DurationController durationWatch,
      MasterController masterWatch) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 70.h,
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Transform.rotate(
                  angle: getAppLanguage() == 'ar' ? pi : 0,
                  child: CommonImageAsset(
                    strIcon: Constant.icBack,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          SizedBox(
            height: 33.h,
            width: Constant.infiniteSize,
            child: Text(
              "Key_Duration".localized,
              style: TextStyles.txtMedium20(context),
            ),
          ),
          SizedBox(
            height: 7.h,
          ),
          searchBar(context, masterWatch, durationWatch),
          SizedBox(
            height: 25.h,
          ),
          Text(
            "${"Key_AddSubscriptionPlan".localized}*",
            style: TextStyles.txtMedium12(context),
          ),
          SizedBox(
            height: 15.h,
          ),
          planListWidget(durationWatch),
          DialogProgressBar(
            isLoading: masterWatch.isLoadingForPagination,
            forPagination: true,
          ).paddingOnly(bottom: 40.h),
        ],
      ),
    );
  }

  Widget searchBar(BuildContext context, MasterController masterWatch,
      DurationController durationWatch) {
    return CustomTextField(
      height: 50,
      context: context,
      myController: searchCTR,
      bgColor: Constant.clrDarkByScaffoldTheme(context),
      myFocus: searchFocus,
      leftPadding: 13.w,
      hintText: "Key_SearchHere".localized + " ",
      onChanged: (str) {
        showLog("Search Keyword - $str");
        if (timer != null) {
          timer!.cancel();
        }
        timer = Timer.periodic(
          Duration(milliseconds: searchDurationInMilliSeconds),
          (timer) {
            timer.cancel();
            if (isInternetConnectionOn) {
              showLog("search text");
              hideKeyboard(context);
              apiGetSubscriptionPackagesList(masterWatch, durationWatch);
            }
          },
        );
      },
      textInputAction: TextInputAction.done,
      prefix: CommonImageAsset(
        strIcon: Constant.icSearchN,
      ),
      paddingNeed: false,
      marginNeed: false,
      borderRadius: 10.r,
    );
  }

  Widget planListWidget(DurationController durationWatch) {
    return (durationWatch.planList!.isEmpty && !durationWatch.isLoading)
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: EmptyStateWidget(emptyStateFor: EmptyState.noResultFound),
            ),
          )
        : ListView.separated(
            padding: EdgeInsets.zero,
            controller: scrollController,
            shrinkWrap: true,
            separatorBuilder: (context, i) {
              return SizedBox(
                height: 10.h,
              );
            },
            itemCount: durationWatch.planList?.length ?? 0,
            itemBuilder: (context, i) {
              PackageList? item = durationWatch.planList?[i];
              return InkWell(
                onTap: () {
                  if (widget.subscriptionID?.contains(durationWatch
                              .planList?[i].subscriptionPackageId) ==
                          false ||
                      widget.subscriptionID?.isEmpty == true ||
                      widget.subscriptionID == null) {
                    durationWatch.updateSelectedPlan(i, item!);
                  } else {
                    showMessageDialog(
                        context, 'Key_Thisplanisalreadyadded'.localized, () {});
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: durationWatch.tempSelectedPlanList
                                    ?.contains(item) ==
                                true
                            ? Constant.clrPrimary
                            : Constant.clrGreyNew),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    children: [
                      (durationWatch.tempSelectedPlanList?.contains(item) ==
                              true)
                          ? Image.asset(Constant.icBlueChecked,
                              height: 20.h, width: 16.h)
                          : Container(
                              height: 16.h,
                              width: 16.h,
                              decoration: BoxDecoration(
                                border: Border.all(color: Constant.clrBlackNew),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item?.packageName.toString() ?? "",
                              style: TextStyles.txtMedium12(context)),
                          Text(
                            "${item?.packageDuration.toString() ?? ""} day(s)",
                            style: TextStyles.txtRegular10(context)
                                .copyWith(color: Constant.clrGreyNew),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  ///bottom widget
  Widget bottomWidget(DurationController durationWatch) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20.w, right: 20.w, bottom: getIsIOSPlatform() ? 20.h : 10.h),
      child: CommonButton(
        label: getLocalValue("Key_AddPrice"),
        textSize: 16.sp,
        onTap: () {
          durationWatch.addItemsInSelectedList();
          if (widget.screenName == ScreenName.EditSubscriptionAmountScreen) {
            // durationWatch.addItemsInSelectedList();
            Navigator.of(context).pop(durationWatch.tempSelectedPlanList);
          } else {
            Navigator.of(context).pop();
          }
        },
        isEnable: durationWatch.tempSelectedPlanList?.isNotEmpty == true,
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
    durationWatch.updateIsLoading(true);
    if (isInternetConnectionOn) {
      await masterWatch.apiGetSubscriptionPackageList(context,
          search: searchCTR.text);
      if (masterWatch.getSubscriptionPackageList?.status ==
          ApiEndPoints.apiStatus_200) {
        // durationWatch.selectedPlanList?.clear();
        durationWatch.tempSelectedPlanList?.clear();
        durationWatch.planList?.clear();
        // durationWatch.priceList.clear();
        durationWatch.planList?.addAll(masterWatch.packageList);
        durationWatch.updateIsLoading(false);
      }
      durationWatch.updateIsLoading(false);
    }
  }
}
