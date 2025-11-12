// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:trader/framework/data_provider/auth/auth_provider.dart';
// import 'package:trader/framework/data_provider/auth/role_selection_screen_controller.dart';
// import 'package:trader/ui/auth/sign_in_screen.dart';
// import 'package:trader/ui/auth/sign_up_screen.dart';
// import 'package:trader/ui/drawer/drawer_menu.dart';
// import 'package:trader/utils/const.dart';
// import 'package:trader/utils/sliderightroute.dart';
// import 'package:trader/utils/theme_const.dart';
// import 'package:trader/utils/widgets/common_image_asset.dart';
// import 'package:trader/utils/widgets/common_button.dart';
//
// class RoleSelectionScreen extends ConsumerStatefulWidget {
//   final String status;
//
//   const RoleSelectionScreen({Key? key, required this.status}) : super(key: key);
//
//   @override
//   ConsumerState<RoleSelectionScreen> createState() =>
//       _RoleSelectionScreenState();
// }
//
// class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen>
//     with Constant {
//   ///init state
//   @override
//   void initState() {
//     super.initState();
//     SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
//       final roleSelectionWatch = ref.watch(roleSelectionProvider);
//       roleSelectionWatch.clearProviderWithName();
//       if (widget.status == signIn) {
//         roleSelectionWatch.updateTitle(signIn);
//       } else {
//         roleSelectionWatch.updateTitle(signUp);
//       }
//       roleSelectionWatch.updateTitle(widget.status);
//     });
//   }
//
//   ///main body
//   @override
//   Widget build(BuildContext context) {
//     final roleSelectionWatch = ref.watch(roleSelectionProvider);
//     return Scaffold(
//       backgroundColor: clrScaffoldBGByTheme(),
//       body: bodyWidget(roleSelectionWatch),
//     );
//   }
//
//   ///widget body
//   Widget bodyWidget(RoleSelectionScreenController roleSelectionWatch) {
//     return Padding(
//       padding: EdgeInsets.all(20.w),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: 100.h,
//             ),
//             Center(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       getTitle(roleSelectionWatch),
//                       style: TextStyles.txtMedium24(context).copyWith(color: clrPrimary),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       roleSelectionWatch.clearProvider();
//                       // roleSelectionWatch.updateSignInStatus((roleSelectionWatch.isSignIn == false)? true: false);
//                       roleSelectionWatch.updateTitle(
//                           (roleSelectionWatch.titleName == signUp)
//                               ? signIn
//                               : signUp);
//                     },
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           getSubTitle(roleSelectionWatch),
//                           style: TextStyles.txtRegular10
//                               (context).copyWith(color: clrWhiteBlackNewByTheme()),
//                         ),
//                         Text(
//                           roleSelectionWatch.titleName != signUp
//                               ? getLocalValue("Key_SignUp")
//                               : getLocalValue("Key_SignIn"),
//                           style: TextStyles.txtMedium10
//                               (context).copyWith(color: clrPrimary),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 25.h,
//             ),
//             SizedBox(
//               height: 3.h,
//               width: infiniteSize,
//               child: Row(
//                 children: [
//                   Container(
//                     width: MediaQuery.of(context).size.width *
//                         getSize(roleSelectionWatch),
//                     color: clrPrimary,
//                   ),
//                   Expanded(
//                     child: Container(
//                       color: clrGrey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 22.h,
//             ),
//             Text(
//               getLocalValue("Key_SelectRole"),
//               style: TextStyles.txtMedium18
//                   (context).copyWith(color: clrWhiteBlackByTheme()),
//             ),
//             SizedBox(
//               height: 4.h,
//             ),
//             Text(
//               getContent(roleSelectionWatch),
//               style: TextStyles.txtRegular12
//                   (context).copyWith(color: clrWhiteBlackNewByTheme()),
//             ),
//             SizedBox(
//               height: 39.h,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       saveLocalData(KEY_USER_STATUS, recommender);
//                       roleSelectionWatch.updateRoleStatus(true);
//                     },
//                     child: Container(
//                       padding: EdgeInsets.only(
//                           left: 20.w, top: 31.h, right: 12.w, bottom: 15.w),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15.r),
//                         color: clrPrimaryLight.withOpacity(0.3),
//                         border: Border.all(
//                             color: roleSelectionWatch.isRoleSelected &&
//                                     roleSelectionWatch.isRecommender
//                                 ? clrPrimary
//                                 : clrPrimaryLight.withOpacity(0.2),),
//                       ),
//                       child: Column(
//                         children: [
//                           CommonImageAsset(
//                             strIcon: icRecommender,
//                           ),
//                           SizedBox(
//                             height: 12.h,
//                           ),
//                           Text(
//                             getLocalValue("Key_Recommender"),
//                             style: TextStyles.txtMedium16
//                                 (context).copyWith(color: clrWhiteBlackByTheme()),
//                           ),
//                           SizedBox(
//                             height: 15.h,
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 10.w, vertical: 4.h),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: roleSelectionWatch.isRoleSelected &&
//                                       roleSelectionWatch.isRecommender
//                                   ? clrPrimary
//                                   : clrPrimaryLight.withOpacity(0.2),
//                               border: Border.all(color: clrPrimary),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "R",
//                                 style: TextStyles.txtRegular14(context).copyWith(
//                                     color: roleSelectionWatch.isRoleSelected &&
//                                             roleSelectionWatch.isRecommender
//                                         ? clrWhite
//                                         : clrTextGreyByTheme()),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 10.w,
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       saveLocalData(KEY_USER_STATUS, trader);
//                       roleSelectionWatch.updateRoleStatus(false);
//                     },
//                     child: Container(
//                       padding: EdgeInsets.only(
//                           left: 20.w, top: 12.h, right: 12.w, bottom: 15.w),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15.r),
//                           color: clrPrimaryLight.withOpacity(0.3),
//                           border: Border.all(
//                               color: roleSelectionWatch.isRoleSelected &&
//                                       roleSelectionWatch.isRecommender == false
//                                   ? clrPrimary
//                                   : clrPrimaryLight.withOpacity(0.2))),
//                       child: Column(
//                         children: [
//                           CommonImageAsset(
//                             strIcon: icTrader,
//                           ),
//                           SizedBox(
//                             height: 12.h,
//                           ),
//                           Text(
//                             getLocalValue("Key_Trader"),
//                             style: TextStyles.txtMedium16
//                                 (context).copyWith(color: clrWhiteBlackByTheme()),
//                           ),
//                           SizedBox(
//                             height: 15.h,
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 10.w, vertical: 4.h),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(color: clrPrimary),
//                               color: roleSelectionWatch.isRoleSelected &&
//                                       roleSelectionWatch.isRecommender == false
//                                   ? clrPrimary
//                                   : clrPrimaryLight.withOpacity(0.2),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "T",
//                                 style: TextStyles.txtRegular14(context).copyWith(
//                                     color: roleSelectionWatch.isRoleSelected &&
//                                             roleSelectionWatch.isRecommender ==
//                                                 false
//                                         ? clrWhite
//                                         : clrTextGreyByTheme()),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 65.h,
//             ),
//             CommonButton(
//               label: getLocalValue("Key_Next"),
//               onTap: () {
//                 if (roleSelectionWatch.titleName == signIn) {
//                   Route route = SlideRightPageRoute(
//                       builder: (context) => SignInScreen(
//                           role: roleSelectionWatch.isRecommender
//                               ? recommender
//                               : "trader"),
//                       settings: const RouteSettings());
//                   Navigator.of(context).push(route);
//                 } else {
//                   Route route = SlideRightPageRoute(
//                       builder: (context) => SignUpScreen(
//                             isRecommender: roleSelectionWatch.isRecommender,
//                           ),
//                       settings: const RouteSettings());
//                   Navigator.of(context).push(route);
//                 }
//               },
//               isEnable: roleSelectionWatch.isValidate,
//               bgColor: clrPrimary,
//               labelColor: clrWhite,
//             ),
//             SizedBox(
//               height: 88.h,
//             ),
//             Align(
//               alignment: Alignment.center,
//               child: TextButton(
//                 onPressed: () {
//                   saveLocalData(KEY_USER_STATUS, guest);
//                   Route route = SlideRightPageRoute(
//                       builder: (context) => const DrawerMenu(),
//                       settings: const RouteSettings());
//                   Navigator.of(context).push(route);
//                 },
//                 child: Text(
//                   getLocalValue("Key_GuestUser"),
//                   style: TextStyles.txtMedium10(context).copyWith(
//                       color: clrPrimary, decoration: TextDecoration.underline),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Get Title
//   getTitle(RoleSelectionScreenController roleSelectionWatch) {
//     String title;
//     if (roleSelectionWatch.titleName == signUp) {
//       title = getLocalValue("Key_Signup");
//     } else {
//       title = getLocalValue("Key_SignIn");
//     }
//     return title;
//   }
//
//   /// Get Sub Title
//   getSubTitle(RoleSelectionScreenController roleSelectionWatch) {
//     String subTitle;
//     if (roleSelectionWatch.titleName == signUp) {
//       subTitle = "${getLocalValue("Key_HaveAnAccount")}? ";
//     } else {
//       subTitle = "${getLocalValue("Key_DontHaveAnAccount")}? ";
//     }
//     return subTitle;
//   }
//
//   ///Get Progress Color
//   getSize(RoleSelectionScreenController roleSelectionWatch) {
//     double size;
//     if (roleSelectionWatch.titleName == signUp) {
//       size = 0.2;
//     } else {
//       size = 0.4;
//     }
//     return size;
//   }
//
//   ///Get Content
//   getContent(RoleSelectionScreenController roleSelectionWatch) {
//     String content;
//     if (roleSelectionWatch.titleName == signUp) {
//       content = getLocalValue("Key_SignUpRoleContent");
//     } else {
//       content = getLocalValue("Key_SignInRoleContent");
//     }
//     return content;
//   }
// }
