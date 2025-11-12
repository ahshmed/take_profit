import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/payment/payment_provider.dart';
import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../auth/helper/success_screen.dart';


class PaymentScreen extends ConsumerStatefulWidget {
  // final ScreenName? fromScreen;
  final String? paymentUrl;
  final String paymentAmount;
  final ScreenName fromScreen;
  final String? packageId;
  final String? orderId;

  const PaymentScreen(
      {Key? key,
      required this.fromScreen,
      this.paymentUrl,
      required this.paymentAmount,
        this.packageId,
        this.orderId
      })
      : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>  {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final paymentWatch = ref.watch(paymentProvider);
      paymentWatch.clearProviderData();
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

  @override
  Widget build(BuildContext context) {
    final paymentWatch = ref.watch(paymentProvider);
    return WillPopScope(
      onWillPop: () async {
        paymentWatch.updateIsLoading(false);
        // Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Constant.clrWhiteNew,
        appBar: CommonAppBar(
          appBar: AppBar(),
          isTitleCenter: false,
          onPress: () {
            paymentWatch.updateIsLoading(false);
            Navigator.pop(context);
          },
          title: "Key_Payment".localized,
          subTitle: "Pay: ${widget.paymentAmount}",
        ),

        body: NoInternetBuilder(
          child: Stack(
            children: <Widget>[
              InAppWebView(
                key: webViewKey,
                initialUrlRequest:
                    URLRequest(url: WebUri(widget.paymentUrl.toString())),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  paymentWatch.updateURL(url.toString());
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
                  paymentWatch.updateURL(url.toString());

                  if (paymentWatch.urlPass != "") {
                    showLog('paymentStatus ==========Normal');
                    if (paymentWatch.urlPass
                        .contains("/api/customer/payment_success")) {
                      showLog('paymentStatus success');
                      if(widget.packageId == null) {
                        /*trackEvent("af_purchase", {
                          "user_id": getUserEntityId(),
                          "af_content_id": widget.orderId,
                          "af_revenue": widget.paymentAmount,
                          "af_content_type": "analysis",
                        });*/
                      } else {
                      /*  trackEvent("af_purchase", {
                          "user_id": getUserEntityId(),
                          "af_content_id": widget.packageId,
                          "af_revenue": widget.paymentAmount,
                          "af_content_type": "package",
                        });*/
                      }
                      Route route = SlideRightPageRoute(
                          builder: (context) => SuccessScreen(
                                content: "Key_PaymentSuccessfulNote",
                                fromScreen: widget.fromScreen,
                                userID: '',
                              ),
                          settings: const RouteSettings());
                      Navigator.of(context).pushReplacement(route);
                    } else if (paymentWatch.urlPass
                        .contains("api/customer/payment_error")) {
                      showCommonSuccessForSVGDialog(
                          context,
                          Constant.icPaymentFailed,
                          "Key_PurchasedFailed".localized,
                          "Key_Purchasedfailedpleasetryagain".localized, () {
                        Navigator.pop(context, true);
                      });
                    }
                  }
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  paymentWatch.updateProgressStatus(progress / 100);
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  paymentWatch.updateURL(url.toString());
                },
                onConsoleMessage: (controller, consoleMessage) {
                  showLog("$consoleMessage");
                },
              ),
              paymentWatch.progress < 1.0 ?
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
                            value: paymentWatch.progress,
                            valueColor: AlwaysStoppedAnimation<Color>(Constant.clrPrimary),
                          ),
                        ),
                      ),
                      24.verticalSpace,
                      Text(
                        "${(paymentWatch.progress * 100).toStringAsFixed(0)} %",
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
        // bottomNavigationBar: bottomWidget(),
      ),
    );
  }

  ///bottom widget
// Widget bottomWidget() {
//   return Padding(
//     padding: EdgeInsets.only(
//         left: 20.w, right: 20.w, bottom: getIsIOSPlatform() ? 20.h : 10.h),
//     child: CommonButton(
//       label: getLocalValue("Key_ProceedToPay"),
//       textSize: 16.sp,
//       onTap: () {
//         Route route = SlideRightPageRoute(
//             builder: (context) => SuccessScreen(
//               content: "Key_PaymentSuccessfulNote".localized,
//               fromScreen: ScreenName.FromPaymentScreen, userID: '',
//             ),
//             settings: const RouteSettings());
//         Navigator.of(context).pushReplacement(route);
//       },
//       // isEnable: requestWatch.isValidaAllField,
//       height: 50.h,
//       bgColor: clrPrimary,
//       labelColor: clrWhite,
//       borderColor: clrPrimary,
//     ),
//   );
// }
}
