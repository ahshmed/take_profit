// ignore_for_file: unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../framework/data_provider/drawer/cms_screen_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/commonappbar.dart';

class CmsScreen extends ConsumerStatefulWidget {
  // final CMSType cmsType;
  final bool isFromDrawer;

  // final String url;
  // final String title;

  const CmsScreen({
    Key? key,
    // required this.cmsType,
    this.isFromDrawer = false,
    // this.url = "",
    // this.title = ""
  }) : super(key: key);

  @override
  _CmsScreenState createState() => _CmsScreenState();
}

class _CmsScreenState extends ConsumerState<CmsScreen>  {
  ///-----Init----
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final cmsWatch = ref.watch(cmsScreenProvider);
      if (isInternetConnectionOn) {
        await cmsWatch.cmsPageAPI(context,
            widget.isFromDrawer ? 'terms_services' : 'terms_conditions');
      }
    });
    super.initState();
  }

  ///----Dispose----
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  ///---main build---
  @override
  Widget build(BuildContext context) {
    final darkModeWatch = ref.watch(darkProvider);
    final cmsWatch = ref.watch(cmsScreenProvider);
    final drawerWatch = ref.watch(drawerProvider);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: Constant.clrDarkByScaffoldTheme(context),
        appBar: CommonAppBar(
          appBar: AppBar(
            backgroundColor:Constant.clrHomeScreenByTheme(context) ,
          ),
          title: cmsWatch.cmsResponseModel?.data?.pageName ?? "",
          isDrawer: widget.isFromDrawer,
        ),
        body: NoInternetBuilder(child: bodyWidget(cmsWatch)),
      ),
    );
  }

  Widget bodyWidget(CMSScreenController cmsWatch) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Html(
                    data: cmsWatch.cmsResponseModel?.data?.content ?? "",
                    // style: {"body": Style(padding: EdgeInsets.zero, margin: EdgeInsets.symmetric(horizontal: 16.w,))},
                    style: {"body": Style(padding: HtmlPaddings.zero)},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///----body Widget---
// Widget bodyWidget(BuildContext context, CMSScreenController cmsWatch) {
//   String url = "";
//   switch (widget.cmsType) {
//     case CMSType.TermsOfServices:
//       url = "https://www.google.co.in/";
//       break;
//
//     case CMSType.AboutUs:
//       url = "https://www.google.co.in/";
//       break;
//
//     case CMSType.None:
//       url = "https://www.google.co.in/";
//       break;
//     case CMSType.PrivacyPolicy:
//       url = "https://www.google.co.in/";
//       break;
//     case CMSType.FAQ:
//       url = "https://www.google.co.in/";
//       break;
//   }
//
//   showLog("Web initial url - $url");
//
//   return (url == "")
//       ? Container()
//       : WebView(
//           initialUrl: url,
//           javascriptMode: JavascriptMode.unrestricted,
//           gestureRecognizers: Set()
//             ..add(Factory<VerticalDragGestureRecognizer>(
//                 () => VerticalDragGestureRecognizer())),
//           onPageFinished: (url) {
//             showLog("On Page Finished - $url");
           }
//           onPageStarted: (url) {
//             showLog("On Page Started - $url");
//           },
//           onWebResourceError: (error) {
//             showLog(
//                 "On Web Resource Error - ${error.errorCode} - ${error.description}");
//           },
//         );
// }

  ///----get screen title----
// String getScreenTitle() {
//   String screenTitle = "";
//   switch (widget.cmsType) {
//     case CMSType.TermsOfServices:
//       screenTitle = "Key_TermsOfServices".tr();
//       break;
//     case CMSType.AboutUs:
//       screenTitle = "Key_AboutUs".tr();
//       break;
//     case CMSType.None:
//       // TODO: Handle this case.
//       break;
//     case CMSType.PrivacyPolicy:
//       // TODO: Handle this case.
//       break;
//     case CMSType.FAQ:
//       // TODO: Handle this case.
//       break;
//   }
//   return screenTitle;
// }

