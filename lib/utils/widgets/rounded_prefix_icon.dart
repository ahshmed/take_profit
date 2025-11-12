import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme_const.dart';

/// Reusable rounded prefix icon used inside text fields.
///
/// Usage: RoundedPrefixIcon(iconPath: Constant.icProfile, size: 20, radius: 15)
class RoundedPrefixIcon extends StatelessWidget {
  final String iconPath;
  final double size; // icon size (logical, will use .h)
  final double radius; // border radius (logical, will use .r)
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? borderColor;

  const RoundedPrefixIcon({
    Key? key,
    required this.iconPath,
    this.size = 20,
    this.radius = 15,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Constant.clrDarkByScaffoldTheme(context);
    final borderCol = borderColor ?? Constant.clrFieldBorderByTheme(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2).w,
      child: Container(
        width: (size * 2).w, // keep container slightly larger than icon
        height: (size * 2).h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius.r),
          border: Border.all(color: borderCol, width: 1.h),
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: size.h,
            height: size.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

