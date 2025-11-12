// ignore_for_file: unused_local_variable

import 'package:easy_localization/easy_localization.dart' as es;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/home/currencies_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/notification/notification_controller.dart';
import '../../framework/data_provider/notification/notification_provider.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../drawer/revenue_screen.dart';
import '../home/recommender_details_screen.dart';
import '../home/signals_details_screen.dart';
import '../recommendation/my_recommendation_screen.dart';
import '../request_analysis/request_analysis_details_screen.dart';
import '../request_analysis/request_analysis_screen.dart';

// ============================================================================
// NOTIFICATION HELPER CLASS - Extracted for better organization
// ============================================================================
class NotificationHelper {
  // Get icon and colors based on notification type
  static NotificationIconData getIconData(String slug) {
    if (slug.contains("signal")) {
      return NotificationIconData(
        icon: Icons.show_chart,
        color: const Color(0xFF2196F3),
        bgColor: const Color(0xFF2196F3).withValues(alpha:0.1),
      );
    } else if (slug.contains("tp_target") || slug.contains("profit")) {
      return NotificationIconData(
        icon: Icons.trending_up,
        color: const Color(0xFF4CAF50),
        bgColor: const Color(0xFF4CAF50).withValues(alpha:0.1),
      );
    } else if (slug.contains("stop_loss") || slug.contains("close")) {
      return NotificationIconData(
        icon: Icons.trending_down,
        color: const Color(0xFFF44336),
        bgColor: const Color(0xFFF44336).withValues(alpha:0.1),
      );
    } else if (slug.contains("request")) {
      return NotificationIconData(
        icon: Icons.description,
        color: const Color(0xFFFF9800),
        bgColor: const Color(0xFFFF9800).withValues(alpha:0.1),
      );
    } else if (slug.contains("payment")) {
      return NotificationIconData(
        icon: Icons.attach_money,
        color: const Color(0xFF4CAF50),
        bgColor: const Color(0xFF4CAF50).withValues(alpha:0.1),
      );
    } else if (slug.contains("social_post") || slug.contains("update")) {
      return NotificationIconData(
        icon: Icons.campaign,
        color: const Color(0xFF9C27B0),
        bgColor: const Color(0xFF9C27B0).withValues(alpha:0.1),
      );
    } else if (slug.contains("scenario")) {
      return NotificationIconData(
        icon: Icons.lightbulb_outline,
        color: const Color(0xFFFFEB3B),
        bgColor: const Color(0xFFFFEB3B).withValues(alpha:0.1),
      );
    } else if (slug.contains("trader_sub") || slug.contains("subscription")) {
      return NotificationIconData(
        icon: Icons.person_add,
        color: const Color(0xFF00BCD4),
        bgColor: const Color(0xFF00BCD4).withValues(alpha:0.1),
      );
    }
    // Default
    return NotificationIconData(
      icon: Icons.notifications_outlined,
      color: const Color(0xFF4CAF50),
      bgColor: const Color(0xFF4CAF50).withValues(alpha:0.1),
    );
  }

