import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../framework/data_provider/portfolio/portfolio_provider.dart';
import '../../utils/const.dart';
import '../../utils/extension/string_extension.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/commonappbar.dart';
import 'stock_details_screen.dart';
import '../../utils/sliderightroute.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    // Load portfolio data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioProvider).loadPortfolio();
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioWatch = ref.watch(portfolioProvider);

    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        title: 'Key_YourPortfolio'.localized,
        isTitleCenter: false,
        isDrawer: false,
        backgroundColor: Constant.clrHomeScreenByTheme(context),
        appBar: AppBar(
          backgroundColor: Constant.clrHomeScreenByTheme(context),
          toolbarHeight: 64.h,
        ),
      ),
      body: portfolioWatch.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Constant.clrPrimary,
              ),
            )
          : portfolioWatch.portfolioItems.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Portfolio Summary Cards - HIDDEN
                      // _buildSummaryCards(portfolioWatch),
                      // SizedBox(height: 24.h),

                      // Section Title
                      Text(
                        'Key_MyStocks'.localized,
                        style: TextStyles.txtSemiBold18(context).copyWith(
                          color: Constant.clrTitlePageByTheme(context),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Portfolio Items List
                      ...portfolioWatch.portfolioItems.map((item) {
                        return _buildPortfolioCard(item, portfolioWatch);
                      }).toList(),
                    ],
                  ),
                ),
    );
  }

  /// Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Constant.clrPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open,
                size: 60.h,
                color: Constant.clrPrimary,
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              'Key_EmptyPortfolio'.localized,
              style: TextStyles.txtBold18(context).copyWith(
                color: Constant.clrTitlePageByTheme(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              'Key_EmptyPortfolioDesc'.localized,
              style: TextStyles.txtRegular14(context).copyWith(
                color: Constant.clrSigDetByTheme(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Add Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constant.clrPrimary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Key_BrowseStocks'.localized,
                style: TextStyles.txtMedium16(context).copyWith(
                  color: Constant.clrWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Summary Cards (Total Value, Total Profit/Loss, etc.)
  Widget _buildSummaryCards(portfolioWatch) {
    final totalValue = portfolioWatch.totalPortfolioValue;
    final totalProfitLoss = portfolioWatch.totalProfitLoss;
    final totalProfitLossPercent = portfolioWatch.totalProfitLossPercent;
    final isProfit = totalProfitLoss >= 0;

    return Column(
      children: [
        // Total Portfolio Value Card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constant.clrPrimary,
                Constant.clrPrimary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Constant.clrPrimary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key_TotalPortfolioValue'.localized,
                style: TextStyles.txtRegular14(context).copyWith(
                  color: Constant.clrWhite.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '\$${totalValue.toStringAsFixed(2)}',
                style: TextStyles.txtBold32(context).copyWith(
                  color: Constant.clrWhite,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    isProfit ? Icons.trending_up : Icons.trending_down,
                    color: Constant.clrWhite,
                    size: 20.h,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${isProfit ? '+' : ''}\$${totalProfitLoss.toStringAsFixed(2)} (${isProfit ? '+' : ''}${totalProfitLossPercent.toStringAsFixed(2)}%)',
                    style: TextStyles.txtSemiBold14(context).copyWith(
                      color: Constant.clrWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Stats Row
        Row(
          children: [
            // Total Stocks
            Expanded(
              child: _buildStatCard(
                'Key_TotalStocks'.localized,
                '${portfolioWatch.portfolioItems.length}',
                Icons.bar_chart,
                const Color(0xFF7B61FF),
              ),
            ),
            SizedBox(width: 12.w),

            // Winners
            Expanded(
              child: _buildStatCard(
                'Key_Winners'.localized,
                '${portfolioWatch.winnersCount}',
                Icons.arrow_upward,
                const Color(0xFF32C671),
              ),
            ),
            SizedBox(width: 12.w),

            // Losers
            Expanded(
              child: _buildStatCard(
                'Key_Losers'.localized,
                '${portfolioWatch.losersCount}',
                Icons.arrow_downward,
                const Color(0xFFE74C3C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Small Stat Card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Constant.clrHomeCardByTheme(context),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.h,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyles.txtBold20(context).copyWith(
              color: Constant.clrTitlePageByTheme(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyles.txtRegular10(context).copyWith(
              color: Constant.clrTitlePageByTheme(context).withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Portfolio Card - Similar to US Market Card
  Widget _buildPortfolioCard(item, portfolioWatch) {
    final currentPrice = double.parse(item.currentPrice.replaceAll(RegExp(r'[^\d.]'), ''));
    final buyPrice = item.buyPrice;
    final profitLoss = currentPrice - buyPrice;
    final profitLossPercent = ((profitLoss / buyPrice) * 100);
    final isProfit = profitLoss >= 0;

    return GestureDetector(
      onTap: () {
        // Navigate to details screen
        Route route = SlideRightPageRoute(
          builder: (context) => StockDetailsScreen(
            ticker: item.ticker,
            companyName: item.companyName,
            price: item.currentPrice,
            buyStatus: item.buyStatus,
            complianceStatus: item.complianceStatus,
            dateTime: item.dateTime,
          ),
          settings: const RouteSettings(),
        );
        Navigator.of(context).push(route);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Constant.clrHomeCardByTheme(context),
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
            // Header: Company Info + Status Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo and Name
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: Constant.clrPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Center(
                          child: Text(
                            item.ticker.substring(0, 1),
                            style: TextStyles.txtMedium24(context).copyWith(
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
                              '${item.companyName} (${item.ticker})',
                              style: TextStyles.txtSemiBold16(context).copyWith(
                                color: Constant.clrTitlePageByTheme(context),
                                fontSize: 15.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.dateTime,
                              style: TextStyles.txtRegular12(context).copyWith(
                                color: Constant.clrTitlePageByTheme(context).withOpacity(0.5),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // Remove Button
                GestureDetector(
                  onTap: () {
                    _showRemoveDialog(item, portfolioWatch);
                  },
                  child: Icon(
                    Icons.delete_outline,
                    color: Constant.clrTitlePageByTheme(context).withOpacity(0.4),
                    size: 24.h,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Prices Row
            Row(
              children: [
                // Current Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key_CurrentPrice'.localized,
                        style: TextStyles.txtRegular12(context).copyWith(
                          color: Constant.clrTitlePageByTheme(context).withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.currentPrice,
                        style: TextStyles.txtSemiBold18(context).copyWith(
                          color: Constant.clrBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Buy Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key_BuyPrice'.localized,
                        style: TextStyles.txtRegular12(context).copyWith(
                          color: Constant.clrTitlePageByTheme(context).withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$${buyPrice.toStringAsFixed(2)}',
                        style: TextStyles.txtSemiBold16(context).copyWith(
                          color: Constant.clrTitlePageByTheme(context).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Profit/Loss
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Key_ProfitLoss'.localized,
                        style: TextStyles.txtRegular12(context).copyWith(
                          color: Constant.clrTitlePageByTheme(context).withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${isProfit ? '+' : ''}\$${profitLoss.toStringAsFixed(2)}',
                        style: TextStyles.txtSemiBold16(context).copyWith(
                          color: isProfit
                              ? const Color(0xFF32C671)
                              : const Color(0xFFE74C3C),
                        ),
                      ),
                      Text(
                        '${isProfit ? '+' : ''}${profitLossPercent.toStringAsFixed(2)}%',
                        style: TextStyles.txtRegular12(context).copyWith(
                          color: isProfit
                              ? const Color(0xFF32C671)
                              : const Color(0xFFE74C3C),
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
  }

  /// Show Remove Dialog
  void _showRemoveDialog(item, portfolioWatch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Key_RemoveFromPortfolio'.localized,
            style: TextStyles.txtBold18(context).copyWith(
              color: Constant.clrTitlePageByTheme(context),
            ),
          ),
          content: Text(
            'Key_RemoveFromPortfolioDesc'.localized,
            style: TextStyles.txtRegular14(context).copyWith(
              color: Constant.clrSigDetByTheme(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Key_Cancel'.localized,
                style: TextStyles.txtMedium14(context).copyWith(
                  color: Constant.clrTitlePageByTheme(context).withOpacity(0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                portfolioWatch.removeFromPortfolio(item.ticker);
                Navigator.of(context).pop();
              },
              child: Text(
                'Key_Remove'.localized,
                style: TextStyles.txtMedium14(context).copyWith(
                  color: const Color(0xFFE74C3C),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
