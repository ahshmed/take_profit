import 'package:flutter/material.dart';

class CommonImageAsset extends StatelessWidget {

  final String strIcon;
  final Color? clrImg;
  final double? height;
  final double? width;
  final BoxFit? boxFit;

  CommonImageAsset({Key? key, this.strIcon="", this.clrImg, this.height, this.width, this.boxFit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      strIcon,
      color: clrImg,
      height: height,
      width: width,
      fit: boxFit,
    );
  }
}