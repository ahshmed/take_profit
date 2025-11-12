import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/theme_const.dart';
import '../../../utils/widgets/common_image_asset.dart';


class CommonTitle extends StatelessWidget  {
  final String icon;
  final String title;
  bool? spaceBeforeTitle;

  CommonTitle({super.key, required this.icon, required this.title, this.spaceBeforeTitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon != ""
            ? CommonImageAsset(
                strIcon: icon,
                height: 24.h,
                width: 24.h, clrImg:Constant.clrWhiteBlackByTheme(context)
              )
            : const SizedBox(),
         SizedBox(
          width: spaceBeforeTitle == false ? 0.w : 10.w,
        ),
        Text(
          title,
          style: TextStyles.txtMedium12(context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
        )
      ],
    );
  }
}
