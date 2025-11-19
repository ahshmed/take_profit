// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:badges/badges.dart' as badge;
import 'package:blur/blur.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:take_profit/framework/data_provider/recommender/recommender_provider.dart';

import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/notification/notification_controller.dart';
import '../../framework/data_provider/notification/notification_provider.dart';


import '../../framework/repository/common/model/crypto_currency_response_model.dart';
import '../../framework/repository/signal/model/signal_list_response_model.dart';
import '../../framework/data_provider/recommender/create_signal_controller.dart';
import '../../framework/data_provider/recommender/my_recommendation_controller.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/common_svg.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../home/chart_screenshot_screen.dart';
import '../home/helper/list_item_widget.dart';
import '../home/helper/list_item_with_images_widget.dart';
import '../home/signals_details_screen.dart';
import '../notification/notification_screen.dart';
import '../search/search_screen.dart';
import '../us_market/select_stock_screen.dart';
import 'create_signal_screen.dart';
import 'helper/close_all_signal_button.dart';
import 'new_btc_scenarios_screen.dart';
import 'new_social_screen.dart';

class MyRecommendationSignalScreen extends ConsumerStatefulWidget {
  const MyRecommendationSignalScreen(
      {Key? key, this.isFromBottom = true, this.selectedSignalIndex = 1})
      : super(key: key);
  final bool isFromBottom;
  final int selectedSignalIndex;

  @override
  ConsumerState<MyRecommendationSignalScreen> createState() =>
      _MyRecommendationSignalScreenState();
}

