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
    // CRITICAL FIX: Watch the stock provider
    final stockWatch = ref.watch(stockProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          // Redesigned App Bar to match the image
          appBar: (widget.appbarRequired)
              ? CommonAppBar(
            title: getLocalValue("Key_RecommenderDetail"),
            isTitleCenter: true,
            appBar: AppBar(
                backgroundColor: Constant.clrHomeScreenByTheme(context),
                toolbarHeight: 64.h),
            isDrawer: false,
          )
              : _buildModernAppBar(context, notificationWatch),
          body: NoInternetBuilder(child: bodyWidget(stockWatch)),
        ),
        // CRITICAL FIX: Show loading indicator from provider
        DialogProgressBar(isLoading: stockWatch.isLoading),
      ],
    );
  }

  /// Modern App Bar matching the design image
  PreferredSizeWidget _buildModernAppBar(
      BuildContext context, notificationWatch) {
    final profileWatch = ref.watch(profileProvider);
    return AppBar(
      backgroundColor: Constant.clrPrimary,
      elevation: 0,
      toolbarHeight: 64.h,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: GestureDetector(
          onTap: () {
            // Open drawer or navigate back
            Navigator.of(context).pop();
          },
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: CacheImage(
                imageURL: profileWatch.profileDetailResponseModel?.data?.profileImage ?? '',
                width: 40.w,
                height: 40.h,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        getLocalValue("Key_UsMarket"),
        style: TextStyles.txtSemiBold18(context).copyWith(
          color: Constant.clrWhite,
          fontWeight: Constant.fwSemiBold,
        ),
      ),
      centerTitle: true,
      actions: [
        badge.Badge(
          showBadge: (notificationWatch.notificationCountResponseModel.data?.count != '0') &&
              (notificationWatch.notificationCountResponseModel.data != null),
          position: badge.BadgePosition.topEnd(top: 8, end: 8),
          badgeStyle: const badge.BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.all(4),
          ),
          badgeContent: Text(
            notificationWatch.notificationCountResponseModel.data?.count ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Constant.clrWhite,
              size: 28.h,
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
        SizedBox(width: 8.w),
      ],
    );
  }

  // Simple App Bar (Back button + Title) - Used when US Market is HOME
  PreferredSizeWidget _buildSimpleAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Constant.clrHomeScreenByTheme(context),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Constant.clrTitlePageByTheme(context),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        getLocalValue("Key_UsMarket"),
        style: TextStyles.txtSemiBold18(context).copyWith(
          color: Constant.clrTitlePageByTheme(context),
          fontWeight: Constant.fwMedium,
        ),
      ),
    );
  }

  // Full App Bar with profile and notifications
  // PreferredSizeWidget _buildFullAppBar(
  //     BuildContext context, notificationWatch) {
  //   final profileWatch = ref.watch(profileProvider);
  //   return CommonAppBar(
  //     appBar: AppBar(
  //       elevation: 0,
  //       backgroundColor: Constant.clrHomeScreenByTheme(context),
  //       title: Text(
  //         getLocalValue("Key_UsMarket"),
  //         style: TextStyles.txtSemiBold18(context).copyWith(
  //           color: Constant.clrTitlePageByTheme(context),
  //           fontWeight: Constant.fwMedium,
  //         ),
  //       ),
  //       leading: GestureDetector(
  //         onTap: () {
  //           // You can add an action here, e.g., open profile screen
  //         },
  //         child: Padding(
  //           padding: EdgeInsets.only(left: 16.w),
  //           child: CircleAvatar(
  //             radius: 20.r,
  //             backgroundColor: Constant.clrHomeScreenByTheme(context),
  //             child: ClipOval(
  //               child: CacheImage(
  //                 imageURL: profileWatch.profileData.data?.profilePic ?? '',
  //                 width: 40.w,
  //                 height: 40.h,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       actions: [
  //         badge.Badge(
  //           showBadge: notificationWatch.notificationCount > 0,
  //           position: badge.BadgePosition.topEnd(top: 8, end: 8),
  //           badgeContent: Text(
  //             notificationWatch.notificationCount.toString(),
  //             style: const TextStyle(color: Colors.white, fontSize: 10),
  //           ),
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.notifications_outlined,
  //               color: Constant.clrTitlePageByTheme(context),
  //             ),
  //             onPressed: () {
  //               Route route = SlideRightPageRoute(
  //                 builder: (context) => const NotificationScreen(),
  //                 settings: const RouteSettings(),
  //               );
  //               Navigator.of(context).push(route);
  //             },
  //           ),
  //         ),
  //         SizedBox(width: 8.w),
  //       ],
  //     ),
  //   );
  // }

  // CRITICAL FIX: Pass stockWatch to bodyWidget
  Widget bodyWidget(stockWatch) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        buildSearchBar(stockWatch), // Pass stockWatch
        SizedBox(height: 20.h),
        buildTabBar(),
        SizedBox(height: 16.h),
        Expanded(
          child: buildStockListView(stockWatch), // Pass stockWatch
        ),
      ],
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

  /// Modern Pill-Shaped Tab Bar matching the design
  Widget buildTabBar() {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabList.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTabIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Constant.clrPrimary
                    : Constant.clrWhite,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: isSelected
                      ? Constant.clrPrimary
                      : Constant.clrBlackOrigin.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Constant.clrPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Center(
                child: Text(
                  getLocalValue(tabList[index]),
                  style: TextStyles.txtMedium14(context).copyWith(
                    color: isSelected
                        ? Constant.clrWhite
                        : Constant.clrBlackOrigin,
                    fontWeight: isSelected ? Constant.fwSemiBold : Constant.fwMedium,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Stock List View
  Widget buildStockListView(stockWatch) {
    // CRITICAL FIX: Use filteredStockList from provider
    final stockList = stockWatch.filteredStockList;

    // Filter by selected tab
    final List<StockModel> filteredList = _filterStocksByTab(stockList);

    if (filteredList.isEmpty && !stockWatch.isLoading) {
      return EmptyStateWidget(
        emptyStateFor: EmptyState.noSearchFound,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: filteredList.length + 1, // +1 for ad banner
      itemBuilder: (context, index) {
        if (index == 3) {
          return buildHorizontalAdBanner();
        }

        final actualIndex = index > 3 ? index - 1 : index;
        if (actualIndex >= filteredList.length) return const SizedBox.shrink();

        return buildStockCard(filteredList[actualIndex]);
      },
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

  /// Modern Stock Card matching the design
  Widget buildStockCard(StockModel stockData) {
    Widget cardContent = GestureDetector(
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
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Constant.clrWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Circular Company Logo
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constant.clrPrimary.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  stockData.ticker.substring(0, 1),
                  style: TextStyles.txtBold16(context).copyWith(
                    color: Constant.clrPrimary,
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            /// Company Name, Ticker & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stockData.companyName,
                    style: TextStyles.txtSemiBold16(context).copyWith(
                      color: Constant.clrBlackOrigin,
                      fontSize: 16.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stockData.ticker,
                    style: TextStyles.txtRegular12(context).copyWith(
                      color: Constant.clrBlackOrigin.withOpacity(0.5),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  /// Buy Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _getBuyStatusColor((stockData as dynamic).buyStatus ?? 'Hold')
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      (stockData as dynamic).buyStatus ?? 'Hold',
                      style: TextStyles.txtMedium10(context).copyWith(
                        color: _getBuyStatusColor((stockData as dynamic).buyStatus ?? 'Hold'),
                        fontWeight: Constant.fwSemiBold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            /// Price & Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stockData.price,
                  style: TextStyles.txtSemiBold16(context).copyWith(
                    color: Constant.clrBlackOrigin,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: stockData.isPositiveChange
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        stockData.isPositiveChange
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12.h,
                        color: stockData.isPositiveChange
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        stockData.changePercent,
                        style: TextStyles.txtMedium12(context).copyWith(
                          color: stockData.isPositiveChange
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontWeight: Constant.fwSemiBold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
        return const Color(0xFF10B981); // Green
      case 'sell':
        return const Color(0xFFEF4444); // Red
      case 'hold':
        return const Color(0xFFF59E0B); // Orange
      default:
        return Colors.grey;
    }
  }

  /// Helper: Get Compliance Color
  Color _getComplianceColor(String status) {
    if (status.toLowerCase().contains('sharia compliant')) {
      return const Color(0xFF8B5CF6); // Purple
    } else {
      return const Color(0xFFF97316); // Orange
    }
  }
}
