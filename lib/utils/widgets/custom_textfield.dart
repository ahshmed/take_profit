import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import '../const.dart';
import '../theme_const.dart';
import '../extension/string_extension.dart';

class CustomTextField extends StatefulWidget {
  final BuildContext context;
  final TextEditingController? myController;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final TextCapitalization? textCapitalization;
  final String? placeHolderMessage;
  final TextStyle? textStyle;
  final String? errorMessage;
  final String? hintText;
  final bool obscureText;
  final bool enable;
  final FocusNode? myFocus;
  final int? maxLine;
  final int? maxLength;
  final double? height;
  final Widget? prefix;
  final Widget? suffix;
  final double? leftPadding;
  final Color? bgColor;
  final Color? borderColor;
  final Function()? onEditingComplete;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsets? scrollPadding;
  final bool? paddingNeed;
  final bool? marginNeed;
  final bool autoFocus;
  final TextAlign? textAlign;
  final bool? isEmail;
  final Function(String?)? onError;
  final bool isPassword;

  CustomTextField({
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
    this.isEmail = false,
    this.onError,
    this.isPassword = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _hasEmailError = false;

  String? _getEmailValidationError(String value) {
    if (value.isEmpty) {
      return "Key_PleaseEnterEmailAddress".tr();
    } else if (!value.isEmailValid()) {
      return "Key_EmailIsInvalid".tr();
    }
    return null;
  }

  void _validateInput(String value) {
    if (widget.isEmail == true) {
      String? error = _getEmailValidationError(value);
      setState(() {
        _hasEmailError = error != null && value.isNotEmpty;
      });
      if (widget.onError != null) {
        widget.onError!(error);
      }
    }
  }

  bool _isIOSPlatform() {
    return Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = context.locale.languageCode == 'ar';
    final String currentLanguage = getAppLanguage();
    final String hintFontFamily = currentLanguage == 'ar' ? 'Almarai-Regular' : 'Gilroy-Regular';
    final Color textColor = const Color(0xFF757575);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height ?? (_isIOSPlatform() ? 45 : 49),
          margin: widget.marginNeed == true
              ? EdgeInsets.symmetric(vertical: 0.h, horizontal: 15.w)
              : EdgeInsets.zero,
          padding: widget.paddingNeed == true
              ? EdgeInsets.symmetric(
              vertical: 0.h, horizontal: widget.leftPadding ?? 10.w)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.bgColor ?? Constant.clrScaffoldBGDarkMode,
            borderRadius: widget.borderRadius == null
                ? BorderRadius.circular(30.r)
                : BorderRadius.circular(widget.borderRadius!),
            border: Border.all(color: widget.borderColor ?? Constant.clrGrey, width: 1.h),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // FIXED: Prefix widget - always visible and properly aligned
              if (widget.prefix != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 8.w, // Space between icon and text
                  ),
                  child: widget.prefix!,
                ),

              // Text field
              Expanded(
                child: TextFormField(
                  scrollPadding: widget.scrollPadding ?? EdgeInsets.zero,
                  textAlignVertical: TextAlignVertical.center,
                  autofocus: widget.autoFocus,
                  maxLines: widget.maxLine ?? 1,
                  textCapitalization: widget.isEmail == true
                      ? TextCapitalization.none
                      : (widget.textCapitalization ?? TextCapitalization.none),
                  enabled: widget.enable,
                  controller: widget.myController,
                  onChanged: (value) {
                    _validateInput(value);
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  },
                  focusNode: widget.myFocus,
                  cursorColor: Constant.clrTextGreyByTheme(context),
                  obscureText: widget.isPassword ? _obscureText : widget.obscureText,
                  keyboardType: widget.isEmail == true ? TextInputType.emailAddress : widget.textInputType,
                  textInputAction: widget.textInputAction,
                  maxLength: widget.maxLength,
                  onEditingComplete: widget.onEditingComplete,
                  style: widget.textStyle ??
                      TextStyle(
                        color: textColor,
                        fontSize: 14.sp,
                        fontFamily: Constant.fontFamily
                      ),
                  inputFormatters: widget.inputFormatters,
                  textAlign: widget.textAlign ?? (isRtl ? TextAlign.right : TextAlign.left),
                  decoration: InputDecoration(
                    // FIXED: Removed prefix from InputDecoration since we're handling it in Row
                    // Show default password toggle for password fields; otherwise honor provided suffix
                    suffixIcon: widget.isPassword ? _buildPasswordSuffixIcon() : widget.suffix,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    // FIXED: Adjusted contentPadding to account for prefix in Row
                    contentPadding: widget.contentPadding ?? EdgeInsets.only(
                      left: 0, // No left padding since prefix is in Row
                      right: 12.w,
                      top: 14.h,
                      bottom: 14.h,
                    ),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: textColor,
                      fontSize: 12.sp,
                      fontFamily: hintFontFamily,
                      fontWeight: Constant.fwRegular
                    ),
                    counterText: "",
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    isDense: true, // FIXED: Helps with vertical alignment
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) ...[
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Text(
              widget.errorMessage!.tr(),
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
                fontFamily: currentLanguage == 'ar' ? 'Almarai-Regular' : 'Gilroy-Regular',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildPasswordSuffixIcon() {
    return IconButton(
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
      icon: Image.asset(
        Constant.icEyeIcon,
        width: 22.sp,
        height: 22.sp,
        color: const Color(0xFF757575),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
      splashRadius: 20.r,
    );
  }
}