class _MyRecommendationSignalScreenState
    extends ConsumerState<MyRecommendationSignalScreen>
    with  WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();

  Timer? currencyTimer;
  //Timer? signalListApiTimer;

  ///-----Init----
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      WidgetsBinding.instance.addObserver(this);
      final myRecommendationWatch = ref.watch(myRecommendationProvider);
      final signalWatch = ref.watch(createSignalProvider);
      final notificationWatch = ref.watch(notificationProvider);
      notificationCountAPICall(notificationWatch);
      myRecommendationWatch.clearProvider();
      signalWatch.clearProvider();

      print("widget.selectedSignalIndex ${widget.selectedSignalIndex}");
      myRecommendationWatch
          .updateSignalsSubTabIndex(widget.selectedSignalIndex);
      if (myRecommendationWatch.mainTabSelectIndex == 0) {
        signalWatch.updateIsLoading(true);
        await apiGetSignalList(signalWatch, myRecommendationWatch);
        await getAllSignalIstApiCallOnPeriodic();
        await scrollListenerMethod(signalWatch, myRecommendationWatch);
        await livePriceChangeFunction();
        //await getAllSignalIstApiCallOnPeriodic();
        signalWatch.updateIsLoading(false);
      }
      if (myRecommendationWatch.mainTabSelectIndex == 1) {
        scrollListenerMethod(signalWatch, myRecommendationWatch);
        await getBTCScenariosList(myRecommendationWatch, getUserEntityId());
      }
      if (myRecommendationWatch.mainTabSelectIndex == 2) {
        scrollListenerMethod(signalWatch, myRecommendationWatch);
        await socialListApi(myRecommendationWatch);
      }
    });
  }

  scrollListenerMethod(CreateSignalController signalWatch,
      MyRecommendationScreenController myRecommendationWatch) {
    _scrollController.addListener(() async {
      if (signalWatch.isHasMoreSignalList) {
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.position.pixels) {
          if (!signalWatch.isLoading &&
              !signalWatch.isLoadingForPagination &&
              !myRecommendationWatch.isLoading &&
              !myRecommendationWatch.isLoadingPagination) {
            await apiGetSignalList(signalWatch, myRecommendationWatch);
          }
        }
      }
    });
    _scrollController2.addListener(() async {
      if (myRecommendationWatch.isHasMorePage) {
        if (_scrollController2.position.maxScrollExtent ==
            _scrollController2.position.pixels) {
          getBTCScenariosList(myRecommendationWatch, getUserEntityId());
        }
      }
    });
    _scrollController3.addListener(() async {
      final newSocialWatch = ref.watch(newSocialProvider);
      if (newSocialWatch.isHasMorePage) {
        if (_scrollController3.position.maxScrollExtent ==
            _scrollController3.position.pixels) {
          socialListApi(myRecommendationWatch);
        }
      }
    });
  }

  ///LifeCycle State
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    showLog('AppLifecycleState :- $state');
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await livePriceChangeFunction(isTimerStart: false);
      await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
      showLog("currency timer ${currencyTimer?.isActive}");
    } else if (state == AppLifecycleState.resumed) {
      await livePriceChangeFunction(isTimerStart: true);
      await getAllSignalIstApiCallOnPeriodic(isTimerStart: true);
      showLog("currency timer ${currencyTimer?.isActive}");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    livePriceChangeFunction(isTimerStart: false);
    getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
    WidgetsBinding.instance.removeObserver(this);
  }

  ///build widget
  @override
  Widget build(BuildContext context) {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    final newSocialWatch = ref.watch(newSocialProvider);
    final signalWatch = ref.watch(createSignalProvider);
    final notificationWatch = ref.watch(notificationProvider);
    final darkModeWatch = ref.watch(darkProvider);
    final drawerWatch = ref.watch(drawerProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue("Key_MyRecommendations"),
            isTitleCenter: false,
            appBar: AppBar(backgroundColor: Constant.clrWhiteNew, toolbarHeight: 64.h),
            isDrawer: widget.isFromBottom,
            action: [
              IconButton(
                onPressed: () async {
                  await livePriceChangeFunction(isTimerStart: false);
                  await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
                  Route route = SlideRightPageRoute(
                      builder: (context) => const SearchScreen(),
                      settings: const RouteSettings());
                  Navigator.of(context).push(route).then((value) async {
                    await livePriceChangeFunction(isTimerStart: true);
                    await getAllSignalIstApiCallOnPeriodic(isTimerStart: true);
                  });
                },
                icon: CommonImageAsset(
                  strIcon: Constant.icSearchN,
                  width: 39.81.h,
                  height: 39.81.h,
                ),
              ),
              SizedBox(
                width: 12.w,
              ),

              Visibility(
                visible: getUserStatus() == guest ? false : true,
                child: IconButton(
                  onPressed: () async {
                    await livePriceChangeFunction(isTimerStart: false);
                    await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
                    Route route = SlideRightPageRoute(
                        builder: (context) => const NotificationScreen(),
                        settings: const RouteSettings());
                    Navigator.of(context).push(route).then((value) async {
                      if (value == true) {
                        await notificationCountAPICall(notificationWatch);
                        await livePriceChangeFunction(isTimerStart: true);
                        await getAllSignalIstApiCallOnPeriodic(
                            isTimerStart: true);
                      }
                    });
                  },
                  icon: Visibility(
                    visible: notificationWatch
                        .notificationCountResponseModel.data?.count !=
                        "0" &&
                        notificationWatch.notificationCountResponseModel.data !=
                            null,
                    replacement: Image.asset(
                      Constant.icNotificationN,
                      width: 39.81.h,
                      height: 39.81.h,
                    ),
                    child: badge.Badge(
                      badgeContent: Text(
                        notificationWatch
                            .notificationCountResponseModel.data?.count ??
                            "",
                        style:
                        TextStyles.txtRegular10(context).copyWith(color: Constant.clrWhite),
                      ),
                      child: Image.asset(
                        Constant.icNotificationN,
                        width: 39.81.h,
                        height: 39.81.h,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: getUserStatus() == guest ? false : true,
                child: SizedBox(
                  width: 10.w,
                ),
              ),
            ],
          ),
          body: NoInternetBuilder(child: bodyWidget(myRecommendationWatch)),
        ),
        DialogProgressBar(
          isLoading: myRecommendationWatch.mainTabSelectIndex == 0
              ? signalWatch.isLoading
              : myRecommendationWatch.mainTabSelectIndex == 2
                  ? newSocialWatch.isLoading
                  : myRecommendationWatch.isLoading ||
                      notificationWatch.isLoading,
        ),
      ],
    );
  }

  ///body widget
  Widget bodyWidget(MyRecommendationScreenController myRecommendationWatch) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          bottom: (MediaQuery.of(context).padding.bottom + 40).h),
      child: Column(
        children: [
          myRecommendationDetailsMainTabList(myRecommendationWatch),
          Expanded(child: myRecommendationDetailsWidget(myRecommendationWatch))
        ],
      ),
    );
  }

  ///MyRecommendation details main tabs List  (Signals, BTC Scenarios, Social)
  Widget myRecommendationDetailsMainTabList(
      MyRecommendationScreenController myRecommendationWatch) {
    final signalWatch = ref.watch(createSignalProvider);
    return Container(
      height: 36.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Constant.clrDarkByScaffoldTheme(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Constant.clrGrey),
      ),
      child: Row(
        children: [
          /// Signals Tab (always shown)
          Flexible(
            flex: 3,
            child: InkWell(
              onTap: () async {
                myRecommendationWatch.updateMainTabIndex(0);
                signalWatch.clearProvider();
                myRecommendationWatch.clearDate();
                await apiGetSignalList(signalWatch, myRecommendationWatch);
              },
              child: Container(
                height: 30.h,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: myRecommendationWatch.mainTabSelectIndex == 0
                      ? Constant.clrPrimary
                      : Constant.clrTransparent,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getLocalValue(myRecommendationWatch.mainTabList[0]),
                      style: TextStyles.txtRegular12(context).copyWith(
                          color: myRecommendationWatch.mainTabSelectIndex == 0
                              ? Constant.clrWhiteNew
                              : Constant.clrBlackNew),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// BTC Scenarios Tab - Only show if exists in mainTabList (not in US Market mode)
          if (myRecommendationWatch.mainTabList.length > 1)
            Flexible(
              flex: 5,
              child: InkWell(
                onTap: () {
                  //trackEvent("tab_pressed", {"user_id": getUserEntityId(), "tab_name": "btc"});
                  getUserStatus() == guest
                      ? getStartedDialog(context)
                      : myRecommendationWatch.updateMainTabIndex(1);
                  myRecommendationWatch.clearDate();
                  getBTCScenariosList(myRecommendationWatch, getUserEntityId());
                },
                child: Container(
                  height: 30.h,
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: myRecommendationWatch.mainTabSelectIndex == 1
                        ? Constant.clrPrimary
                        : Colors.transparent,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getLocalValue(myRecommendationWatch.mainTabList[1]),
                        style: TextStyles.txtRegular12(context).copyWith(
                            color: myRecommendationWatch.mainTabSelectIndex == 1
                                ? Constant.clrWhiteNew
                                : Constant.clrBlackNew),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// Social Tab - Only show if exists in mainTabList (not in US Market mode)
          if (myRecommendationWatch.mainTabList.length > 2)
            Flexible(
              flex: 4,
              child: InkWell(
                onTap: () {
                  //trackEvent("tab_pressed", {"user_id": getUserEntityId(), "tab_name": "social"});
                  myRecommendationWatch.updateMainTabIndex(2);
                  myRecommendationWatch.updateSocialSubTabIndex(0);
                  myRecommendationWatch.clearDate();
                  socialListApi(myRecommendationWatch);
                },
                child: Container(
                  height: 30.h,
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: myRecommendationWatch.mainTabSelectIndex == 2
                        ? Constant.clrPrimary
                        : Colors.transparent,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getLocalValue(myRecommendationWatch.mainTabList[2]),
                        style: TextStyles.txtRegular12(context).copyWith(
                            color: myRecommendationWatch.mainTabSelectIndex == 2
                                ? Constant.clrWhiteNew
                                : Constant.clrBlackNew),
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

  ///MyRecommendation details widget
  Widget myRecommendationDetailsWidget(
      MyRecommendationScreenController myRecommendationWatch) {
    return Container(
      child: myRecommendationWatch.mainTabSelectIndex == 0

          ///Signals Tab
          ? myRecommendationSignalsTabWidget(myRecommendationWatch)
          : myRecommendationWatch.mainTabSelectIndex == 1

              ///BTC Scenarios Tab
              ? myRecommendationBTCScenariosTabWidget(myRecommendationWatch)

              ///Social Tab
              : myRecommendationSocialTabWidget(myRecommendationWatch),
    );
  }

  ///MyRecommendation details Common SubTab List (Only For (Signals Tab and Social Tab)'s Sub Tab List)
  Widget myRecommendationDetailsCommonSubTabList(
      MyRecommendationScreenController myRecommendationWatch,
      List? listName,
      int listLength,
      int listIndex,
      dynamic Function(int index) updateIndex) {
    final drawerWatch = ref.watch(drawerProvider);
    final signalWatch = ref.watch(createSignalProvider);
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      alignment: drawerWatch.isEngEnable == false
          ? Alignment.centerRight
          : Alignment.centerLeft,
      height: 35.h,
      child: ListView.separated(
        itemCount: listLength,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              if (listName == myRecommendationWatch.socialSubTabList &&
                  listName?[index] == listName?[2]) {
                openCalender();
              } else {
                updateIndex(index);
                if (myRecommendationWatch.mainTabSelectIndex == 2) {
                  socialListApi(myRecommendationWatch);
                } else if (myRecommendationWatch.mainTabSelectIndex == 0) {
                  signalWatch.clearProvider();
                  signalWatch.updateIsLoading(true);
                  signalWatch.activeSignalList.clear();
                  signalWatch.closedSignalList.clear();
                  signalWatch.pendingSignalList.clear();
                  await apiGetSignalList(signalWatch, myRecommendationWatch);
                  signalWatch.updateIsLoading(false);
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: 5.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      listName == myRecommendationWatch.socialSubTabList &&
                              listName?[index] == listName?[2] &&
                              myRecommendationWatch.selectDateStr != null
                          ? Text(
                              myRecommendationWatch.selectDateStr.toString(),
                              style: TextStyles.txtRegular12(context).copyWith(
                                  color: index == listIndex
                                      ? Constant.clrDarkPurple
                                      : Constant.clrBlackNew),
                            )
                          : Text(
                              getLocalValue(listName?[index]),
                              style: TextStyles.txtRegular12(context).copyWith(
                                  color: index == listIndex
                                      ? Constant.clrDarkPurple
                                      : Constant.clrBlackNew),
                            ),
                      Visibility(
                        visible: listName ==
                                myRecommendationWatch.socialSubTabList &&
                            listName?[index] == listName?[2],
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: CommonImageAsset(
                            strIcon: Constant.icCalender,
                            height: 14.h,
                            width: 14.h,
                            boxFit: BoxFit.cover,
                            clrImg: index == listIndex
                                ? Constant.clrDarkPurple
                                : Constant.clrBlackNew,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: index == listIndex,
                    child: Container(
                      height: 5.h,
                      width: 5.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Constant.clrPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: 20.w,
          );
        },
      ),
    );
  }

  ///MyRecommendation Signals Tab Widget
  Widget myRecommendationSignalsTabWidget(
      MyRecommendationScreenController myRecommendationWatch) {
    return Column(
      children: [
        ///Active , Closed Tabs
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: myRecommendationDetailsCommonSubTabList(
                    myRecommendationWatch,
                    myRecommendationWatch.signalSubTabList,
                    myRecommendationWatch.signalSubTabList.length,
                    myRecommendationWatch.signalsSubTabSelectIndex,
                    myRecommendationWatch.updateSignalsSubTabIndex)),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () async {
                  await livePriceChangeFunction(isTimerStart: false);
                  await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);

                  // Check selected market
                  final selectedMarket = getSelectedMarket();
                  final bool isUSMarket = selectedMarket == 'us_market';

                  Route route;
                  if (isUSMarket) {
                    // US Market: Open stock selection screen
                    route = SlideRightPageRoute(
                        builder: (context) => const SelectStockScreen(),
                        settings: const RouteSettings());
                  } else {
                    // Crypto: Open create signal screen
                    route = SlideRightPageRoute(
                        builder: (context) => const CreateSignalScreen(),
                        settings: const RouteSettings());
                  }

                  Navigator.of(context).push(route).then((value) async {
                    await livePriceChangeFunction(isTimerStart: true);
                    await getAllSignalIstApiCallOnPeriodic(isTimerStart: true);
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Text("+${getLocalValue("Key_AddNew")}",
                      style: TextStyles.txtRegular12(context).copyWith(
                          color: Constant.clrPrimary,
                          decoration: TextDecoration.underline)),
                ),
              ),
            )
          ],
        ),

        myRecommendationWatch.signalsSubTabSelectIndex == 0
            ?
        ///Pending Tab
        myRecommendationSignalsTabPendingList(myRecommendationWatch)

            :
        myRecommendationWatch.signalsSubTabSelectIndex == 1
            ?
        ///Active Tab
        myRecommendationSignalsTabActiveList(myRecommendationWatch):

        ///Closed Tab
            myRecommendationSignalsTabClosedList(myRecommendationWatch)

      ],
    );
  }

  ///MyRecommendation Signals Tab Active List Widget
  Widget myRecommendationSignalsTabActiveList(
      MyRecommendationScreenController myRecommendationWatch) {
    final signalWatch = ref.watch(createSignalProvider);

    // Check if in US Market mode
    final selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    // If US Market mode, show dummy US Market story cards
    if (isUSMarket) {
      final stories = _getDummyUSMarketActiveStories();
      return Expanded(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: stories.length,
                padding: EdgeInsets.only(
                  bottom: (MediaQuery.of(context).padding.bottom + 60.h),
                ),
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return InkWell(
                    onTap: () {
                      // Show close signal confirmation dialog
                      showConfirmationDialog(
                          context,
                          '',
                          getLocalValue('Key_CloseSignal'),
                          getLocalValue('Key_CloseSignalConfirmMsg'),
                          (isPositive) {
                            if (isPositive) {
                              // TODO: Implement close individual story API when available
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${story['ticker']} ${getLocalValue('Key_CloseSignal')}',
                                    style: TextStyles.txtRegular14(context).copyWith(
                                      color: Constant.clrWhite,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF32C671),
                                ),
                              );
                            }
                          },
                          borderRadius: 20.r,
                          titleTextStyle: TextStyles.txtHeader25(context).copyWith(fontSize: 22.sp),
                          buttonRadius: 30.r,
                          yesBtnBGClr: Constant.clrTransparent,
                          yesBtnWidth: MediaQuery.of(context).size.width * 0.35,
                          noBtnWidth: MediaQuery.of(context).size.width * 0.35);
                    },
                    child: _buildUSMarketStoryCard(story),
                  );
                },
              ),
            ),

            /// Close All Button for US Market Active stories
            if (stories.isNotEmpty)
              CloseAllSignalButton(
                onTap: () {
                  // Show confirmation dialog for closing all active stories
                  showConfirmationDialog(
                      context,
                      '',
                      getLocalValue('Key_ClosedAllSignals'),
                      getLocalValue('Key_ClosedSignalsConfirmationNote'),
                      (isPositive) {
                        if (isPositive) {
                          // TODO: Implement close all stories API when available
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                getLocalValue('Key_ClosedAllSignals'),
                                style: TextStyles.txtRegular14(context).copyWith(
                                  color: Constant.clrWhite,
                                ),
                              ),
                              backgroundColor: const Color(0xFF32C671),
                            ),
                          );
                        }
                      },
                      borderRadius: 20.r,
                      titleTextStyle: TextStyles.txtHeader25(context).copyWith(fontSize: 22.sp),
                      buttonRadius: 30.r,
                      yesBtnBGClr: Constant.clrTransparent,
                      yesBtnWidth: MediaQuery.of(context).size.width * 0.35,
                      noBtnWidth: MediaQuery.of(context).size.width * 0.35);
                },
              ),
          ],
        ),
      );
    }

    // Original crypto signals logic
    return Expanded(
      child: (signalWatch.activeSignalList.isEmpty == true &&
              !signalWatch.isLoading)
          ? EmptyStateWidget(emptyStateFor: EmptyState.noActiveSignalFound)
          : Consumer(builder: (context, ref, child) {
              final commonWatch = ref.watch(commonProvider);
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: signalWatch.activeSignalList.length,
                      padding: EdgeInsets.only(
                        bottom: (MediaQuery.of(context).padding.bottom + 60.h),
                      ),
                      itemBuilder: (context, index) {
                        final activeSignalObj =
                            signalWatch.activeSignalList[index];
                        return InkWell(
                          onTap: getUserStatus() == guest
                              ? () => getStartedDialog(context)
                              : () async {
                                  await livePriceChangeFunction(
                                      isTimerStart: false);
                                  await getAllSignalIstApiCallOnPeriodic(
                                      isTimerStart: false);
                                  Route route = SlideRightPageRoute(
                                    builder: (context) => SignalDetailsScreen(
                                      recommenderID: getUserEntityId(),
                                      seeAllScreen: SeeAllScreen
                                          .fromMyRecommenderSignalActive,
                                      signalData: activeSignalObj,
                                    ),
                                    settings: const RouteSettings(),
                                  );
                                  Navigator.of(context)
                                      .push(route)
                                      .then((value) async {
                                    await livePriceChangeFunction();
                                    await getAllSignalIstApiCallOnPeriodic();
                                  });
                                },
                          child: buildSignalCard(
                            activeSignalObj,
                            isActive: true,
                          ),
                        );
                      },
                    ),
                  ),

                  /// Close All Signal
                  Visibility(
                    visible: signalWatch.activeSignalList.isNotEmpty,
                    child: CloseAllSignalButton(
                      onTap: () {
                        showConfirmationDialog(
                            context,
                            '',
                            'Key_ClosedSignals'.localized,
                            'Key_ClosedSignalsConfirmationNote'.localized,
                            (isPositive) {
                          if (isPositive) {
                            /// Closed All Signals Api Call
                            signalWatch.closeAllSignalApi(context);
                          }
                        },
                            borderRadius: 20.r,
                            titleTextStyle: TextStyles.txtHeader25
                                (context).copyWith(fontSize: 22.sp),
                            buttonRadius: 30.r,
                            yesBtnBGClr: Constant.clrTransparent,
                            yesBtnWidth:
                                MediaQuery.of(context).size.width * 0.35,
                            noBtnWidth:
                                MediaQuery.of(context).size.width * 0.35);
                      },
                    ),
                  ),

                  /// Dialog
                  DialogProgressBar(
                    isLoading: signalWatch.isLoadingForPagination,
                    forPagination: true,
                  ).paddingOnly(bottom: 40.h)
                ],
              );
            }),
    );
  }

  ///MyRecommendation Signals Tab Closed List Widget
  Widget myRecommendationSignalsTabClosedList(
      MyRecommendationScreenController myRecommendationWatch) {
    final signalWatch = ref.watch(createSignalProvider);
    final commonWatch = ref.watch(commonProvider);

    // Check if in US Market mode
    final selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    // If US Market mode, show dummy US Market story cards
    if (isUSMarket) {
      return Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: _getDummyUSMarketClosedStories().length,
          padding: EdgeInsets.only(
            bottom: (MediaQuery.of(context).padding.bottom + 60.h),
          ),
          itemBuilder: (context, index) {
            final story = _getDummyUSMarketClosedStories()[index];
            return _buildUSMarketStoryCard(story);
          },
        ),
      );
    }

    // Original crypto signals logic
    return Expanded(
      child: (signalWatch.closedSignalList.isEmpty == true &&
              !signalWatch.isLoading)
          ? EmptyStateWidget(emptyStateFor: EmptyState.noClosedSignalFound)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                        bottom: (MediaQuery.of(context).padding.bottom + 60.h)),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollController,
                    itemCount: signalWatch.closedSignalList.length,
                    itemBuilder: (context, index) {
                      final closedSignalObj =
                          signalWatch.closedSignalList[index];
                      return InkWell(
                        onTap: () async {
                          await livePriceChangeFunction(isTimerStart: false);
                          await getAllSignalIstApiCallOnPeriodic(
                              isTimerStart: false);
                          Route route = SlideRightPageRoute(
                              builder: (context) => SignalDetailsScreen(
                                  recommenderID: getUserEntityId(),
                                  seeAllScreen: SeeAllScreen
                                      .fromMyRecommenderSignalClosed,
                                  signalData: closedSignalObj),
                              settings: const RouteSettings());
                          Navigator.of(context).push(route).then((value) async {
                            await livePriceChangeFunction();
                            await getAllSignalIstApiCallOnPeriodic();
                          });
                        },
                        child: buildSignalCard(
                          closedSignalObj,
                          isActive: false,
                        ),
                      );
                    },
                  ),
                ),
                DialogProgressBar(
                  isLoading: signalWatch.isLoadingForPagination,
                  forPagination: true,
                ).paddingOnly(bottom: 40.h),
              ],
            ),
    );
  }
  ///MyRecommendation Signals Tab Active List Widget
  Widget myRecommendationSignalsTabPendingList(
      MyRecommendationScreenController myRecommendationWatch) {
    final signalWatch = ref.watch(createSignalProvider);

    // Check if in US Market mode
    final selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    // If US Market mode, show dummy US Market story cards
    if (isUSMarket) {
      return Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: _getDummyUSMarketPendingStories().length,
          padding: EdgeInsets.only(
            bottom: (MediaQuery.of(context).padding.bottom + 60.h),
          ),
          itemBuilder: (context, index) {
            final story = _getDummyUSMarketPendingStories()[index];
            return InkWell(
              onTap: () {
                // Show close signal confirmation dialog
                showConfirmationDialog(
                    context,
                    '',
                    getLocalValue('Key_CloseSignal'),
                    getLocalValue('Key_CloseSignalConfirmMsg'),
                    (isPositive) {
                      if (isPositive) {
                        // TODO: Implement close individual story API when available
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${story['ticker']} ${getLocalValue('Key_CloseSignal')}',
                              style: TextStyles.txtRegular14(context).copyWith(
                                color: Constant.clrWhite,
                              ),
                            ),
                            backgroundColor: const Color(0xFF32C671),
                          ),
                        );
                      }
                    },
                    borderRadius: 20.r,
                    titleTextStyle: TextStyles.txtHeader25(context).copyWith(fontSize: 22.sp),
                    buttonRadius: 30.r,
                    yesBtnBGClr: Constant.clrTransparent,
                    yesBtnWidth: MediaQuery.of(context).size.width * 0.35,
                    noBtnWidth: MediaQuery.of(context).size.width * 0.35);
              },
              child: _buildUSMarketStoryCard(story),
            );
          },
        ),
      );
    }

    // Original crypto signals logic
    return Expanded(
      child: (signalWatch.pendingSignalList.isEmpty == true &&
          !signalWatch.isLoading)
          ? EmptyStateWidget(emptyStateFor: EmptyState.noPendingSignalFound)
          : Consumer(builder: (context, ref, child) {
        final commonWatch = ref.watch(commonProvider);
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: signalWatch.pendingSignalList.length,
                padding: EdgeInsets.only(
                  bottom: (MediaQuery.of(context).padding.bottom + 60.h),
                ),
                itemBuilder: (context, index) {
                  final pendingSignalObj =
                  signalWatch.pendingSignalList[index];
                  return InkWell(
                    onTap: getUserStatus() == guest
                        ? () => getStartedDialog(context)
                        : () async {
                      await livePriceChangeFunction(
                          isTimerStart: false);
                      await getAllSignalIstApiCallOnPeriodic(
                          isTimerStart: false);
                      Route route = SlideRightPageRoute(
                        builder: (context) => SignalDetailsScreen(
                          recommenderID: getUserEntityId(),
                          seeAllScreen: SeeAllScreen
                              .fromMyRecommenderSignalPending,
                          signalData: pendingSignalObj,
                        ),
                        settings: const RouteSettings(),
                      );
                      Navigator.of(context)
                          .push(route)
                          .then((value) async {
                        await livePriceChangeFunction();
                        await getAllSignalIstApiCallOnPeriodic();
                      });
                    },
                    child: buildSignalCard(
                      pendingSignalObj,
                      isActive: true,
                    ),
                  );
                },
              ),
            ),

            /// Close All Signal
            Visibility(
              visible: signalWatch.activeSignalList.isNotEmpty,
              child: CloseAllSignalButton(
                onTap: () {
                  showConfirmationDialog(
                      context,
                      '',
                      'Key_ClosedSignals'.localized,
                      'Key_ClosedSignalsConfirmationNote'.localized,
                          (isPositive) {
                        if (isPositive) {
                          /// Closed All Signals Api Call
                          signalWatch.closeAllSignalApi(context);
                          //todo close only pending signals
                        }
                      },
                      borderRadius: 20.r,
                      titleTextStyle: TextStyles.txtHeader25
                          (context).copyWith(fontSize: 22.sp),
                      buttonRadius: 30.r,
                      yesBtnBGClr: Constant.clrTransparent,
                      yesBtnWidth:
                      MediaQuery.of(context).size.width * 0.35,
                      noBtnWidth:
                      MediaQuery.of(context).size.width * 0.35);
                },
              ),
            ),

            /// Dialog
            DialogProgressBar(
              isLoading: signalWatch.isLoadingForPagination,
              forPagination: true,
            ).paddingOnly(bottom: 40.h)
          ],
        );
      }),
    );
  }

  ///MyRecommendation BTC Scenarios Tab Widget
  Widget myRecommendationBTCScenariosTabWidget(
      MyRecommendationScreenController myRecommendationWatch) {
    final drawerWatch = ref.watch(drawerProvider);
    return Column(
      children: [
        SizedBox(
          height: 10.h,
        ),
        InkWell(
          onTap: () async {
            await livePriceChangeFunction(isTimerStart: false);
            await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
            Route route = SlideRightPageRoute(
                builder: (context) =>
                    const NewBTCScenariosScreen(isEdit: false),
                settings: const RouteSettings());
            Navigator.of(context).push(route).then((value) async {
              await livePriceChangeFunction();
              await getAllSignalIstApiCallOnPeriodic();
            });
          },
          child: Align(
            alignment: drawerWatch.isEngEnable == false
                ? Alignment.topLeft
                : Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: Text(
                "+" + getLocalValue("Key_AddNew"),
                style: TextStyles.txtRegular12(context).copyWith(
                    color: Constant.clrPrimary, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ),
        Expanded(
          child: (myRecommendationWatch.signalList?.isEmpty == true &&
                  !myRecommendationWatch.isLoading)
              ? EmptyStateWidget(emptyStateFor: EmptyState.noBTCScenariosFound)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                          padding: EdgeInsets.only(
                              bottom: (MediaQuery.of(context).padding.bottom +
                                  60.h)),
                          itemCount: myRecommendationWatch.signalList?.length ?? 0,
                          shrinkWrap: true,
                          controller: _scrollController2,
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: const Divider(thickness: 1),
                            );
                          },
                          itemBuilder: (context, index) {
                            ///Image Grid View List
                            return ListItemWithImageWidget(
                              isSameUser: '1',
                              imageClick: () {
                                Route route = SlideRightPageRoute(
                                    builder: (context) => ChartScreenShotScreen(
                                        chartImage: '',
                                        btcImages: myRecommendationWatch
                                            .signalList?[index].images),
                                    settings: const RouteSettings());
                                Navigator.push(context, route);
                              },
                              gridView: true,
                              editData: () async {
                                await livePriceChangeFunction(
                                    isTimerStart: false);
                                await getAllSignalIstApiCallOnPeriodic(
                                    isTimerStart: false);
                                Route route = SlideRightPageRoute(
                                    builder: (context) => NewBTCScenariosScreen(
                                        isEdit: true,
                                        scenarioId: myRecommendationWatch
                                            .signalList?[index].scenarioId,
                                        model: myRecommendationWatch
                                            .signalList?[index],
                                        stringImageList: myRecommendationWatch
                                            .signalList?[index].images),
                                    settings: const RouteSettings());
                                Navigator.of(context)
                                    .push(route)
                                    .then((value) async {
                                  await livePriceChangeFunction();
                                  await getAllSignalIstApiCallOnPeriodic();
                                });
                              },
                              userType: getUserStatus().toString(),
                              listLength:
                                  myRecommendationWatch.btcImageList?.length,
                              date:
                                  myRecommendationWatch.signalList?[index].date,
                              time:
                              DateFormat('hh:mm a').format(DateTime.parse(myRecommendationWatch.signalList![index].createdAt!).add(DateTime.parse(myRecommendationWatch.signalList![index].createdAt!).timeZoneOffset)),
                              imageList: myRecommendationWatch
                                  .signalList?[index].images,
                              message: myRecommendationWatch
                                  .signalList?[index].description,
                              showData: getUserStatus() != guest,
                              recommenderId: getUserEntityId(),
                            );
                          }),
                    ),
                    DialogProgressBar(
                      isLoading: myRecommendationWatch.isLoadingPagination,
                      forPagination: true,
                    ).paddingOnly(bottom: 40.h)
                  ],
                ),
        ),
      ],
    );
  }

  ///MyRecommendation Social Tab Widget
  Widget myRecommendationSocialTabWidget(
      MyRecommendationScreenController myRecommendationWatch) {
    final drawerWatch = ref.watch(drawerProvider);
    return Column(
      children: [
        SizedBox(
          height: 15.h,
        ),
        InkWell(
          onTap: () async {
            await livePriceChangeFunction(isTimerStart: false);
            await getAllSignalIstApiCallOnPeriodic(isTimerStart: false);
            Route route = SlideRightPageRoute(
                builder: (context) => const NewSocialScreen(
                      isEdit: false,
                    ),
                settings: const RouteSettings());
            Navigator.of(context).push(route).then((value) async {
              await livePriceChangeFunction(isTimerStart: true);
              await getAllSignalIstApiCallOnPeriodic(isTimerStart: true);
            });
          },
          child: Align(
            alignment: drawerWatch.isEngEnable == false
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              "+" + getLocalValue("Key_AddNew"),
              style: TextStyles.txtRegular12(context).copyWith(
                  color: Constant.clrPrimary, decoration: TextDecoration.underline),
            ),
          ),
        ),

        ///Today , Yesterday, Select Date Tabs
        /*myRecommendationDetailsCommonSubTabList(
          myRecommendationWatch,
          myRecommendationWatch.socialSubTabList,
          myRecommendationWatch.socialSubTabList.length,
          myRecommendationWatch.socialSubTabSelectIndex,
          myRecommendationWatch.updateSocialSubTabIndex,
        ),*/
        SizedBox(
          height: 15.h,
        ),
        myRecommendationWatch.socialSubTabSelectIndex == 0

            ///Today Tab
            ? Expanded(
                child: myRecommendationSocialTabList(
                    myRecommendationWatch, myRecommendationWatch.imageList),
              )
            : myRecommendationWatch.socialSubTabSelectIndex == 1

                ///YesterDay Tab
                ? Expanded(
                    child: myRecommendationSocialTabList(
                        myRecommendationWatch, myRecommendationWatch.imageList),
                  )

                ///Select Date Tab
                : Expanded(
                    child: myRecommendationSocialTabList(
                        myRecommendationWatch, myRecommendationWatch.imageList),
                  )
      ],
    );
  }

  ///MyRecommendation Social Tab List Widget
  Widget myRecommendationSocialTabList(
      MyRecommendationScreenController myRecommendationWatch, List? listName) {
    final newSocialWatch = ref.watch(newSocialProvider);

    return (newSocialWatch.socialList?.isEmpty == true &&
            !newSocialWatch.isLoading)
        ? (myRecommendationWatch.socialSubTabSelectIndex == 0)
            ? EmptyStateWidget(emptyStateFor: EmptyState.noSocialFoundForToday)
            : (myRecommendationWatch.socialSubTabSelectIndex == 1)
                ? EmptyStateWidget(
                    emptyStateFor: EmptyState.noSocialFoundForYesterday)
                : EmptyStateWidget(
                    emptyStateFor: EmptyState.noSocialFoundForThisDay)
        : Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: newSocialWatch.socialList?.length ?? 0,
                  padding: EdgeInsets.only(
                      bottom: (MediaQuery.of(context).padding.bottom + 60.h)),
                  shrinkWrap: true,
                  controller: _scrollController3,
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: const Divider(thickness: 1),
                    );
                  },
                  itemBuilder: (context, index) {
                    ///Single Image List
                    final socialDataObj = newSocialWatch.socialList?[index];
                    return ListItemWithImageWidget(
                        isSameUser: '1',
                        imageClick: () {
                          Route route = SlideRightPageRoute(
                              builder: (context) => ChartScreenShotScreen(
                                  chartImage:
                                      socialDataObj?.image.toString() ?? '',
                                  btcImages: null),
                              settings: const RouteSettings());
                          Navigator.push(context, route);
                        },
                        imageName: socialDataObj?.image ?? "",
                        showData: getUserStatus() != guest,
                        userType: getUserStatus().toString(),
                        editData: () async {
                          await livePriceChangeFunction(isTimerStart: false);
                          await getAllSignalIstApiCallOnPeriodic(
                              isTimerStart: false);
                          Route route = SlideRightPageRoute(
                            builder: (context) => NewSocialScreen(
                              isEdit: true,
                              socialData: socialDataObj,
                            ),
                            settings: const RouteSettings(),
                          );
                          Navigator.of(context).push(route).then((value) async {
                            await livePriceChangeFunction(isTimerStart: true);
                            await getAllSignalIstApiCallOnPeriodic(
                                isTimerStart: true);
                          });
                        },
                        gridView: false,
                        listLength: listName?.length,
                        date: socialDataObj?.date ?? "",
                        time: DateFormat('hh:mm a').format(DateTime.parse(socialDataObj!.createdAt!).add(DateTime.parse(socialDataObj.createdAt!).timeZoneOffset)),
                        recommenderId: getUserEntityId(),
                        message: socialDataObj.description ?? "");
                  },
                ),
              ),
              DialogProgressBar(
                isLoading: newSocialWatch.isLoadingPagination,
                forPagination: true,
              ).paddingOnly(bottom: 40.h),
            ],
          );
  }

  ///MyRecommendation open calender
  openCalender() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Consumer(builder: (context, ref, child) {
        final myRecommendationWatch = ref.watch(myRecommendationProvider);
        final newSocialWatch = ref.watch(newSocialProvider);
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Material(
            color: Constant.clrTransparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Center(
                child: Container(
                  height: 440.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      color: Constant.clrGrey //clrPrimaryLight.withOpacity(0.9)
                      ),
                  padding: EdgeInsets.all(15.w),
                  child: Stack(
                    children: [
                      /// Calender Carousel
                      CalendarCarousel<Event>(
                        onDayPressed: (DateTime date, List<Event> events) {
                          myRecommendationWatch.updateSocialSubTabIndex(2);
                          myRecommendationWatch.updateDate(date);
                          myRecommendationWatch.updateWidget();
                        },
                        isScrollable: false,
                        childAspectRatio: 1,
                        pageScrollPhysics: const NeverScrollableScrollPhysics(),
                        minSelectedDate:
                            myRecommendationWatch.todayDate.subtract(
                          const Duration(days: 1000),
                        ),
                        maxSelectedDate: DateTime.now(),
                        showHeader: true,
                        locale: getAppLanguage(),
                        headerText:
                            "${myRecommendationWatch.currentSelectedMonth}  ${myRecommendationWatch.currentSelectedYear}",
                        headerTitleTouchable: true,

                        daysHaveCircularBorder: false,
                        showOnlyCurrentMonthDate: true,
                        shouldShowTransform: true,

                        thisMonthDayBorderColor: Constant.clrWhite,
                        targetDateTime: myRecommendationWatch.selectDate2,
                        nextDaysTextStyle:
                            TextStyles.txtMedium12(context).copyWith(color: Constant.clrRed),
                        onLeftArrowPressed: () async {
                          Future.delayed(const Duration(milliseconds: 750), () {
                            myRecommendationWatch.selectDate2 = DateTime(
                                myRecommendationWatch.selectDate2.year,
                                myRecommendationWatch.selectDate2.month - 1);
                            myRecommendationWatch.updateWidget();
                            myRecommendationWatch.currentSelectedMonth =
                                DateFormat.MMMM(getAppLanguage())
                                    .format(myRecommendationWatch.selectDate2);
                            myRecommendationWatch.currentSelectedYear =
                                DateFormat.y(getAppLanguage())
                                    .format(myRecommendationWatch.selectDate2);
                            myRecommendationWatch.updateWidget();
                            myRecommendationWatch
                                .updateDate(myRecommendationWatch.selectDate2);
                          });
                        },
                        onRightArrowPressed: () {
                          Future.delayed(const Duration(milliseconds: 750), () {
                            if (myRecommendationWatch.selectDate2.year <
                                    DateTime.now().year ||
                                myRecommendationWatch.selectDate2.month <
                                    DateTime.now().month) {
                              myRecommendationWatch.selectDate2 = DateTime(
                                  myRecommendationWatch.selectDate2.year,
                                  myRecommendationWatch.selectDate2.month + 1);
                              myRecommendationWatch.updateWidget();
                              myRecommendationWatch.currentSelectedMonth =
                                  DateFormat.MMMM(getAppLanguage()).format(
                                      myRecommendationWatch.selectDate2);
                              myRecommendationWatch.currentSelectedYear =
                                  DateFormat.y(getAppLanguage()).format(
                                      myRecommendationWatch.selectDate2);
                              myRecommendationWatch.updateWidget();
                              myRecommendationWatch.updateDate(
                                  myRecommendationWatch.selectDate2);
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
                            svgColor: (myRecommendationWatch.selectDate2.year <
                                        DateTime.now().year ||
                                    myRecommendationWatch.selectDate2.month <
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

                        weekFormat: false,
                        headerTextStyle:
                            TextStyles.txtBold16(context).copyWith(color: Constant.clrDarkBlue),
                        inactiveDaysTextStyle: TextStyles.txtMedium12(context).copyWith(
                            color: Constant.clrLightGrey, backgroundColor: Constant.clrWhite),
                        inactiveWeekendTextStyle: TextStyles.txtMedium12
                            (context).copyWith(
                                color: Constant.clrLightGrey, backgroundColor: Constant.clrWhite),
                        //height: 400.h,
                        width: 335.w,
                        todayButtonColor: Constant.clrWhite,
                        todayBorderColor: Constant.clrWhite,
                        selectedDayButtonColor: Constant.clrPrimary,
                        selectedDateTime: DateTime.parse(
                          myRecommendationWatch.selectDate2.toString(),
                        ),
                        dayButtonColor: Constant.clrWhite,
                        selectedDayTextStyle: TextStyles.txtMedium12(context).copyWith(
                            color: Constant.clrWhite, backgroundColor: Constant.clrPrimary),
                        weekdayTextStyle: TextStyles.txtSemiBold14
                            (context).copyWith(color: Constant.clrDarkBlue),
                        todayTextStyle:
                            TextStyles.txtMedium12(context).copyWith(color: Constant.clrDarkBlue),
                        daysTextStyle:
                            TextStyles.txtMedium12(context).copyWith(color: Constant.clrDarkBlue),
                      ),

                      /// Month Dropdown
                      // Positioned(
                      //   top: 25.h,
                      //   right: 150.w,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: clrWhite,
                      //       borderRadius: BorderRadius.circular(10.r),
                      //     ),
                      //     padding: EdgeInsets.all(5.h),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           myRecommendationWatch.currentSelectedMonthAndYear
                      //               .toString()
                      //               .split(" ")
                      //               .first,
                      //           style: TextStyles.txtSemiBold16
                      //               (context).copyWith(color: clrBlack),
                      //         ),
                      //         CommonImageAsset(
                      //           strIcon: icCalenderDropDown,
                      //           boxFit: BoxFit.cover,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      //
                      /// Year Dropdown
                      // Positioned(
                      //   top: 25.h,
                      //   right: 85.w,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         color: clrWhite,
                      //         borderRadius: BorderRadius.circular(10.r)),
                      //     padding: EdgeInsets.all(5.h),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           myRecommendationWatch.currentSelectedMonthAndYear
                      //               .toString()
                      //               .split(" ")
                      //               .last,
                      //           style: TextStyles.txtSemiBold16
                      //               (context).copyWith(color: clrBlack),
                      //         ),
                      //         CommonImageAsset(
                      //           strIcon: icCalenderDropDown,
                      //           boxFit: BoxFit.cover,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      /// Clear & Apply Button
                      Positioned(
                        bottom: 5.h,
                        right: 2.w,
                        child: Row(
                          children: [
                            CommonButton(
                              label: getLocalValue("Key_Clear"),
                              onTap: () {
                                myRecommendationWatch.selectDateStr = null;
                                myRecommendationWatch.selectDate2 =
                                    DateTime.now();
                                newSocialWatch.socialList?.clear();
                                // socialListApi(myRecommendationWatch);
                                myRecommendationWatch.updateWidget();
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
                                socialListApi(myRecommendationWatch);
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
          ),
        );
      }),
    );
  }

  /// Get BTC Scenarios List
  Future getBTCScenariosList(
      MyRecommendationScreenController myRecommenderWatch,
      String? recommenderID) async {
    await myRecommenderWatch.getBTCScenariosListApi(context, recommenderID);
  }

  /// social list api calling tab-wise
  Future<void> socialListApi(
      MyRecommendationScreenController myRecommendationWatch) async {
    final newSocialWatch = ref.watch(newSocialProvider);
    if (myRecommendationWatch.socialSubTabSelectIndex == 0) {
      showLog("TODAY");
      String todaysDate =
          getCustomFormatDateFromDateTime(DateTime.now(), "dd-MM-yyyy");
      showLog(todaysDate);
      await newSocialWatch.socialListApi(
          context, todaysDate, getUserEntityId());

      getCustomFormatDateFromDateTime(DateTime.now(), "dd-MM-yyyy");
    } else if (myRecommendationWatch.socialSubTabSelectIndex == 1) {
      showLog("YESTERDAY");
      String yesterdayDate = getCustomFormatDateFromDateTime(
          DateTime.now().subtract(const Duration(days: 1)), "dd-MM-yyyy");
      showLog(yesterdayDate);
      await newSocialWatch.socialListApi(
          context, yesterdayDate, getUserEntityId());
    } else if (myRecommendationWatch.socialSubTabSelectIndex == 2) {
      showLog("CALENDER DATE");
      String calenderDate = getCustomFormatDateFromDateTime(
          myRecommendationWatch.selectDate2, "dd-MM-yyyy");
      showLog(calenderDate);
      if (myRecommendationWatch.selectDate2 == DateTime.now()) {
        myRecommendationWatch.updateSocialSubTabIndex(0);
      }
      await newSocialWatch.socialListApi(
          context, calenderDate, getUserEntityId());
    }
  }

  /// Signal list
  Future<void> apiGetSignalList(CreateSignalController signalWatch,
      MyRecommendationScreenController myRecommendationWatch) async {
    if (myRecommendationWatch.mainTabSelectIndex == 0) {
      if (myRecommendationWatch.signalsSubTabSelectIndex == 0) {
        await signalWatch.apiSignalList(context, "pending", getUserEntityId());
      } else if(myRecommendationWatch.signalsSubTabSelectIndex == 1) {
        await signalWatch.apiSignalList(context, "active", getUserEntityId());
      }else {
        await signalWatch.apiSignalList(context, "closed", getUserEntityId());
      }
    }
  }

  ///All Signal List
  Future<void> apiGetAllSignalList(CreateSignalController signalWatch,
      MyRecommendationScreenController myRecommendationWatch) async {
    if (myRecommendationWatch.mainTabSelectIndex == 0) {
      if (mounted && myRecommendationWatch.signalsSubTabSelectIndex == 0) {
        await signalWatch.apiAllSignalList(
            context, "pending", getUserEntityId());
      } else if (mounted && myRecommendationWatch.signalsSubTabSelectIndex == 1){
        await signalWatch.apiAllSignalList(
            context, "active", getUserEntityId());
      }else {
        if (mounted) {
          await signalWatch.apiAllSignalList(
              context, "closed", getUserEntityId());
        }
      }
    }
  }

  Future<void> getAllSignalIstApiCallOnPeriodic(
      {bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      //if (isTimerStart) {
        final myRecommendationWatch = ref.watch(myRecommendationProvider);
        final signalWatch = ref.watch(createSignalProvider);

       /* signalListApiTimer = Timer.periodic(
            Duration(milliseconds: activeSignalTimeAPICall), (timer) async {*/
          if (!signalWatch.isLoading &&
              !signalWatch.isLoadingForPagination &&
              !myRecommendationWatch.isLoading &&
              !myRecommendationWatch.isLoadingPagination) {
            await apiGetAllSignalList(signalWatch, myRecommendationWatch);
          }
       // });
     /* } else {
        /// cancel Timer
        if (signalListApiTimer != null) {
          signalListApiTimer?.cancel();
        }
      }*/
    }
  }

  Future<void> notificationCountAPICall(
      NotificationController notificationWatch) async {
    if (getUserStatus() != guest) {
      if (isInternetConnectionOn) {
        await notificationWatch.notificationCountAPI(context);
      }
    }
  }

  /// Get Crypto Currency Data Live
  Future<void> getCryptoCurrencyData(
      CommonController commonWatch, CreateSignalController signalWatch) async {
    final myRecommendationWatch = ref.read(myRecommendationProvider);
    if (isInternetConnectionOn &&
        myRecommendationWatch.mainTabSelectIndex == 0) {
      // if (mounted) {
      // await commonWatch.getCryptoCurrencyAPI(context);
      // }
      if (commonWatch.cryptoCurrencyResponseModel.data != null ||
          commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
        /// Set Price in Main List Every 2 seconds
        for (var element1
            in ((myRecommendationWatch.signalsSubTabSelectIndex == 0)
                ? signalWatch.pendingSignalList
                : (myRecommendationWatch.signalsSubTabSelectIndex == 1) ? signalWatch.activeSignalList : [])) {
          CryptoCurrencyData? currencyData = commonWatch
              .cryptoCurrencyResponseModel.data
              ?.where(
                  (element) => element.id.toString() == element1.apiCurrencyId)
              .first;
          if (currencyData != null) {
            //showLog(" currencyData ${currencyData.priceUsd}");
            double oldLivePrice = double.tryParse(element1.livePrice ?? "0") ?? 0;
            bool livePriceFromBinance = element1.livePriceFromBinance;
            element1.livePrice = currencyData.priceUsd;
            element1.livePriceFromBinance = true;
            double newLivePrice = double.tryParse(element1.livePrice ?? "0") ?? 0;
            double entryPrice = double.tryParse(element1.entryPrice ?? "0") ?? 0;
            if(myRecommendationWatch.signalsSubTabSelectIndex != 2 && livePriceFromBinance) {
              if (newLivePrice > oldLivePrice) {
                if (oldLivePrice <= entryPrice && newLivePrice >= entryPrice) {
                  getAllSignalIstApiCallOnPeriodic();
                }
                else {
                  for (Target target in element1.targets ?? []) {
                    var targetPrice = double.tryParse(target.rawPrice ?? "0") ?? 0;

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
                }
                else {
                  for (Target target in element1.targets ?? []) {
                    var targetPrice = double.tryParse(target.rawPrice ?? "0") ?? 0;
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
    } else {}
  }

  /// Live Price Changes
  Future<void> livePriceChangeFunction({bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      if (isTimerStart) {
        final commonWatch = ref.watch(commonProvider);
        final signalWatch = ref.watch(createSignalProvider);

        /// Live Price Api Call every 2 seconds
        currencyTimer = Timer.periodic(
            Duration(milliseconds: secondsDelayForRealTimeAPICall),
            (timer) async {
          if (!signalWatch.isLoading &&
              !signalWatch.isLoadingForPagination &&
              mounted) {
            await getCryptoCurrencyData(commonWatch, signalWatch);
          }
        });
      } else {
        /// cancel Timer
        if (currencyTimer != null) {
          currencyTimer?.cancel();
        }
      }
    }
  }

  /// Signal Card Widget (same design as Recommender Details Screen)
  Widget buildSignalCard(SignalList signalData, {required bool isActive}) {
    final isRTL = Directionality.of(context) == ui.TextDirection.rtl;
    final commonWatch = ref.watch(commonProvider);

    // Check if we're in US Market mode
    final selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    // For my recommendation screen, show data since user is the recommender
    final bool shouldBlur = false;

    // Determine which logo, name, and symbol to show
    final String displayLogo = isUSMarket
        ? (signalData.stockLogo ?? signalData.currencyLogo ?? "")
        : (signalData.currencyLogo ?? "");
    final String displayName = isUSMarket
        ? (signalData.stockName ?? signalData.currencyName ?? "")
        : (signalData.currencyName ?? "");
    final String displaySymbol = isUSMarket
        ? (signalData.stockSymbol ?? signalData.currencySymbol ?? "")
        : (signalData.currencySymbol ?? "");

    Widget cardContent = Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.13.r),
        color: Constant.clrHomeCardByTheme(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          /// Currency/Stock Header with badges on opposite side
          Directionality(
            textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Currency/Stock Logo
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.r),
                    child: CacheImage(
                      imageURL: displayLogo,
                      height: 50.h,
                      width: 50.h,
                      contentMode: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                /// Currency/Stock Name and Timestamp - Expanded to take available space
                Expanded(
                  child: Column(
                    crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$displayName ($displaySymbol)",
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
                      height: 26.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
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
                      child: Center(
                        child: Text(
                          _getLocalizedRiskLabel(signalData.riskFactor),
                          style: TextStyles.txtSemiBoldG10(context).copyWith(
                            fontWeight: Constant.fwRegular,
                            color: Constant.clrWhite,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),

                    /// Status Badge (Invalid for Trading / Valid, etc.)
                    Container(
                      width: 97.w,
                      height: 26.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
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
                      child: Center(
                        child: Text(
                          isActive ? getLocalValue('Key_Valid') : getLocalValue('Key_InvalidForTrading'),
                          style: TextStyles.txtMedium10(context).copyWith(
                            color: Constant.clrWhite,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                      '${signalData.livePrice ?? "0"} USDT',
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
                      '${signalData.entryPrice ?? "0"} USDT',
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
                      '${signalData.stopLoss ?? "0"} USDT',
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

    return cardContent;
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

  /// Get localized risk label
  String _getLocalizedRiskLabel(String? riskFactor) {
    if (riskFactor == null || riskFactor.isEmpty) {
      return getLocalValue('Key_MediumRisk');
    }

    final riskLower = riskFactor.toLowerCase();
    if (riskLower.contains("high")) {
      return getLocalValue('Key_HighRisk');
    } else if (riskLower.contains("medium")) {
      return getLocalValue('Key_MediumRisk');
    } else if (riskLower.contains("low")) {
      return getLocalValue('Key_LowRisk');
    }

    return getLocalValue('Key_MediumRisk'); // default
  }

  /// Dummy US Market Stories - Active
  List<Map<String, dynamic>> _getDummyUSMarketActiveStories() {
    return [
      {
        'ticker': 'AAPL',
        'name': 'Apple Inc.',
        'price': '\$175.50',
        'status': 'Active',
        'date': '19/11/2025 10:30',
        'risk': 'Low',
        'description': 'Strong buy signal based on technical analysis. Price showing upward momentum.',
      },
      {
        'ticker': 'NVDA',
        'name': 'NVIDIA Corporation',
        'price': '\$495.20',
        'status': 'Active',
        'date': '19/11/2025 09:15',
        'risk': 'Medium',
        'description': 'AI sector leader with strong fundamentals. Watch for support at \$490.',
      },
    ];
  }

  /// Dummy US Market Stories - Pending
  List<Map<String, dynamic>> _getDummyUSMarketPendingStories() {
    return [
      {
        'ticker': 'TSLA',
        'name': 'Tesla Inc.',
        'price': '\$238.75',
        'status': 'Pending',
        'date': '19/11/2025 11:00',
        'risk': 'High',
        'description': 'Awaiting confirmation of breakout above resistance level.',
      },
      {
        'ticker': 'MSFT',
        'name': 'Microsoft Corporation',
        'price': '\$378.90',
        'status': 'Pending',
        'date': '19/11/2025 10:45',
        'risk': 'Low',
        'description': 'Monitoring for entry point near support zone.',
      },
    ];
  }

  /// Dummy US Market Stories - Closed
  List<Map<String, dynamic>> _getDummyUSMarketClosedStories() {
    return [
      {
        'ticker': 'GOOGL',
        'name': 'Alphabet Inc.',
        'price': '\$142.30',
        'status': 'Closed',
        'date': '18/11/2025 16:00',
        'risk': 'Low',
        'description': 'Target reached. Position closed with +5.2% profit.',
      },
      {
        'ticker': 'AMZN',
        'name': 'Amazon.com Inc.',
        'price': '\$155.60',
        'status': 'Closed',
        'date': '18/11/2025 14:30',
        'risk': 'Medium',
        'description': 'Stop loss triggered. Closed with minimal loss.',
      },
    ];
  }

  /// Build US Market Story Card - Matching US Market screen buildInvestmentCard design
  Widget _buildUSMarketStoryCard(Map<String, dynamic> story) {
    // Get localized status and risk labels
    final String statusKey = story['status'] == 'Active'
        ? 'Key_Active'
        : story['status'] == 'Pending'
            ? 'Key_Pending'
            : 'Key_Closed';
    final String statusLabel = getLocalValue(statusKey);
    final String riskLabel = _getLocalizedRiskLabel(story['risk']);
    final bool isRTL = getAppLanguage() == 'ar';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Constant.clrHomeCardByTheme(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content with padding
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Time
                Text(
                  story['date'],
                  style: TextStyles.txtRegular12(context).copyWith(
                    color: Constant.clrTitlePageByTheme(context).withOpacity(0.5),
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 12.h),

                // Stock Title with Logo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stock Icon
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Constant.clrPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Text(
                          story['ticker'].substring(0, min(2, story['ticker'].length)),
                          style: TextStyles.txtBold16(context).copyWith(
                            color: Constant.clrPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Company Name and Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${story['name']} (${story['ticker']})',
                            style: TextStyles.txtSemiBold16(context).copyWith(
                              color: Constant.clrTitlePageByTheme(context),
                              fontSize: 15.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
                          // Price in Blue
                          Text(
                            story['price'],
                            style: TextStyles.txtSemiBold18(context).copyWith(
                              color: Constant.clrBlue,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add spacing for status tags so text doesn't overlap
                    SizedBox(width: 105.w),
                  ],
                ),
              ],
            ),
          ),

          // Status Tags positioned at card edge (matching US Market screen exactly)
          Positioned(
            top: 40.h,
            right: isRTL ? null : 0,
            left: isRTL ? 0 : null,
            child: Column(
              crossAxisAlignment: isRTL
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                // Status Tag (Active/Pending/Closed)
                Container(
                  width: 97.w,
                  height: 23.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusBadgeColor(story['status']),
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
                    statusLabel,
                    style: TextStyles.txtSemiBoldG10(context).copyWith(
                      fontWeight: Constant.fwRegular,
                      color: Constant.clrWhite,
                      fontSize: 10.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 6.h),
                // Risk Tag (High/Medium/Low)
                Container(
                  width: 97.w,
                  height: 23.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getRiskBadgeColor(story['risk']),
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
                    riskLabel,
                    style: TextStyles.txtSemiBoldG10(context).copyWith(
                      fontWeight: Constant.fwRegular,
                      color: Constant.clrWhite,
                      fontSize: 9.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get status badge color
  Color _getStatusBadgeColor(String status) {
    if (status == 'Active') {
      return Color(0xFF10B981); // Green
    } else if (status == 'Pending') {
      return Color(0xFFFBBF24); // Yellow/Orange
    } else {
      return Color(0xFF6B7280); // Gray
    }
  }
}
