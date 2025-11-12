
import 'package:flutter/material.dart';

import '../theme_const.dart';
import 'common_text.dart';

class CommonTextButton extends StatelessWidget {

  final String title;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? fontSize;
  final Size? buttonSizeWH;
  final Color? clrBgShadow;
  final Color? clrFont;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextDecoration? textDecoration;
  final VoidCallback? onPressed;

  CommonTextButton({Key? key, this.onPressed, this.title="", this.fontWeight, this.fontStyle, this.fontSize, this.buttonSizeWH, this.clrFont, this.clrBgShadow,
    this.maxLines, this.textAlign, this.textDecoration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: clrBgShadow, fixedSize: buttonSizeWH
      ),
      onPressed: onPressed,
      child: CommonText(
        title: title,
        maxLines: maxLines,
        textAlign: textAlign,
        fontWeight: Constant.fwBold,
        fontSize: fontSize,
        clrFont: clrFont,
        fontStyle: fontStyle,
        textDecoration: textDecoration,
      ),
    );
  }

}
