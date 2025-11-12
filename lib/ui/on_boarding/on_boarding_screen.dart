// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import 'package:carousel_slider/carousel_slider.dart';
//
// import '../../framework/data_provider/home/home_provider.dart';
// import '../../framework/data_provider/on_boarding/on_boarding_screen_controller.dart';
// import '../../framework/data_provider/on_boarding/on_boarding_screen_provider.dart';
// import '../../utils/const.dart';
// import '../../utils/sliderightroute.dart';
// import '../../utils/theme_const.dart';
// import '../../utils/widgets/common_button.dart';
// import '../../utils/widgets/common_image_asset.dart';
// import '../drawer/drawer_menu.dart';
//
//
// class OnBoardingScreen extends ConsumerStatefulWidget {
//   const OnBoardingScreen({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }
//
// class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen>
//      {
//   /// carousel Controller
//   final CarouselSliderController _carouselController = CarouselSliderController();
//
//   List<String> boardingTitle = [
//     "Key_EasyToUseAndUserfriendly",
//     "Key_Instantnotificationsforrecommendationsandanalysisrequestsupdates",
//     "Key_Livecurrencypricesinrealtime"
//   ];
//
//   // List<String> boardingDescription = [
//   //   "Key_EasyToUseAndUserfriendly",
//   //   "Key_Instantnotificationsforrecommendationsandanalysisrequestsupdates",
//   //   "Key_Livecurrencypricesinrealtime"
//   // ];
//
//   ///-----Init----
//   @override
//   void initState() {
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       final dashboardWatch = ref.watch(dashboardProvider);
//       dashboardWatch.clearProvider();
//     });
//     super.initState();
//   }
//
//   ///main build
//   @override
//   Widget build(BuildContext context) {
//     final onBoardingWatch = ref.watch(onBoardingScreenProvider);
//     return Scaffold(
//       backgroundColor: Constant.clrScaffoldBGByTheme(),
//       body: bodyWidget(onBoardingWatch),
//       bottomNavigationBar: bottomButton(),
//     );
//   }
//
//   ///body Widget
//   Widget bodyWidget(OnBoardingScreenController onBoardingWatch) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             height: 85.h,
//           ),
//           SizedBox(
//             height: 320.h,
//             child: CarouselSlider(
//               items: boardingTitle.map((value) {
//                 return Builder(
//                   builder: (BuildContext context) {
//                     int index = boardingTitle.indexOf(value);
//                     return carouselWidget(onBoardingWatch, index);
//                   },
//                 );
//               }).toList(),
//               carouselController: _carouselController,
//               options: CarouselOptions(
//                   autoPlay: true,
//                   reverse: false,
//                   enlargeCenterPage: true,
//                   scrollDirection: Axis.horizontal,
//                   pauseAutoPlayOnTouch: true,
//                   aspectRatio: 1.5,
//                   enableInfiniteScroll: true,
//                   autoPlayAnimationDuration: const Duration(seconds: 1),
//                   autoPlayInterval: const Duration(seconds: 5),
//                   onPageChanged: (index, reason) {
//                     onBoardingWatch.updateActiveIndex(index);
//                   }),
//             ),
//           ),
//           SizedBox(
//             height: 5.h,
//           ),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: boardingTitle.asMap().entries.map((entry) {
//               return GestureDetector(
//                 onTap: () => _carouselController.animateToPage(entry.key),
//                 child: Container(
//                   width: onBoardingWatch.activeIndex == entry.key ? 30.0 : 6,
//                   height: 5.0,
//                   margin: const EdgeInsets.symmetric(
//                       vertical: 8.0, horizontal: 4.0),
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10.r),
//                       color: (Constant.clrPrimary)),
//                 ),
//               );
//             }).toList(),
//           ),
//           SizedBox(
//             height: 26.h,
//           ),
//           ...List.generate(
//             3,
//             (index) => index == onBoardingWatch.activeIndex
//                 ? Padding(
//                     padding: EdgeInsets.only(left: 46.w, right: 45.w),
//                     child: Text(
//                       getLocalValue(boardingTitle[onBoardingWatch.activeIndex]),
//                       style: TextStyles.txtSemiBold28
//                           (context).copyWith(color: Constant.clrWhiteBlackByTheme()),
//                       textAlign: TextAlign.center,
//                     ),
//                   )
//                 : const SizedBox(),
//           ),
//           SizedBox(
//             height: 18.h,
//           ),
//           // ...List.generate(
//           //   3,
//           //   (index) => index == onBoardingWatch.activeIndex
//           //       ? Padding(
//           //           padding: EdgeInsets.only(left: 20.w, right: 20.w),
//           //           child: Text(
//           //             getLocalValue(
//           //                 boardingDescription[onBoardingWatch.activeIndex]),
//           //             style: TextStyles.txtRegular12
//           //                 (context).copyWith(color: clrWhiteBlackByTheme()),
//           //             textAlign: TextAlign.center,
//           //           ),
//           //         )
//           //       : const SizedBox(),
//           // ),
//           SizedBox(
//             height: 10.h,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget carouselWidget(OnBoardingScreenController onBoardingWatch, int index) {
//     return RotationTransition(
//       turns: index == onBoardingWatch.activeIndex
//           ? const AlwaysStoppedAnimation(0 / 360)
//           : const AlwaysStoppedAnimation(2 / 360),
//       child: Container(
//         height: 300.h,
//         width: MediaQuery.of(context).size.width * 0.8,
//         margin: EdgeInsets.symmetric(horizontal: 10.w),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(18.r),
//           color: Constant.clrPrimaryLight.withOpacity(0.3),
//         ),
//         child: ClipRRect(
//           child: CommonImageAsset(
//             strIcon: onBoardingWatch.imageList[index],
//             boxFit: BoxFit.contain,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget bottomButton() {
//     return Padding(
//       padding: EdgeInsets.only(
//           left: 57.w,
//           right: 55.w,
//           bottom: (MediaQuery.of(context).padding.bottom + 8).h),
//       child: CommonButton(
//         label: getLocalValue("Key_Explore"),
//         onTap: () async {
//           saveLocalData(KEY_IS_ONBOARDING_SHOWED, true);
//           saveLocalData(KEY_USER_STATUS, guest);
//           Route route = SlideRightPageRoute(
//               builder: (context) => const DrawerMenu(),
//               settings: const RouteSettings());
//           Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
//         },
//         bgColor: Constant.clrPrimary,
//         labelColor: Constant.clrWhite,
//         borderRadius: 25.r,
//         textSize: 16.sp,
//       ),
//     );
//   }
// }
