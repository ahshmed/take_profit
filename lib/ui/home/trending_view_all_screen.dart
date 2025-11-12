// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:trader/framework/data_provider/home/home_provider.dart';
// import 'package:trader/framework/data_provider/home/trending_view_all_controller.dart';
// import 'package:trader/ui/home/recommender_details_screen.dart';
// import 'package:trader/utils/const.dart';
// import 'package:trader/utils/extension/extension.dart';
// import 'package:trader/utils/no_internet_builder.dart';
// import 'package:trader/utils/sliderightroute.dart';
// import 'package:trader/utils/theme_const.dart';
// import 'package:trader/utils/widgets/cache_image.dart';
// import 'package:trader/utils/widgets/commonappbar.dart';
// import 'package:trader/utils/widgets/dialog_progressbar.dart';
//
// class TrendingViewAllScreen extends ConsumerStatefulWidget {
//   const TrendingViewAllScreen({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<TrendingViewAllScreen> createState() =>
//       _TrendingViewAllScreenState();
// }
//
// class _TrendingViewAllScreenState extends ConsumerState<TrendingViewAllScreen>
//     with Constant {
//   final ScrollController _scrollController = ScrollController();
//
//   ///-----Init----
//   @override
//   void initState() {
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       final trendingWatch = ref.watch(trendingViewAllProvider);
//
//       ///here call home api
//       scrollListenerMethod(trendingWatch);
//       _getTrendingList(trendingWatch);
//     });
//     super.initState();
//   }
//
//   scrollListenerMethod(TrendingViewAllScreenController trendingWatch) {
//     _scrollController.addListener(() async {
//       if (trendingWatch.isHasMorePage) {
//         if (_scrollController.position.maxScrollExtent ==
//             _scrollController.position.pixels) {
//           _getTrendingList(trendingWatch);
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   ///build widget
//   @override
//   Widget build(BuildContext context) {
//     final trendingWatch = ref.watch(trendingViewAllProvider);
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor: clrScaffoldBGByTheme(),
//           appBar: CommonAppBar(
//             isTitleCenter: true,
//             title: getLocalValue("Key_Trending"),
//             appBar: AppBar(backgroundColor: clrWhiteNew, toolbarHeight: 64.h),
//             isDrawer: false,
//           ),
//           body: NoInternetBuilder(child: bodyWidget()),
//         ),
//         DialogProgressBar(isLoading: trendingWatch.isLoading)
//       ],
//     );
//   }
//
//   ///body widget
//   Widget bodyWidget() {
//     final trendingViewAllWatch = ref.watch(trendingViewAllProvider);
//     return Padding(
//       padding: EdgeInsets.all(20.w),
//       child: Column(
//         children: [
//           GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               mainAxisSpacing: 21.h,
//               childAspectRatio: 10 / 11,
//             ),
//             controller: _scrollController,
//             shrinkWrap: true,
//             itemCount: trendingViewAllWatch
//                     .trendingListResponseModel?.data?.trendingList?.length ??
//                 0,
//             itemBuilder: (context, index) {
//               final trendingObj = trendingViewAllWatch
//                   .trendingListResponseModel?.data?.trendingList?[index];
//
//               return InkWell(
//                 onTap: () {
//                   Route route = SlideRightPageRoute(
//                       builder: (context) => RecommenderDetailScreen(
//                             recommenderID: trendingObj?.recommenderId ?? "",
//                           ),
//                       settings: const RouteSettings());
//                   Navigator.of(context).push(route);
//                 },
//                 child: Column(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(15.r),
//                       child: CacheImage(
//                           imageURL: trendingObj?.profileImage ?? "",
//                           height: 84.h,
//                           width: 84.h,
//                           contentMode: BoxFit.fill),
//                     ),
//                     SizedBox(
//                       height: 10.h,
//                     ),
//                     Text(
//                       trendingObj?.name.toString() ?? "",
//                       maxLines: 1,
//                       textAlign: TextAlign.center,
//                       style: TextStyles.txtRegular12
//                           (context).copyWith(color: clrWhiteBlackByTheme()),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//           DialogProgressBar(
//             isLoading: trendingViewAllWatch.isLoadingPagination,
//             forPagination: true,
//           ).paddingOnly(bottom: 40.h)
//         ],
//       ),
//     );
//   }
//
//   /// Get Trending List
//   Future _getTrendingList(TrendingViewAllScreenController trendingWatch) async {
//     if (isInternetConnectionOn) {
//       await trendingWatch.trendingListAPI(context, "");
//     }
//   }
// }
