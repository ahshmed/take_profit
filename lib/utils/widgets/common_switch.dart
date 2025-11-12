import 'package:flutter/material.dart';

import '../theme_const.dart';


class CommonSwitch extends StatelessWidget {
  final Function(bool val) onChanged;
  bool status;

  CommonSwitch({Key? key, required this.onChanged, required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      onChanged: (val){
        onChanged(val);
      },
      value: status,
      activeColor: Constant.clrPrimary,
      activeTrackColor: Constant.clrPrimary.withOpacity(0.2),
      inactiveThumbColor: Constant.clrSwithcInActive,
      inactiveTrackColor: Constant.clrGreyNew,
    );
  }
}
