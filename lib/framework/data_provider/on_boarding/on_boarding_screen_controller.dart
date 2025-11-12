import 'package:flutter/material.dart';
import '../../../utils/theme_const.dart';

class OnBoardingScreenController extends ChangeNotifier {
  int activeIndex = 0;

  List<String> imageList = [
    Constant.icIntroSlider1,
    Constant.icIntroSlider2,
    Constant.icIntroSlider3
  ];

  void updateActiveIndex(int index) {
    activeIndex = index;
    notifyListeners();
  }
}
