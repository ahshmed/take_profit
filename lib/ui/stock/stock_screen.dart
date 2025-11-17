import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:badges/badges.dart' as badge;
import '../../framework/data_provider/stock/stock_provider.dart';
import '../../framework/data_provider/notification/notification_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/repository/stock/model/stock_model.dart';
import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/extension/string_extension.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/commonappbar.dart';
import '../notification/notification_screen.dart';
import '../us_market/us_market_details_screen.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize stock data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stockWatch = ref.read(stockProvider);
      final notificationWatch = ref.read(notificationProvider);

      stockWatch.initializeStockData();

      // Load notification count for logged-in users only (not guest)
      if (getUserStatus() != guest) {
        notificationWatch.notificationCountAPI(context);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockWatch = ref.watch(stockProvider);
    final profileWatch = ref.watch(profileProvider);
    final notificationWatch = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        backgroundColor: Constant.clrHomeScreenByTheme(context),
        isPremiumIconRequired: false,
        title: getUserStatus() == guest
            ? 'Key_USStocks'.localized
            : getUserStatus() == trader
            ? 'Key_USStocks'.localized
            : 'Key_USStocks'.localized,
        titleTextStyle: TextStyles.txtRegular16(context)
            .copyWith(color: Constant.clrTitlePageByTheme(context)),
        isDrawer: false,
        appBar: AppBar(
          backgroundColor: Constant.clrHomeScreenByTheme(context),
          toolbarHeight: 64.h,
          leading: Padding(
            padding: EdgeInsets.all(8.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.r),
              child: CacheImage(
                imageURL: getUserStatus() == guest ? "" : getUserImage(),
                isProfileImg: true,
                height: 50.h,
                width: 50.w,
              ),
            ),
          ),
          actions: [
            // Search Icon - opens search stock screen
            IconButton(
              icon: Icon(
                Icons.search,
                color: Constant.clrTitlePageByTheme(context),
                size: 24.h,
              ),
              onPressed: () {
                Route route = SlideRightPageRoute(
                  builder: (context) => const SearchStockScreen(),
                  settings: const RouteSettings(),
                );
                Navigator.of(context).push(route);
              },
            ),
            // Notification Icon with Badge
            badge.Badge(
              position: badge.BadgePosition.topEnd(top: 8.h, end: 8.w),
              showBadge: (notificationWatch
                  .notificationCountResponseModel
                  .data
                  ?.count !=
                  null &&
                  notificationWatch
                      .notificationCountResponseModel
                      .data
                      ?.count !=
                      '0'),
              badgeContent: Text(
                notificationWatch.notificationCountResponseModel?.data
                    ?.count ??
                    '0',
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Constant.clrTitlePageByTheme(context),
                  size: 24.h,
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
        ),

      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Constant.clrSearchByTheme(context),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  stockWatch.searchStocks(value);
                },
                decoration: InputDecoration(
                  hintText: 'Key_SearchStock'.localized,
                  hintStyle: TextStyles.txtRegular14(context).copyWith(
                    color: Constant.clrSearchHintByTheme(context),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Constant.clrTitlePageByTheme(context),
                    size: 24.h,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Constant.clrSearchHintByTheme(context),
                      size: 20.h,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      stockWatch.clearSearch();
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                ),
              ),
            ),
          ),

          // Stock List
          Expanded(
            child: stockWatch.isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Constant.clrPrimary,
              ),
            )
                : stockWatch.filteredStockList.isEmpty
                ? Center(
              child: Text(
                'Key_NoStocksFound'.localized,
                style: TextStyles.txtRegular16(context).copyWith(
                  color: Constant.clrTitlePageByTheme(context),
                ),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: stockWatch.filteredStockList.length,
              itemBuilder: (context, index) {
                final stock = stockWatch.filteredStockList[index];
                return _buildStockCard(stock);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(stock) {
    return GestureDetector(
      onTap: () {
        // Navigate to US Market Details Screen
        Route route = SlideRightPageRoute(
          builder: (context) => USMarketDetailsScreen(
            ticker: stock.ticker,
            companyName: stock.companyName,
          ),
          settings: const RouteSettings(),
        );
        Navigator.of(context).push(route);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Constant.clrCardBGByTheme(context),
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Stock Icon/Logo Placeholder
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Constant.clrPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Center(
                child: Text(
                  stock.ticker.substring(0, 1),
                  style: TextStyles.txtMedium18(context).copyWith(
                    color: Constant.clrPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Company Name and Ticker
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.ticker,
                    style: TextStyles.txtBold16(context).copyWith(
                      color: Constant.clrTitlePageByTheme(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stock.companyName,
                    style: TextStyles.txtRegular12(context).copyWith(
                      color: Constant.clrTitlePageByTheme(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Note: Favorite icon removed as per requirements
          ],
        ),
      ),
    );
  }
}

// Search Stock Screen (looks like Stock Screen)
class SearchStockScreen extends ConsumerStatefulWidget {
  const SearchStockScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchStockScreen> createState() => _SearchStockScreenState();
}

class _SearchStockScreenState extends ConsumerState<SearchStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus search bar when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      final stockWatch = ref.read(stockProvider);
      if (stockWatch.stockList.isEmpty) {
        stockWatch.initializeStockData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockWatch = ref.watch(stockProvider);

    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: AppBar(
        backgroundColor: Constant.clrHomeScreenByTheme(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Constant.clrTitlePageByTheme(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Key_SearchStock'.localized,
          style: TextStyles.txtRegular16(context).copyWith(
            color: Constant.clrTitlePageByTheme(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Constant.clrSearchByTheme(context),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  stockWatch.searchStocks(value);
                },
                decoration: InputDecoration(
                  hintText: 'Key_SearchStock'.localized,
                  hintStyle: TextStyles.txtRegular14(context).copyWith(
                    color: Constant.clrSearchHintByTheme(context),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Constant.clrTitlePageByTheme(context),
                    size: 24.h,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Constant.clrSearchHintByTheme(context),
                      size: 20.h,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      stockWatch.clearSearch();
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                ),
              ),
            ),
          ),

          // Stock List
          Expanded(
            child: stockWatch.isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Constant.clrPrimary,
              ),
            )
                : stockWatch.filteredStockList.isEmpty
                ? Center(
              child: Text(
                'Key_NoStocksFound'.localized,
                style: TextStyles.txtRegular16(context).copyWith(
                  color: Constant.clrTitlePageByTheme(context),
                ),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: stockWatch.filteredStockList.length,
              itemBuilder: (context, index) {
                final stock = stockWatch.filteredStockList[index];
                return _buildStockCard(stock);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(stock) {
    return GestureDetector(
      onTap: () {
        // Navigate to US Market Details Screen
        Route route = SlideRightPageRoute(
          builder: (context) => USMarketDetailsScreen(
            ticker: stock.ticker,
            companyName: stock.companyName,
          ),
          settings: const RouteSettings(),
        );
        Navigator.of(context).push(route);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Constant.clrCardBGByTheme(context),
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Stock Icon/Logo Placeholder
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Constant.clrPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Center(
                child: Text(
                  stock.ticker.substring(0, 1),
                  style: TextStyles.txtMedium18(context).copyWith(
                    color: Constant.clrPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Company Name and Ticker
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.ticker,
                    style: TextStyles.txtBold16(context).copyWith(
                      color: Constant.clrTitlePageByTheme(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stock.companyName,
                    style: TextStyles.txtRegular12(context).copyWith(
                      color: Constant.clrTitlePageByTheme(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}