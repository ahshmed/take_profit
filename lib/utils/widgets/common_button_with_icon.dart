import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme_const.dart';

class CommonButtonWithIcon extends StatelessWidget  {
  final String label;
  final String icon;
  final Function()? onTap;
  final Color bgColor;
  final Color labelColor;
  final Color? borderColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? height;
  final double? textSize;
  final double? icHeight;
  final double? icWidth;

  CommonButtonWithIcon(
      {Key? key,
        required this.label,
        required this.icon,
        required this.onTap,
        required this.bgColor,
        required this.labelColor,
        this.borderColor,
        this.iconColor,
        this.borderRadius,
        this.height,
        this.textSize,
        this.icWidth,
        this.icHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height??50.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius??80.r),
                side: BorderSide(color: borderColor ?? bgColor)),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(bgColor),
        ),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgColor, bgColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(35.r)),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: iconColor == null ? Image.asset(
                        icon,
                        height: icHeight??20.h,width: icWidth??20.w,
                      ) : Image.asset(
                        icon,
                        color: iconColor,
                        height: icHeight??20.h,width: icWidth??20.w,
                      )
                  ),
                  SizedBox(width: 5.h,),
                  Padding(
                    padding:const EdgeInsets.all(10),
                    child: VerticalDivider(
                      color: Constant.clrPrimary,
                      width: 0.w,
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: textSize??14.sp,
                              fontFamily: Constant.fontFamily,
                              color: labelColor,
                              fontWeight: Constant.fwMedium),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
