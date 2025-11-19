import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import '../../utils/const.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';

/// Screen for editing US Market story technical analysis
class EditUSMarketStoryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> story;

  const EditUSMarketStoryScreen({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  ConsumerState<EditUSMarketStoryScreen> createState() =>
      _EditUSMarketStoryScreenState();
}

class _EditUSMarketStoryScreenState
    extends ConsumerState<EditUSMarketStoryScreen> {
  final TextEditingController _technicalAnalysisController =
      TextEditingController();
  final int maxCharacters = 3000;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing technical analysis if available
    _technicalAnalysisController.text =
        widget.story['technicalAnalysis'] ?? '';
  }

  @override
  void dispose() {
    _technicalAnalysisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        appBar: AppBar(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          toolbarHeight: 64.h,
        ),
        title: getLocalValue("Key_EditStory"),
        titleTextStyle: TextStyles.txtMedG16(context),
        isTitleCenter: false,
        isDrawer: false,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock Info Header
          _buildStockHeader(),
          SizedBox(height: 24.h),

          // Technical Analysis Section
          Text(
            getLocalValue("Key_TechnicalAnalysis"),
            style: TextStyles.txtSemiBold18(context).copyWith(
              color: Constant.clrTitlePageByTheme(context),
            ),
          ),
          SizedBox(height: 12.h),

          // Technical Analysis Text Field
          Container(
            decoration: BoxDecoration(
              color: Constant.clrHomeCardByTheme(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Constant.clrGrey.withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: _technicalAnalysisController,
              maxLength: maxCharacters,
              maxLines: null,
              minLines: 12,
              style: TextStyles.txtRegular14(context).copyWith(
                color: Constant.clrTitlePageByTheme(context),
              ),
              decoration: InputDecoration(
                hintText: getLocalValue("Key_EnterTechnicalAnalysis"),
                hintStyle: TextStyles.txtRegular14(context).copyWith(
                  color: Constant.clrGrey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.w),
                counterStyle: TextStyles.txtRegular12(context).copyWith(
                  color: Constant.clrGrey,
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Rebuild to update character count
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Constant.clrHomeCardByTheme(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Constant.clrGrey.withOpacity(0.2),
        ),
      ),
      child: Row(
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

          // Stock Name and Ticker
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.story['ticker'],
                  style: TextStyles.txtSemiBold16(context).copyWith(
                    color: Constant.clrTitlePageByTheme(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.story['name'],
                  style: TextStyles.txtRegular14(context).copyWith(
                    color: Constant.clrGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Price
          Text(
            widget.story['price'],
            style: TextStyles.txtSemiBold16(context).copyWith(
              color: Constant.clrBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: getIsIOSPlatform() ? 34.h : 20.h,
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
      child: CommonButton(
        label: getLocalValue("Key_Save"),
        textSize: 16.sp,
        onTap: () => _saveChanges(),
        height: 56.h,
        bgColor: Constant.clrPrimary,
        labelColor: Colors.white,
      ),
    );
  }

  void _saveChanges() {
    // Update the story with the new technical analysis
    widget.story['technicalAnalysis'] = _technicalAnalysisController.text;

    // TODO: Save to backend API when available

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          getLocalValue("Key_ChangesSaved"),
          style: TextStyles.txtRegular14(context).copyWith(
            color: Constant.clrWhite,
          ),
        ),
        backgroundColor: const Color(0xFF32C671),
      ),
    );

    // Go back
    Navigator.pop(context);
  }
}
