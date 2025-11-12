import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../const.dart';
import '../theme_const.dart';


class CommonSearchBar extends StatelessWidget  {
  final double? height;
  final String? label;
  final bool? isHomeSearch;
  final Function()? onTap;
  final ValueChanged<String>? onChanged;
  final double? elevation;
  final double? circularValue;
  final Color? clrSplash;
  final Color? clrBG;
  final bool? isRemoveMargin;
  TextEditingController controller;
  FocusNode? focusNode;
  final double? borderRadius;
  final String? hintText;

  CommonSearchBar({
    Key? key,
    this.onTap,
    this.height,
    this.label,
    this.isHomeSearch,
    this.onChanged,
    this.elevation,
    this.circularValue,
    this.clrSplash,
    this.clrBG,
    this.isRemoveMargin,
    this.borderRadius,
    required this.controller,
    this.focusNode,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isHomeSearch ?? false
        ? InkWell(
            onTap: onTap,
            child: Container(
                height: height ?? 48.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Constant.clrGrey),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        Constant.icSearchN,
                        height: 18.h,
                        width: 18.w,
                        color: Constant.clrPrimary,
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Text(
                        label ?? "Key_SearchHere...".localized,
                        style: TextStyle(
                            fontWeight: Constant.fwRegular,
                            fontSize: 12.sp,
                            color: Constant.clrDarkBlue),
                      ),
                    ],
                  ),
                )),
          )
        : Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return Container(
              decoration: BoxDecoration(
                  color: Constant.clrCardBGByTheme(context),
                  borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
                  border: Border.all(color: Constant.clrGrey, width: 0.5.w)),
              height: height ?? 48.h,
              child: InkWell(
                splashColor: clrSplash ?? Constant.clrDarkGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(circularValue ?? 7.r),
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Center(
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: Constant.clrPrimary,
                      textAlignVertical: TextAlignVertical.center,
                      style:
                          TextStyles.txtRegular15(context).copyWith(color: Constant.clrDarkBlue),
                      textInputAction: TextInputAction.search,
                      onChanged: onChanged,
                      maxLines: 1,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(maxTextLength60),
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: InputBorder.none,
                        hintStyle:
                            TextStyles.txtRegular12(context).copyWith(color: Constant.clrGreyNew),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              top: 10.h,
                              bottom: 10.h,
                              right: 16.w,
                              left:
                                  ref.watch(drawerProvider).isEngEnable == false
                                      ? 10.w
                                      : 0),
                          child: Image.asset(
                            Constant.icSearchN,
                            height: 18.h,
                            width: 18.w,
                          ),
                        ),
                        prefixIconConstraints:
                            BoxConstraints(minHeight: 10.h, minWidth: 20.w),
                        hintText: hintText,
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
  }
}
