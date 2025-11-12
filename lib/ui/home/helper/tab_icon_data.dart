import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

import '../../../utils/const.dart';
import '../../../utils/theme_const.dart';
import '../../../utils/widgets/cache_image.dart';


class TabIconData {
  TabIconData({
    required this.imagePath,
    required this.name,
    this.index = 0,
    required this.selectedImagePath,
    this.isSelected = false,
    this.animationController,
    this.statusWiseTabs,
  });

  Widget imagePath;
  Widget selectedImagePath;
  bool isSelected;
  String name;
  int index;
  StatusWiseTabs? statusWiseTabs;

  AnimationController? animationController;

  static List<TabIconData> tabIconsListGuest = <TabIconData>[
    TabIconData(
      imagePath: Image.asset(Constant.icHome),
      selectedImagePath: Image.asset(Constant.icSelectHome),
      index: 0,
      name: "Key_Home",
      isSelected: true,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icState),
      selectedImagePath: Image.asset(Constant.icSelectState),
      index: 1,
      name: "Key_Currencies",
      isSelected: false,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icUserGuide),
      selectedImagePath: Image.asset(
        Constant.icSelectUserGuide,
      ),
      index: 2,
      name: "Key_UserGuide",
      isSelected: false,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icProfileTabIcon),
      selectedImagePath: Image.asset(Constant.icProfileTabIcon),
      index: 4,
      name: "Key_Login/SignUp",
      isSelected: false,
    ),
  ];

  // Guest tabs for US Market mode
  static List<TabIconData> tabIconsListGuestUSMarket = <TabIconData>[
    TabIconData(
      imagePath: Image.asset(Constant.icHome),
      selectedImagePath: Image.asset(Constant.icSelectHome),
      index: 0,
      name: "Key_Home",
      isSelected: true,
      statusWiseTabs: StatusWiseTabs.usMarket,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icCurrenciesN), // TODO: Add this icon
      selectedImagePath: Image.asset(Constant.icCurrenciesN), // TODO: Add this icon
      index: 1,
      name: "Key_Stock",
      isSelected: false,
      statusWiseTabs: StatusWiseTabs.stock,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icAiN), // TODO: Add this icon
      selectedImagePath: Image.asset(Constant.icAiN), // TODO: Add this icon
      index: 2,
      name: "Key_AIAssistant",
      isSelected: false,
      statusWiseTabs: StatusWiseTabs.aiAssistant,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icCoursesN), // TODO: Add this icon
      selectedImagePath: Image.asset(Constant.icCoursesN), // TODO: Add this icon
      index: 3,
      name: "Key_Courses",
      isSelected: false,
      statusWiseTabs: StatusWiseTabs.courses,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icCryptoN), // TODO: Add this icon
      selectedImagePath: Image.asset(Constant.icCryptoN), // TODO: Add this icon
      index: 4,
      name: "Key_Crypto",
      isSelected: false,
      statusWiseTabs: StatusWiseTabs.crypto,
    ),
  ];

  static List<TabIconData> tabIconsListRecommender = <TabIconData>[
    TabIconData(
      imagePath: Image.asset(Constant.icHome),
      selectedImagePath: Image.asset(Constant.icSelectHome),
      index: 0,
      name: "Key_Home",
      isSelected: true,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icState),
      selectedImagePath: Image.asset(
        Constant.icSelectState,
      ),
      index: 1,
      name: "Key_Currencies",
      isSelected: false,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icUnselectedRecommendations),
      selectedImagePath: Stack(
        children: [
          Image.asset(
            Constant.icSelectedRecommendations,
          ),
          Positioned(
            left: 0.w,
            top: 0.h,
            right: 0.w,
            bottom: 0.h,
            child: Image.asset(
              Constant.icRecommendations,
              color: Constant.clrWhite,
            ),
          ),
        ],
      ),
      index: 5,
      name: "Key_Recommendations",
      isSelected: false,
    ),
    TabIconData(
      imagePath: ClipRRect(
        borderRadius: BorderRadius.circular(35 / 2 - 35 / 18),
        child: CacheImage(
          imageURL: getUserImage(),
          isProfileImg: true,
          height: 35.h,
          width: 35.h,
        ),
      ),
      selectedImagePath: ClipRRect(
        borderRadius: BorderRadius.circular(35 / 2 - 35 / 18),
        child: CacheImage(
          imageURL: getUserImage(),
          isProfileImg: true,
          height: 35.h,
          width: 35.h,
        ),
      ),
      index: 3,
      name: "Key_Profile",
      isSelected: false,
    ),
  ];

  static List<TabIconData> tabIconsListTrader = <TabIconData>[
    TabIconData(
      imagePath: Image.asset(Constant.icHome),
      selectedImagePath: Image.asset(Constant.icSelectHome),
      index: 0,
      name: "Key_Home",
      isSelected: true,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icState),
      selectedImagePath: Image.asset(Constant.icSelectState),
      index: 1,
      name: "Key_Currencies",
      isSelected: false,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icUserGuide),
      selectedImagePath: Image.asset(
        Constant.icSelectUserGuide,
      ),
      index: 2,
      name: "Key_UserGuide",
      isSelected: false,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icUser),
      selectedImagePath: Image.asset(Constant.icSelectUser),
      index: 3,
      name: "Key_Profile",
      isSelected: false,
    ),
  ];

  // Trader tabs for US Market mode
  static List<TabIconData> tabIconsListTraderUSMarket = <TabIconData>[
    TabIconData(
      imagePath: Image.asset(Constant.icHome),
      selectedImagePath: Image.asset(Constant.icSelectHome),
      index: 0,
      name: "Key_Home",
      isSelected: true,
      statusWiseTabs: StatusWiseTabs.usMarket,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icCurrenciesN),
      selectedImagePath: Image.asset(Constant.icCurrenciesN),
      index: 1,
      name: "Key_Stock",
      isSelected: false,
      statusWiseTabs: StatusWiseTabs.stock,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icAiN),
      selectedImagePath: Image.asset(Constant.icAiN),
      index: 2,
      name: "Key_AIAssistant",
      isSelected: false,
      statusWiseTabs: StatusWiseTabs.aiAssistant,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icCoursesN),
      selectedImagePath: Image.asset(Constant.icCoursesN),
      index: 3,
      name: "Key_Courses",
      isSelected: false,
      statusWiseTabs: StatusWiseTabs.courses,
    ),
    TabIconData(
      imagePath: Image.asset(Constant.icCryptoN),
      selectedImagePath: Image.asset(Constant.icCryptoN),
      index: 4,
      name: "Key_Crypto",
      isSelected: false,
      statusWiseTabs: StatusWiseTabs.crypto,
    ),
  ];
}

// StatusWiseTabs enum for identifying different tab types
enum StatusWiseTabs {
  home,
  currencies,
  usMarket,
  stock,
  crypto,
  aiAssistant,
  courses,
  profile,
  recommendations,
  userGuide,
  loginSignup,
}