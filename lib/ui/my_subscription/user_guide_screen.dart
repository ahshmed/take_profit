// ignore_for_file: unused_local_variable
import 'dart:math' as math;
import 'dart:io';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/my_subscription/my_subscription_provider.dart';
import '../../framework/data_provider/my_subscription/user_guide_controller.dart';
import '../../framework/data_provider/notification/notification_controller.dart';
import '../../framework/data_provider/notification/notification_provider.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../home/home_screen.dart';
import '../notification/notification_screen.dart';
import '../search/search_screen.dart';

class UserGuideScreen extends ConsumerStatefulWidget {
  const UserGuideScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserGuideScreen> createState() =>
      _UserGuideScreenState();
}

class _UserGuideScreenState extends ConsumerState<UserGuideScreen>
     {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;

  ///-----Init----
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final userGuideWatch = ref.watch(userGuideProvider);
      final notificationWatch = ref.watch(notificationProvider);
      userGuideWatch.clearProviderData();
      notificationCountAPICall(notificationWatch);
    });
    loadWebViewPullToRefreshController();
  }

  loadWebViewPullToRefreshController() {
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: (Constant.clrPrimary),
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(
              url: await webViewController?.getUrl(),
            ),
          );
        }
      },
    );
  }

  ///build widget
  @override
  Widget build(BuildContext context) {
    final dashboardWatch = ref.watch(dashboardProvider);
    final darkModeWatch = ref.watch(darkProvider);
    final notificationWatch = ref.watch(notificationProvider);
    final userGuideWatch = ref.watch(userGuideProvider);
    final drawerWatch = ref.watch(drawerProvider);
    return WillPopScope(
      onWillPop: () async {
        if(await webViewController?.canGoBack() ?? false){
          webViewController?.goBack();
          return false;
        }
        dashboardWatch.updateProfile(false);
        dashboardWatch.tabBody = const HomeScreen();
        dashboardWatch.bottomTabInit();
        dashboardWatch.updateWidget();
        return false;
      },
      child: Scaffold(
        backgroundColor: Constant.clrScaffoldBGByTheme(context),
        appBar: CommonAppBar(
          isTitleCenter: false,
          title: getLocalValue("Key_UserGuide"),
          leading: GestureDetector(
            onTap: () async{
              if(await webViewController?.canGoBack() ?? false){
                webViewController?.goBack();
              } else{
                dashboardWatch.updateProfile(false);
                dashboardWatch.tabBody = const HomeScreen();
                dashboardWatch.bottomTabInit();
                dashboardWatch.updateWidget();
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(getAppLanguage() == "ar" ? math.pi : 0),
                child:Image.asset(Constant.icBackPrimary),
              ),
            ),
          ),
          appBar: AppBar(backgroundColor: Constant.clrWhiteNew, toolbarHeight: 64.h),
          action: [
            IconButton(
              onPressed: () {
                Route route = SlideRightPageRoute(
                    builder: (context) => const SearchScreen(),
                    settings: const RouteSettings());
                Navigator.of(context).push(route);
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
            IconButton(
              onPressed: () {
                Route route = SlideRightPageRoute(
                    builder: (context) => const NotificationScreen(),
                    settings: const RouteSettings());
                Navigator.of(context).push(route).then((value) {
                  if (value == true) {
                    notificationCountAPICall(notificationWatch);
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
                    style: TextStyles.txtRegular10(context).copyWith(color: Constant.clrWhite),
                  ),
                  child: Image.asset(
                    Constant.icNotificationN,
                    width: 39.81.h,
                    height: 39.81.h,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
          ],
        ),
        body: NoInternetBuilder(
          child: bodyWidget(userGuideWatch),
        ),
      ),
    );
  }

  ///body widget
  Widget bodyWidget(UserGuideController mySubscriptionWatch) {
    final drawerWatch = ref.watch(drawerProvider);
    final commonWatch = ref.watch(commonProvider);
    return NoInternetBuilder(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 80.h),
        child: Stack(
          children: <Widget>[
            InAppWebView(
              key: webViewKey,
              gestureRecognizers: Set()..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())),
              initialUrlRequest:
              URLRequest(url: WebUri(commonWatch.guideUrl)),
              initialOptions: options,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                mySubscriptionWatch.updateURL(url.toString());
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
              onLoadStop: (controller, url) async {
                showLog("Current url:-$url");
                pullToRefreshController.endRefreshing();
                mySubscriptionWatch.updateURL(url.toString());
              },
              onLoadError: (controller, url, code, message) {
                pullToRefreshController.endRefreshing();
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController.endRefreshing();
                }
                mySubscriptionWatch.updateProgressStatus(progress / 100);
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) {
                mySubscriptionWatch.updateURL(url.toString());
              },
              onConsoleMessage: (controller, consoleMessage) {
                showLog("$consoleMessage");
              },
            ),
            mySubscriptionWatch.progress < 1.0 ?
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: isDarkMode ? Constant.clrScaffoldBGDarkMode : Constant.clrWhite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonImageAsset(
                      strIcon: isDarkMode ? Constant.icLogoLight : Constant.icLogoDark,
                      width: 175.h,
                      boxFit: BoxFit.contain,
                    ),
                    50.verticalSpace,
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 20.h,
                      margin: EdgeInsets.symmetric(horizontal: 30.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.h),
                        child: LinearProgressIndicator(
                          backgroundColor: isDarkMode ? Constant.clrLightGrey : Constant.clrDarkGrey,
                          value: mySubscriptionWatch.progress,
                          valueColor: AlwaysStoppedAnimation<Color>(Constant.clrPrimary),
                        ),
                      ),
                    ),
                    24.verticalSpace,
                    Text(
                      "${(mySubscriptionWatch.progress * 100).toStringAsFixed(0)} %",
                      style: TextStyles.txtMedium20(context).copyWith(
                        color: Constant.clrWhiteBlackByTheme(context),
                      ),
                    ),
                  ],
                ),
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> notificationCountAPICall(
      NotificationController notificationWatch) async {
    if (getUserStatus() != guest) {
      if (isInternetConnectionOn) {
        await notificationWatch.notificationCountAPI(context);
      }
    }
  }
}
