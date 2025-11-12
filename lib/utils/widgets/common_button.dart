import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme_const.dart';

class CommonButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final Color bgColor;
  final Color labelColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? height;
  final double? width;
  final double? textSize;
  final bool isEnable;
  final double? padding;

  CommonButton(
      {Key? key,
      required this.label,
      required this.onTap,
      required this.bgColor,
      required this.labelColor,
      this.borderColor,
      this.borderRadius,
      this.height,
      this.width,
      this.padding,
      this.isEnable = true,
      this.textSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 49.h,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isEnable ? onTap : null,
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          padding:
              WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(0.0)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
                side: BorderSide(
                    color: !isEnable ? Constant.clrGreyNew : borderColor ?? bgColor)),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(
              !isEnable ? Constant.clrGreyNew : bgColor),
        ),
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.r)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: padding ?? 0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: textSize ?? 16.sp,
                        fontFamily: Constant.fontFamily,
                        color: labelColor,
                        fontWeight: Constant.fwRegular),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
