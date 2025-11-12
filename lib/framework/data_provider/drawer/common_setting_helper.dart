import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/const.dart';
import '../../../utils/theme_const.dart';
import '../../../utils/widgets/common_switch.dart';


class CommonSettingsHelper extends StatelessWidget  {
  final String title;
  final String subTitle;
  final Function(bool val) onChanged;
  bool status;

  CommonSettingsHelper(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.onChanged,
      required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getLocalValue(title),
                style: TextStyles.txtMedium14
                    (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
              ),
              SizedBox(
                height: 6.h,
              ),
              Text(
                getLocalValue(subTitle),
                style: TextStyles.txtMedium10(context).copyWith(
                  color: Constant.clrGreyNew,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        const Spacer(),
        CommonSwitch(
          onChanged: (val) {
            onChanged(val);
          },
          status: status,
        ),
      ],
    );
  }
}