  // Get subtitle based on notification type
  static String getSubtitle(String slug, bool isTrader) {
    final Map<String, String> traderSubtitles = {
      'signal_update': 'Check your current booking detail...',
      'signal_close': 'Signal has been closed',
      'all_signal_close': 'All signals have been closed',
      'new_scenario': 'New scenario available',
      'stop_loss': 'Stop loss signal triggered',
      'tp_target': 'Take profit target alert',
      'request_completed': 'Your request has been completed',
      'request_refunded': 'Request refunded successfully',
      'signal_create': 'New signal created',
      'signal_activate': 'New signal created',
      'social_post': 'Check the latest update',
    };

    final Map<String, String> recommenderSubtitles = {
      'stop_loss_signal': 'Stop loss signal triggered',
      'tp_target': 'Take profit target alert',
      'signal_close': 'Signal has been closed',
      'new_scenario': 'New scenario available',
      'new_request': 'You have a new request',
      'request_completed': 'Request completed successfully',
      'request_refunded': 'Request refunded',
      'payment_recieved': 'Payment received',
      'new_trader_sub': 'New trader subscription',
      'all_signal_close': 'All signals have been closed',
    };

    final subtitles = isTrader ? traderSubtitles : recommenderSubtitles;

    for (var entry in subtitles.entries) {
      if (slug.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'Tap to view details';
  }

  // Format date to relative string
  static String getDateKey(DateTime date) {
    final now = DateTime.now();
    final notificationDate = date.add(date.timeZoneOffset);

    if (notificationDate.year == now.year &&
        notificationDate.month == now.month &&
        notificationDate.day == now.day) {
      return "Today";
    } else if (notificationDate.year == now.year &&
        notificationDate.month == now.month &&
        notificationDate.day == now.day - 1) {
      return "Yesterday";
    } else {
      return es.DateFormat('MMMM dd, yyyy').format(notificationDate);
    }
  }
}

// Data class for icon information
class NotificationIconData {
  final IconData icon;
  final Color color;
  final Color bgColor;

  NotificationIconData({
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

// ============================================================================
// MAIN NOTIFICATION SCREEN
// ============================================================================
class NotificationScreen extends ConsumerStatefulWidget {
  final bool isFromDrawer;

  const NotificationScreen({super.key, this.isFromDrawer = false});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final SwipeActionController _swipeController = SwipeActionController();

  // State
  int _selectedFilterIndex = 0; // 0: All, 1: Unread
  bool _isSelectionMode = false;
  Set<String> _selectedIds = {};

  // Computed properties
  List<dynamic> get _filteredNotifications {
    final notificationWatch = ref.watch(notificationProvider);
    if (_selectedFilterIndex == 0) {
      return notificationWatch.notificationList;
    }
    return notificationWatch.notificationList
        .where((n) => n.isRead == "0" || n.isRead == null)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _setupScrollListener();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  void _initializeData() {
    final notificationWatch = ref.watch(notificationProvider);
    _fetchNotifications(notificationWatch, true);
  }

  void _setupScrollListener() {
    _scrollController.addListener(() async {
      final notificationWatch = ref.watch(notificationProvider);
      if (!notificationWatch.isHasMorePage) return;

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreNotifications(notificationWatch);
      }
    });
  }

  void _loadMoreNotifications(NotificationController controller) {
    final currentPage = int.parse(
        controller.notificationListResponseModel?.data?.pageNumber?.toString() ?? "0");
    final totalPages = int.parse(
        controller.notificationListResponseModel?.data?.totalPage?.toString() ?? "0");

    if (currentPage != totalPages) {
      _fetchNotifications(controller, false);
    }
  }

  // ============================================================================
  // BUILD UI
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    final notificationWatch = ref.watch(notificationProvider);
    final currenciesWatch = ref.watch(currenciesProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop,dynamic result) { {
        _handleBackPress();
      }
      },
      
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Constant.clrScaffoldBGByTheme(context),
            appBar: _buildAppBar(),
            body: NoInternetBuilder(
              child: Column(
                children: [
                  if (!_isSelectionMode) _buildFilterTabs(notificationWatch),
                  if (_isSelectionMode) _buildSelectionBar(notificationWatch),
                  Expanded(child: _buildNotificationList(currenciesWatch, notificationWatch)),
                  _buildPaginationLoader(notificationWatch),
                ],
              ),
            ),
          ),
          DialogProgressBar(isLoading: notificationWatch.isLoading),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CommonAppBar(
      title: _isSelectionMode
          ? "${_selectedIds.length} Selected"
          : getLocalValue("Key_Notification"),
      titleTextStyle: TextStyles.txtMedG16(context),
      isTitleCenter: false,
      onPress: () {
        if (_isSelectionMode) {
          _exitSelectionMode();
        } else {
          Navigator.pop(context, true);
        }
      },
      appBar: AppBar(backgroundColor: Constant.clrBasicByTheme(context), toolbarHeight: 64.h),
      isDrawer: widget.isFromDrawer,
    );
  }

  Widget _buildFilterTabs(NotificationController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          _buildFilterChip(getLocalValue("Key_AllNotifications"), 0),
          SizedBox(width: 11.w),
          _buildFilterChip(getLocalValue("Key_Unread"), 1),
          const Spacer(),
          _buildDeleteAllButton(controller),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7B61FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7B61FF)
                : Constant.clrGreyNew.withValues(alpha:0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyles.txtMedG12(context).copyWith(
            color: isSelected ? Colors.white : Constant.clrGrey2,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAllButton(NotificationController controller) {
    return InkWell(
      onTap: () => _showDeleteAllDialog(controller),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Constant.clrNotifDeleteRColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          getLocalValue("Key_DeleteAll"),
          style: TextStyles.txtRegG12(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBar(NotificationController controller) {
    final allSelected = _selectedIds.length == _filteredNotifications.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF7B61FF).withValues(alpha:0.1),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF7B61FF).withValues(alpha:0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildSelectionButton(
            label: allSelected ? "Key_DeselectAll".localized :"Key_SelectAll".localized,
            onTap: _toggleSelectAll,
            isPrimary: false,
          ),
          const Spacer(),
          _buildSelectionButton(
            label: getLocalValue("Key_Delete"),
            icon: Icons.delete_outline,
            onTap: _selectedIds.isEmpty ? null : () => _showDeleteSelectedDialog(controller),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton({
    required String label,
    IconData? icon,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    final isDisabled = onTap == null;
    final bgColor = isPrimary
        ? (isDisabled ? Colors.grey.withValues(alpha:0.3) : Constant.clrNotifDeleteRColor)
        : Constant.clrDarkByScaffoldTheme(context);
    final textColor = isPrimary
        ? (isDisabled ? Colors.grey : Colors.white)
        : const Color(0xFF7B61FF);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15.r),
          border: isPrimary ? null : Border.all(color: const Color(0xFF7B61FF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 18.sp),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyles.txtRegG12(context).copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(
      CurrenciesScreenController currenciesWatch,
      NotificationController notificationWatch,
      ) {
    if (_filteredNotifications.isEmpty && !notificationWatch.isLoading) {
      return EmptyStateWidget(emptyStateFor: EmptyState.noNotificationFound);
    }

    final grouped = _groupByDate();

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: (MediaQuery.of(context).padding.bottom + 62).h),
      itemCount: grouped.length,
      itemBuilder: (context, sectionIndex) {
        final dateKey = grouped.keys.elementAt(sectionIndex);
        final notifications = grouped[dateKey]!;

        return _buildDateSection(dateKey, notifications, notificationWatch);
      },
    );
  }

  Widget _buildDateSection(
      String dateKey,
      List<dynamic> notifications,
      NotificationController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(dateKey),
        ...notifications.map((item) => _buildNotificationCard(item, controller)),
      ],
    );
  }

  Widget _buildDateHeader(String dateKey) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Text(
          dateKey,
          style: TextStyles.txtMedG12(context)
      ),),
    );
  }

  Widget _buildNotificationCard(dynamic item, NotificationController controller) {
    final isSelected = _selectedIds.contains(item.id);
    final globalIndex = controller.notificationList.indexOf(item);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          // Selection Checkbox (outside card on the left)
          if (_isSelectionMode)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: InkWell(
                onTap: () => _toggleSelection(item.id ?? ""),
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ?  Constant.clrNotifSelectBColor : Colors.transparent,
                    // border: Border.all(
                    //   color: isSelected ? const Color(0xFF7B61FF) : Constant.clrGreyNew,
                    //   width: 2,
                    // ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                      : null,
                ),
              ),
            ),

          // Notification Card
          Expanded(
            child: InkWell(
              onTap: () => _handleNotificationTap(item, globalIndex, controller),
              onLongPress: () => _handleNotificationLongPress(item),
              child: Container(
                decoration: BoxDecoration(
                  color: Constant.clrDarkByScaffoldTheme(context),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildCardContent(item, controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(dynamic item, NotificationController controller) {
    // Disable swipe in selection mode by conditionally rendering
    if (_isSelectionMode) {
      return Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(item.slug ?? ""),
            SizedBox(width: 12.w),
            Expanded(child: _buildNotificationContent(item)),
          ],
        ),
      );
    }

    return SwipeActionCell(
      backgroundColor: Colors.transparent,
      key: ObjectKey(item.id),
      controller: _swipeController,
      closeWhenScrolling: true,
      trailingActions: [_buildSwipeDeleteAction(item, controller)],
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(item.slug ?? ""),
            SizedBox(width: 12.w),
            Expanded(child: _buildNotificationContent(item)),
          ],
        ),
      ),
    );
  }

  SwipeAction _buildSwipeDeleteAction(dynamic item, NotificationController controller) {
    return SwipeAction(
      icon: Icon(Icons.delete, color: Constant.clrWhite),
      backgroundRadius: 12.r,
      widthSpace: 80.w,
      title: getLocalValue("Key_Delete"),
      style: TextStyle(
        fontFamily: Constant.fontFamily,
        fontSize: 10.sp,
        color: Constant.clrWhite,
      ),
      onTap: (handler) => _showDeleteSingleDialog(controller, item.id ?? ""),
    );
  }

  Widget _buildNotificationIcon(String slug) {
    final iconData = NotificationHelper.getIconData(slug);

    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: iconData.bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: iconData.color.withValues(alpha:0.3), width: 2),
      ),
      child: Icon(iconData.icon, color: iconData.color, size: 24.sp),
    );
  }

  Widget _buildNotificationContent(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.content ?? "",
                style: TextStyles.txtMedG14(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              es.DateFormat('HH:mm').format(
                item.createdAt!.add(item.createdAt!.timeZoneOffset),
              ),
              style: TextStyles.txtMedG10(context).copyWith(
                color: Constant.clrGreyNew,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          NotificationHelper.getSubtitle(
            item.slug ?? "",
            getUserStatus() == trader,
          ),
          style: TextStyles.txtMedG10(context).copyWith(
            color: Constant.clrSubTitleGColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPaginationLoader(NotificationController controller) {
    return DialogProgressBar(
      isLoading: controller.isLoadingPagination,
      forPagination: true,
    ).paddingOnly(bottom: 40.h);
  }

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================
  Future<bool> _handleBackPress() async {
    if (_isSelectionMode) {
      _exitSelectionMode();
      return false;
    }
    Navigator.pop(context, true);
    return true;
  }

  void _handleNotificationTap(dynamic item, int index, NotificationController controller) {
    if (_isSelectionMode) {
      _toggleSelection(item.id ?? "");
    } else {
      _navigateToDetails(index, controller);
    }
  }

  void _handleNotificationLongPress(dynamic item) {
    setState(() {
      if (!_isSelectionMode) _isSelectionMode = true;
      _toggleSelection(item.id ?? "");
    });
  }

  // ============================================================================
  // SELECTION MANAGEMENT
  // ============================================================================
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _filteredNotifications.length) {
        _selectedIds.clear();
      } else {
        _selectedIds = _filteredNotifications.map((n) => n.id as String).toSet();
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  // ============================================================================
  // DATA OPERATIONS
  // ============================================================================
  Map<String, List<dynamic>> _groupByDate() {
    final Map<String, List<dynamic>> grouped = {};

    for (var notification in _filteredNotifications) {
      if (notification.createdAt == null) continue;

      final dateKey = NotificationHelper.getDateKey(notification.createdAt!);
      grouped.putIfAbsent(dateKey, () => []).add(notification);
    }

    return grouped;
  }

  Future<void> _fetchNotifications(NotificationController controller, bool clearOld) async {
    if (clearOld) controller.isHasMorePage = false;
    if (isInternetConnectionOn) {
      await controller.notificationListAPI(context);
    }
  }

  Future<void> _deleteNotification(NotificationController controller, String id) async {
    if (!isInternetConnectionOn) return;

    await controller.notificationDeleteAPI(context, id);
    if (controller.commonResponseModel.status == ApiEndPoints.apiStatus_200) {
      _fetchNotifications(controller, true);
    }
  }

  Future<void> _deleteMultipleNotifications(
      NotificationController controller,
      List<String> ids,
      ) async {
    if (!isInternetConnectionOn) return;

    for (String id in ids) {
      await controller.notificationDeleteAPI(context, id);
    }

    if (controller.commonResponseModel.status == ApiEndPoints.apiStatus_200) {
      _exitSelectionMode();
      _fetchNotifications(controller, true);
    }
  }

  // ============================================================================
  // DIALOGS
  // ============================================================================
  void _showDeleteSingleDialog(NotificationController controller, String id) {
    showConfirmationDialog(
      context,
      "",
      "Key_Delete".localized,
      "Key_DeleteAll".localized,
          (result) {
        _swipeController.closeAllOpenCell();
        if (result) _deleteNotification(controller, id);
      },
    );
  }

  void _showDeleteSelectedDialog(NotificationController controller) {
    showConfirmationDialog(
      context,
      "",
      "Key_Delete".localized,
      "Delete ${_selectedIds.length} notification(s)?",
          (result) {
        if (result) {
          _deleteMultipleNotifications(controller, _selectedIds.toList());
        }
      },
    );
  }

  void _showDeleteAllDialog(NotificationController controller) {
    showConfirmationDialog(
      context,
      "",
      "Key_Delete".localized,
      "Key_DeleteAll".localized,
          (result) {
        if (result) {
          final allIds = controller.notificationList.map((n) => n.id as String).toList();
          _deleteMultipleNotifications(controller, allIds);
        }
      },
    );
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================
  void _navigateToDetails(int index, NotificationController controller) {
    if (controller.notificationList.isEmpty) return;

    final notification = controller.notificationList[index];
    final slug = notification.slug?.toString() ?? "";
    final id = notification.dataId;
    final recommenderId = notification.recommenderId;

    final route = _getRouteForNotification(slug, id, recommenderId);
    if (route != null) {
      Navigator.push(context, SlideRightPageRoute(
        builder: (context) => route,
        settings: const RouteSettings(),
      ));
    }
  }

  Widget? _getRouteForNotification(String slug, String? id, String? recommenderId) {
    final isTrader = getUserStatus() == trader;

    // Signal-related notifications
    if (slug.contains("signal_update") || slug.contains("signal_create") ||
        slug.contains("signal_activate") || slug.contains("tp_target_trader_alert") ||
        slug.contains("tp_target_sub_trader_alert") || slug.contains("tp_target_alert")) {
      return SignalDetailsScreen(
        signalData: null,
        signalId: id,
        seeAllScreen: isTrader
            ? SeeAllScreen.fromRecommenderDetailsActive
            : SeeAllScreen.fromMyRecommenderSignalActive,
      );
    }

    if (slug.contains("signal_close")) {
      return SignalDetailsScreen(
        signalData: null,
        signalId: id,
        seeAllScreen: SeeAllScreen.fromRecommenderDetailsClosed,
      );
    }

    if (slug.contains("stop_loss")) {
      return SignalDetailsScreen(
        signalData: null,
        signalId: id,
        seeAllScreen: SeeAllScreen.fromRecommenderDetailsClosed,
      );
    }

    // Scenario notifications
    if (slug.contains("new_scenario")) {
      return RecommenderDetailScreen(
        recommenderID: recommenderId ?? "",
        notificationTraderSlug: isTrader ? NotificationSlugTrader.new_scenario : null,
        notificationSlugRecommender: !isTrader ? NotificationSlugRecommender.new_scenario : null,
      );
    }

    // All signals closed
    if (slug.contains("all_signal_close")) {
      if (isTrader) {
        return RecommenderDetailScreen(
          recommenderID: recommenderId ?? "",
          notificationTraderSlug: NotificationSlugTrader.all_signal_close,
        );
      } else {
        return MyRecommendationSignalScreen(
          isFromBottom: false,
          selectedSignalIndex: slug.contains("failed") ? 1 : 2,
        );
      }
    }

    // Request-related notifications
    if (slug.contains("request_completed")) {
      if (isTrader) {
        return RequestAnalysisScreen(
          notificationTraderSlug: NotificationSlugTrader.request_completed,
        );
      } else {
        return RequestAnalysisScreen(
          notificationSlugRecommender: NotificationSlugRecommender.request_completed,
        );
      }
    }

    if (slug.contains("request_refunded")) {
      return RequestAnalysisDetailsScreen(
        requestAnalysisData: null,
        notificationSlugTrader: isTrader ? NotificationSlugTrader.request_refunded : null,
        notificationSlugRecommender: !isTrader ? NotificationSlugRecommender.request_refunded : null,
        requestAnalysisId: id,
      );
    }

    if (slug.contains("new_request")) {
      return RequestAnalysisScreen(
        notificationSlugRecommender: NotificationSlugRecommender.new_request,
      );
    }

    // Social post notifications
    if (slug.contains("social_post")) {
      return RecommenderDetailScreen(
        recommenderID: recommenderId!,
        notificationTraderSlug: slug.contains("update")
            ? NotificationSlugTrader.update_social_post
            : NotificationSlugTrader.new_social_post,
      );
    }

    // Payment notification
    if (slug.contains("payment_recieved")) {
      return MyRevenue(isFromDrawer: false);
    }

    // Trader achievement
    if (slug.contains("tp_target_trader_achieve_alert") ||
        slug.contains("tp_target_achieve_alert")) {
      return SignalDetailsScreen(
        signalData: null,
        signalId: id,
        recommenderID: recommenderId,
        seeAllScreen: SeeAllScreen.fromRecommenderDetailsClosed,
      );
    }

    // New trader subscription
    if (slug.contains("new_trader_sub")) {
      return RecommenderDetailScreen(recommenderID: recommenderId!);
    }

    return null;
  }
}