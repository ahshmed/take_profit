import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme_const.dart';


// ignore: must_be_immutable
class CacheImage extends StatelessWidget {
  final String imageURL;
  final double height;
  final double? topLeftRadius;
  final double? topRightRadius;
  final double? bottomLeftRadius;
  final double? bottomRightRadius;
  final double width;
  final bool? setPlaceHolder;
  final bool isProfileImg;
  final String? placeholderImage;
  final BoxFit? contentMode;
  final Color? bgColor;
  final Color? placeholderColor;

  CacheImage(
      {Key? key,
      required this.imageURL,
      required this.height,
      required this.width,
      this.setPlaceHolder = true,
      this.isProfileImg = false,
      this.placeholderImage,
      this.contentMode,
      this.bottomLeftRadius,
      this.bottomRightRadius,
      this.topLeftRadius,
      this.topRightRadius,
      this.bgColor, this.placeholderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (imageURL == "")
        ? placeHolderWidget()
        : CachedNetworkImage(
            imageUrl: imageURL,
            imageBuilder: (context, imageProvider) => Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topLeftRadius ?? 0.0),
                  topRight: Radius.circular(topRightRadius ?? 0.0),
                  bottomRight: Radius.circular(bottomRightRadius ?? 0.0),
                  bottomLeft: Radius.circular(bottomLeftRadius ?? 0.0),
                ),
                image: DecorationImage(
                  image: imageProvider,
                  fit: contentMode ?? BoxFit.fill,
                  // colorFilter:ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                ),
              ),
            ),
            // progressIndicatorBuilder: (BuildContext context, url,__){
            //   return placeHolderWidget();
            // },
            placeholder: (context, url) {
              return placeHolderWidget();
            },
            errorWidget: (context, url, error) => placeHolderWidget(),
          );
  }

  Widget placeHolderWidget() {

    return Container(
      height: height,
      width: width,
      color: bgColor, // Use bgColor for the container background
      child: (isProfileImg == true)
          ? SvgPicture.asset(
        Constant.icProfileSvg,
        height: height,
        width: width,
        // Use colorFilter only if placeholderColor is provided
        colorFilter: placeholderColor != null
            ? ColorFilter.mode(placeholderColor!, BlendMode.srcIn)
            : null,
      )
          : Image.asset(
        placeholderImage ?? Constant.icLogoDark,
        height: height,
        width: width,
        // Use color for Image.asset (not deprecated for this widget)
        color: placeholderColor,
      ),
    );
  }
}
