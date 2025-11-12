import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const.dart';
import '../theme_const.dart';


class DescriptionTextField extends StatelessWidget {
  BuildContext context;
  TextEditingController? myController;
  ValueChanged<String>? onChanged;
  List<TextInputFormatter>? inputFormatters;
  TextInputAction? textInputAction;
  TextInputType? textInputType;
  TextCapitalization? textCapitalization;
  String? placeHolderMessage;
  TextStyle? textStyle;
  String? errorMessage;
  String? hintText;
  bool obscureText;
  bool enable;
  FocusNode? myFocus;
  int? maxLine;
  int? maxLength;
  double? height;
  Widget? prefix;
  Widget? suffix;
  double? leftPadding;
  Color? bgColor;
  Color? borderColor;
  Function()? onEditingComplete;
  double? borderRadius;
  EdgeInsetsGeometry? contentPadding;
  EdgeInsets? scrollPadding;
  bool? paddingNeed;
  bool? marginNeed;
  bool autoFocus;
  TextAlign? textAlign;

  DescriptionTextField({
    Key? key,
    required this.context,
    required this.myController,
    this.onChanged,
    this.textInputType,
    this.textInputAction,
    this.textStyle,
    this.placeHolderMessage = "",
    this.errorMessage = "",
    this.hintText = "",
    this.textCapitalization,
    this.obscureText = false,
    this.enable = true,
    this.inputFormatters,
    this.myFocus,
    this.maxLine,
    this.height,
    this.prefix,
    this.suffix,
    this.borderRadius,
    this.leftPadding,
    this.paddingNeed = true,
    this.contentPadding,
    this.scrollPadding,
    this.marginNeed = true,
    this.bgColor,
    this.maxLength,
    this.onEditingComplete,
    this.borderColor,
    this.autoFocus = false,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            margin: marginNeed == true
                ? EdgeInsets.symmetric(vertical: 0.h, horizontal: 15.w)
                : EdgeInsets.zero,
            padding: paddingNeed == true
                ? EdgeInsets.symmetric(
                    vertical: 0.h, horizontal: leftPadding ?? 10.w)
                : EdgeInsets.zero,
            child: Column(
              children: [
                Expanded(
                  child: TextFormField(
                    minLines: null,
                    expands: true,
                    scrollPadding: scrollPadding ?? EdgeInsets.zero,
                    textAlignVertical: TextAlignVertical.top,
                    autofocus: autoFocus,
                    maxLines: null,
                    textCapitalization: textCapitalization ?? TextCapitalization.none,
                    enabled: enable,
                    controller: myController,
                    onChanged: onChanged,
                    focusNode: myFocus,
                    cursorColor: Constant.clrTextGreyByTheme(context),
                    obscureText: obscureText,
                    keyboardType: textInputType,
                    textInputAction: textInputAction,
                    maxLength: maxLength,
                    onEditingComplete: onEditingComplete,
                    style: textStyle ??
                        TextStyle(
                            fontSize: 14.sp,
                            color: Constant.clrTextByTheme(context),
                            fontWeight: Constant.fwSemiBold),
                    inputFormatters: inputFormatters,
                    textAlign: textAlign ?? TextAlign.start,
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(
                            top: (getIsIOSPlatform() == true) ? 0 : 4.0),
                        child: suffix,
                      ),
                      contentPadding: contentPadding ??
                          const EdgeInsets.only(left: 20, top: 20, right: 20),
                      labelText: placeHolderMessage,
                      alignLabelWithHint: true,
                      hintMaxLines: 1,
                      // isDense: true,

                      constraints: BoxConstraints(
                        maxHeight: height ?? ((getIsIOSPlatform() == true) ? 45 : 49),
                        minHeight: height ?? ((getIsIOSPlatform() == true) ? 45 : 49),
                      ),
                      prefixIcon: prefix,
                      hintStyle: TextStyle(
                          fontFamily: Constant.fontFamily,
                          fontSize: 14.sp,
                          color: Constant.clrHintText,
                          fontWeight: Constant.fwMedium),
                      labelStyle: TextStyle(
                          fontFamily: Constant.fontFamily,
                          fontSize: 15.sp,
                          color: Constant.clrTextGrey,
                          fontWeight: Constant.fwRegular),
                      errorStyle: TextStyle(color: Constant.clrDarkBlue),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: borderRadius == null
                            ? BorderRadius.circular(30.r)
                            : BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(
                          color: Constant.clrGrey,
                          width: 1.h,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: borderRadius == null
                            ? BorderRadius.circular(30.r)
                            : BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(color: Constant.clrGrey, width: 1.h),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: borderRadius == null
                            ? BorderRadius.circular(30.r)
                            : BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(color: Constant.clrGrey, width: 1.h),
                      ),
                      hintText: hintText,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: borderRadius == null
                            ? BorderRadius.circular(30.r)
                            : BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(color: Constant.clrGrey, width: 1.h),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: borderRadius == null
                            ? BorderRadius.circular(30.r)
                            : BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(color: Constant.clrGrey, width: 1.h),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: borderRadius == null
                            ? BorderRadius.circular(30.r)
                            : BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(color: Constant.clrGrey, width: 1.h),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        (errorMessage != null && errorMessage != "")
            ? Padding(
                padding: EdgeInsets.only(top: 6.h, bottom: 6.h, left: 20.w),
                child: Text(
                  errorMessage ?? "",
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Constant.clrDarkRed,
                      fontWeight: Constant.fwRegular),
                ),
              )
            : Container()
      ],
    );
  }
}
