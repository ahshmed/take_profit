import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/const.dart';
import '../../utils/extension/string_extension.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/commonappbar.dart';

class StockDetailsScreen extends ConsumerStatefulWidget {
  final String ticker;
  final String companyName;
  final String price;
  final String buyStatus;
  final String complianceStatus;
  final String dateTime;

  const StockDetailsScreen({
    Key? key,
    required this.ticker,
    required this.companyName,
    required this.price,
    required this.buyStatus,
    required this.complianceStatus,
    required this.dateTime,
  }) : super(key: key);

  @override
  ConsumerState<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends ConsumerState<StockDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        title: '${widget.companyName} (${widget.ticker})',
        isTitleCenter: false,
        isDrawer: false,
        backgroundColor: Constant.clrHomeScreenByTheme(context),
        appBar: AppBar(
          backgroundColor: Constant.clrHomeScreenByTheme(context),
          toolbarHeight: 64.h,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // First Chart Section
            Container(
              width: double.infinity,
              height: 241.h,
              decoration: BoxDecoration(
                color: Constant.clrHomeCardByTheme(context),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  'assets/images/image1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Live Price Section
            Row(
              children: [
                Text(
                  'Key_LivePrice'.localized,
                  style: TextStyles.txtSemiBold20(context).copyWith(
                    fontWeight: Constant.fwRegular,
                    color: Constant.clrTitlePageByTheme(context),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.price,
                  style: TextStyles.txtRegular14(context).copyWith(
                    fontSize: 16.sp,
                    color: Constant.clrBlue,
                    fontWeight: Constant.fwSemiBold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Second Chart Section
            Container(
              width: double.infinity,
              height: 250.h,
              decoration: BoxDecoration(
                color: Constant.clrHomeCardByTheme(context),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  'assets/images/image2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // News Section
            Text(
              'Key_News'.localized,
              style: TextStyles.txtSemiBold20(context).copyWith(
                color: Constant.clrTitlePageByTheme(context),
              ),
            ),

            SizedBox(height: 16.h),

            // News Cards
            ..._buildNewsCards(),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNewsCards() {
    // Sample news data - this should come from API in real implementation
    final newsItems = [
      {
        'title': 'Stock Market Analysis',
        'description': 'Latest updates and trends in the stock market',
        'date': widget.dateTime,
      },
      {
        'title': 'Company Performance',
        'description': '${widget.companyName} shows strong quarterly results',
        'date': widget.dateTime,
      },
      {
        'title': 'Market Insights',
        'description': 'Expert analysis on current market conditions',
        'date': widget.dateTime,
      },
    ];

    return newsItems.map((news) => _buildNewsCard(
      title: news['title']!,
      description: news['description']!,
      date: news['date']!,
    )).toList();
  }

  Widget _buildNewsCard({
    required String title,
    required String description,
    required String date,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Constant.clrPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.article,
                  color: Constant.clrPrimary,
                  size: 20.h,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.txtSemiBold16(context).copyWith(
                        color: Constant.clrTitlePageByTheme(context),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      date,
                      style: TextStyles.txtRegular12(context).copyWith(
                        color: Constant.clrTitlePageByTheme(context).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: TextStyles.txtRegular14(context).copyWith(
              color: Constant.clrSigDetByTheme(context),
            ),
          ),
        ],
      ),
    );
  }
}
