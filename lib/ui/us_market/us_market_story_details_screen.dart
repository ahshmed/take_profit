import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import 'package:take_profit/utils/sliderightroute.dart';
import '../../utils/const.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import 'edit_us_market_story_screen.dart';

/// Details screen for US Market stories (Active/Pending)
/// Shows story information with Edit and Close buttons at the bottom
class USMarketStoryDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> story;
  final VoidCallback? onClose;

  const USMarketStoryDetailsScreen({
    Key? key,
    required this.story,
    this.onClose,
  }) : super(key: key);

  @override
  ConsumerState<USMarketStoryDetailsScreen> createState() =>
      _USMarketStoryDetailsScreenState();
}

class _USMarketStoryDetailsScreenState
    extends ConsumerState<USMarketStoryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        appBar: AppBar(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          toolbarHeight: 64.h,
        ),
        title: getLocalValue("Key_StoryDetails"),
        titleTextStyle: TextStyles.txtMedG16(context),
        isTitleCenter: false,
        isDrawer: false,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStoryCard(),
        ],
      ),
    );
  }

  /// Story Card matching the design from recommendation screen
  Widget _buildStoryCard() {
    final String statusKey = widget.story['status'] == 'Active'
        ? 'Key_Active'
        : widget.story['status'] == 'Pending'
            ? 'Key_Pending'
            : 'Key_Closed';
    final String statusLabel = getLocalValue(statusKey);
    final String riskLabel = _getLocalizedRiskLabel(widget.story['risk']);
    final bool isRTL = getAppLanguage() == 'ar';

    return Container(
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
      child: Stack(
        children: [
          // Main content with padding
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Time
                Text(
                  widget.story['date'],
                  style: TextStyles.txtRegular12(context).copyWith(
                    color:
                        Constant.clrTitlePageByTheme(context).withOpacity(0.5),
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 12.h),

                // Stock Title with Logo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stock Icon
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Constant.clrPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Text(
                          widget.story['ticker']
                              .substring(
                                  0,
                                  widget.story['ticker'].length >= 2
                                      ? 2
                                      : widget.story['ticker'].length)
                              .toUpperCase(),
                          style: TextStyles.txtBold16(context).copyWith(
                            color: Constant.clrPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Company Name and Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.story['name']} (${widget.story['ticker']})',
                            style: TextStyles.txtSemiBold16(context).copyWith(
                              color: Constant.clrTitlePageByTheme(context),
                              fontSize: 15.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),

                          // Price in Blue
                          Text(
                            widget.story['price'],
                            style: TextStyles.txtSemiBold18(context).copyWith(
                              color: Constant.clrBlue,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add spacing for status tags so text doesn't overlap
                    SizedBox(width: 105.w),
                  ],
                ),
              ],
            ),
          ),

          // Status Tags positioned at card edge (matching US Market screen exactly)
          Positioned(
            top: 40.h,
            right: isRTL ? null : 0,
            left: isRTL ? 0 : null,
            child: Column(
              crossAxisAlignment: isRTL
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                // Status Tag (Active/Pending/Closed)
                Container(
                  width: 97.w,
                  height: 23.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusBadgeColor(widget.story['status']),
                    borderRadius: isRTL
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
                    statusLabel,
                    style: TextStyles.txtSemiBoldG10(context).copyWith(
                      fontWeight: Constant.fwRegular,
                      color: Constant.clrWhite,
                      fontSize: 10.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 6.h),

                // Risk Tag (High/Medium/Low)
                Container(
                  width: 97.w,
                  height: 23.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getRiskBadgeColor(widget.story['risk']),
                    borderRadius: isRTL
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
                    riskLabel,
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
          ),
        ],
      ),
    );
  }

  /// Bottom Buttons (Close and Edit)
  Widget _buildBottomButtons() {
    // Get safe area bottom padding (handles navigation buttons on Android)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: bottomPadding > 0 ? bottomPadding : 20.h,
        top: 16.h,
      ),
      decoration: BoxDecoration(
        color: Constant.clrScaffoldBGByTheme(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CommonButton(
              label: getLocalValue("Key_CloseSignal"),
              textSize: 16.sp,
              onTap: () => _showCloseSignalConfirmation(),
              height: 56.h,
              bgColor: Colors.white,
              labelColor: const Color(0xFF1A1A1A),
              borderColor: const Color(0xFFE5E7EB),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CommonButton(
              label: getLocalValue("Key_Edit"),
              textSize: 16.sp,
              onTap: () => _navigateToEditStory(),
              height: 56.h,
              bgColor: const Color(0xFF6366F1),
              labelColor: Colors.white,
              borderColor: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  void _showCloseSignalConfirmation() {
    showConfirmationDialog(
      context,
      '',
      getLocalValue("Key_CloseSignal"),
      getLocalValue("Key_CloseSignalConfirmMsg"),
      (isPositive) {
        if (isPositive) {
          // Close the story
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.story['ticker']} ${getLocalValue("Key_CloseSignal")}',
                style: TextStyles.txtRegular14(context).copyWith(
                  color: Constant.clrWhite,
                ),
              ),
              backgroundColor: const Color(0xFF32C671),
            ),
          );

          // Call the onClose callback if provided
          if (widget.onClose != null) {
            widget.onClose!();
          }

          // Go back to previous screen
          Navigator.pop(context, true);
        }
      },
      dialogInsidePadding: EdgeInsets.all(15.h),
      borderRadius: 16.r,
      titleTextStyle: TextStyles.txtMedium24(context).copyWith(
        color: Constant.clrTextMainFontByTheme(context),
        fontSize: 22.sp,
      ),
      titleTxtPadding: EdgeInsets.only(top: 10.h, bottom: 5.h),
      messageTextStyle: TextStyles.txtMedium14(context).copyWith(
        color: Constant.clrBlackNew,
      ),
      msgTxtPadding: EdgeInsets.only(bottom: 10.h, left: 58.w, right: 58.w),
      warning: getLocalValue("Key_CloseSignalWarningMsg"),
      yesBtnTextClr: Constant.clrBlackNew,
      yesBtnBGClr: Constant.clrWhite,
      yesBtnBorderClr: Constant.clrGreyNew,
      yesBtnWidth: 146.w,
      noBtnWidth: 146.w,
      buttonRadius: 30.r,
      noBtnTextClr: Constant.clrWhite,
      noBtnBGClr: Constant.clrPrimary,
      noBtnBorderClr: Constant.clrPrimary,
    );
  }

  void _navigateToEditStory() {
    // Navigate to edit screen for adding technical analysis
    Route route = SlideRightPageRoute(
      builder: (context) => EditUSMarketStoryScreen(story: widget.story),
      settings: const RouteSettings(),
    );
    Navigator.of(context).push(route);
  }

  // Helper methods
  String _getLocalizedRiskLabel(String risk) {
    if (risk == 'High') {
      return getLocalValue('Key_HighRisk');
    } else if (risk == 'Medium') {
      return getLocalValue('Key_MediumRisk');
    } else {
      return getLocalValue('Key_LowRisk');
    }
  }

  Color _getStatusBadgeColor(String status) {
    if (status == 'Active') {
      return const Color(0xFF10B981); // Green
    } else if (status == 'Pending') {
      return const Color(0xFFFBBF24); // Yellow/Orange
    } else {
      return const Color(0xFF6B7280); // Gray
    }
  }

  Color _getRiskBadgeColor(String risk) {
    if (risk == 'High') {
      return const Color(0xFFEF4444); // Red
    } else if (risk == 'Medium') {
      return const Color(0xFFF59E0B); // Orange
    } else {
      return const Color(0xFF10B981); // Green
    }
  }
}
