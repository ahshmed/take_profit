import 'package:flutter/material.dart';

import '../../utils/theme_const.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      body: Center(
        child: Text(
          'Coming Soon',
          style: TextStyles.txtHeader25(context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
        ),
      ),
    );
  }
}
