import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/data_provider/drawer/settings_screen_controller.dart';
import 'package:take_profit/framework/data_provider/drawer/supports_screen_controller.dart';

import 'cms_screen_controller.dart';
import 'drawer_controller.dart';
import 'my_revenue_controller.dart';

final drawerProvider =
    ChangeNotifierProvider.autoDispose((ref) => CustomDrawerController());

///Setting screen provider
final settingsScreenProvider =
    ChangeNotifierProvider.autoDispose((ref) => SettingsScreenController());

///Cms screen provider
final cmsScreenProvider =
    ChangeNotifierProvider.autoDispose((ref) => CMSScreenController());

///Supports screen provider
final supportsScreenProvider =
    ChangeNotifierProvider.autoDispose((ref) => SupportsScreenController());

///My Revenue screen provider
final myRevenueScreenProvider =
    ChangeNotifierProvider.autoDispose((ref) => MyRevenueController());
