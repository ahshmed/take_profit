import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/framework/data_provider/home/home_provider.dart';
import 'package:take_profit/framework/data_provider/select_market/market_providers.dart';
import 'package:take_profit/ui/ai_assistant/ai_assistant_screen.dart';
import 'package:take_profit/ui/courses/courses_screen.dart';
import 'package:take_profit/ui/home/widgets/custom_bottom_nav_bar.dart';
import 'package:take_profit/ui/home/widgets/recommender_bottom_nav_bar.dart';
import 'package:take_profit/ui/profile/profile_screen.dart';
import 'package:take_profit/ui/recommendation/my_recommendation_screen.dart';
import 'package:take_profit/ui/us_market/us_market_screen.dart';
import 'package:take_profit/utils/theme_const.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:take_profit/ui/stock/stock_screen.dart';
import '../../utils/const.dart';
import '../currencies/currencies_screen.dart';
import 'home_screen.dart';

/// Main Dashboard Screen that displays different bottom navigation bars
/// based on user role (Guest/Trader vs Recommender) and selected market
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _previousMarket;

  @override
  void initState() {
    super.initState();
    _previousMarket = getSelectedMarket();

    // Initialize to home tab
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider).updateSelectedIndex(0);
    });
  }

  void _onItemTapped(int index) {
    final isRecommender = getUserStatus() == recommender;
    final String? selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    // Check if user tapped on market-switching tab (index 4 for guest/trader)
    if (!isRecommender && index == 4) {
      // User tapped on the last tab which switches between markets
      if (isUSMarket) {
        // Currently in US Market mode, switch to Crypto
        setSelectedMarket('crypto_signals');
        ref.read(selectMarketProvider.notifier).selectMarketById('crypto_signals');
      } else {
        // Currently in Crypto mode, switch to US Market
        setSelectedMarket('us_market');
        ref.read(selectMarketProvider.notifier).selectMarketById('us_market');
      }
      // Reset to home tab (index 0) after market switch
      ref.read(dashboardProvider).updateSelectedIndex(0);
      _previousMarket = isUSMarket ? 'crypto_signals' : 'us_market';
    } else {
      // Normal tab selection
      ref.read(dashboardProvider).updateSelectedIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardWatch = ref.watch(dashboardProvider);
    final marketState = ref.watch(selectMarketProvider);
    final isRecommender = getUserStatus() == recommender;

    // Check selected market
    final String? selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    // CRITICAL FIX: Detect market change and reset to home tab
    if (_previousMarket != null && _previousMarket != selectedMarket) {
      // Market has changed - reset to home (index 0)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(dashboardProvider).updateSelectedIndex(0);
      });
      _previousMarket = selectedMarket;
    }

    // Navigation items for Guest and Trader (5 tabs - dynamic based on market)
    final List<BottomNavItem> guestTraderNavItems = isUSMarket
        ? [
      // US Market Mode: Home (US Market), Stock, AI Assistant, Courses, Crypto
      // CRITICAL FIX: US Market screen with appbarRequired=false for proper simple app bar
      BottomNavItem(
        iconPath: Constant.icUsMarketN,
        label: getLocalValue("Key_Us_Market"),
        screen: const UsMarketDetailScreen(
          recommenderID: '',
          appbarRequired: false,  // Shows back button + "US Market" title
        ),
      ),
      BottomNavItem(
        iconPath: Constant.icCurrenciesN,
        label: getLocalValue("Key_Stock"),  // Changed from "Currencies" to "Stock"
        screen: const StockScreen(),
      ),
      BottomNavItem(
        iconPath: Constant.icAiN,
        label: getLocalValue("Key_Ai_Assistant"),
        screen: const AiAssistantScreen(),
      ),
      BottomNavItem(
        iconPath: Constant.icCoursesN,
        label: getLocalValue("Key_Courses"),
        screen: const CoursesScreen(),
      ),
      BottomNavItem(
        iconPath: Constant.icCryptoN,
        label: getLocalValue("Key_Crypto"),  // Changed from "US Market" to "Crypto"
        screen: const HomeScreen(), // Crypto home
      ),
    ]
        : [
      // Crypto Mode: Home (Crypto), Currencies, AI Assistant, Courses, US Market
      BottomNavItem(
        iconPath: Constant.icHomeN,
        label: getLocalValue("Key_Home"),
        screen: const HomeScreen(),
      ),
      BottomNavItem(
        iconPath: Constant.icCurrenciesN,
        label: getLocalValue("Key_Currencies"),  // "Currencies" in crypto mode
        screen: const CurrenciesScreen(isDrawer: true),
      ),
      BottomNavItem(
        iconPath: Constant.icAiN,
        label: getLocalValue("Key_Ai_Assistant"),
        screen: const AiAssistantScreen(),
      ),
      BottomNavItem(
        iconPath: Constant.icCoursesN,
        label: getLocalValue("Key_Courses"),
        screen: const CoursesScreen(),
      ),
      BottomNavItem(
        iconPath: Constant.icUsMarketN,
        label: getLocalValue("Key_Us_Market"),
        screen: const UsMarketDetailScreen(
          recommenderID: '',
          appbarRequired: true,  // Shows full header with profile/search/notifications
        ),
      ),
    ];

    // Navigation items for Recommender (4 tabs + center button with new styled design)
    final List<BottomNavItem> recommenderNavItems = [
      BottomNavItem(
        iconPath: Constant.icHomeN,
        label: getLocalValue("Key_Home"),
        screen: const HomeScreen(),
      ),
      BottomNavItem(
        iconPath: Constant.icCurrenciesN,
        label: getLocalValue("Key_Currencies"),
        screen: const CurrenciesScreen(isDrawer: true),
      ),
      BottomNavItem(
        iconPath: Constant.icRecommendations,
        label: getLocalValue("Key_Recommendations"),
        screen: const MyRecommendationSignalScreen(),
      ),
      BottomNavItem(
        iconPath: Constant.icProfile,
        label: getLocalValue("Key_Profile"),
        screen: const ProfileScreen(),
      ),
    ];

    // Select appropriate navigation items based on user type
    final navItems = isRecommender ? recommenderNavItems : guestTraderNavItems;

    // CRITICAL FIX: Ensure selected index doesn't exceed available tabs
    final safeIndex = dashboardWatch.selectedIndex >= navItems.length
        ? 0
        : dashboardWatch.selectedIndex;

    return Scaffold(
      // Scaffold background transparent
      backgroundColor: Constant.clrTransparent,
      // This is IMPORTANT - allows body to extend behind navigation bar
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: 50.w,
        height: 50.w,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: _openWhatsapp,
            backgroundColor: Constant.clrWhatsapp,
            child: Image.asset(Constant.icWhatsappFab),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          // CRITICAL FIX: Include market in key to force rebuild when market changes
          key: ValueKey('$selectedMarket-$safeIndex'),
          child: navItems[safeIndex].screen,
        ),
      ),
      // Conditionally render navigation bar based on user type
      // Guest/Trader: Use CustomBottomNavBar (5 tabs with animated indicator)
      // Recommender: Use RecommenderBottomNavBar (4 tabs + center floating button)
      bottomNavigationBar: isRecommender
          ? RecommenderBottomNavBar(
        items: recommenderNavItems,
        onTabSelected: _onItemTapped,
      )
          : CustomBottomNavBar(
        items: guestTraderNavItems,
        onTabSelected: _onItemTapped,
      ),
    );
  }

  Future<void> _openWhatsapp() async {
    const contact = '+1234567890'; // TODO: Move to config
    final url = Platform.isIOS
        ? "https://wa.me/$contact"
        : "whatsapp://send?phone=$contact";

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (kDebugMode) {
          debugPrint('Could not launch WhatsApp');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error opening WhatsApp: $e');
      }
    }
  }
}