
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/ui/home/helper/tab_icon_data.dart';

import '../../../utils/const.dart';


class DashboardScreenController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Widget? tabBody;
  List<TabIconData> tabIconsList = [];

  void bottomTabInit() {
    if (getUserStatus() == trader) {
      tabIconsList = TabIconData.tabIconsListTrader;
    } else if (getUserStatus() == recommender) {
      tabIconsList = TabIconData.tabIconsListRecommender;
    } else if (getUserStatus() == guest) {
      tabIconsList = TabIconData.tabIconsListGuest;
    }
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  void updateHome(bool val) {
    notifyListeners();
  }

  void updateProfile(bool val) {
    notifyListeners();
  }

  void clearProvider() {
    _selectedIndex = 0;
    notifyListeners();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
