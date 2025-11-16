// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/home/recommender_details_screen.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/notification/notification_controller.dart';
import '../../framework/data_provider/notification/notification_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/select_market/market_providers.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../notification/notification_screen.dart';
import '../search/search_screen.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  ///-----Init----
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final trendingWatch = ref.watch(trendingViewAllProvider);
      final homeWatch = ref.watch(homeProvider);
      final commonWatch = ref.watch(commonProvider);
      final notificationWatch = ref.watch(notificationProvider);
      homeWatch.clearProvider();
      await homeRecommenderDetailsApiCall();

      /// Live Price Api Call every secondsDelayForRealTimeAPICall seconds
  /*    if (!commonWatch.isLoading ||
          !homeWatch.isLoading ||
          !trendingWatch.isLoading ||
          !notificationWatch.isLoading) {*/
        /*currencyTimerHome = Timer.periodic(
            Duration(milliseconds: secondsDelayForRealTimeAPICall),
            (timer) async {
              showLog('timer.isActive ${timer.isActive}');
          if (timer.isActive) {*/
            await commonWatch.getCryptoCurrencyAPI(
                NavigationService.navigatorKey.currentContext!);
         /* }
        });*/
      // }

      ///here call home api
      // _getTrendingList(trendingWatch);

      // await recommenderListApi(
      //     homeWatch,
      //     homeWatch.recommenderTabSelectIndex == 0
      //         ? all
      //         : homeWatch.recommenderTabSelectIndex == 1
      //             ? matched
      //             : subscribed,
      //     getUserStatus() == guest ? "" : getUserEntityId(),
      //     true);
      if (mounted) {
        await notificationCountAPICall(notificationWatch);
        await profileApiCall();
      }
    });

    // _scrollController.addListener(() async {
    //   final homeWatch = ref.watch(homeProvider);
    //   if (homeWatch.isHasMorePage) {
    //     if (_scrollController.position.maxScrollExtent ==
    //         _scrollController.position.pixels) {
    //       if ((int.parse(homeWatch
    //                   .recommenderListResponseModel?.data?.pageNumber
    //                   ?.toString() ??
    //               "0") !=
    //           int.parse(homeWatch.recommenderListResponseModel?.data?.totalPage
    //                   .toString() ??
    //               "0"))) {
    //         recommenderListApi(
    //             homeWatch,
    //             homeWatch.recommenderTabSelectIndex == 0
    //                 ? all
    //                 : homeWatch.recommenderTabSelectIndex == 1
    //                     ? matched
    //                     : subscribed,
    //             getUserStatus() == guest ? "" : getUserEntityId(),
    //             false);
    //       }
    //     }
    //   }
    // });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // currencyTimer?.cancel();
    super.dispose();
  }

  ///build widget
  @override
  Widget build(BuildContext context) {
    final homeWatch = ref.watch(homeProvider);
    final darkModeWatch = ref.watch(darkProvider);
    final drawerWatch = ref.watch(drawerProvider);
    final profileWatch = ref.watch(profileProvider);
    final notificationWatch = ref.watch(notificationProvider);
    final trendingWatch = ref.watch(trendingViewAllProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            backgroundColor:Constant.clrHomeScreenByTheme(context) ,
            isPremiumIconRequired: true,
            title: getUserStatus() == guest
                ? getLocalValue("Key_Hi") + 'Key_TakeProfit'.localized
                : getLocalValue("Key_Hi") +
                    ((getAppLanguage() == 'ar')
                        ? (profileWatch
                                .profileDetailResponseModel?.data?.nameAr ??
                            "")
                        : (profileWatch
                                .profileDetailResponseModel?.data?.nameEn ??
                            "")),
            // getLocalValue("Key_Hi") + 'Key_TakeProfit'.localized,
            titleTextStyle: TextStyles.txtRegular16(context).copyWith(color: Constant.clrTitlePageByTheme(context)),
            subTitle: /*getUserStatus() != guest
                ? getUserStatus() == trader
                    ? "Key_Trader".localized
                    : "Key_Recommender".localized
                ? profileWatch.profileDetailResponseModel?.data?.userTypeLabel ?? ""
                :*/
                '',
            isTitleCenter: false,
            appBar: AppBar(backgroundColor: Constant.clrWhiteNew, toolbarHeight: 64.h),
            isDrawer: true,
            action: [
              // Search (compact IconButton)
              IconButton(
                onPressed: () {
                  final route = SlideRightPageRoute(
                    builder: (context) => const SearchScreen(),
                    settings: const RouteSettings(),
                  );
                  Navigator.of(context).push(route);
                },
                //padding: EdgeInsets.zero,
                //constraints: const BoxConstraints(), // remove 48x48 min constraints
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(39.81.h, 39.81.h), // match icon size
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // no extra padding
                ),
                splashRadius: 18,
                icon: CommonImageAsset(
                  strIcon: Constant.icSearchN,
                  width: 39.81.h, // visual size; keep around ~20–24 for compact look
                  height: 39.81.h,
                  clrImg: Constant.clrTitlePageByTheme(context)
                ),
              ),
              SizedBox(width: 5.w), // explicit small gap
              // Notifications (compact, with tight badge)
              Visibility(
                visible: getUserStatus() != guest,
                child: IconButton(
                  onPressed: () {
                    final route = SlideRightPageRoute(
                      builder: (context) => const NotificationScreen(),
                      settings: const RouteSettings(),
                    );
                    Navigator.of(context).push(route).then((value) {
                      if (value == true) {
                        notificationCountAPICall(notificationWatch);
                      }
                    });
                  },
                  //padding: EdgeInsets.zero,
                  //constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(39.81.h, 39.81.h), // match icon size
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // no extra padding
                  ),
                  splashRadius: 18,
                  icon: Visibility(
                    visible: (notificationWatch
                        .notificationCountResponseModel.data?.count != '0') &&
                        (notificationWatch.notificationCountResponseModel.data != null),
                    replacement: Image.asset(
                      Constant.icNotificationN,
                      width: 39.81.h,
                      height: 39.81.h,
                      color: Constant.clrTitlePageByTheme(context),
                    ),
                    child: badge.Badge(
                      position: badge.BadgePosition.topEnd(top: 1, end: 6), // pull badge in
                      badgeStyle: const badge.BadgeStyle(
                        badgeColor: Colors.red,
                        padding: EdgeInsets.all(4),
                        elevation: 0
                      ),
                      badgeContent: Text(
                        notificationWatch.notificationCountResponseModel.data?.count ?? '',
                        style: TextStyles.txtRegular10(context).copyWith(color: Constant.clrTitlePageByTheme(context)),
                      ),
                      child: Image.asset(
                        Constant.icNotificationN,
                        width: 39.81.h,
                        height: 39.81.h,
                        color: Constant.clrTitlePageByTheme(context)
                      ),
                    ),
                  ),
                ),
              ),
              // Optional trailing spacing only when visible
              Visibility(
                visible: getUserStatus() != guest,
                child: SizedBox(width: 4.w),
              ),
            ],

            // action: [
            //   IconButton(
            //     onPressed: () {
            //       Route route = SlideRightPageRoute(
            //         builder: (context) => const SearchScreen(),
            //         settings: const RouteSettings(),
            //       );
            //       Navigator.of(context).push(route);
            //     },
            //     icon: CommonImageAsset(
            //       strIcon: Constant.icSearchN,
            //       width: 39.81.h,
            //       height: 39.81.h,
            //     ),
            //   ),
            //   SizedBox(
            //     width: 12.w,
            //   ),
            //   Visibility(
            //     visible: getUserStatus() == guest ? false : true,
            //     child: IconButton(
            //       onPressed: () {
            //         Route route = SlideRightPageRoute(
            //           builder: (context) => const NotificationScreen(),
            //           settings: const RouteSettings(),
            //         );
            //         Navigator.of(context).push(route).then((value) {
            //           if (value == true) {
            //             notificationCountAPICall(notificationWatch);
            //           }
            //         });
            //       },
            //       icon: Visibility(
            //         visible: notificationWatch
            //                     .notificationCountResponseModel.data?.count !=
            //                 "0" &&
            //             notificationWatch.notificationCountResponseModel.data !=
            //                 null,
            //         replacement: Image.asset(
            //           Constant.icNotificationN,
            //           width: 39.81.h,
            //           height: 39.81.h,
            //         ),
            //         child: badge.Badge(
            //           badgeContent: Text(
            //             notificationWatch
            //                     .notificationCountResponseModel.data?.count ??
            //                 "",
            //             style:
            //                 TextStyles.txtRegular10(context).copyWith(color: Constant.clrWhite),
            //           ),
            //           child: Image.asset(
            //             Constant.icNotificationN,
            //             width: 39.81.h,
            //             height: 39.81.h,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            //   Visibility(
            //     visible: getUserStatus() == guest ? false : true,
            //     child: SizedBox(
            //       width: 10.w,
            //     ),
            //   ),
            // ],
          ),
          body: NoInternetBuilder(
            child: (homeWatch.homeRecommenderDetailsResponseModel?.data != null)
                ? Column(
                    children: [
                      // Market selector for recommenders only
                      if (getUserStatus() == recommender)
                        _buildMarketSelector(ref),

                      // Main content
                      Expanded(
                        child: RecommenderDetailScreen(
                          recommenderID: homeWatch.homeRecommenderDetailsResponseModel
                                  ?.data?.recommenderId ??
                              '',
                          appbarRequired: false,
                        ),
                      ),
                    ],
                  )
                : const Offstage(),
          ),
        ),
        DialogProgressBar(
            isLoading: trendingWatch.isLoading ||
                homeWatch.isLoading ||
                notificationWatch.isLoading),
      ],
    );
  }

  /// Market Selector Widget for Recommenders
  Widget _buildMarketSelector(WidgetRef ref) {
    final selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Constant.clrScaffoldBGByTheme(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Constant.clrPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Crypto Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isUSMarket) {
                  setSelectedMarket('crypto_signals');
                  ref.read(selectMarketProvider.notifier).selectMarketById('crypto_signals');
                  ref.read(dashboardProvider).updateSelectedIndex(0);
                  setState(() {});
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: !isUSMarket ? Constant.clrPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Constant.icCryptoN,
                      width: 20.w,
                      height: 20.h,
                      color: !isUSMarket ? Constant.clrWhite : Constant.clrTitlePageByTheme(context),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      getLocalValue('Key_Crypto'),
                      style: TextStyles.txtMedium14(context).copyWith(
                        color: !isUSMarket ? Constant.clrWhite : Constant.clrTitlePageByTheme(context),
                        fontWeight: !isUSMarket ? Constant.fwSemiBold : Constant.fwRegular,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // US Market Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isUSMarket) {
                  setSelectedMarket('us_market');
                  ref.read(selectMarketProvider.notifier).selectMarketById('us_market');
                  ref.read(dashboardProvider).updateSelectedIndex(0);
                  setState(() {});
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isUSMarket ? Constant.clrPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Constant.icUsMarketN,
                      width: 20.w,
                      height: 20.h,
                      color: isUSMarket ? Constant.clrWhite : Constant.clrTitlePageByTheme(context),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      getLocalValue('Key_Us_Market'),
                      style: TextStyles.txtMedium14(context).copyWith(
                        color: isUSMarket ? Constant.clrWhite : Constant.clrTitlePageByTheme(context),
                        fontWeight: isUSMarket ? Constant.fwSemiBold : Constant.fwRegular,
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

//   ///body widget
//   Widget bodyWidget(HomeScreenController homeWatch) {
//     return SingleChildScrollView(
//       controller: _scrollController,
//       physics: const BouncingScrollPhysics(),
//       child: Column(
//         children: [
// /*          trendingWidget(homeWatch),
//           recommenderWidget(homeWatch),*/
//           SizedBox(
//             height: 70.h,
//           ),
//         ],
//       ),
//     );
//   }
//
//   ///trending widget
//   Widget trendingWidget(HomeScreenController homeWatch) {
//     final trendingWatch = ref.watch(trendingViewAllProvider);
//     return Container(
//       height: 180.h,
//       width: MediaQuery.of(context).size.width,
//       color: clrPrimaryLight.withOpacity(0.2), // clrPrimaryLight,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 10.h,
//             ),
//             Row(
//               children: [
//                 Text(
//                   getLocalValue("Key_Trending"),
//                   style: TextStyles.txtMedium14
//                       (context).copyWith(color: clrWhiteBlackByTheme()),
//                 ),
//                 const Spacer(),
//                 Visibility(
//                   visible: (trendingWatch
//                               .trendingListResponseModel?.data?.trendingList !=
//                           null) &&
//                       (trendingWatch.trendingListResponseModel?.data
//                                   ?.trendingList?.length ??
//                               0) >
//                           4,
//                   child: InkWell(
//                     onTap: () {
//                       Route route = SlideRightPageRoute(
//                           builder: (context) => const TrendingViewAllScreen(),
//                           settings: const RouteSettings());
//                       Navigator.of(context).push(route);
//                     },
//                     child: Text(
//                       getLocalValue("Key_ViewAll"),
//                       style: TextStyles.txtRegular12(context).copyWith(
//                         fontSize: 10.sp,
//                         color: clrWhiteBlackByTheme(),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 20.h,
//             ),
//             Expanded(
//               child: trendingUserList(homeWatch),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   ///Trending User List
//   Widget trendingUserList(HomeScreenController homeWatch) {
//     final trendingWatch = ref.watch(trendingViewAllProvider);
//     return Container(
//       alignment: ref.watch(drawerProvider).isEngEnable == false
//           ? Alignment.centerRight
//           : Alignment.centerLeft,
//       child: ListView.builder(
//           padding: EdgeInsets.zero,
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           itemCount: (trendingWatch.trendingList.length) >= 4
//               ? 4
//               : (trendingWatch.trendingList.length),
//           scrollDirection: Axis.horizontal,
//           itemBuilder: (context, index) {
//             final trendingObj = trendingWatch.trendingList[index];
//             return InkWell(
//               splashColor: clrTransparent,
//               highlightColor: clrTransparent,
//               onTap: () {
//                 Route route = SlideRightPageRoute(
//                     builder: (context) => RecommenderDetailScreen(
//                           recommenderID: trendingObj.recommenderId ?? "",
//                         ),
//                     settings: const RouteSettings());
//                 Navigator.of(context).push(route);
//               },
//               child: Padding(
//                 padding: EdgeInsets.only(
//                     right: ref.watch(drawerProvider).isEngEnable == false
//                         ? 0
//                         : 30.w,
//                     left: ref.watch(drawerProvider).isEngEnable == false
//                         ? 30.w
//                         : 0),
//                 child: Column(
//                   children: [
//                     ClipRRect(
//                       child: CacheImage(
//                           imageURL: trendingObj.profileImage ?? "",
//                           height: 60.h,
//                           width: 60.h,
//                           contentMode: BoxFit.fill),
//                       borderRadius: BorderRadius.circular(15.r),
//                     ),
//                     //CacheImage(imageURL: ,  contentMode: BoxFit.fill),
//                     SizedBox(
//                       height: 6.h,
//                     ),
//                     SizedBox(
//                       width: 70.h,
//                       child: Text(
//                         trendingObj.name ?? "",
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         style: TextStyles.txtRegular10(context).copyWith(
//                           fontSize: 10.sp,
//                           color: clrWhiteBlackByTheme(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//     );
//   }
//
//   ///recommender widget
//   Widget recommenderWidget(HomeScreenController homeWatch) {
//     return Container(
//       color: clrPrimaryLight.withOpacity(0.2),
//       child: Container(
//         decoration: BoxDecoration(
//           color: clrScaffoldBGByTheme(),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20.r),
//             topRight: Radius.circular(20.r),
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.only(top: 15.h, left: 20.w, right: 20.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Text(
//                   getLocalValue("Key_Recommenders"),
//                   style: TextStyles.txtMedium14(context).copyWith(
//                     color: clrWhiteBlackByTheme(),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 15.h,
//               ),
//               Container(
//                 padding: EdgeInsets.all(3.w),
//                 decoration: BoxDecoration(
//                   color: clrDarkByScaffoldTheme(),
//                   borderRadius: BorderRadius.circular(12.r),
//                   border: Border.all(color: clrGrey),
//                 ),
//                 child: recommenderTabList(homeWatch),
//               ),
//               SizedBox(
//                 height: 15.h,
//               ),
//               homeWatch.isLoading
//                   ? const Offstage()
//                   : recommenderUserList(homeWatch),
//               DialogProgressBar(
//                 isLoading: homeWatch.isLoadingPagination,
//                 forPagination: true,
//               ).paddingOnly(bottom: 120.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   ///Widget tabs List
//   Widget recommenderTabList(HomeScreenController homeWatch) {
//     return Row(
//       children: [
//         Flexible(
//           flex: 2,
//           child: InkWell(
//             onTap: () {
//               ///here call home api with filter (all)
//               homeWatch.updateRecommenderTabIndex(0);
//               homeWatch.recommenderList.clear();
//
//               recommenderListApi(homeWatch, all,
//                   getUserStatus() == guest ? "" : getUserEntityId(), true);
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.r),
//                 color: homeWatch.recommenderTabSelectIndex == 0
//                     ? clrPrimary
//                     : clrTransparent,
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CommonSVG(
//                     strIcon: svgAllProfile,
//                     svgColor: homeWatch.recommenderTabSelectIndex == 0
//                         ? clrWhite
//                         : clrBlackNew,
//                     height: 20.h,
//                     width: 20.h,
//                   ),
//                   SizedBox(
//                     width: 3.w,
//                   ),
//                   Text(
//                     getLocalValue(homeWatch.recommenderTabList[0]),
//                     style: TextStyles.txtRegular12(context).copyWith(
//                         fontSize: 12.sp,
//                         color: homeWatch.recommenderTabSelectIndex == 0
//                             ? clrWhiteNew
//                             : clrBlackNew),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Flexible(
//           flex: 2,
//           child: InkWell(
//             onTap: () {
//               ///here call home api with filter (matched)
//               getUserStatus() == guest
//                   ? getStartedDialog(context)
//                   : homeWatch.updateRecommenderTabIndex(1);
//
//               homeWatch.recommenderList.clear();
//               recommenderListApi(
//                   homeWatch,
//                   (getUserStatus() == guest) ? all : matched,
//                   getUserStatus() == guest ? "" : getUserEntityId(),
//                   true);
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.r),
//                 color: homeWatch.recommenderTabSelectIndex == 1
//                     ? clrPrimary
//                     : Colors.transparent,
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CommonImageAsset(
//                     strIcon: icMatched,
//                     clrImg: homeWatch.recommenderTabSelectIndex == 1
//                         ? clrWhite
//                         : clrBlackNew,
//                     height: 20.h,
//                     width: 20.h,
//                   ),
//                   SizedBox(
//                     width: 3.w,
//                   ),
//                   Text(
//                     getLocalValue(homeWatch.recommenderTabList[1]),
//                     style: TextStyles.txtRegular12(context).copyWith(
//                         fontSize: 12.sp,
//                         color: homeWatch.recommenderTabSelectIndex == 1
//                             ? clrWhiteNew
//                             : clrBlackNew),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Flexible(
//           flex: 2,
//           child: InkWell(
//             onTap: () {
//               ///here call home api with filter (subscribed)
//               getUserStatus() == guest
//                   ? getStartedDialog(context)
//                   : homeWatch.updateRecommenderTabIndex(2);
//               homeWatch.recommenderList.clear();
//               recommenderListApi(
//                   homeWatch,
//                   (getUserStatus() == guest) ? all : subscribed,
//                   getUserStatus() == guest ? "" : getUserEntityId(),
//                   true);
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.r),
//                 color: homeWatch.recommenderTabSelectIndex == 2
//                     ? clrPrimary
//                     : Colors.transparent,
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CommonImageAsset(
//                     strIcon: icSub,
//                     clrImg: homeWatch.recommenderTabSelectIndex == 2
//                         ? clrWhite
//                         : clrBlackNew,
//                     height: 20.h,
//                     width: 20.h,
//                   ),
//                   SizedBox(
//                     width: 2.w,
//                   ),
//                   Text(
//                     getLocalValue(homeWatch.recommenderTabList[2]),
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyles.txtRegular12(context).copyWith(
//                         fontSize: 12.sp,
//                         color: homeWatch.recommenderTabSelectIndex == 2
//                             ? clrWhiteNew
//                             : clrBlackNew),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   ///Recommender User List
//   Widget recommenderUserList(HomeScreenController homeWatch) {
//     final drawerWatch = ref.watch(drawerProvider);
//     return (homeWatch.recommenderList.isEmpty && !homeWatch.isLoading)
//         ? SizedBox(
//             height: 400.h,
//             child: EmptyStateWidget(
//                 emptyStateFor: homeWatch.recommenderTabSelectIndex == 0
//                     ? EmptyState.noRecommenderFound
//                     : homeWatch.recommenderTabSelectIndex == 1
//                         ? EmptyState.noRecommenderMatchedRN
//                         : EmptyState.noSubscribeRecommender))
//         : ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: homeWatch.recommenderList.length,
//             itemBuilder: (context, index) {
//               var item = homeWatch.recommenderList[index];
//               return InkWell(
//                 onTap: () {
//                   Route route = SlideRightPageRoute(
//                       builder: (context) => RecommenderDetailScreen(
//                             recommenderID: item.recommenderId ?? "",
//                           ),
//                       settings: const RouteSettings());
//                   Navigator.of(context).push(route);
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: 10.h),
//                   child: Card(
//                     elevation: 0.h,
//                     color: clrDarkByScaffoldTheme(),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     child: Container(
//                       margin: EdgeInsets.all(15.sp),
//                       child: Row(
//                         children: [
//                           ClipRRect(
//                             child: CacheImage(
//                               imageURL: item.profileImage ?? "",
//                               height: 45.h,
//                               width: 45.h,
//                             ),
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                           SizedBox(
//                             width: 15.w,
//                           ),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Flexible(
//                                       child: Text(
//                                         item.name ?? "",
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyles.txtMedium12(context).copyWith(
//                                           color: clrWhiteBlackByTheme(),
//                                         ),
//                                       ).paddingOnly(right: 5.w),
//                                     ),
//                                     Visibility(
//                                       visible: item.isPremiumUser == '1',
//                                       child: CommonSVG(
//                                         strIcon: svgPremiumUser,
//                                         height: 15.h,
//                                         width: 15.h,
//                                       ),
//                                     ),
//                                     const Spacer(),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 10.h,
//                                 ),
//                                 Row(
//                                   children: [
//                                     ...List.generate(
//                                       item.cryptoImages?.length ?? 0,
//                                       (index) {
//                                         return Padding(
//                                           padding: EdgeInsets.only(right: 10.w),
//                                           child: CacheImage(
//                                             imageURL: item.cryptoImages?[index],
//                                             height: 18.h,
//                                             width: 18.h,
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: ClipRRect(
//                               borderRadius:
//                                   BorderRadius.circular(26.h / 2 - 26.h / 18),
//                               child: Transform.rotate(
//                                 angle:
//                                     (drawerWatch.isEngEnable == false) ? pi : 0,
//                                 child: CommonSVG(
//                                   strIcon: svgForward,
//                                   boxFit: BoxFit.cover,
//                                   height: 26.h,
//                                   width: 26.h,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//   }
//
//   /// Get Trending List
//   Future _getTrendingList(TrendingViewAllScreenController trendingWatch) async {
//     if (isInternetConnectionOn) {
//       await trendingWatch.trendingListAPI(context, "");
//     }
//   }
//
//   ///Recommender List Api
//   Future recommenderListApi(HomeScreenController homeWatch, String type,
//       String userId, bool removeOldData) async {
//     if (removeOldData == true) {
//       homeWatch.isHasMorePage = false;
//     }
//     if (isInternetConnectionOn) {
//       await homeWatch.recommenderListApi(context, type: type, userId: userId);
//     }
//   }

  /// Notification Count
  Future<void> notificationCountAPICall(
      NotificationController notificationWatch) async {
    if (getUserStatus() != guest) {
      if (isInternetConnectionOn) {
        await notificationWatch.notificationCountAPI(context);
      }
    }
  }

  Future<void> profileApiCall() async {
    final profileWatch = ref.watch(profileProvider);
    if (isInternetConnectionOn && getUserAccessToken() != "") {
      await profileWatch.profileAPI(context);
    }
  }

  /// Home Recommender Details get
  Future<void> homeRecommenderDetailsApiCall() async {
    final homeWatch = ref.watch(homeProvider);
    if (isInternetConnectionOn) {
      await homeWatch.homeRecommenderDetailsApi(context);
    }
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
