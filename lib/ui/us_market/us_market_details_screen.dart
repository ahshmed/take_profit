import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../framework/data_provider/portfolio/portfolio_provider.dart';
import '../../utils/const.dart';
import '../../utils/extension/string_extension.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/commonappbar.dart';

class USMarketDetailsScreen extends ConsumerStatefulWidget {
  final String ticker;
  final String companyName;
  final String price;
  final String buyStatus;
  final String complianceStatus;
  final String dateTime;

  const USMarketDetailsScreen({
    Key? key,
    required this.ticker,
    required this.companyName,
    required this.price,
    required this.buyStatus,
    required this.complianceStatus,
    required this.dateTime,
  }) : super(key: key);

  @override
  ConsumerState<USMarketDetailsScreen> createState() =>
      _USMarketDetailsScreenState();
}

class _USMarketDetailsScreenState
    extends ConsumerState<USMarketDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  bool _showDisclaimer = true; // Show disclaimer by default

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        title: 'Key_Details'.localized,
        isTitleCenter: false,
        isDrawer: false,
        backgroundColor: Constant.clrHomeScreenByTheme(context),
        appBar: AppBar(
            backgroundColor: Constant.clrHomeScreenByTheme(context),
            toolbarHeight: 64.h),
      ),
      body: Column(
        children: [
          // Stock Header Card (with button inside)
          _buildStockHeader(),

          // Tabs
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInsightTab(),
                _buildStoryTab(),
                _buildScorecardTab(),
                _buildRisksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockHeader() {
    return Container(
      margin: EdgeInsets.all(20.w),
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
        children: [
          Row(
            children: [
              // Stock Icon Placeholder
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Constant.clrPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Center(
                  child: Text(
                    widget.ticker.substring(0, 1),
                    style: TextStyles.txtMedium24(context).copyWith(
                      color: Constant.clrPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Company Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date with matching style from US Market screen
                    Text(
                      widget.dateTime,
                      style: TextStyles.txtRegular12(context).copyWith(
                        color: Constant.clrBlackOrigin.withOpacity(0.5),
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Company name with matching style from US Market screen
                    Text(
                      '${widget.companyName} (${widget.ticker})',
                      style: TextStyles.txtSemiBold16(context).copyWith(
                        color: Constant.clrBlackOrigin,
                        fontSize: 15.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // Price
                    Text(
                      widget.price,
                      style: TextStyles.txtSemiBold18(context).copyWith(
                        color: Constant.clrBlue,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badges - matching US Market screen style
              Column(
                crossAxisAlignment: getAppLanguage() == 'ar'
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  // Buy Status Tag with one-sided radius
                  Container(
                    width: 97.w,
                    height: 23.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getBuyStatusColor(widget.buyStatus),
                      borderRadius: getAppLanguage() == 'ar'
                          ? BorderRadius.only(
                        topRight: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      )
                          : BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        bottomLeft: Radius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      widget.buyStatus,
                      style: TextStyles.txtSemiBoldG10(context).copyWith(
                        fontWeight: Constant.fwRegular,
                        color: Constant.clrWhite,
                        fontSize: 10.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Sharia Compliance Tag with one-sided radius
                  Container(
                    width: 97.w,
                    height: 23.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getComplianceColor(widget.complianceStatus),
                      borderRadius: getAppLanguage() == 'ar'
                          ? BorderRadius.only(
                        topRight: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      )
                          : BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        bottomLeft: Radius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      _getComplianceText(widget.complianceStatus),
                      style: TextStyles.txtSemiBoldG10(context).copyWith(
                        fontWeight: Constant.fwRegular,
                        color: Constant.clrWhite,
                        fontSize: 9.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Add to Portfolio Button inside the card
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton(
              onPressed: () {
                final portfolioWatch = ref.read(portfolioProvider);

                // Check if already in portfolio
                final isInPortfolio = portfolioWatch.isInPortfolio(widget.ticker);

                if (isInPortfolio) {
                  // Show already added message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Key_AlreadyInPortfolio'.localized),
                      backgroundColor: Constant.clrPrimary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  // Add to portfolio
                  final currentPrice = double.parse(widget.price.replaceAll(RegExp(r'[^\d.]'), ''));

                  portfolioWatch.addToPortfolio(
                    ticker: widget.ticker,
                    companyName: widget.companyName,
                    currentPrice: widget.price,
                    buyPrice: currentPrice, // Use current price as buy price
                    buyStatus: widget.buyStatus,
                    complianceStatus: widget.complianceStatus,
                    dateTime: widget.dateTime,
                  );

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Key_AddedToPortfolio'.localized),
                      backgroundColor: const Color(0xFF32C671),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Constant.clrPrimary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Key_AddToMyPortfolio'.localized,
                style: TextStyles.txtRegular16(context).copyWith(
                  color: Constant.clrPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      height: 40.h,
      child: Row(
        children: [
          _buildTab('Key_Insight'.localized, 0),
          SizedBox(width: 8.w),
          _buildTab('Key_Story'.localized, 1),
          SizedBox(width: 8.w),
          _buildTab('Key_Scorecard'.localized, 2),
          SizedBox(width: 8.w),
          _buildTab('Key_Risks'.localized, 3),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Constant.clrBlackOrigin : Colors.transparent,
            border: Border.all(
              color: Constant.clrGrey.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyles.txtRegular12(context).copyWith(
              color: isSelected ? Constant.clrWhite : Constant.clrTitlePageByTheme(context),
              fontWeight: isSelected ? Constant.fwSemiBold : Constant.fwRegular,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildInsightTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _buildInsightCard(
            icon: 'IC_INSIGHT_PREDICTION', // Placeholder
            iconColor: Colors.red,
            title: 'Key_OurPredictions'.localized,
            content:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          ),
          SizedBox(height: 16.h),
          _buildInsightCard(
            icon: 'IC_INSIGHT_GROWTH', // Placeholder
            iconColor: Colors.green,
            title: 'Key_HowMuchGrowth'.localized,
            content:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          ),
          SizedBox(height: 16.h),
          _buildInsightCard(
            icon: 'IC_INSIGHT_TIME', // Placeholder
            iconColor: Colors.blue,
            title: 'Key_HowMuchGrowth'.localized,
            content:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
          ),
          SizedBox(height: 16.h),

          // Disclaimer with close button
          if (_showDisclaimer)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Constant.clrOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: Constant.clrOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Constant.clrOrange,
                    size: 24.h,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key_Disclaimer'.localized,
                          style: TextStyles.txtBold14(context).copyWith(
                            color: Constant.clrOrange,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Key_DisclaimerText'.localized,
                          style: TextStyles.txtRegular12(context).copyWith(
                            color: Constant.clrTitlePageByTheme(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Close button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showDisclaimer = false;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Constant.clrOrange,
                      size: 20.h,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.star, // Placeholder icon
              color: iconColor,
              size: 24.h,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.txtBold16(context).copyWith(
                    color: Constant.clrTitlePageByTheme(context),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  content,
                  style: TextStyles.txtRegular12(context).copyWith(
                    color: Constant.clrSigDetByTheme(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _buildStoryCard(
            icon: 'IC_STORY_SIMPLE', // Placeholder
            iconColor: Colors.green,
            title: 'Key_TheSimpleStory'.localized,
            content:
            'Remember when everyone wanted smartphones? Apple made billions. Now everyone wants AI (smart computers). NVIDIA makes the "brains" for ALL AI computers!',
          ),
          SizedBox(height: 16.h),
          _buildStoryCard(
            icon: 'IC_STORY_STORES', // Placeholder
            iconColor: Colors.purple,
            title: 'Key_TheyOwnTheBestStores'.localized,
            content:
            '8 out of 10 AI computers use NVIDIA chips\n• It\'s like owning the only gas station in town\n• Everyone MUST buy from them',
          ),
          SizedBox(height: 16.h),
          _buildStoryCard(
            icon: 'IC_STORY_MONEY', // Placeholder
            iconColor: Colors.orange,
            title: 'Key_MoneyIsPouringIn'.localized,
            content:
            '• Last year: Made \$60 billion (that\'s a LOT!)\n• This year: Will make even more\n• Companies are spending billions on AI',
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildStoryCard({
    required String icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.article, // Placeholder icon
                  color: iconColor,
                  size: 24.h,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.txtBold16(context).copyWith(
                    color: Constant.clrTitlePageByTheme(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyles.txtRegular14(context).copyWith(
              color: Constant.clrSigDetByTheme(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorecardTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key_TheSimpleStory'.localized,
            style: TextStyles.txtMedium18(context).copyWith(
              color: Constant.clrTitlePageByTheme(context),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Remember when everyone wanted smartphones? Apple made billions. Now everyone wants AI (smart computers). NVIDIA makes the "brains" for ALL AI computers!',
            style: TextStyles.txtRegular14(context).copyWith(
              color: Constant.clrSigDetByTheme(context),
            ),
          ),
          SizedBox(height: 20.h),

          // Chart/Dashboard Placeholder
          Container(
            height: 300.h,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    color: Colors.green,
                    size: 60.h,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'IC_SCORECARD_CHART', // Placeholder for actual chart image
                    style: TextStyles.txtRegular14(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Additional Description
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute iure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
            style: TextStyles.txtRegular12(context).copyWith(
              color: Constant.clrSigDetByTheme(context),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildRisksTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Text(
            'Key_RisksContent'.localized,
            style: TextStyles.txtRegular14(context).copyWith(
              color: Constant.clrSigDetByTheme(context),
            ),
          ),
          SizedBox(height: 20.h),
        ],
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

  /// Helper: Get Compliance Text
  String _getComplianceText(String status) {
    if (status.toLowerCase().contains('sharia compliant')) {
      return 'Sharia Compliant';
    } else {
      return 'Non-Sharia';
    }
  }
}