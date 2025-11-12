import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import 'package:take_profit/utils/theme_const.dart';

import 'const.dart';

class NoInternetBuilder extends StatelessWidget {
  final Widget child;
  final bool showInternetWidget;

  NoInternetBuilder({
    Key? key,
    required this.child,
    this.showInternetWidget = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
        debounceDuration: Duration.zero,
        connectivityBuilder: (
            BuildContext context,
            List<ConnectivityResult> connectivityResults, // Changed parameter type
            Widget child,
            ) {
          // Check if any connectivity result indicates no internet
          final bool isConnected = connectivityResults.isNotEmpty &&
              connectivityResults.any((result) => result != ConnectivityResult.none);

          isInternetConnectionOn = isConnected;

          if (!isConnected) {
            showLog("NO INTERNET AVAILABLE ");
            if (!showInternetWidget) {
              return child;
            } else {
              return noInterNetWidget(context);
            }
          }
          //showLog("INTERNET IS AVAILABLE ");
          return child;
        },
        child: child);
  }

  Widget noInterNetWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// no internet image
            SvgPicture.asset(
              Constant.icNoInternet,
              height: 130.h,
              width: 130.h,
            ),
            SizedBox(
              height: 30.h,
            ),

            /// no internet text
            Text(
              "Key_ConnectionLost".localized,
              style: TextStyle(
                  fontSize: 20.sp,
                  color: Constant.clrTextByTheme(context),
                  fontWeight: Constant.fwMedium),
            ),
            SizedBox(
              height: 11.h,
            ),

            /// no internet message
            Center(
              child: Text(
                "Key_PleaseCheckYourConnectedToTheInternet".localized,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16.sp,
                    color: Constant.clrTextGrey,
                    fontWeight: Constant.fwRegular),
              ),
            ),
          ],
        ),
      ),
    );
  }
}