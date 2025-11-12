// ignore_for_file: prefer_is_empty, unused_local_variable

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/drawer/my_revenue_controller.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';


class MyRevenue extends ConsumerStatefulWidget {
  final bool isFromDrawer;

  const MyRevenue({Key? key, required this.isFromDrawer}) : super(key: key);

  @override
  ConsumerState<MyRevenue> createState() => _MyRevenueState();
}

class _MyRevenueState extends ConsumerState<MyRevenue>  {
  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final myRevenueWatch = ref.watch(myRevenueScreenProvider);

      /// To Select Default Current Month From MonthList
      myRevenueWatch.selectedMonth = myRevenueWatch.monthList
          .where((element) => (element.id == DateTime.now().month))
          .first;
      revenueChartAPICall(myRevenueWatch);
      myRevenueWatch.generateYears();
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final myRevenueWatch = ref.watch(myRevenueScreenProvider);

    final darkModeWatch = ref.watch(darkProvider);
    final drawerWatch = ref.watch(drawerProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue("Key_MyRevenue"),
            isTitleCenter: true,
            appBar: AppBar(
              backgroundColor: Constant.clrScaffoldBGByTheme(context),
            ),
            isDrawer: widget.isFromDrawer,
          ),
          body: NoInternetBuilder(
            child: bodyWidget(myRevenueWatch),
          ),
        ),
        DialogProgressBar(isLoading: myRevenueWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(MyRevenueController myRevenueWatch) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
          Container(
            height: 360.h,
            width: Constant.infiniteSize,
            padding: EdgeInsets.only(
              top: 20.h,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Constant.clrPrimaryWhiteByTheme(context),
            ),
            child: chartWidget(myRevenueWatch),
          ),
          SizedBox(
            height: 22.h,
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Constant.clrDarkByScaffoldTheme(context),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.h),
                          decoration: BoxDecoration(
                            color: Constant.clrPrimaryLight.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: CommonImageAsset(
                            strIcon: Constant.icWallet,
                            height: 30.h,
                            width: 30.h,
                          ),
                        ),
                        SizedBox(
                          height: 14.h,
                        ),
                        Text(
                          (myRevenueWatch.revenueChartResponseModel?.data
                                      ?.totalPayment ??
                                  "")
                              .split(' ')
                              .first,
                          style: TextStyles.txtSemiBold18
                              (context).copyWith(color: Constant.clrDarkPurple),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          currency,
                          style: TextStyles.txtSemiBold18
                              (context).copyWith(color: Constant.clrDarkPurple),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          getLocalValue("Key_TotalIncome"),
                          style: TextStyles.txtMedium12(context).copyWith(
                            color: Constant.clrBlackWhiteByTheme(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 15.w,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Constant.clrDarkByScaffoldTheme(context),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.h),
                          decoration: BoxDecoration(
                            color: Constant.clrDarkGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: CommonImageAsset(
                            strIcon: Constant.icSubscribers,
                            height: 30.h,
                            width: 30.h,
                          ),
                        ),
                        SizedBox(
                          height: 14.h,
                        ),
                        Text(
                          '',
                          style: TextStyles.txtSemiBold18
                              (context).copyWith(color: Constant.clrDarkPurple, fontSize: 9),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          myRevenueWatch
                                  .revenueChartResponseModel?.data?.totalSubs ??
                              "",
                          style: TextStyles.txtSemiBold18
                              (context).copyWith(color: Constant.clrDarkGreen),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '',
                          style: TextStyles.txtSemiBold18
                              (context).copyWith(color: Constant.clrDarkPurple, fontSize: 9),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          getLocalValue("Key_Subscribers"),
                          style: TextStyles.txtMedium12(context).copyWith(
                            color: Constant.clrBlackWhiteByTheme(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///Chart Widget
  Widget chartWidget(MyRevenueController myRevenueWatch) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              getLocalValue("Key_Statistics"),
              style: TextStyles.txtMedium16
                  (context).copyWith(color: Constant.clrBlackWhiteByTheme(context)),
            ),
            Container(
              height: 26.h,
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: isDarkMode ? Constant.clrBlackOrigin : Constant.clrGreyNew,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MonthModel>(
                  icon: Icon(
                    Icons.arrow_drop_down_outlined,
                    size: 20,
                    color: Constant.clrWhiteBlackByTheme(context),
                  ),
                  hint: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      getLocalValue("Key_Month"),
                      style: TextStyles.txtRegular10(context).copyWith(
                        color: Constant.clrWhiteBlackByTheme(context),
                      ),
                    ),
                  ),
                  value: myRevenueWatch.selectedMonth,
                  dropdownColor: Constant.clrDarkByScaffoldTheme(context),
                  items: myRevenueWatch.monthList.map((MonthModel data) {
                    return DropdownMenuItem<MonthModel>(
                      value: data,
                      child: Text(
                        data.monthName.localized,
                        style: TextStyles.txtRegular10
                            (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
                      ),
                    );
                  }).toList(),
                  underline: Divider(
                    color: Constant.clrPrimary,
                  ),
                  onTap: () {
                    showLog("Tap");
                  },
                  enableFeedback: false,
                  borderRadius: BorderRadius.circular(10.r),
                  onChanged: (newValue) {
                    myRevenueWatch.updateSelectedMonth(newValue!);
                    revenueChartAPICall(myRevenueWatch);
                  },
                ),
              ),
            ),
            Container(
              height: 26.h,
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: isDarkMode ? Constant.clrBlackOrigin : Constant.clrGreyNew,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  icon: Icon(
                    Icons.arrow_drop_down_outlined,
                    size: 20,
                    color: Constant.clrWhiteBlackByTheme(context),
                  ),
                  hint: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      getLocalValue("Key_Year"),
                      style: TextStyles.txtRegular10(context).copyWith(
                        color: Constant.clrWhiteBlackByTheme(context),
                      ),
                    ),
                  ),
                  value: myRevenueWatch.selectedYear,
                  dropdownColor: Constant.clrDarkByScaffoldTheme(context),
                  items: myRevenueWatch.yearList.map((int data) {
                    return DropdownMenuItem<int>(
                      value: data,
                      child: Text(
                        data.toString(),
                        style: TextStyles.txtRegular10
                            (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
                      ),
                    );
                  }).toList(),
                  underline: Divider(
                    color: Constant.clrPrimary,
                  ),
                  onTap: () {
                    showLog("Tap");
                  },
                  enableFeedback: false,
                  borderRadius: BorderRadius.circular(10.r),
                  onChanged: (int? newValue) {
                    myRevenueWatch.updateSelectedYear(newValue!);
                    revenueChartAPICall(myRevenueWatch);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20.h,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 10.h),
          child: Container(
            alignment: getAppLanguage() == 'ar'
                ? Alignment.bottomRight
                : Alignment.bottomLeft,
            padding: EdgeInsets.only(
              right: getAppLanguage() == 'ar' ? 0 : 20.sp,
              left: 0,
              top: 55.h,
            ),
            height: 270.h,
            width: ((myRevenueWatch.revenueChartResponseModel?.data?.graphData
                            ?.length ??
                        0) >
                    10)
                ? 500.h
                : 300.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 30,
                      getTitlesWidget: bottomTitles,
                    ),
                  ),
                  leftTitles: getAppLanguage() == 'ar'
                      ? AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        )
                      : AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: (myRevenueWatch.revenueChartResponseModel
                                        ?.data?.yAxisMaxValue !=
                                    "0")
                                ? double.parse(
                                    (double.parse(myRevenueWatch
                                                    .revenueChartResponseModel
                                                    ?.data
                                                    ?.yAxisMaxValue ??
                                                "10.0") /
                                            10)
                                        .toString(),
                                  )
                                : 10.0,
                            getTitlesWidget: leftTitles,
                          ),
                        ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: getAppLanguage() == 'ar'
                      ? AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: (myRevenueWatch.revenueChartResponseModel
                                        ?.data?.yAxisMaxValue !=
                                    "0")
                                ? double.parse(
                                    (double.parse(myRevenueWatch
                                                    .revenueChartResponseModel
                                                    ?.data
                                                    ?.yAxisMaxValue ??
                                                "10.0") /
                                            10)
                                        .toString(),
                                  )
                                : 10.0,
                            getTitlesWidget: leftTitles,
                          ),
                        )
                      : AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Constant.clrDarkBlue.withOpacity(0.1),
                    strokeWidth: 2,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                groupsSpace: 20,
                barGroups: (myRevenueWatch.revenueChartResponseModel?.data
                            ?.graphData?.length !=
                        0)
                    ? bottomTitleListFromAPI(myRevenueWatch)
                    : (getAppLanguage() == 'ar')
                        ? getDataStatic().reversed.toList()
                        : getDataStatic(),
                maxY: (myRevenueWatch
                            .revenueChartResponseModel?.data?.yAxisMaxValue !=
                        "0")
                    ? double.parse(myRevenueWatch
                            .revenueChartResponseModel?.data?.yAxisMaxValue ??
                        "10.0")
                    : 100.0,
              ),
              swapAnimationCurve: Curves.linear,
              swapAnimationDuration: const Duration(milliseconds: 750),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> bottomTitleListFromAPI(
      MyRevenueController myRevenueWatch) {
    return [
      ...List.generate(
        myRevenueWatch.revenueChartResponseModel?.data?.graphData?.length ?? 0,
        (index) => BarChartGroupData(
          x: (getAppLanguage() == 'ar')
              ? int.parse(myRevenueWatch
                      .revenueChartResponseModel?.data?.graphData?.reversed
                      .toList()[index]
                      .xAxis
                      .toString() ??
                  "0")
              : int.parse(myRevenueWatch
                      .revenueChartResponseModel?.data?.graphData?[index].xAxis
                      .toString() ??
                  "0"),
          barsSpace: 4,
          groupVertically: false,
          barRods: [
            barChartData(
              (getAppLanguage() == 'ar')
                  ? double.parse(myRevenueWatch.revenueChartResponseModel?.data
                              ?.graphData?.reversed
                              .toList()[index]
                              .yAxis
                              .toString()
                              .replaceAll("k", "") ??
                          "")
                      .abs()
                  : double.parse(myRevenueWatch.revenueChartResponseModel?.data
                              ?.graphData?[index].yAxis
                              .toString()
                              .replaceAll("k", "") ??
                          "")
                      .abs(),
            ),
          ],
        ),
      )
    ];
  }

  List<BarChartGroupData> getDataStatic() {
    return [
      BarChartGroupData(x: 1, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 2, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 3, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 4, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 5, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 6, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 7, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 8, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 9, barsSpace: 4, groupVertically: false),
      BarChartGroupData(x: 10, barsSpace: 4, groupVertically: false),
    ];
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    TextStyle style =
        TextStyles.txtMedium8(context).copyWith(fontSize: 7.sp, color: Constant.clrDarkBlue);
    return SideTitleWidget(
      meta: meta,
      child: Text(value.abs().toStringAsFixed(0).toString().toString(),
          style: style),

    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    TextStyle style =
        TextStyles.txtMedium8(context).copyWith(fontSize: 7.sp, color: Constant.clrDarkBlue);
    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: Text(value.abs().toStringAsFixed(0).toString(), style: style),
    );
  }

  barChartData(double toYValue) {
    return BarChartRodData(
      toY: toYValue,
      color: Constant.clrPrimaryLight,
      borderRadius: BorderRadius.all(
        Radius.circular(6.r),
      ),
    );
  }

  Future<void> revenueChartAPICall(MyRevenueController revenueWatch) async {
    if (isInternetConnectionOn) {
      await revenueWatch.revenueChartAPI(context);
    }
  }
}
