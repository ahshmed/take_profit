// ignore_for_file: unused_local_variable
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:badges/badges.dart' as badge;
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/us_market/us_market_details_screen.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import '../../framework/data_provider/notification/notification_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/stock/stock_provider.dart'; // ADD THIS
import '../../framework/repository/stock/model/stock_model.dart'; // ADD THIS
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../notification/notification_screen.dart';
import '../stock/stock_screen.dart';

// REMOVE the StockData class - we'll use StockModel instead

class UsMarketDetailScreen extends ConsumerStatefulWidget {
  final String recommenderID;
  final bool appbarRequired;

  const UsMarketDetailScreen({
    Key? key,
    required this.recommenderID,
    this.appbarRequired = true,
  }) : super(key: key);

  @override
  ConsumerState<UsMarketDetailScreen> createState() =>
      _UsMarketDetailScreenState();
}

class _UsMarketDetailScreenState extends ConsumerState<UsMarketDetailScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final PageController _adPageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  Timer? adAutoScrollTimer;
  int currentAdPage = 0;
  String searchQuery = "";
  int selectedTabIndex = 0; // 0: All, 1: Strong Buy, 2: Buy, 3: Hold, 4: Sell

  // Placeholder tabs
  final List<String> tabList = [
    'Key_All',
    'Key_StrongBuy',
    'Key_Buy',
    'Key_Hold',
    'Key_Sell',
  ];

  // Placeholder ad images (same as crypto)
  final List<String> adImages = [
    Constant.icAdvertiseN,
    Constant.icAdvertiseN,
    Constant.icAdvertiseN,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startAdAutoScroll();

    // CRITICAL FIX: Initialize the stock data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockProvider).initializeStockData();
    });
  }

  void startAdAutoScroll() {
    adAutoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_adPageController.hasClients && adImages.isNotEmpty) {
        currentAdPage = (currentAdPage + 1) % adImages.length;
        _adPageController.animateToPage(
          currentAdPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      adAutoScrollTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      startAdAutoScroll();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _adPageController.dispose();
    _searchController.dispose();
    adAutoScrollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final notificationWatch = ref.watch(notificationProvider);
    final profileWatch = ref.watch(profileProvider);
    final stockWatch = ref.watch(stockProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrWhite,
          appBar: (widget.appbarRequired)
              ? CommonAppBar(
            title: getLocalValue("Key_RecommenderDetail"),
            isTitleCenter: true,
            appBar: AppBar(
                backgroundColor: Constant.clrHomeScreenByTheme(context),
                toolbarHeight: 64.h),
            isDrawer: false,
          )
              : _buildCustomHeader(context, profileWatch, notificationWatch),
          body: NoInternetBuilder(child: bodyWidget(stockWatch, profileWatch)),
        ),
        DialogProgressBar(isLoading: stockWatch.isLoading),
      ],
    );
  }

  /// Custom Header with Profile, Greeting, Search, and Notification
  PreferredSizeWidget _buildCustomHeader(
      BuildContext context, profileWatch, notificationWatch) {
    final String userName = profileWatch.profileDetailResponseModel?.data?.nameEn ?? 'User';

    return AppBar(
      backgroundColor: Constant.clrWhite,
      elevation: 0,
      toolbarHeight: 70.h,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Profile Photo
          GestureDetector(
            onTap: () {
              // Open drawer or profile
            },
            child: Container(
              width: 45.w,
              height: 45.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CacheImage(
                  imageURL: profileWatch.profileDetailResponseModel?.data?.profileImage ?? '',
                  width: 45.w,
                  height: 45.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Greeting Text
          Expanded(
            child: Text(
              'Hi, $userName',
              style: TextStyles.txtSemiBold18(context).copyWith(
                color: Constant.clrBlackOrigin,
                fontWeight: Constant.fwSemiBold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Search Icon
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Constant.clrGrey.withOpacity(0.3),
          ),
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: Constant.clrBlackOrigin,
              size: 22.h,
            ),
            onPressed: () {
              // Search functionality
            },
          ),
        ),
        SizedBox(width: 10.w),
        // Notification Icon
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Constant.clrGrey.withOpacity(0.3),
          ),
          child: IconButton(
            icon: badge.Badge(
              showBadge: (notificationWatch.notificationCountResponseModel.data?.count != '0') &&
                  (notificationWatch.notificationCountResponseModel.data != null),
              position: badge.BadgePosition.topEnd(top: 0, end: 2),
              badgeStyle: const badge.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(3),
              ),
              badgeContent: Text(
                notificationWatch.notificationCountResponseModel.data?.count ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Constant.clrBlackOrigin,
                size: 22.h,
              ),
            ),
            onPressed: () {
              Route route = SlideRightPageRoute(
                builder: (context) => const NotificationScreen(),
                settings: const RouteSettings(),
              );
              Navigator.of(context).push(route);
            },
          ),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }


  // Body Widget with complete redesigned layout
  Widget bodyWidget(stockWatch, profileWatch) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.h),
          // Banner Section
          buildBannerSection(),
          SizedBox(height: 16.h),
          // Action Buttons
          buildActionButtons(),
          SizedBox(height: 24.h),
          // Category Tabs with Underline
          buildUnderlineTabs(),
          SizedBox(height: 16.h),
          // Investment Cards
          buildInvestmentCards(stockWatch),
        ],
      ),
    );
  }

  /// Banner Section with Bitcoin Image
  Widget buildBannerSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6B35A), // Gold
              Color(0xFFD4A049), // Darker gold
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Bitcoin Icon/Pattern Background
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.3,
                child: Icon(
                  Icons.currency_bitcoin,
                  size: 150.h,
                  color: Constant.clrWhite,
                ),
              ),
            ),
            // Text Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '3D Gold Bitcoin',
                    style: TextStyles.txtBold22(context).copyWith(
                      color: Constant.clrWhite,
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Invest in the future of finance',
                    style: TextStyles.txtRegular14(context).copyWith(
                      color: Constant.clrWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action Buttons Section
  Widget buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // First Row: Consultation and Subscribe
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: 'Consultation',
                  isPrimary: false,
                  color: Constant.clrPrimary,
                  onTap: () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildButton(
                  text: 'Subscribe',
                  isPrimary: true,
                  color: const Color(0xFFE6B35A), // Gold
                  onTap: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Second Row: TakeProfit Investments and Your Portfolio
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: 'TakeProfit Investments',
                  isPrimary: true,
                  color: Constant.clrBlackOrigin,
                  onTap: () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildButton(
                  text: 'Your Portfolio',
                  isPrimary: false,
                  color: Constant.clrGrey,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper: Build Button
  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: isPrimary ? color : Constant.clrWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: isPrimary ? null : Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyles.txtMedium14(context).copyWith(
              color: isPrimary ? Constant.clrWhite : color,
              fontWeight: Constant.fwSemiBold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Modern Search Bar matching the design
  Widget buildSearchBar(stockWatch) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Constant.clrWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
            // CRITICAL FIX: Use provider search instead of local search
            ref.read(stockProvider).searchStocks(value);
          },
          style: TextStyles.txtRegular14(context).copyWith(
            color: Constant.clrBlackOrigin,
          ),
          decoration: InputDecoration(
            hintText: getLocalValue('Key_Search'),
            hintStyle: TextStyles.txtRegular14(context).copyWith(
              color: Constant.clrBlackOrigin.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Constant.clrBlackOrigin.withOpacity(0.5),
              size: 22.h,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Constant.clrBlackOrigin.withOpacity(0.5),
                size: 20.h,
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  searchQuery = "";
                });
                // CRITICAL FIX: Clear provider search
                ref.read(stockProvider).clearSearch();
              },
            )
                : null,
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ),
    );
  }

  /// Underline-Style Tabs
  Widget buildUnderlineTabs() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabList.length, (index) {
          bool isSelected = selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTabIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? Constant.clrPrimary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    getLocalValue(tabList[index]),
                    style: TextStyles.txtMedium12(context).copyWith(
                      color: isSelected
                          ? Constant.clrPrimary
                          : Constant.clrBlackOrigin.withOpacity(0.6),
                      fontWeight: isSelected ? Constant.fwSemiBold : Constant.fwMedium,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Investment Cards Section
  Widget buildInvestmentCards(stockWatch) {
    final stockList = stockWatch.filteredStockList;
    final List<StockModel> filteredList = _filterStocksByTab(stockList);

    if (filteredList.isEmpty && !stockWatch.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 50.h),
        child: EmptyStateWidget(
          emptyStateFor: EmptyState.noSearchFound,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          ...filteredList.asMap().entries.map((entry) {
            int index = entry.key;
            StockModel stock = entry.value;

            // Add promotional banner after 2nd card
            if (index == 2) {
              return Column(
                children: [
                  buildInvestmentCard(stock),
                  SizedBox(height: 16.h),
                  buildPromotionalBanner(),
                  SizedBox(height: 16.h),
                ],
              );
            }

            return Column(
              children: [
                buildInvestmentCard(stock),
                SizedBox(height: 16.h),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Promotional Banner
  Widget buildPromotionalBanner() {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF5E3FBE), // Purple
            Color(0xFF2A1A5E), // Dark purple
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Bitcoin icons in background
          Positioned(
            right: -30,
            top: 10,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.currency_bitcoin,
                size: 100.h,
                color: Constant.clrWhite,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Crypto Promotional\nOffers',
                  style: TextStyles.txtBold22(context).copyWith(
                    color: Constant.clrWhite,
                    fontSize: 20.sp,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CRITICAL FIX: Filter stocks by tab based on buyStatus
  List<StockModel> _filterStocksByTab(List<StockModel> stockList) {
    if (selectedTabIndex == 0) {
      // "All" tab - return all stocks
      return stockList;
    }

    // Map tab index to buyStatus
    String filterStatus = '';
    switch (selectedTabIndex) {
      case 1:
        filterStatus = 'Strong Buy';
        break;
      case 2:
        filterStatus = 'Buy';
        break;
      case 3:
        filterStatus = 'Hold';
        break;
      case 4:
        filterStatus = 'Sell';
        break;
    }

    // Filter stocks by buyStatus
    return stockList.where((stock) {
      // Check if StockModel has buyStatus field (for backward compatibility)
      try {
        final buyStatus = (stock as dynamic).buyStatus as String?;
        return buyStatus?.toLowerCase() == filterStatus.toLowerCase();
      } catch (e) {
        // If buyStatus doesn't exist, return true (show all)
        return true;
      }
    }).toList();
  }

  /// Investment Card matching the detailed design
  Widget buildInvestmentCard(StockModel stockData) {
    final now = DateTime.now();
    final dateTime = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    Widget cardContent = Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Constant.clrWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Time
          Text(
            dateTime,
            style: TextStyles.txtRegular12(context).copyWith(
              color: Constant.clrBlackOrigin.withOpacity(0.5),
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 12.h),

          // Investment Title and Tags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stockData.companyName} (${stockData.ticker})',
                      style: TextStyles.txtSemiBold16(context).copyWith(
                        color: Constant.clrBlackOrigin,
                        fontSize: 15.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // Price in Blue
                    Text(
                      stockData.price,
                      style: TextStyles.txtSemiBold18(context).copyWith(
                        color: Constant.clrBlue,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Status Tags Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Buy Status Tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _getBuyStatusColor((stockData as dynamic).buyStatus ?? 'Hold'),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      (stockData as dynamic).buyStatus ?? 'Hold',
                      style: TextStyles.txtMedium10(context).copyWith(
                        color: Constant.clrWhite,
                        fontWeight: Constant.fwSemiBold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Sharia Compliance Tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _getComplianceColor((stockData as dynamic).complianceStatus ?? 'Sharia Compliant'),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      _getComplianceText((stockData as dynamic).complianceStatus ?? 'Sharia Compliant'),
                      style: TextStyles.txtMedium10(context).copyWith(
                        color: Constant.clrWhite,
                        fontWeight: Constant.fwSemiBold,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Add to portfolio action
                  },
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: Constant.clrWhite,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Constant.clrPrimary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'Add to Portfolio',
                        style: TextStyles.txtMedium12(context).copyWith(
                          color: Constant.clrPrimary,
                          fontWeight: Constant.fwSemiBold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Route route = SlideRightPageRoute(
                      builder: (context) => USMarketDetailsScreen(
                        ticker: stockData.ticker,
                        companyName: stockData.companyName,
                      ),
                      settings: const RouteSettings(),
                    );
                    Navigator.of(context).push(route);
                  },
                  child: Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: Constant.clrBlackOrigin,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        'View Details',
                        style: TextStyles.txtMedium12(context).copyWith(
                          color: Constant.clrWhite,
                          fontWeight: Constant.fwSemiBold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    /// Apply blur if stock is marked as blurred
    final isBlurred = (stockData as dynamic).isBlurred ?? false;
    return isBlurred
        ? Blur(
      borderRadius: BorderRadius.circular(16.r),
      blurColor: Constant.clrDarkByScaffoldTheme(context).withOpacity(0.2),
      child: cardContent,
    )
        : cardContent;
  }

  /// Helper: Get Compliance Text
  String _getComplianceText(String status) {
    if (status.toLowerCase().contains('sharia compliant')) {
      return 'Sharia Compliant';
    } else {
      return 'Non-Sharia';
    }
  }

  /// Horizontal Ad Banner
  Widget buildHorizontalAdBanner() {
    return Container(
      height: 120.h,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: PageView.builder(
        controller: _adPageController,
        itemCount: adImages.length,
        onPageChanged: (index) {
          setState(() {
            currentAdPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: index % 2 == 0
                        ? [const Color(0xFF5E3FBE), const Color(0xFF2A1A5E)]
                        : [const Color(0xFFFF6B35), const Color(0xFFF7931A)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          adImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            index % 2 == 0
                                ? 'Stock Market\nPromotional\nOffers'
                                : 'Investment\nBanners\n& Video Ads',
                            style: TextStyles.txtBold22(context).copyWith(
                              color: Constant.clrWhite,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16.w,
                      bottom: 16.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Constant.clrWhite,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 16.h,
                              color: const Color(0xFF5E3FBE),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Learn More',
                              style: TextStyles.txtMedium12(context).copyWith(
                                color: const Color(0xFF5E3FBE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper: Get Buy Status Color
  Color _getBuyStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'strong buy':
      case 'buy':
        return const Color(0xFF32C671); // Green (Success)
      case 'sell':
        return const Color(0xFFE74C3C); // Red (Danger)
      case 'hold':
        return const Color(0xFFF59E0B); // Orange
      default:
        return Colors.grey;
    }
  }

  /// Helper: Get Compliance Color
  Color _getComplianceColor(String status) {
    if (status.toLowerCase().contains('sharia compliant')) {
      return const Color(0xFF7B61FF); // Purple (Secondary)
    } else {
      return const Color(0xFFF97316); // Orange
    }
  }
}
