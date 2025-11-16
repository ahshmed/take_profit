import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/framework/repository/stock/model/stock_model.dart';
import 'package:take_profit/ui/us_market/create_us_market_story_screen.dart';
import 'package:take_profit/utils/const.dart';
import 'package:take_profit/utils/sliderightroute.dart';
import 'package:take_profit/utils/theme_const.dart';
import 'package:take_profit/utils/widgets/commonappbar.dart';

/// Screen to select a stock before creating US Market story/signal
class SelectStockScreen extends ConsumerStatefulWidget {
  const SelectStockScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectStockScreen> createState() => _SelectStockScreenState();
}

class _SelectStockScreenState extends ConsumerState<SelectStockScreen> {
  final List<StockModel> _stockList = StockModel.getMockStockList();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter stocks based on search query
    final filteredStocks = _searchQuery.isEmpty
        ? _stockList
        : _stockList.where((stock) {
            final query = _searchQuery.toLowerCase();
            return stock.ticker.toLowerCase().contains(query) ||
                stock.companyName.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        title: getLocalValue("Key_SelectStock"),
        isTitleCenter: false,
        appBar: AppBar(
          backgroundColor: Constant.clrWhiteNew,
          toolbarHeight: 64.h,
        ),
        isDrawer: false,
      ),
      body: Column(
        children: [
          /// Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: getLocalValue("Key_SearchStock"),
                hintStyle: TextStyles.txtRegular14(context).copyWith(
                  color: Constant.clrGrey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Constant.clrGrey,
                ),
                filled: true,
                fillColor: Constant.clrDarkByScaffoldTheme(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          /// Stock List
          Expanded(
            child: filteredStocks.isEmpty
                ? Center(
                    child: Text(
                      getLocalValue("Key_NoResultsFound"),
                      style: TextStyles.txtRegular14(context),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: filteredStocks.length,
                    itemBuilder: (context, index) {
                      final stock = filteredStocks[index];
                      return _buildStockCard(stock);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Stock Card Widget
  Widget _buildStockCard(StockModel stock) {
    return InkWell(
      onTap: () {
        // Navigate to story creation screen with selected stock
        Route route = SlideRightPageRoute(
          builder: (context) => CreateUSMarketStoryScreen(
            selectedStock: stock,
          ),
          settings: const RouteSettings(),
        );
        Navigator.of(context).push(route);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Constant.clrHomeCardByTheme(context),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Stock Icon (placeholder - you can add actual icons later)
            Container(
              width: 48.h,
              height: 48.h,
              decoration: BoxDecoration(
                color: Constant.clrPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  stock.ticker.substring(0, 2),
                  style: TextStyles.txtSemiBold14(context).copyWith(
                    color: Constant.clrPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            /// Stock Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.ticker,
                    style: TextStyles.txtSemiBold16(context).copyWith(
                      color: Constant.clrSigDetByTheme(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stock.companyName,
                    style: TextStyles.txtRegular12(context).copyWith(
                      color: Constant.clrGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            /// Price and Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.price,
                  style: TextStyles.txtSemiBold14(context).copyWith(
                    color: Constant.clrSigDetByTheme(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  stock.changePercent,
                  style: TextStyles.txtRegular12(context).copyWith(
                    color: stock.isPositiveChange
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
