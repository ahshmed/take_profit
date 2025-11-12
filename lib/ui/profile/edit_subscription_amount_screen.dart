import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/duration_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/master/master_provider.dart';
import '../../framework/data_provider/profile/edit_subscription_amount_controller.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/profile/profile_screen_controller.dart';
import '../../framework/repository/master/model/get_subscription_package_list.dart';
import '../../framework/repository/my_subscription/model/recommender_subscription_packages_response_model.dart';
import '../../framework/repository/profile/model/profile_details_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../auth/duration_screen.dart';

class EditSubscriptionAmountScreen extends ConsumerStatefulWidget {
  final ProfileData? profileData;

  const EditSubscriptionAmountScreen({Key? key, required this.profileData})
      : super(key: key);

  @override
  ConsumerState<EditSubscriptionAmountScreen> createState() =>
      _EditSubscriptionAmountScreenState();
}

class _EditSubscriptionAmountScreenState
    extends ConsumerState<EditSubscriptionAmountScreen>  {
  ScrollController scrollController = ScrollController();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final editSubscriptionAmountWatch =
          ref.watch(editSubscriptionAmountProvider);
      final profileWatch = ref.watch(profileProvider);

      editSubscriptionAmountWatch.clearProvider();
      getRecommenderSubscriptionPackagesAPI(
          editSubscriptionAmountWatch, profileWatch);

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
              getRecommenderSubscriptionPackagesAPI(
                  editSubscriptionAmountWatch, profileWatch);
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final editSubscriptionAmountWatch =
        ref.watch(editSubscriptionAmountProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue("Key_EditSubscriptionAmount"),
            isTitleCenter: true,
            appBar: AppBar(backgroundColor: Constant.clrWhiteNew, toolbarHeight: 64.h),
            isDrawer: false,
          ),
          body: NoInternetBuilder(
            child: bodyWidget(editSubscriptionAmountWatch),
          ),
          bottomNavigationBar: bottomWidget(editSubscriptionAmountWatch),
        ),
        DialogProgressBar(isLoading: editSubscriptionAmountWatch.isLoading)
      ],
    );
  }

  ///body widget
  Widget bodyWidget(
      EditSubscriptionAmountController editSubscriptionAmountWatch) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: (editSubscriptionAmountWatch.subscriptionPackageList.isEmpty &&
              !editSubscriptionAmountWatch.isLoading)
          ? EmptyStateWidget(emptyStateFor: EmptyState.noPlanToFound)
          : ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      controller: scrollController,
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        final item = editSubscriptionAmountWatch
                            .subscriptionPackageList[i];
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            color: Constant.clrDarkByScaffoldTheme(context),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Constant.clrLightPurple),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: item.packageName.toString(),
                                      style: TextStyles.txtMedium12(context),
                                      children: [
                                        const TextSpan(text: "  "),
                                        TextSpan(
                                          text:
                                              "${item.packageDuration} day(s)",
                                          style: TextStyles.txtRegular10
                                              (context).copyWith(color: Constant.clrGreyNew),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      editSubscriptionAmountWatch
                                          .removeItemAtIndex(i, item);
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
                                style: TextStyles.txtRegular10
                                    (context).copyWith(color: Constant.clrGreyNew),
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              CustomTextField(
                                autoFocus: true,
                                context: context,
                                myController:
                                    editSubscriptionAmountWatch.amountCTR[i],
                                myFocus:
                                    editSubscriptionAmountWatch.amountFocus[i],
                                bgColor: Constant.clrDarkByScaffoldTheme(context),
                                textInputType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (str) {
                                  editSubscriptionAmountWatch
                                          .subscriptionPackageList[i].price =
                                      editSubscriptionAmountWatch
                                          .amountCTR[i].text;
                                  editSubscriptionAmountWatch
                                          .subscriptionPackageList[i]
                                          .subscriptionPackageId =
                                      item.subscriptionPackageId;
                                  editSubscriptionAmountWatch.checkValidation();
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
                                      left: ref
                                                  .watch(drawerProvider)
                                                  .isEngEnable ==
                                              false
                                          ? 16.w
                                          : 0),
                                  child: Text(
                                    currency,
                                    style: TextStyles.txtMedium12
                                        (context).copyWith(color: Constant.clrGreyNew),
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
                      itemCount: editSubscriptionAmountWatch
                          .subscriptionPackageList.length),
                ),
                Visibility(
                  visible: editSubscriptionAmountWatch
                      .subscriptionPackageList.isNotEmpty,
                  child: SizedBox(
                    height: 30.h,
                  ),
                ),
                InkWell(
                  onTap: () {
                    List<PackageList> tempPlanList;
                    apiGetSubscriptionPackagesList();
                    Route route = SlideRightPageRoute(
                      builder: (context) => DurationScreen(
                        screenName: ScreenName.EditSubscriptionAmountScreen,
                        subscriptionID:
                            editSubscriptionAmountWatch.subscriptionIdList,
                      ),
                      settings: const RouteSettings(),
                    );
                    Navigator.of(context).push(route).then(
                      (value) async {
                        if (value != null) {
                          tempPlanList = [];
                          tempPlanList = await value as List<PackageList>;
                          showLog("tempPlanList ${tempPlanList.length}");
                          addDataToEditSubscriptionAmountList(
                              editSubscriptionAmountWatch, tempPlanList);
                        }
                      },
                    );
                  },
                  child: Text(
                    editSubscriptionAmountWatch
                            .subscriptionPackageList.isNotEmpty
                        ? "Key_AddMoreWithPlus".localized
                        : '',
                    textAlign: TextAlign.center,
                    style: TextStyles.txtMedium16(context).copyWith(color: Constant.clrPrimary),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
              ],
            ),
    );
  }

  ///bottom Widget
  Widget bottomWidget(
      EditSubscriptionAmountController editSubscriptionAmountWatch) {
    final profileWatch = ref.watch(profileProvider);
    return Padding(
      padding: EdgeInsets.only(
          left: 20.w, right: 20.w, bottom: getIsIOSPlatform() ? 20.h : 10.h),
      child: CommonButton(
        label: editSubscriptionAmountWatch.subscriptionPackageList.isNotEmpty
            ? getLocalValue("Key_Save")
            : "Key_AddNewPlans".localized,
        textSize: 16.sp,
        onTap: () {
          if (editSubscriptionAmountWatch.subscriptionPackageList.isNotEmpty) {
            updateProfileDetailsAPI(editSubscriptionAmountWatch, profileWatch);
          } else {
            List<PackageList> tempPlanList;
            apiGetSubscriptionPackagesList();
            Route route = SlideRightPageRoute(
              builder: (context) => DurationScreen(
                screenName: ScreenName.EditSubscriptionAmountScreen,
                subscriptionID: editSubscriptionAmountWatch.subscriptionIdList,
              ),
              settings: const RouteSettings(),
            );
            Navigator.of(context).push(route).then(
              (value) async {
                if (value != null) {
                  tempPlanList = [];
                  tempPlanList = await value as List<PackageList>;
                  showLog("tempPlanList ${tempPlanList.length}");
                  addDataToEditSubscriptionAmountList(
                      editSubscriptionAmountWatch, tempPlanList);
                }
              },
            );
          }
        },
        height: 50.h,
        bgColor: Constant.clrPrimary,
        labelColor: Constant.clrWhite,
        borderColor: Constant.clrPrimary,
        isEnable:
            (editSubscriptionAmountWatch.subscriptionPackageList.isNotEmpty)
                ? editSubscriptionAmountWatch.isValidate
                : true,
      ),
    );
  }

  /// Update Profile
  Future<void> updateProfileDetailsAPI(
      EditSubscriptionAmountController editSubscriptionAmountWatch,
      ProfileScreenController profileWatch) async {
    if (isInternetConnectionOn) {
      await editSubscriptionAmountWatch.updateProfileAPI(context);
      if (editSubscriptionAmountWatch.profileDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        Navigator.of(context).pop();
        profileWatch.profileAPI(context);
      }
    }
  }

  void addDataToEditSubscriptionAmountList(
      EditSubscriptionAmountController editSubscriptionAmountWatch,
      List<PackageList> value) {
    editSubscriptionAmountWatch.planList = [];
    editSubscriptionAmountWatch.planList = value;
    List<SubscriptionPackageList> tempSubscriptionPackageList = [];
    tempSubscriptionPackageList.clear();
    showLog(
        "editSubscriptionAmountWatch.planList  ${editSubscriptionAmountWatch.planList.length}");

    /// Add Data into temp Subscription List Data
    for (int i = 0; i < (editSubscriptionAmountWatch.planList.length); i++) {
      showLog(
          "planList Item ${editSubscriptionAmountWatch.planList[i].interval}");
      showLog(
          "planList Item ${editSubscriptionAmountWatch.planList[i].packageDuration}");
      showLog(
          "planList Item ${editSubscriptionAmountWatch.planList[i].subscriptionPackageId}");
      showLog(
          "planList Item ${editSubscriptionAmountWatch.planList[i].packageName}");

      tempSubscriptionPackageList.add(SubscriptionPackageList());
      editSubscriptionAmountWatch.amountFocus.add(FocusNode());
      editSubscriptionAmountWatch.amountCTR.add(TextEditingController());
      editSubscriptionAmountWatch.priceList.add(PriceModel());

      /// Subscription id Lost adding Data
      editSubscriptionAmountWatch.subscriptionIdList.add(
          editSubscriptionAmountWatch.planList[i].subscriptionPackageId ?? "");
      tempSubscriptionPackageList[i].interval =
          editSubscriptionAmountWatch.planList[i].interval;
      tempSubscriptionPackageList[i].packageDuration =
          editSubscriptionAmountWatch.planList[i].packageDuration;
      tempSubscriptionPackageList[i].packageName =
          editSubscriptionAmountWatch.planList[i].packageName;
      tempSubscriptionPackageList[i].subscriptionPackageId =
          editSubscriptionAmountWatch.planList[i].subscriptionPackageId;
    }

    /// Add temp Data into main list
    editSubscriptionAmountWatch.subscriptionPackageList
        .addAll(tempSubscriptionPackageList);

    /// To Update Widget
    editSubscriptionAmountWatch.updateWidget();
  }

  Future<void> getRecommenderSubscriptionPackagesAPI(
      EditSubscriptionAmountController editSubscriptionAmountWatch,
      ProfileScreenController profileWatch) async {
    if (isInternetConnectionOn) {
      await editSubscriptionAmountWatch.recommenderSubscriptionPackageListApi(
          context,
          recommenderID: widget.profileData?.id);
    }
  }

  /// Get Subscription Package List APi Call
  apiGetSubscriptionPackagesList() async {
    final masterWatch = ref.watch(masterProvider);
    final durationWatch = ref.watch(durationProvider);
    durationWatch.updateIsLoading(true);
    await masterWatch.apiGetSubscriptionPackageList(context);
    if (masterWatch.getSubscriptionPackageList?.status ==
        ApiEndPoints.apiStatus_200) {
      durationWatch.planList?.clear();
      durationWatch.priceList.clear();
      durationWatch.planList?.addAll(masterWatch.packageList);
      durationWatch.updateIsLoading(false);
    }
  }
}
