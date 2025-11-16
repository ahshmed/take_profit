// ignore_for_file: unused_local_variable
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:blur/blur.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/home/signals_details_screen.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/home/recommender_controller.dart';
import '../../framework/data_provider/recommender/my_recommendation_controller.dart';
import '../../framework/data_provider/recommender/recommender_provider.dart';
import '../../framework/repository/common/model/crypto_currency_response_model.dart';
import '../../framework/repository/signal/model/signal_list_response_model.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_svg.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../my_subscription/choose_plan_screen.dart';
import '../request_analysis/requesting_for_analysis_screen.dart';
import 'chart_screenshot_screen.dart';
import 'helper/list_item_with_images_widget.dart';

class RecommenderDetailScreen extends ConsumerStatefulWidget {
  final String recommenderID;
  final NotificationSlugTrader? notificationTraderSlug;
  final NotificationSlugRecommender? notificationSlugRecommender;
  final bool appbarRequired;

  const RecommenderDetailScreen(
      {Key? key,
        required this.recommenderID,
        this.notificationTraderSlug,
        this.notificationSlugRecommender,
        this.appbarRequired = true})
      : super(key: key);

  @override
  ConsumerState<RecommenderDetailScreen> createState() =>
      _RecommenderDetailScreenState();
}

class _RecommenderDetailScreenState
    extends ConsumerState<RecommenderDetailScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();
  final PageController _adPageController = PageController();
  final TextEditingController _searchController = TextEditingController();


  Timer? currencyTimer;
  Timer? adAutoScrollTimer;
  int currentAdPage = 0;
  String searchQuery = "";

  // Placeholder data for ads (will be replaced with API data later)
  final List<String> adImages = [
    Constant.icAdvertiseN,
    Constant.icAdvertiseN,
    Constant.icAdvertiseN,
  ];

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final recommenderWatch = ref.watch(recommenderProvider);
      final myRecommendationWatch = ref.watch(myRecommendationProvider);

      WidgetsBinding.instance.addObserver(this);
      await apiCallFromInit();
      if (recommenderWatch.signalsSubTabSelectIndex == 0 ||
          recommenderWatch.signalsSubTabSelectIndex == 1) {
        await livePriceChangeFunction();
        await getAllSignalIstApiCallOnPeriodic();
      } else {
        await livePriceChangeFunction(isTimerStart: false);
        await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
      }

      startAdAutoScroll();

      if (widget.notificationTraderSlug ==
          NotificationSlugTrader.all_signal_close) {
        recommenderWatch.updateSignalsSubTabIndex(2);
      } else if (widget.notificationTraderSlug ==
          NotificationSlugTrader.new_scenario ||
          widget.notificationSlugRecommender ==
              NotificationSlugRecommender.new_scenario) {
        recommenderWatch.updateMainTabIndex(1);
        getBTCScenariosList(myRecommendationWatch, widget.recommenderID,
            removeOld: true);
        recommenderWatch.clearDate();
      } else if (widget.notificationTraderSlug ==
          NotificationSlugTrader.update_social_post ||
          widget.notificationTraderSlug ==
              NotificationSlugTrader.new_social_post) {
        recommenderWatch.updateMainTabIndex(2);
        recommenderWatch.clearDate();
        socialListApi(recommenderWatch);
      }
    });
    super.initState();
  }

  void startAdAutoScroll() {
    adAutoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adPageController.hasClients && adImages.isNotEmpty) {
        currentAdPage = (currentAdPage + 1) % adImages.length;
        _adPageController.animateToPage(
          currentAdPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    showLog('AppLifecycleState :- $state');
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await livePriceChangeFunction(isTimerStart: false);
      await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
      adAutoScrollTimer?.cancel();
      showLog("currency timer ${currencyTimer?.isActive}");
    } else if (state == AppLifecycleState.resumed) {
      await livePriceChangeFunction();
      await getAllSignalIstApiCallOnPeriodic();
      startAdAutoScroll();
      showLog("currency timer ${currencyTimer?.isActive}");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    _adPageController.dispose();
    _searchController.dispose();
    adAutoScrollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    livePriceChangeFunction(isTimerStart: false);
    getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
  }

  apiCallFromInit() {
    final recommenderWatch = ref.watch(recommenderProvider);
    final myRecommendationWatch = ref.watch(myRecommendationProvider);

    myRecommendationWatch.clearProvider();
    recommenderWatch.clearProvider();

    if (recommenderWatch.mainTabSelectIndex == 0) {
      scrollListenerMethod(myRecommendationWatch, recommenderWatch);
      apiCall(recommenderWatch);
    }
    if (recommenderWatch.mainTabSelectIndex == 1) {
      scrollListenerMethod(myRecommendationWatch, recommenderWatch);
      getBTCScenariosList(myRecommendationWatch, widget.recommenderID);
    }
    if (recommenderWatch.mainTabSelectIndex == 2) {
      scrollListenerMethod(myRecommendationWatch, recommenderWatch);
      socialListApi(recommenderWatch);
    }
  }

  scrollListenerMethod(MyRecommendationScreenController myRecommendationWatch,
      RecommenderScreenController recommenderWatch) {
    _scrollController.addListener(() async {
      if (recommenderWatch.isHasMoreSignalList) {
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.position.pixels) {
          await apiGetAllSignalList();
        }
      }
    });
    _scrollController2.addListener(() async {
      if (myRecommendationWatch.isHasMorePage) {
        if (_scrollController2.position.maxScrollExtent ==
            _scrollController2.position.pixels) {
          getBTCScenariosList(myRecommendationWatch, widget.recommenderID);
        }
      }
    });
    _scrollController3.addListener(() async {
      final newSocialWatch = ref.watch(newSocialProvider);
      if (newSocialWatch.isHasMorePage) {
        if (_scrollController3.position.maxScrollExtent ==
            _scrollController3.position.pixels) {
          socialListApi(recommenderWatch);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommenderWatch = ref.watch(recommenderProvider);
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    final newSocialWatch = ref.watch(newSocialProvider);
    final drawerWatch = ref.watch(drawerProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrHomeScreenByTheme(context),
          appBar: (widget.appbarRequired)
              ? CommonAppBar(
            title: getLocalValue("Key_RecommenderDetail"),
            isTitleCenter: true,
            appBar: AppBar(
                backgroundColor: Constant.clrHomeScreenByTheme(context),
                toolbarHeight: 64.h),
            isDrawer: false,
          )
              : const PreferredSize(
              preferredSize: Size(0, 0),
              child: Offstage()),
          body: (recommenderWatch.recommenderDetailResponseModel?.data != null)
              ? NoInternetBuilder(child: bodyWidget(recommenderWatch))
              : const Offstage(),
        ),
        DialogProgressBar(
            isLoading: recommenderWatch.isLoading ||
                myRecommendationWatch.isLoading ||
                newSocialWatch.isLoading),
      ],
    );
  }

  Widget bodyWidget(RecommenderScreenController recommenderWatch) {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    final socialWatch = ref.watch(newSocialProvider);

    return CustomScrollView(
      controller: (recommenderWatch.mainTabSelectIndex == 0)
          ? _scrollController
          : (recommenderWatch.mainTabSelectIndex == 1)
          ? _scrollController2
          : _scrollController3,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              ConstrainedBox(
                constraints: const BoxConstraints(),
                child: Column(
                  children: [
                    SizedBox(height: 15.h),

                    /// Hero Banner with Bitcoin Image
                    buildHeroBanner(),

                    SizedBox(height: 20.h),

                    /// Search Bar - HIDDEN for recommender users
                    // buildSearchBar(),

                    // SizedBox(height: 20.h),

                    /// Gain History Section - HIDDEN for recommender users
                    // buildGainHistorySection(),

                    // SizedBox(height: 20.h),

                    /// Consultation and Subscribe Buttons
                    Visibility(
                      visible: ((recommenderWatch.recommenderDetailResponseModel
                          ?.data?.isSameUser !=
                          '1') &&
                          (getUserEntityId() !=
                              recommenderWatch.recommenderDetailResponseModel
                                  ?.data?.recommenderId)),
                      child: buildActionButtons(recommenderWatch),
                    ),

                    SizedBox(height: 20.h),

                    /// Main Tabs and Content
                    moreDetailsWidget(recommenderWatch),

                    DialogProgressBar(
                      isLoading: (recommenderWatch.mainTabSelectIndex == 0)
                          ? recommenderWatch.isLoadingForPagination
                          : (recommenderWatch.mainTabSelectIndex == 1)
                          ? myRecommendationWatch.isLoadingPagination
                          : socialWatch.isLoadingPagination,
                      forPagination: true,
                    ),
                    SizedBox(height: 24.h)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Hero Banner with Bitcoin Image
  Widget buildHeroBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.r),
        child: SizedBox(
          width: double.infinity,
          child: Image.asset(
            Constant.icAdvertiseN,
            height: 125.h,
            width: 345.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// Search Bar with active search
  Widget buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Constant.clrSearchByTheme(context),
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Key_SearchArea'.localized,
            hintStyle: TextStyles.txtRegular10(context).copyWith(
              color: Constant.clrSearchHintByTheme(context),
              fontSize: 10,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Constant.clrTitlePageByTheme(context),
              size: 24.h,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.grey.shade400,
                size: 20.h,
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchQuery = "";
                });
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
    );
  }

  /// Gain History Section - PLACEHOLDER
  Widget buildGainHistorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:15.0),
      child: Container(
      padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.13),
          color: Constant.clrGainByTheme(context),
          boxShadow:[ BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 16.13,
            offset: const Offset(0, 2),
          )]

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key_GainHistory'.localized,
              style: TextStyles.txtSemiG16(context).copyWith(
                fontWeight: FontWeight.w500,
                color: Constant.clrTitlePageByTheme(context),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(color: Constant.clrGainByTheme(context)),
              child: Row(
                children: [
                  Expanded(
                    child: buildGainHistoryCard('3 Months', '+154%'),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    height: 40.h,
                    child: VerticalDivider(
                      width: 1.w,
                      thickness: 1.08,
                      color: Constant.clrHomeDividerColor,
                    ),
                  ),
                  Expanded(
                    child: buildGainHistoryCard('6 Months', '+784%'),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    height: 40.h,
                    child: VerticalDivider(
                      width: 1.w,
                      thickness: 1.08,
                      color: Constant.clrHomeDividerColor,
                    ),
                  ),
                  Expanded(
                    child: buildGainHistoryCard('Total', '+791%'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGainHistoryCard(String period, String percentage) {
    return Column(
      children: [
        Text(
          period,
          style: TextStyles.txtRegG14(context).copyWith(
            color: Constant.clrGainColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          percentage,
          style: TextStyles.txtSemiBold18(context).copyWith(
            color: Constant.clrSignDetailsAchColor,
            fontWeight: Constant.fwRegular
          ),
        ),
      ],
    );
  }

  /// Action Buttons with DOTTED border for Consultation
  Widget buildActionButtons(RecommenderScreenController recommenderWatch) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          /// Consultation Button with DOTTED border
          Expanded(
            child: InkWell(
              onTap: () async {
                if (getUserStatus() != guest) {
                  if (recommenderWatch.recommenderDetailResponseModel?.data
                      ?.enableRequestAnalysis ==
                      "0") {
                    showMessageDialog(
                        context,
                        "Key_RecommenderNotAcceptingAnyRequest".localized,
                            () {});
                  } else {
                    await livePriceChangeFunction(isTimerStart: false);
                    await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
                    Route route = SlideRightPageRoute(
                        builder: (context) => RequestingForAnalysisScreen(
                          fromScreen: ScreenName.RecommenderDetailsScreen,
                          recommenderID: widget.recommenderID,
                        ),
                        settings: const RouteSettings());
                    Navigator.push(context, route).then((value) async {
                      await apiCallFromInit();
                      await livePriceChangeFunction();
                      await getAllSignalIstApiCallOnPeriodic();
                    });
                  }
                } else {
                  getStartedDialog(context, canPop: false);
                }
              },
              child: CustomPaint(
                painter: DottedBorderPainter(
                  color: Constant.clrPrimary,
                  strokeWidth: 1.5,
                  dashWidth: 5,
                  dashSpace: 3,
                ),
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Key_RequestAnalysis'.localized,
                      style: TextStyles.txtMedG12(context).copyWith(
                        color: Constant.clrPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          /// Subscribe Button
          Expanded(
            child: InkWell(
              onTap: () async {
                if (getUserStatus() == guest) {
                  getStartedDialog(context);
                } else if (recommenderWatch.recommenderDetailResponseModel
                    ?.data?.isSubscribed ==
                    "0") {
                  if (getUserEntityId() !=
                      recommenderWatch.recommenderDetailResponseModel?.data
                          ?.recommenderId) {
                    livePriceChangeFunction(isTimerStart: false);
                    await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
                    Route route = SlideRightPageRoute(
                        builder: (context) => ChoosePlanScreen(
                          fromScreen: ScreenName.RecommenderDetailsScreen,
                          recommenderID: widget.recommenderID,
                        ),
                        settings: const RouteSettings());
                    Navigator.push(context, route).then((value) async {
                      await apiCallFromInit();
                      await livePriceChangeFunction();
                      await getAllSignalIstApiCallOnPeriodic();
                    });
                  }
                }
              },
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    colors: recommenderWatch.recommenderDetailResponseModel
                        ?.data?.isSubscribed ==
                        "1"
                        ? [Colors.grey.shade300, Colors.grey.shade300]
                        : [const Color(0xFFFFA726), const Color(0xFFFB8C00)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      recommenderWatch.recommenderDetailResponseModel?.data
                          ?.isSubscribed ==
                          "1"
                          ? Icons.star
                          : Icons.star_border,
                      color: Constant.clrWhite,
                      size: 20.h,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      recommenderWatch.recommenderDetailResponseModel?.data
                          ?.isSubscribed ==
                          "1"
                          ? getLocalValue("Key_Subscribed")
                          : getLocalValue("Key_Subscribe"),
                      style: TextStyles.txtMedG12(context).copyWith(
                        color: Constant.clrWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget moreDetailsWidget(RecommenderScreenController recommenderWatch) {
    return Container(
      color: Constant.clrScaffoldBGByTheme(context),
      child: Padding(
        padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
        child: Column(
          children: [
            /// Main Tabs with UNDERLINE selection
            moreDetailsMainTabList(recommenderWatch),
            SizedBox(height: 20.h),
            Column(
              children: [
                recommenderWatch.mainTabSelectIndex == 0
                    ? signalsTabWidget(recommenderWatch)
                    : recommenderWatch.mainTabSelectIndex == 1
                    ? btcScenariosTabWidget(recommenderWatch)
                    : socialTabWidget(recommenderWatch),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Main Tabs with UNDERLINE indicator
  Widget moreDetailsMainTabList(RecommenderScreenController recommenderWatch) {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          /// Signals Tab
          Flexible(
            flex: 3,
            child: InkWell(
              onTap: () async {
                recommenderWatch.updateMainTabIndex(0);
                recommenderWatch.clearDate();
                recommenderWatch.isHasMoreSignalList = false;
                await apiGetAllSignalList();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getLocalValue(recommenderWatch.mainTabList[0]),
                    style: TextStyles.txtBold14(context).copyWith(
                      color: recommenderWatch.mainTabSelectIndex == 0
                          ? Constant.clrPrimary
                          : Constant.clrHomeUnselectedColor,
                      fontWeight: recommenderWatch.mainTabSelectIndex == 0
                          ? FontWeight.w400
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: recommenderWatch.mainTabSelectIndex == 0
                          ? Constant.clrPrimary
                          : Constant.clrTransparent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BTC Scenarios Tab
          Flexible(
            flex: 5,
            child: InkWell(
              onTap: () {
                getUserStatus() == guest
                    ? getStartedDialog(context)
                    : recommenderWatch.updateMainTabIndex(1);
                getBTCScenariosList(myRecommendationWatch, widget.recommenderID,
                    removeOld: true);
                recommenderWatch.clearDate();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getLocalValue(recommenderWatch.mainTabList[1]),
                    style: TextStyles.txtBold14(context).copyWith(
                      color: recommenderWatch.mainTabSelectIndex == 1
                          ? Constant.clrPrimary
                          : Constant.clrHomeUnselectedColor,
                      fontWeight: recommenderWatch.mainTabSelectIndex == 1
                          ? FontWeight.w400
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: recommenderWatch.mainTabSelectIndex == 1
                          ? Constant.clrPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Social Tab
          Flexible(
            flex: 4,
            child: InkWell(
              onTap: () {
                recommenderWatch.updateMainTabIndex(2);
                recommenderWatch.clearDate();
                socialListApi(recommenderWatch);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getLocalValue(recommenderWatch.mainTabList[2]),
                    style: TextStyles.txtBold14(context).copyWith(
                      color: recommenderWatch.mainTabSelectIndex == 2
                          ? Constant.clrPrimary
                          : Constant.clrHomeUnselectedColor,
                      fontWeight: recommenderWatch.mainTabSelectIndex == 2
                          ? FontWeight.w400
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: recommenderWatch.mainTabSelectIndex == 2
                          ? Constant.clrPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget moreDetailsCommonSubTabList(
      RecommenderScreenController recommenderWatch,
      List? listName,
      int listLength,
      int listIndex,
      dynamic Function(int index) updateIndex) {
    final drawerWatch = ref.watch(drawerProvider);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      alignment: drawerWatch.isEngEnable == false
          ? Alignment.centerRight
          : Alignment.centerLeft,
      height: 40.h,
      child: ListView.separated(
        itemCount: listLength,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          bool isSelected = index == listIndex;
          return InkWell(
            onTap: () async {
              if (listName == recommenderWatch.socialSubTabList &&
                  listName?[index] == listName?[2]) {
                openCalender();
              } else {
                showLog("index $index");
                updateIndex(index);
                if (recommenderWatch.mainTabSelectIndex == 2) {
                  await socialListApi(recommenderWatch);
                } else if (recommenderWatch.mainTabSelectIndex == 0) {
                  recommenderWatch.clearSignalData();
                  await apiGetAllSignalList();
                }
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    listName == recommenderWatch.socialSubTabList &&
                        listName?[index] == listName?[2] &&
                        recommenderWatch.selectDateStr != null
                        ? Text(
                      recommenderWatch.selectDateStr.toString(),
                      style: TextStyles.txtBold14(context).copyWith(
                        color: isSelected
                            ? Constant.clrPrimary
                            : Constant.clrHomeUnselectedColor,
                        fontWeight: isSelected
                            ? FontWeight.w400
                            : FontWeight.w400,
                      ),
                    )
                        : Text(
                      getLocalValue(listName?[index]),
                      style: TextStyles.txtBold14(context).copyWith(
                        color: isSelected
                            ? Constant.clrPrimary
                            : Constant.clrHomeUnselectedColor,
                        fontWeight: isSelected
                            ? FontWeight.w400
                            : FontWeight.w400,
                      ),
                    ),
                    Visibility(
                      visible: listName == recommenderWatch.socialSubTabList &&
                          listName?[index] == listName?[2],
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Icon(
                          Icons.calendar_today,
                          size: 14.h,
                          color: isSelected
                              ? Constant.clrPrimary
                              : Constant.clrHomeUnselectedColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  height: 2.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Constant.clrPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 20.w);
        },
      ),
    );
  }

  /// Horizontal Ad Banner - Appears AFTER first card
  Widget buildHorizontalAdBanner() {
    return Container(
      height: 120.h,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: PageView.builder(
        controller: _adPageController,
        itemCount: adImages.length,
        onPageChanged: (index) {
          setState(() {
            currentAdPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: index % 2 == 0
                        ? [const Color(0xFF5E3FBE), const Color(0xFF2A1A5E)]
                        : [const Color(0xFFFF6B35), const Color(0xFFF7931A)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          adImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16.w,
                      top: 16.h,
                      right: 100.w,
                      bottom: 50.h,
                      child: Text(
                        (index % 2 == 0
                            ? getLocalValue('Key_CryptoPromotionalOffers')
                            : getLocalValue('Key_CryptoBannersVideoAds')).replaceAll(' ', '\n'),
                        style: TextStyles.txtBold22(context).copyWith(
                          color: Constant.clrWhite,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Positioned(
                      right: 16.w,
                      bottom: 16.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Constant.clrWhite,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 16.h,
                              color: const Color(0xFFF7931A),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              getLocalValue('Key_LearnMore'),
                              style: TextStyles.txtMedium12(context).copyWith(
                                color: const Color(0xFF5E3FBE),
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
          );
        },
      ),
    );
  }

  /// Signals Tab Widget
  Widget signalsTabWidget(RecommenderScreenController recommenderWatch) {
    return Column(
      children: [
        moreDetailsCommonSubTabList(
            recommenderWatch,
            recommenderWatch.signalSubTabList,
            recommenderWatch.signalSubTabList.length,
            recommenderWatch.signalsSubTabSelectIndex,
            recommenderWatch.updateSignalsSubTabIndex),

        recommenderWatch.signalsSubTabSelectIndex == 0
            ? signalsTabPendingList(recommenderWatch)
            : recommenderWatch.signalsSubTabSelectIndex == 1
            ? signalsTabActiveList(recommenderWatch)
            : signalsTabClosedList(recommenderWatch)
      ],
    );
  }

  /// Signal Card Widget
  Widget buildSignalCard(
      SignalList signalData,
      RecommenderScreenController recommenderWatch, {
        required bool isActive,
      }) {
    final isRTL = Directionality.of(context) == ui.TextDirection.rtl;
    final commonWatch = ref.watch(commonProvider);

    // Use isActive directly for blur logic
    final bool shouldBlur = _shouldBlurCard(recommenderWatch, isActive, commonWatch: commonWatch);

    // bool showData = (isActive
    //     ? (recommenderWatch.recommenderDetailResponseModel?.data?.isSubscribed == "1" && getUserStatus() != guest)
    //     : (commonWatch.showClosedSignal || (recommenderWatch.recommenderDetailResponseModel?.data?.isSubscribed == "1" && getUserStatus() != guest)));

    Widget cardContent = Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.13.r),
          color: Constant.clrHomeCardByTheme(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            /// Currency Header with badges on opposite side
            Directionality(
              textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Currency Logo
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: CacheImage(
                        imageURL: signalData.currencyLogo ?? "",
                        height: 50.h,
                        width: 50.h,
                        contentMode: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  /// Currency Name and Timestamp - Expanded to take available space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${signalData.currencyName ?? ""} (${signalData.currencySymbol ?? ""})",
                          style: TextStyles.txtSemiBold14(context).copyWith(
                            color: Constant.clrSigDetByTheme(context),
                            fontWeight: Constant.fwMedium,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '01/11/2022 14:35', // PLACEHOLDER - TO BE LINKED WITH API
                          style: TextStyles.txtMedGI12(context).copyWith(
                            fontSize: 11.sp,
                            color: Constant.clrHeaderSubSignDetailsColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Status Badges Stack
                  Column(
                    crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      /// Risk Badge
                      Container(
                        width: 97.w,
                        height: 23.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _getRiskBadgeColor(signalData.riskFactor ?? ""),
                          borderRadius: isRTL
                              ? BorderRadius.only(
                            topRight: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          )
                              : BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            bottomLeft: Radius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          '${signalData.riskFactor ?? "Medium"} Risk',
                          style: TextStyles.txtSemiBoldG10(context).copyWith(
                            fontWeight: Constant.fwRegular,
                            color: Constant.clrWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 6.h),

                      /// Status Badge (Invalid for Trading / Valid, etc.)
                      Container(
                        width: 97.w,
                        height: 23.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? (signalData.profitStatus == 'profit'
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                              : const Color(0xFFEF4444),
                          borderRadius: isRTL
                              ? BorderRadius.only(
                            topRight: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          )
                              : BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            bottomLeft: Radius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          isActive
                              ? (shouldBlur ? getLocalValue('Key_InvalidForTrading') : getLocalValue('Key_Valid'))
                              : getLocalValue('Key_InvalidForTrading'),
                          style: TextStyles.txtMedium10(context).copyWith(
                            color: Constant.clrWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            /// Free Text Section - PLACEHOLDER (To be linked with API later)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '[Free text goes here. It\'s provided from the backend api]',
                style: TextStyles.txtSemiBoldG12(context).copyWith(
                  fontWeight: Constant.fwRegular,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),

            SizedBox(height: 8.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Divider(color: Constant.clrSigDetDividerByTheme(context)),
            ),

            /// Price Details Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  /// Live Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Key_LivePrice'.localized,
                        style: TextStyles.txtMedG12(context).copyWith(
                          color: Constant.clrNotifSelectBColor,
                        ),
                      ),
                      Text(
                        shouldBlur
                            ? '••••••'
                            : '${signalData.livePrice ?? "0"} USDT',

                        style: TextStyles.txtSemiBold14(context).copyWith(
                          fontWeight: Constant.fwRegular,
                          color: Constant.clrNotifSelectBColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                  Divider(color: Constant.clrSigDetDividerByTheme(context)),
                  /// Entry Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Key_EntryPrice'.localized,
                        style: TextStyles.txtMedG12(context).copyWith(
                          color: Constant.clrSigDetEntByTheme(context),
                        ),
                      ),
                      Text(
                        shouldBlur
                            ? '••••••'
                            : '${signalData.entryPrice ?? "0"} USDT',

                        style: TextStyles.txtSemiBold14(context).copyWith(
                          fontWeight: Constant.fwRegular,
                          color: Constant.clrSigDetEntByTheme(context),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                  Divider(color: Constant.clrSigDetDividerByTheme(context)),
                  /// Stop Loss
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Key_StopLoss'.localized,
                        style: TextStyles.txtMedG12(context).copyWith(
                          color: Constant.clrSignOutRColor,
                        ),
                      ),
                      Text(
                        shouldBlur
                            ? '••••••'
                            : '${signalData.stopLoss ?? "0"} USDT',

                        style: TextStyles.txtSemiBold14(context).copyWith(
                          fontWeight: Constant.fwRegular,
                          color: Constant.clrSignOutRColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      );
        /// Blur Overlay
    return (shouldBlur &&
        getUserEntityId() != recommenderWatch.recommenderDetailResponseModel?.data?.recommenderId &&
        recommenderWatch.recommenderDetailResponseModel?.data?.isSameUser != '1')
        ? Blur(
      borderRadius: BorderRadius.circular(16.13.r),
      blurColor: Constant.clrDarkByScaffoldTheme(context).withValues(alpha: 0.2),
      child: cardContent,
    )
        : cardContent;
  }
  /// Price Row
  Widget _buildPriceRow({
    required String label,
    required String value,
    required Color valueColor,
    VoidCallback? onCopy,
    bool showCopy = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyles.txtSemiBoldG12(context).copyWith(
              color: valueColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyles.txtRegG14(context).copyWith(
              color: valueColor,
            ),
          ),
          if (showCopy) SizedBox(width: 12.w),
          if (showCopy)
            InkWell(
              onTap: onCopy,
              child: Icon(
                Icons.copy_outlined,
                size: 20.sp,
                color: Constant.clrSignDetailsCopyColor,
              ),
            ),
        ],
      ),
    );
  }

  Color _getRiskBadgeColor(String riskLabel) {
    if (riskLabel.toLowerCase().contains("high")) {
      return Color(0xFFEF4444);
    } else if (riskLabel.toLowerCase().contains("medium")) {
      return Constant.clrHomeLabelColor; // Purple/Blue for medium
    } else {
      return Color(0xFF10B981); // Green for low
    }
  }

  /// Active List with ad AFTER first card and search filter
  Widget signalsTabActiveList(RecommenderScreenController recommenderWatch) {
    // Filter signals based on search query
    final filteredList = searchQuery.isEmpty
        ? recommenderWatch.activeSignalList
        : recommenderWatch.activeSignalList.where((signal) {
      return (signal.currencyName?.toLowerCase().contains(searchQuery) ?? false) ||
          (signal.currencyCode?.toLowerCase().contains(searchQuery) ?? false) ||
          (signal.currencySymbol?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    return (filteredList.isEmpty && !recommenderWatch.isLoading)
        ? SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Align(
        alignment: Alignment.center,
        child: searchQuery.isNotEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.h, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              '${getLocalValue('Key_NoResultsFoundFor')} "$searchQuery"',
              style: TextStyles.txtRegular14(context).copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        )
            : EmptyStateWidget(emptyStateFor: EmptyState.noActiveSignalFound),
      ),
    )
        : Consumer(builder: (context, ref, child) {
      return Column(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final activeSignalObj = filteredList[index];

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Check if card is blurred using the same logic as old code
                      final bool shouldBlur = _shouldBlurCard(recommenderWatch, true);

                      if (shouldBlur) {
                        if (getUserStatus() == guest) {
                          getStartedDialog(context);
                        }
                        return; // Don't navigate if blurred (like old code)
                      }

                      // If not blurred, allow navigation (EXACT OLD CODE LOGIC)
                      livePriceChangeFunction(isTimerStart: false);
                      getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
                      Route route = SlideRightPageRoute(
                        builder: (context) => SignalDetailsScreen(
                          recommenderID: widget.recommenderID,
                          seeAllScreen: SeeAllScreen.fromRecommenderDetailsActive,
                          signalData: activeSignalObj,
                        ),
                        settings: const RouteSettings(),
                      );
                      Navigator.of(context).push(route).then((value) async {
                        livePriceChangeFunction();
                        await getAllSignalIstApiCallOnPeriodic();
                      });
                    },
                    child: buildSignalCard(
                      activeSignalObj,
                      recommenderWatch,
                      isActive: true,
                    ),
                  ),

                  /// Show ad AFTER first card (only if not searching)
                  if (index == 0 && searchQuery.isEmpty) buildHorizontalAdBanner(),
                ],
              );
            },
          ),
        ],
      );
    });
  }

  /// Closed List with ad AFTER first card and search filter
  Widget signalsTabClosedList(RecommenderScreenController recommenderWatch) {
    final commonWatch = ref.watch(commonProvider);

    // Filter based on old code logic - don't show cards if showClosedSignal is false and user not subscribed
    final visibleClosedSignals = recommenderWatch.closedSignalList.where((signal) {
      final isSubscribed = recommenderWatch.recommenderDetailResponseModel?.data?.isSubscribed == "1";
      final isGuest = getUserStatus() == guest;
      final isSameUser = recommenderWatch.recommenderDetailResponseModel?.data?.isSameUser == '1';
      final isRecommenderOwner = getUserEntityId() == recommenderWatch.recommenderDetailResponseModel?.data?.recommenderId;

      // EXACT OLD CODE VISIBILITY LOGIC
      return commonWatch.showClosedSignal ||
          isSubscribed ||
          isRecommenderOwner ||
          isSameUser;
    }).toList();

    // Also apply search filter
    final filteredList = searchQuery.isEmpty
        ? visibleClosedSignals
        : visibleClosedSignals.where((signal) {
      return (signal.currencyName?.toLowerCase().contains(searchQuery) ?? false) ||
          (signal.currencyCode?.toLowerCase().contains(searchQuery) ?? false) ||
          (signal.currencySymbol?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    return (filteredList.isEmpty && !recommenderWatch.isLoading)
        ? SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Align(
        alignment: Alignment.center,
        child: searchQuery.isNotEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.h, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              '${getLocalValue('Key_NoResultsFoundFor')} "$searchQuery"',
              style: TextStyles.txtRegular14(context).copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        )
            : EmptyStateWidget(emptyStateFor: EmptyState.noClosedSignalFound),
      ),
    )
        : Column(
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final closedSignalObj = filteredList[index];

            return Column(
              children: [
                InkWell(
                  onTap: () {
                    final commonWatch = ref.watch(commonProvider);

                    // EXACT OLD CODE TAP CONDITION FOR CLOSED SIGNALS
                    if (commonWatch.showClosedSignal ||
                        recommenderWatch.recommenderDetailResponseModel?.data?.isSubscribed == "1" ||
                        getUserEntityId() == recommenderWatch.recommenderDetailResponseModel?.data?.recommenderId ||
                        recommenderWatch.recommenderDetailResponseModel?.data?.isSameUser == '1') {

                      livePriceChangeFunction(isTimerStart: false);
                      getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
                      Route route = SlideRightPageRoute(
                        builder: (context) => SignalDetailsScreen(
                          recommenderID: widget.recommenderID,
                          seeAllScreen: SeeAllScreen.fromRecommenderDetailsClosed,
                          signalData: closedSignalObj,
                        ),
                        settings: const RouteSettings(),
                      );
                      Navigator.of(context).push(route).then((value) {
                        livePriceChangeFunction();
                        getAllSignalIstApiCallOnPeriodic();
                      });
                    }
                    // If condition fails, do nothing (like old code)
                  },
                  child: buildSignalCard(
                    closedSignalObj,
                    recommenderWatch,
                    isActive: false,
                  ),
                ),
                if (index == 0 && searchQuery.isEmpty) buildHorizontalAdBanner(),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Pending List with ad AFTER first card and search filter
  Widget signalsTabPendingList(RecommenderScreenController recommenderWatch) {
    // Filter signals based on search query
    final filteredList = searchQuery.isEmpty
        ? recommenderWatch.pendingSignalList
        : recommenderWatch.pendingSignalList.where((signal) {
      return (signal.currencyName?.toLowerCase().contains(searchQuery) ?? false) ||
          (signal.currencyCode?.toLowerCase().contains(searchQuery) ?? false) ||
          (signal.currencySymbol?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    return (filteredList.isEmpty && !recommenderWatch.isLoading)
        ? SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Align(
        alignment: Alignment.center,
        child: searchQuery.isNotEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.h, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              '${getLocalValue('Key_NoResultsFoundFor')} "$searchQuery"',
              style: TextStyles.txtRegular14(context).copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        )
            : EmptyStateWidget(emptyStateFor: EmptyState.noPendingSignalFound),
      ),
    )
        : Consumer(builder: (context, ref, child) {
      return Column(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final pendingSignalObj = filteredList[index];

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Check if card is blurred using the same logic as old code
                      final bool shouldBlur = _shouldBlurCard(recommenderWatch, true);

                      if (shouldBlur) {
                        if (getUserStatus() == guest) {
                          getStartedDialog(context);
                        }
                        return; // Don't navigate if blurred (like old code)
                      }

                      // If not blurred, allow navigation (EXACT OLD CODE LOGIC)
                      livePriceChangeFunction(isTimerStart: false);
                      getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
                      Route route = SlideRightPageRoute(
                        builder: (context) => SignalDetailsScreen(
                          recommenderID: widget.recommenderID,
                          seeAllScreen: SeeAllScreen.fromRecommenderDetailsPending,
                          signalData: pendingSignalObj,
                        ),
                        settings: const RouteSettings(),
                      );
                      Navigator.of(context).push(route).then((value) async {
                        livePriceChangeFunction();
                        await getAllSignalIstApiCallOnPeriodic();
                      });
                    },
                    child: buildSignalCard(
                      pendingSignalObj,
                      recommenderWatch,
                      isActive: true,
                    ),
                  ),

                  /// Show ad AFTER first card (only if not searching)
                  if (index == 0 && searchQuery.isEmpty) buildHorizontalAdBanner(),
                ],
              );
            },
          ),
        ],
      );
    });
  }

  /// BTC Scenarios Tab
  Widget btcScenariosTabWidget(RecommenderScreenController recommenderWatch) {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    return Padding(
      padding: EdgeInsets.only(top: 23.h),
      child: (myRecommendationWatch.btcScenariosListResponseModel?.data
          ?.signalList?.isEmpty ==
          true &&
          !myRecommendationWatch.isLoading)
          ? SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Align(
          alignment: Alignment.center,
          child:
          EmptyStateWidget(emptyStateFor: EmptyState.noBTCScenarios),
        ),
      )
          : Column(
        children: [
          ListView.separated(
            itemCount: myRecommendationWatch.signalList?.length ?? 0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: const Divider(thickness: 1),
              );
            },
            itemBuilder: (context, index) {
              return ListItemWithImageWidget(
                isSameUser: recommenderWatch
                    .recommenderDetailResponseModel
                    ?.data
                    ?.isSameUser ??
                    '',
                gridView: true,
                imageClick: () {
                  Route route = SlideRightPageRoute(
                      builder: (context) => ChartScreenShotScreen(
                          chartImage: '',
                          btcImages: myRecommendationWatch
                              .signalList?[index].images),
                      settings: const RouteSettings());
                  Navigator.push(context, route);
                },
                showData: recommenderWatch.recommenderDetailResponseModel
                    ?.data?.isSubscribed ==
                    "1",
                listLength: myRecommendationWatch.btcImageList?.length,
                listName: recommenderWatch.imageList,
                date: myRecommendationWatch.signalList?[index].date,
                time: DateFormat('hh:mm a').format(DateTime.parse(
                    myRecommendationWatch
                        .signalList![index].createdAt!)
                    .add(DateTime.parse(myRecommendationWatch
                    .signalList![index].createdAt!)
                    .timeZoneOffset)),
                message:
                myRecommendationWatch.signalList?[index].description,
                recommenderId: recommenderWatch
                    .recommenderDetailResponseModel
                    ?.data
                    ?.recommenderId ??
                    "",
                imageList:
                myRecommendationWatch.signalList?[index].images,
              );
            },
          ),
          DialogProgressBar(
            isLoading: myRecommendationWatch.isLoadingPagination,
            forPagination: true,
          ).paddingOnly(bottom: 40.h),
        ],
      ),
    );
  }

  /// Social Tab
  Widget socialTabWidget(RecommenderScreenController recommenderWatch) {
    final socialWatch = ref.watch(newSocialProvider);

    return Column(
      children: [
        const SizedBox(height: 16),
        socialWatch.socialList?.isEmpty == true && !socialWatch.isLoading
            ? SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Align(
            alignment: Alignment.center,
            child: (recommenderWatch.socialSubTabSelectIndex == 0)
                ? EmptyStateWidget(
                emptyStateFor: EmptyState.noSocialFoundForToday)
                : (recommenderWatch.socialSubTabSelectIndex == 1)
                ? EmptyStateWidget(
                emptyStateFor:
                EmptyState.noSocialFoundForYesterday)
                : EmptyStateWidget(
                emptyStateFor:
                EmptyState.noSocialFoundForThisDay),
          ),
        )
            : socialTabList(recommenderWatch)
      ],
    );
  }

  Widget socialTabList(RecommenderScreenController recommenderWatch) {
    final socialWatch = ref.watch(newSocialProvider);
    final commonWatch = ref.watch(commonProvider);
    return Column(
      children: [
        ListView.separated(
            itemCount: socialWatch.socialList?.length ?? 0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: const Divider(thickness: 1),
              );
            },
            itemBuilder: (context, index) {
              final socialObj = socialWatch.socialList?[index];

              return ListItemWithImageWidget(
                isSameUser: recommenderWatch
                    .recommenderDetailResponseModel?.data?.isSameUser,
                imageClick: () {
                  Route route = SlideRightPageRoute(
                      builder: (context) => ChartScreenShotScreen(
                          chartImage: socialObj.image.toString(),
                          btcImages: null),
                      settings: const RouteSettings());
                  Navigator.push(context, route);
                },
                showData: recommenderWatch.recommenderDetailResponseModel?.data
                    ?.isSubscribed ==
                    "1" ||
                    commonWatch.showSocialPosts,
                imageName: socialObj?.image,
                gridView: false,
                date: socialObj?.date,
                time: DateFormat('hh:mm a').format(
                    DateTime.parse(socialObj!.createdAt!).add(
                        DateTime.parse(socialObj.createdAt!).timeZoneOffset)),
                message: socialObj.description,
                recommenderId: recommenderWatch
                    .recommenderDetailResponseModel?.data?.recommenderId ??
                    "",
              );
            }),
      ],
    );
  }

  /// Helper method to determine if card should be blurred (using EXACT old logic)
  bool _shouldBlurCard(
      RecommenderScreenController recommenderWatch,
      bool isActive, {
        CommonController? commonWatch,
      }) {
    final isSubscribed = recommenderWatch.recommenderDetailResponseModel?.data?.isSubscribed == "1";
    final isGuest = getUserStatus() == guest;
    final isSameUser = recommenderWatch.recommenderDetailResponseModel?.data?.isSameUser == '1';
    final isRecommenderOwner = getUserEntityId() == recommenderWatch.recommenderDetailResponseModel?.data?.recommenderId;

    // If user is the recommender owner or same user, never blur (EXACT OLD LOGIC)
    if (isRecommenderOwner || isSameUser) {
      return false;
    }

    if (isActive) {
      // For active AND pending signals: blur if not subscribed OR guest
      return !isSubscribed || isGuest;
    } else {
      // For closed signals: EXACT OLD CODE LOGIC
      final showClosed = commonWatch?.showClosedSignal ?? false;
      // OLD CODE: showData: commonWatch.showClosedSignal || (isSubscribed && !isGuest)
      // So we blur when showData is false
      return !(showClosed || (isSubscribed && !isGuest));
    }
  }

  /// Helper method to get blur message (using old logic)
  String _getBlurMessage(bool isActive) {
    if (getUserStatus() == guest) {
      return 'Sign up to view signal details';
    } else if (isActive) {
      return 'Subscribe to view signal details'; // Same message for active AND pending
    } else {
      return 'Subscribe to view closed signals';
    }
  }

  /// Calendar
  openCalender() {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final recommenderWatch = ref.watch(recommenderProvider);
          final newSocialWatch = ref.watch(newSocialProvider);
          return Material(
            color: Constant.clrTransparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Center(
                child: Container(
                  height: 440.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      color: Constant.clrGrey),
                  padding: EdgeInsets.all(15.w),
                  child: Stack(
                    children: [
                      CalendarCarousel<Event>(
                        onDayPressed: (DateTime date, List<Event> events) {
                          recommenderWatch.updateSocialSubTabIndex(2);
                          recommenderWatch.updateDate(date);
                          recommenderWatch.updateWidget();
                        },
                        isScrollable: false,
                        childAspectRatio: 1,
                        pageScrollPhysics: const NeverScrollableScrollPhysics(),
                        minSelectedDate: recommenderWatch.todayDate.subtract(
                          const Duration(days: 1000),
                        ),
                        locale: getAppLanguage(),
                        showHeader: true,
                        headerText:
                        "${recommenderWatch.currentSelectedMonth}  ${recommenderWatch.currentSelectedYear}",
                        headerTitleTouchable: true,
                        maxSelectedDate: DateTime.now(),
                        daysHaveCircularBorder: false,
                        showOnlyCurrentMonthDate: true,
                        shouldShowTransform: true,
                        thisMonthDayBorderColor: Constant.clrWhite,
                        targetDateTime: recommenderWatch.selectDate2,
                        onLeftArrowPressed: () async {
                          Future.delayed(const Duration(milliseconds: 750), () {
                            recommenderWatch.selectDate2 = DateTime(
                                recommenderWatch.selectDate2.year,
                                recommenderWatch.selectDate2.month - 1);
                            recommenderWatch.updateWidget();
                            recommenderWatch.currentSelectedMonth =
                                DateFormat.MMMM(getAppLanguage())
                                    .format(recommenderWatch.selectDate2);
                            recommenderWatch.currentSelectedYear =
                                DateFormat.y(getAppLanguage())
                                    .format(recommenderWatch.selectDate2);
                            recommenderWatch.updateWidget();
                            recommenderWatch
                                .updateDate(recommenderWatch.selectDate2);
                          });
                        },
                        onRightArrowPressed: () {
                          Future.delayed(const Duration(milliseconds: 750), () {
                            if (recommenderWatch.selectDate2.year <
                                DateTime.now().year ||
                                recommenderWatch.selectDate2.month <
                                    DateTime.now().month) {
                              recommenderWatch.selectDate2 = DateTime(
                                  recommenderWatch.selectDate2.year,
                                  recommenderWatch.selectDate2.month + 1);
                              recommenderWatch.updateWidget();
                              recommenderWatch.currentSelectedMonth =
                                  DateFormat.MMMM(getAppLanguage())
                                      .format(recommenderWatch.selectDate2);
                              recommenderWatch.currentSelectedYear =
                                  DateFormat.y(getAppLanguage())
                                      .format(recommenderWatch.selectDate2);
                              recommenderWatch.updateWidget();
                              recommenderWatch
                                  .updateDate(recommenderWatch.selectDate2);
                            }
                          });
                        },
                        leftButtonIcon: Transform.rotate(
                          angle: getAppLanguage() == 'ar' ? 0 : -pi,
                          child: CommonSVG(
                            strIcon: Constant.svgForward,
                          ),
                        ),
                        rightButtonIcon: Transform.rotate(
                          angle: getAppLanguage() == 'ar' ? pi : 0,
                          child: CommonSVG(
                            strIcon: Constant.svgForward,
                            svgColor: (recommenderWatch.selectDate2.year <
                                DateTime.now().year ||
                                recommenderWatch.selectDate2.month <
                                    DateTime.now().month)
                                ? null
                                : Constant.clrGrey,
                          ),
                        ),
                        customDayBuilder: (
                            bool isSelectable,
                            int index,
                            bool isSelectedDay,
                            bool isToday,
                            bool isPrevMonthDay,
                            TextStyle textStyle,
                            bool isNextMonthDay,
                            bool isThisMonthDay,
                            DateTime day,
                            ) {
                          return null;
                        },
                        dayButtonColor: Constant.clrWhite,
                        weekFormat: false,
                        headerTextStyle:
                        TextStyles.txtBold16(context).copyWith(color: Constant.clrDarkBlue),
                        inactiveDaysTextStyle: TextStyles.txtMedium12(context).copyWith(
                            color: Constant.clrLightGrey, backgroundColor: Constant.clrWhite),
                        inactiveWeekendTextStyle: TextStyles.txtMedium12
                            (context).copyWith(
                            color: Constant.clrLightGrey, backgroundColor: Constant.clrWhite),
                        width: 335.w,
                        weekdayTextStyle: TextStyles.txtSemiBold14
                            (context).copyWith(color: Constant.clrDarkBlue),
                        todayButtonColor: Constant.clrWhite,
                        todayBorderColor: Constant.clrWhite,
                        selectedDayButtonColor: Constant.clrPrimary,
                        selectedDayTextStyle: TextStyles.txtMedium12(context).copyWith(
                            color: Constant.clrWhite, backgroundColor: Constant.clrPrimary),
                        selectedDateTime: DateTime.parse(
                          recommenderWatch.selectDate2.toString(),
                        ),
                        todayTextStyle:
                        TextStyles.txtMedium12(context).copyWith(color: Constant.clrDarkBlue),
                      ),
                      Positioned(
                        bottom: 5.h,
                        right: 2.w,
                        child: Row(
                          children: [
                            CommonButton(
                              label: getLocalValue("Key_Clear"),
                              onTap: () {
                                recommenderWatch.selectDateStr = null;
                                recommenderWatch.selectDate2 = DateTime.now();
                                newSocialWatch.socialList?.clear();
                                recommenderWatch.updateWidget();
                                Navigator.pop(context);
                              },
                              bgColor: Constant.clrWhite,
                              labelColor: Constant.clrCalenderBtn,
                              width: 95.w,
                              height: 30.h,
                              borderRadius: 10.r,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            CommonButton(
                              label: getLocalValue("Key_Apply"),
                              onTap: () {
                                socialListApi(recommenderWatch);
                                Navigator.pop(context);
                              },
                              bgColor: Constant.clrPrimary,
                              labelColor: Constant.clrCalenderBtn,
                              width: 95.w,
                              height: 30.h,
                              borderRadius: 10.r,
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
        },
      ),
    );
  }

  Future apiCall(RecommenderScreenController recommenderWatch) async {
    if (isInternetConnectionOn) {
      await recommenderWatch.recommenderDetailAPI(
          context, widget.recommenderID);
      if (recommenderWatch.mainTabSelectIndex == 0) {
        await apiGetAllSignalList();
      }
    }
  }

  Future getBTCScenariosList(
      MyRecommendationScreenController myRecommenderWatch,
      String? recommenderID,
      {bool removeOld = false}) async {
    if (removeOld) {
      myRecommenderWatch.isHasMorePage = false;
    }
    await myRecommenderWatch.getBTCScenariosListApi(context, recommenderID);
  }

  Future<void> apiGetAllSignalList() async {
    if (!mounted) return;

    final recommenderWatch = ref.watch(recommenderProvider);
    if (recommenderWatch.mainTabSelectIndex == 0) {
      if (recommenderWatch.signalsSubTabSelectIndex == 0) {
        await recommenderWatch.apiAllSignalList(
            context, "pending", widget.recommenderID);
      } else if (recommenderWatch.signalsSubTabSelectIndex == 1) {
        await recommenderWatch.apiAllSignalList(
            context, "active", widget.recommenderID);
      } else {
        await recommenderWatch.apiAllSignalList(
            context, "closed", widget.recommenderID);
      }
    }
  }

  Future<void> getAllSignalIstApiCallOnPeriodic(
      {bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      final recommenderWatch = ref.watch(recommenderProvider);
      if (!recommenderWatch.isLoading) {
        await apiGetAllSignalList();
      }
    }
  }

  Future<void> socialListApi(
      RecommenderScreenController myRecommendationWatch) async {
    final newSocialWatch = ref.watch(newSocialProvider);
    newSocialWatch.clearProvider();
    if (myRecommendationWatch.socialSubTabSelectIndex == 0) {
      String todaysDate =
      getCustomFormatDateFromDateTime(DateTime.now(), "dd-MM-yyyy");
      await newSocialWatch.socialListApi(
          context, todaysDate, widget.recommenderID);
    } else if (myRecommendationWatch.socialSubTabSelectIndex == 1) {
      String yesterdayDate = getCustomFormatDateFromDateTime(
          DateTime.now().subtract(const Duration(days: 1)), "dd-MM-yyyy");
      await newSocialWatch.socialListApi(
          context, yesterdayDate, widget.recommenderID);
    } else if (myRecommendationWatch.socialSubTabSelectIndex == 2) {
      String calenderDate = getCustomFormatDateFromDateTime(
          myRecommendationWatch.selectDate2, "dd-MM-yyyy");
      if (myRecommendationWatch.selectDate2 == DateTime.now()) {
        myRecommendationWatch.updateSocialSubTabIndex(0);
      }
      await newSocialWatch.socialListApi(
          context, calenderDate, widget.recommenderID);
    }
  }

  Future<void> getCryptoCurrencyData(CommonController commonWatch,
      RecommenderScreenController recommenderWatch) async {
    if (isInternetConnectionOn) {
      if (mounted) {
        // await commonWatch.getCryptoCurrencyAPI(context);
      }
      if (commonWatch.cryptoCurrencyResponseModel.data != null ||
          commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
        for (var element1 in ((recommenderWatch.signalsSubTabSelectIndex == 0)
            ? recommenderWatch.pendingSignalList
            : (recommenderWatch.signalsSubTabSelectIndex == 1)
            ? recommenderWatch.activeSignalList
            : [])) {
          CryptoCurrencyData? currencyData = commonWatch
              .cryptoCurrencyResponseModel.data
              ?.where(
                  (element) => element.id.toString() == element1.apiCurrencyId)
              .first;
          if (currencyData != null) {
            double oldLivePrice =
                double.tryParse(element1.livePrice ?? "0") ?? 0;
            bool livePriceFromBinance = element1.livePriceFromBinance;
            element1.livePrice = currencyData.priceUsd;
            element1.livePriceFromBinance = true;
            double newLivePrice =
                double.tryParse(element1.livePrice ?? "0") ?? 0;
            double entryPrice =
                double.tryParse(element1.entryPrice ?? "0") ?? 0;
            if (recommenderWatch.signalsSubTabSelectIndex != 2 &&
                livePriceFromBinance) {
              if (newLivePrice > oldLivePrice) {
                if (oldLivePrice <= entryPrice && newLivePrice >= entryPrice) {
                  getAllSignalIstApiCallOnPeriodic();
                } else {
                  for (Target target in element1.targets ?? []) {
                    var targetPrice =
                        double.tryParse(target.rawPrice ?? "0") ?? 0;

                    if (oldLivePrice <= targetPrice &&
                        newLivePrice >= targetPrice) {
                      getAllSignalIstApiCallOnPeriodic();
                      break;
                    }
                  }
                }
              } else if (newLivePrice < oldLivePrice) {
                if (oldLivePrice >= entryPrice && newLivePrice <= entryPrice) {
                  getAllSignalIstApiCallOnPeriodic();
                } else {
                  for (Target target in element1.targets ?? []) {
                    var targetPrice =
                        double.tryParse(target.rawPrice ?? "0") ?? 0;
                    if (oldLivePrice >= targetPrice &&
                        newLivePrice <= targetPrice) {
                      getAllSignalIstApiCallOnPeriodic();
                      break;
                    }
                  }
                }
              }
            }
          }
        }
      }
      commonWatch.updateUi();
    }
  }

  Future<void> livePriceChangeFunction({bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      if (isTimerStart) {
        final commonWatch = ref.watch(commonProvider);
        final recommenderWatch = ref.watch(recommenderProvider);

        currencyTimer = Timer.periodic(
            Duration(milliseconds: secondsDelayForRealTimeAPICall),
                (timer) async {
              if (!recommenderWatch.isLoading &&
                  !recommenderWatch.isLoadingForPagination) {
                await getCryptoCurrencyData(commonWatch, recommenderWatch);
              }
            });
      } else {
        if (currencyTimer != null) {
          currencyTimer?.cancel();
        }
      }
    }
  }
}

/// Custom Painter for Dotted Border
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DottedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(12),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}