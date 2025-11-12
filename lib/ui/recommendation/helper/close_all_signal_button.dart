import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../../utils/const.dart';
import '../../../utils/theme_const.dart';
import '../../../utils/widgets/common_text.dart';


class CloseAllSignalButton extends ConsumerWidget {
  final GestureTapCallback? onTap;

  const CloseAllSignalButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30.h,
        width: double.maxFinite,
        padding: EdgeInsets.only(
            left: (getAppLanguage() != 'ar') ? 10.w : 5.w,
            right: (getAppLanguage() == 'ar') ? 10.w : 5.w),
        margin: EdgeInsets.only(
            bottom: 15.h,
            left: MediaQuery.of(context).size.width * 0.5,
            top: 5.h),
        decoration: BoxDecoration(
          color: Constant.clrRed,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            CommonText(
              title: 'Key_ClosedAllSignals'.localized,
              fontSize: 12.sp,
              clrFont: Constant.clrWhite,
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: Constant.clrWhite,
            ),
          ],
        ),
      ),
    );
  }
}
