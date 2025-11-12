import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme_const.dart';

class CommonCardRippleEffect extends StatelessWidget {

  final Widget? child;
  final GestureTapCallback? onTap;
  final double? circularValue;
  final double? elevation;
  final Color? clrSplash;
  final Color? clrBG;

  CommonCardRippleEffect({Key? key, this.child, this.onTap, this.circularValue, this.elevation, this.clrSplash, this.clrBG}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(

      elevation: elevation??5,
      shadowColor: Constant.clrDarkBlue.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(circularValue??7.w)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(circularValue??7.w),
        child: Material(
          color: clrBG??Constant.clrWhite,
          child: InkWell(
            splashColor: clrSplash??Constant.clrDarkGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(circularValue??7.w),
            onTap: onTap,
            child: Container(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
