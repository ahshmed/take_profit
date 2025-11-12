import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'on_boarding_screen_controller.dart';

///OnBoarding Screen Provider
final onBoardingScreenProvider =
    ChangeNotifierProvider((ref) => OnBoardingScreenController());
