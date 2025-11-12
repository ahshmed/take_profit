import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/const.dart';
import '../../../utils/sliderightroute.dart';
import '../../../utils/theme_const.dart';
import '../../../utils/widgets/common_button.dart';
import '../../../utils/widgets/common_image_asset.dart';
import '../sign_in_screen.dart';
import '../sign_up_screen.dart';


class GetStartedScreen extends StatelessWidget  {
  final Function(bool val)? callBack;
  final bool canPop;

  GetStartedScreen({Key? key, this.callBack, this.canPop = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        callBack != null ? callBack!(true) : null;
        showLog("Can pop $canPop");
        return canPop;
      },
      child: Padding(
        padding: EdgeInsets.all(10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: getAppLanguage() == 'en'
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(10.h),
                child: InkWell(
                  onTap: () {
                    // if (canPop) {
                    Navigator.of(context).pop();
                    // callBack!(true);
                    callBack != null ? callBack!(true) : null;
                    // }
                  },
                  child: CommonImageAsset(
                    strIcon: Constant.icClose,
                    clrImg: Constant.clrWhiteBlackByTheme(context),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 36.h,
            ),
            Align(
              alignment: Alignment.center,
              child: CommonImageAsset(
                strIcon: Constant.icLogoDark,
              ),
            ),
            SizedBox(
              height: 59.h,
            ),
            Text(
              getLocalValue("Key_TakeProftTradingAndRecommending"),
              style: TextStyles.txtSemiBold28(context).copyWith(color: Constant.clrDarkBlue),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 38.h,
            ),
            CommonButton(
              label: getLocalValue("Key_SignIn"),
              onTap: () {
                Navigator.of(context).pop();
                Route route = SlideRightPageRoute(
                    builder: (context) => SignInScreen(trader,"",),
                    settings: const RouteSettings());
                Navigator.of(context).pushReplacement(route);
              },
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              textSize: 16.sp,
            ),
            SizedBox(
              height: 25.h,
            ),
            CommonButton(
              label: getLocalValue("Key_IDontHaveAnAccount"),
              onTap: () {
                Navigator.of(context).pop();
                Route route = SlideRightPageRoute(
                    builder: (context) =>
                        const SignUpScreen(isRecommender: false),
                    settings: const RouteSettings());
                Navigator.of(context).pushReplacement(route);
              },
              bgColor: Constant.clrWhite,
              labelColor: Constant.clrPrimary,
              borderColor: Constant.clrPrimary,
              textSize: 16.sp,
            ),
            SizedBox(
              height: 20.h,
            ),
          ],
        ),
      ),
    );
  }
}
