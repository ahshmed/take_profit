import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/request_analysis/request_analysis_details_screen.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/request_analysis/request_analsis_provider.dart';
import '../../framework/data_provider/request_analysis/request_analysis_controller.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_svg.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';

class RequestAnalysisScreen extends ConsumerStatefulWidget {
  final NotificationSlugTrader? notificationTraderSlug;
  final NotificationSlugRecommender? notificationSlugRecommender;

  const RequestAnalysisScreen({
    Key? key,
    this.notificationTraderSlug,
    this.notificationSlugRecommender,
  }) : super(key: key);

  @override
  ConsumerState<RequestAnalysisScreen> createState() =>
      _RequestAnalysisScreenState();
}

class _RequestAnalysisScreenState extends ConsumerState<RequestAnalysisScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final requestAnalysisWatch = ref.read(requestAnalysisProvider);
      requestAnalysisWatch.clearProvider(true);

      _requestAnalysisListAPICall(
        requestAnalysisWatch,
        status: requestAnalysisWatch.tabIndex == '0' ? 'pending' : 'completed',
        isHasMorePage: false,
      );

      // Handle notification navigation
      if (widget.notificationTraderSlug ==
          NotificationSlugTrader.request_completed ||
          widget.notificationSlugRecommender ==
              NotificationSlugRecommender.request_completed) {
        requestAnalysisWatch.setSelectedTabIndex("1");
        _requestAnalysisListAPICall(
          requestAnalysisWatch,
          status: "completed",
          isHasMorePage: false,
        );
      }

      // Pagination listener
      _scrollController.addListener(() async {
        if (requestAnalysisWatch.isHasMorePage) {
          if (_scrollController.position.maxScrollExtent ==
              _scrollController.position.pixels) {
            final currentPage = int.parse(requestAnalysisWatch
                .requestAnalysisListResponseModel?.data?.pageNumber
                ?.toString() ??
                "0");
            final totalPages = int.parse(requestAnalysisWatch
                .requestAnalysisListResponseModel?.data?.totalPage
                .toString() ??
                "0");

            if (currentPage != totalPages) {
              _requestAnalysisListAPICall(
                requestAnalysisWatch,
                status: requestAnalysisWatch.tabIndex == '0'
                    ? 'pending'
                    : 'completed',
                isHasMorePage: true,
              );
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestAnalysisWatch = ref.watch(requestAnalysisProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrBasicByTheme(context),
          appBar: _buildAppBar(),
          body: NoInternetBuilder(
            child: _buildBody(requestAnalysisWatch),
          ),
        ),
        DialogProgressBar(isLoading: requestAnalysisWatch.isLoading),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CommonAppBar(
      appBar: AppBar(),
      backgroundColor: Constant.clrBasicByTheme(context),
      isDrawer: widget.notificationSlugRecommender == null &&
          widget.notificationTraderSlug == null,
      title: "Request Analysis",
      isTitleCenter: false,
    );
  }

  Widget _buildBody(RequestAnalysisController requestAnalysisWatch) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          _buildTabBar(requestAnalysisWatch),
          SizedBox(height: 20.h),
          _buildListContent(requestAnalysisWatch),
          DialogProgressBar(
            isLoading: requestAnalysisWatch.isLoadingPagination,
            forPagination: true,
          ).paddingOnly(bottom: 40.h),
        ],
      ),
    );
  }

  /// Modern Tab Bar
  Widget _buildTabBar(RequestAnalysisController requestAnalysisWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Constant.clrCardCurrGColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Constant.clrTextBorderGColor,
          width: 1,
        ),
      ),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: _buildTabButton(
              label: getUserStatus() == "recommender"
                  ? "Key_Pending".localized
                  : "Key_Active".localized,
              isSelected: requestAnalysisWatch.tabIndex == "0",
              onTap: () {
                requestAnalysisWatch.setSelectedTabIndex("0");
                _requestAnalysisListAPICall(
                  requestAnalysisWatch,
                  status: "pending",
                  isHasMorePage: false,
                );
              },
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _buildTabButton(
              label: "Key_Analyzed".localized,
              isSelected: requestAnalysisWatch.tabIndex == "1",
              onTap: () {
                requestAnalysisWatch.setSelectedTabIndex("1");
                _requestAnalysisListAPICall(
                  requestAnalysisWatch,
                  status: "completed",
                  isHasMorePage: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyles.txtSemiBoldG12(context).copyWith(
              color: isSelected ? Colors.white : Constant.clrSubTitleUploadGColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// List Content Router
  Widget _buildListContent(RequestAnalysisController requestAnalysisWatch) {
    if (requestAnalysisWatch.tabIndex == "0") {
      return getUserStatus() == "recommender"
          ? _buildPendingList(requestAnalysisWatch)
          : _buildActiveList(requestAnalysisWatch);
    } else {
      return _buildAnalyzedList(requestAnalysisWatch);
    }
  }

  /// Pending List (For Recommenders)
  Widget _buildPendingList(RequestAnalysisController requestAnalysisWatch) {
    return Expanded(
      child: (requestAnalysisWatch.requestAnalysisListData.isEmpty &&
          !requestAnalysisWatch.isLoading)
          ? EmptyStateWidget(emptyStateFor: EmptyState.noDataFound)
          : ListView.separated(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        padding: EdgeInsets.zero,
        itemCount: requestAnalysisWatch.requestAnalysisListData.length,
        itemBuilder: (context, index) {
          final item = requestAnalysisWatch.requestAnalysisListData[index];
          return _buildPendingCard(item, requestAnalysisWatch);
        },
      ),
    );
  }

  /// Pending Card Design
  Widget _buildPendingCard(
      dynamic item,
      RequestAnalysisController requestAnalysisWatch,
      ) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      onTap: () => _handlePendingItemTap(item, requestAnalysisWatch),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Constant.clrTextBorderGColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Request ID & Status
            Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "${"Key_RequestId".localized}: ",
                      style: TextStyles.txtRegG12(context).copyWith(
                        color: Constant.clrSubTitleUploadGColor,
                      ),
                      children: [
                        TextSpan(
                          text: "#${item.requestId}",
                          style: TextStyles.txtSemiBoldG12(context).copyWith(
                            color: Constant.clrTitleUploadByTheme(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildStatusBadge(item.status.toString()),
              ],
            ),
            SizedBox(height: 12.h),

            // Divider
            Container(
              height: 1,
              color: Constant.clrTextBorderGColor,
            ),
            SizedBox(height: 12.h),

            // Request By & Date
            Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildInfoRow(
                    "Key_RequestBy".localized,
                    item.requestBy ?? "-",
                  ),
                ),
                _buildInfoRow(
                  "Key_Date".localized,
                  item.createdAt ?? "-",
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Amount
            _buildInfoRow(
              "Key_Amount".localized,
              item.amount ?? "-",
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Active List (For Traders)
  Widget _buildActiveList(RequestAnalysisController requestAnalysisWatch) {
    return Expanded(
      child: (requestAnalysisWatch.requestAnalysisListData.isEmpty &&
          !requestAnalysisWatch.isLoading)
          ? EmptyStateWidget(emptyStateFor: EmptyState.noDataFound)
          : ListView.separated(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        padding: EdgeInsets.zero,
        itemCount: requestAnalysisWatch.requestAnalysisListData.length,
        itemBuilder: (context, index) {
          final item = requestAnalysisWatch.requestAnalysisListData[index];
          return _buildAnalysisCard(item, requestAnalysisWatch);
        },
      ),
    );
  }

  /// Analyzed List (Completed)
  Widget _buildAnalyzedList(RequestAnalysisController requestAnalysisWatch) {
    return Expanded(
      child: (requestAnalysisWatch.requestAnalysisListData.isEmpty &&
          !requestAnalysisWatch.isLoading)
          ? EmptyStateWidget(emptyStateFor: EmptyState.noDataFound)
          : ListView.separated(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        padding: EdgeInsets.zero,
        itemCount: requestAnalysisWatch.requestAnalysisListData.length,
        itemBuilder: (context, index) {
          final item = requestAnalysisWatch.requestAnalysisListData[index];
          return _buildAnalysisCard(item, requestAnalysisWatch);
        },
      ),
    );
  }

  /// Analysis Card (For Active & Analyzed Lists)
  Widget _buildAnalysisCard(
      dynamic item,
      RequestAnalysisController requestAnalysisWatch,
      ) {
    final drawerWatch = ref.watch(drawerProvider);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      onTap: () => _navigateToDetails(item, requestAnalysisWatch),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Constant.clrTextBorderGColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // Screenshot Thumbnail
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Constant.clrTextBorderGColor,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.r),
                child: item.image?.toString().isNotEmpty == true
                    ? CacheImage(
                  imageURL: item.image.toString(),
                  height: 60.w,
                  width: 60.w,
                  contentMode: BoxFit.cover,
                )
                    : Icon(
                  Icons.image_not_supported_outlined,
                  color: Constant.clrIconUploadGColor,
                  size: 30.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: isRTL
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    item.requestDescription?.toString() ?? "No description",
                    style: TextStyles.txtRegG12(context).copyWith(
                      color: Constant.clrTitleUploadByTheme(context),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                  SizedBox(height: 8.h),
                  _buildStatusBadge(item.status.toString()),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Arrow Icon
            Transform.rotate(
              angle: (drawerWatch.isEngEnable == false) ? pi : 0,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Constant.clrSubTitleUploadGColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Status Badge Component
  Widget _buildStatusBadge(String status) {
    final statusLower = status.toLowerCase();
    Color bgColor;

    switch (statusLower) {
      case "pending":
        bgColor = Color(0xFFEF4444);
        break;
      case "completed":
        bgColor = Color(0xFF10B981);
        break;
      case "refunded":
        bgColor = Color(0xFFFBBF24);
        break;
      default:
        bgColor = Color(0xFF6B7280);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.capitalizeFirstLetterOfSentence,
        style: TextStyles.txtSemiBoldG10(context).copyWith(
          color: Colors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Info Row Component
  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return RichText(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      text: TextSpan(
        text: "$label: ",
        style: TextStyles.txtRegG12(context).copyWith(
          color: Constant.clrSubTitleUploadGColor,
        ),
        children: [
          TextSpan(
            text: value,
            style: TextStyles.txtRegG12(context).copyWith(
              color: highlight
                  ? Color(0xFF6366F1)
                  : Constant.clrTitleUploadByTheme(context),
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Navigation & API Methods ====================

  void _handlePendingItemTap(
      dynamic item,
      RequestAnalysisController requestAnalysisWatch,
      ) {
    if (item.isRequester == 'no') {
      _navigateToDetails(item, requestAnalysisWatch);
    } else {
      showMessageDialog(
        context,
        getLocalValue('Key_Pleasewaitwhileyourrequestisbeinganalyzed'),
            () {},
      );
    }
  }

  void _navigateToDetails(
      dynamic item,
      RequestAnalysisController requestAnalysisWatch,
      ) {
    Route route = SlideRightPageRoute(
      builder: (context) => RequestAnalysisDetailsScreen(
        requestAnalysisData: item,
        requestAnalysisId: "",
      ),
      settings: const RouteSettings(),
    );

    Navigator.push(context, route).then((value) {
      if (value == "pending") {
        _requestAnalysisListAPICall(
          requestAnalysisWatch,
          status: item.status.toString(),
          isHasMorePage: false,
        );
      } else {
        _requestAnalysisListAPICall(
          requestAnalysisWatch,
          status: "completed",
          isHasMorePage: false,
        );
      }
    });
  }

  Future<void> _requestAnalysisListAPICall(
      RequestAnalysisController requestAnalysisWatch, {
        required String status,
        required bool isHasMorePage,
      }) async {
    await requestAnalysisWatch.requestAnalysisListAPI(
      context,
      status: status,
      isHarMorePagee: isHasMorePage,
    );
  }
}