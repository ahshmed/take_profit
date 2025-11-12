// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonSVG extends StatelessWidget {
  final String strIcon;
  final ColorFilter? colorFilter;
  final Color? svgColor;
  final double? height;
  final double? width;
  final BoxFit? boxFit;

  const CommonSVG(
      {Key? key,
      required this.strIcon,
      this.svgColor,
      this.height,
      this.width,
      this.boxFit,
      this.colorFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      strIcon,
      // colocrFilter: colorFilter,
      color: svgColor,
      height: height,
      width: width,
      fit: boxFit ?? BoxFit.contain,
    );
  }
}
