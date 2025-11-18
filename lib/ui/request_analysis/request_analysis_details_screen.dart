import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/request_analysis/request_analsis_provider.dart';
import '../../framework/data_provider/request_analysis/request_analysis_controller.dart';
import '../../framework/repository/request_analysis/model/request_analysis_list_resopnse_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';

class RequestAnalysisDetailsScreen extends ConsumerStatefulWidget {
  final RequestAnalysisList? requestAnalysisData;
  final String? requestAnalysisId;
  final NotificationSlugTrader? notificationSlugTrader;
  final NotificationSlugRecommender? notificationSlugRecommender;

  const RequestAnalysisDetailsScreen({
    Key? key,
    required this.requestAnalysisData,
    required this.requestAnalysisId,
    this.notificationSlugTrader,
    this.notificationSlugRecommender,
  }) : super(key: key);

  @override
  ConsumerState<RequestAnalysisDetailsScreen> createState() =>
      _RequestAnalysisDetailsScreenState();
}

class _RequestAnalysisDetailsScreenState
    extends ConsumerState<RequestAnalysisDetailsScreen> {
  final TextEditingController _analysisCTR = TextEditingController();
  final FocusNode _analysisFocus = FocusNode();
  static const int _maxCharacters = 3000; // Increased for rich content
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _analysisImages = [];
  final List<int> _imagePositions = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final requestAnalysisWatch = ref.read(requestAnalysisProvider);
      requestAnalysisWatch.clearProvider(false);
      _analysisFocus.addListener(() {
        requestAnalysisWatch.checkAnalysisValidation(context, _analysisCTR.text);
      });

      if (widget.requestAnalysisData == null && widget.requestAnalysisId != "") {
        _requestAnalysisDetailsAPICall(requestAnalysisWatch);
      }
    });
  }

  @override
  void dispose() {
    _analysisCTR.dispose();
    _analysisFocus.dispose();
    super.dispose();
  }

  /// Pick image and insert placeholder at cursor position
  Future<void> _pickAnalysisImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          final cursorPosition = _analysisCTR.selection.baseOffset >= 0
              ? _analysisCTR.selection.baseOffset
              : _analysisCTR.text.length;

          final imageIndex = _analysisImages.length + 1;
          _analysisImages.add(File(pickedFile.path));
          _imagePositions.add(cursorPosition);

          // Insert placeholder text at cursor position
          final placeholder = '\n📷 [Image $imageIndex]\n';
          final currentText = _analysisCTR.text;
          final beforeCursor = currentText.substring(0, cursorPosition);
          final afterCursor = currentText.substring(cursorPosition);

          final newText = beforeCursor + placeholder + afterCursor;
          _analysisCTR.text = newText;

          // Update validation
          final requestAnalysisWatch = ref.read(requestAnalysisProvider);
          requestAnalysisWatch.checkAnalysisValidation(context, newText);

          // Move cursor after placeholder
          _analysisCTR.selection = TextSelection.collapsed(
            offset: cursorPosition + placeholder.length,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getLocalValue('Key_ErrorPickingImage')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Remove image and its placeholder
  void _removeAnalysisImage(int imageIndex) {
    setState(() {
      // Remove placeholder text from description
      final placeholder = '📷 [Image ${imageIndex + 1}]';
      final currentText = _analysisCTR.text;
      final newText = currentText.replaceAll('\n$placeholder\n', '');

      _analysisCTR.text = newText;
      _analysisImages.removeAt(imageIndex);
      _imagePositions.removeAt(imageIndex);

      // Update validation
      final requestAnalysisWatch = ref.read(requestAnalysisProvider);
      requestAnalysisWatch.checkAnalysisValidation(context, newText);
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestAnalysisWatch = ref.watch(requestAnalysisProvider);
    final status = _getStatus(requestAnalysisWatch);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Navigator.pop(context, status?.toLowerCase());
        }
      },
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Constant.clrBasicByTheme(context),
            appBar: _buildAppBar(status),
            body: NoInternetBuilder(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => hideKeyboard(context),
                child: _buildBody(requestAnalysisWatch),
              ),
            ),
            bottomNavigationBar: _shouldShowBottomButton(status)
                ? _buildBottomButton(requestAnalysisWatch)
                : const Offstage(),
          ),
          DialogProgressBar(isLoading: requestAnalysisWatch.isLoading),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String? status) {
    return CommonAppBar(
      appBar: AppBar(),
      isDrawer: false,
      backgroundColor: Constant.clrBasicByTheme(context),
      onPress: () => Navigator.pop(context, status?.toLowerCase()),
      title: "Request Analysis Details",
      isTitleCenter: false,
    );
  }

  Widget _buildBody(RequestAnalysisController requestAnalysisWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: isRTL
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          _buildStatusHeader(requestAnalysisWatch),
          SizedBox(height: 24.h),
          _buildScreenshotSection(requestAnalysisWatch),
          SizedBox(height: 24.h),
          _buildMessageSection(requestAnalysisWatch),
          SizedBox(height: 24.h),
          _buildAnalysisSection(requestAnalysisWatch),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  /// Status Header with Badge
  Widget _buildStatusHeader(RequestAnalysisController requestAnalysisWatch) {
    final status = _getStatus(requestAnalysisWatch);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Row(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Request Status",
          style: TextStyles.txtSemiBoldG14(context).copyWith(
            fontWeight: Constant.fwSemiBold,
            color: Constant.clrTitleUploadByTheme(context),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            status?.capitalizeFirstLetterOfSentence ?? "Unknown",
            style: TextStyles.txtSemiBoldG10(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Screenshot Section
  Widget _buildScreenshotSection(RequestAnalysisController requestAnalysisWatch) {
    final hasImage = _hasScreenshot(requestAnalysisWatch);
    final imageUrl = _getImageUrl(requestAnalysisWatch);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: isRTL
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          "Key_Screenshot".localized,
          style: TextStyles.txtSemiBoldG14(context).copyWith(
            fontWeight: Constant.fwSemiBold,
            color: Constant.clrTitleUploadByTheme(context),
          ),
        ),
        SizedBox(height: 16.h),
        hasImage
            ? Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Color(0xFFE0E0E0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: CacheImage(
              imageURL: imageUrl,
              height: 120.w,
              width: 120.w,
              contentMode: BoxFit.cover,
            ),
          ),
        )
            : Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: Constant.clrCardCurrGColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Color(0xFFE0E0E0),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 40.sp,
                color: Constant.clrIconUploadGColor,
              ),
              SizedBox(height: 8.h),
              Text(
                "Key_NoScreenshot".localized,
                style: TextStyles.txtMedG10(context).copyWith(
                  color: Constant.clrSubTitleUploadGColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Message Section (Read-only)
  Widget _buildMessageSection(RequestAnalysisController requestAnalysisWatch) {
    final message = _getMessage(requestAnalysisWatch);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: isRTL
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          "Key_Message".localized,
          style: TextStyles.txtSemiBoldG14(context).copyWith(
            fontWeight: Constant.fwSemiBold,
            color: Constant.clrTitleUploadByTheme(context),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: Constant.clrTextBorderGColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.isNotEmpty ? message : "No message provided",
            style: TextStyles.txtRegG12(context).copyWith(
              color: message.isNotEmpty
                  ? Color(0xFF1A1A1A)
                  : Constant.clrHintGColor,
              height: 1.5,
            ),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  /// Analysis Section (Editable or Read-only based on status)
  Widget _buildAnalysisSection(RequestAnalysisController requestAnalysisWatch) {
    final status = _getStatus(requestAnalysisWatch);
    final isEditable = _shouldShowBottomButton(status);
    final analysis = _getAnalysis(requestAnalysisWatch);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: isRTL
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "Key_Analysis".localized,
            style: TextStyles.txtSemiBoldG14(context).copyWith(
              fontWeight: Constant.fwSemiBold,
              color: Constant.clrTitleUploadByTheme(context),
            ),
            children: isEditable
                ? [
              TextSpan(
                text: " *",
                style: TextStyles.txtSemiBoldG14(context).copyWith(
                  color: Colors.red,
                ),
              ),
            ]
                : null,
          ),
        ),
        SizedBox(height: 12.h),
        isEditable
            ? _buildAnalysisTextFieldEditable(requestAnalysisWatch)
            : _buildAnalysisTextReadOnly(analysis, isRTL),
      ],
    );
  }

  /// Editable Analysis TextField with Image Support
  Widget _buildAnalysisTextFieldEditable(
      RequestAnalysisController requestAnalysisWatch) {
    final currentLength = _analysisCTR.text.length;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: requestAnalysisWatch.strAnalysisError.isNotEmpty
                  ? Colors.red
                  : Constant.clrTextBorderGColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _analysisCTR,
                focusNode: _analysisFocus,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 12,
                maxLines: null,
                maxLength: _maxCharacters,
                style: TextStyles.txtRegG12(context).copyWith(
                  color: Color(0xFF1A1A1A),
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: "Enter your consultation analysis here...",
                  hintStyle: TextStyles.txtRegG12(context).copyWith(
                    color: Constant.clrHintGColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  counterText: "",
                ),
                onChanged: (value) {
                  requestAnalysisWatch.checkAnalysisValidation(context, value);
                  setState(() {});
                },
              ),
              Row(
                children: [
                  // Image picker button
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, bottom: 12.h),
                    child: InkWell(
                      onTap: _pickAnalysisImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Constant.clrPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 16.sp,
                              color: Constant.clrPrimary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Add Image",
                              style: TextStyles.txtRegG12(context).copyWith(
                                color: Constant.clrPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  // Character counter
                  Container(
                    padding: EdgeInsets.only(right: 16.w, bottom: 12.h),
                    child: Text(
                      "$currentLength/$_maxCharacters",
                      style: TextStyles.txtRegG12(context).copyWith(
                        color: currentLength > _maxCharacters
                            ? Colors.red
                            : Constant.clrHintGColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Display added images
        if (_analysisImages.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Constant.clrPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: Constant.clrPrimary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: Constant.clrPrimary,
                      size: 16.h,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${_analysisImages.length} Attached Image${_analysisImages.length > 1 ? 's' : ''}',
                      style: TextStyles.txtSemiBold12(context).copyWith(
                        color: Constant.clrPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ...List.generate(
                  _analysisImages.length,
                  (imageIndex) => Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '📷 Image ${imageIndex + 1}',
                              style: TextStyles.txtMedium12(context).copyWith(
                                color: Constant.clrPrimary,
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () => _removeAnalysisImage(imageIndex),
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            _analysisImages[imageIndex],
                            width: double.infinity,
                            fit: BoxFit.cover,
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
      ],
    );
  }

  /// Read-only Analysis Text
  Widget _buildAnalysisTextReadOnly(String analysis, bool isRTL) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: Constant.clrTextBorderGColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        analysis.isNotEmpty ? analysis : "No analysis provided yet",
        style: TextStyles.txtRegG12(context).copyWith(
          color: analysis.isNotEmpty
              ? Color(0xFF1A1A1A)
              : Constant.clrHintGColor,
          height: 1.5,
        ),
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }

  /// Bottom Submit Button
  Widget _buildBottomButton(RequestAnalysisController requestAnalysisWatch) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: getIsIOSPlatform() ? 34.h : 20.h,
        top: 12.h,
      ),
      decoration: BoxDecoration(
        color: Constant.clrScaffoldBGByTheme(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: CommonButton(
        label: getLocalValue("Key_Submit"),
        textSize: 16.sp,
        onTap: () => _completeAnalysisRequestAPI(requestAnalysisWatch),
        isEnable: requestAnalysisWatch.isValidaAllFieldRecommender,
        height: 56.h,
        bgColor: Color(0xFF6366F1),
        labelColor: Colors.white,
        borderColor: Color(0xFF6366F1),
      ),
    );
  }

  // ==================== Helper Methods ====================

  String? _getStatus(RequestAnalysisController requestAnalysisWatch) {
    return widget.requestAnalysisData != null
        ? widget.requestAnalysisData?.status
        : requestAnalysisWatch.requestAnalysisDetailsResponseModel.data?.status;
  }

  bool _hasScreenshot(RequestAnalysisController requestAnalysisWatch) {
    final imageUrl = _getImageUrl(requestAnalysisWatch);
    return imageUrl.isNotEmpty;
  }

  String _getImageUrl(RequestAnalysisController requestAnalysisWatch) {
    return widget.requestAnalysisData != null
        ? widget.requestAnalysisData?.image ?? ""
        : requestAnalysisWatch
        .requestAnalysisDetailsResponseModel.data?.image ??
        "";
  }

  String _getMessage(RequestAnalysisController requestAnalysisWatch) {
    return widget.requestAnalysisData != null
        ? widget.requestAnalysisData?.requestDescription ?? ""
        : requestAnalysisWatch
        .requestAnalysisDetailsResponseModel.data?.requestDescription ??
        "";
  }

  String _getAnalysis(RequestAnalysisController requestAnalysisWatch) {
    return widget.requestAnalysisData != null
        ? widget.requestAnalysisData?.analysisDescription ?? ""
        : requestAnalysisWatch.requestAnalysisDetailsResponseModel.data
        ?.analysisDescription ??
        "";
  }

  bool _shouldShowBottomButton(String? status) {
    return getUserStatus() == recommender &&
        status?.capitalizeFirstLetterOfSentence == "Pending";
  }

  Color _getStatusColor(String? status) {
    final statusLower = status?.toLowerCase() ?? "";
    switch (statusLower) {
      case "pending":
        return Color(0xFFEF4444); // Red
      case "completed":
        return Color(0xFF10B981); // Green
      case "refunded":
        return Color(0xFFFBBF24); // Yellow
      default:
        return Color(0xFF6B7280); // Gray
    }
  }

  // ==================== API Methods ====================

  Future<void> _completeAnalysisRequestAPI(
      RequestAnalysisController requestAnalysisWatch) async {
    final requestID = widget.requestAnalysisData != null
        ? widget.requestAnalysisData?.requestId ?? ""
        : requestAnalysisWatch
        .requestAnalysisDetailsResponseModel.data?.requestId ??
        "";

    await requestAnalysisWatch.completeAnalysisRequestAPI(
      context,
      requestID: requestID,
    );

    if (requestAnalysisWatch.commonResponseModel.status ==
        ApiEndPoints.apiStatus_200) {
      requestAnalysisWatch.setSelectedTabIndex("1");
      Navigator.pop(context, "completed");
    }
  }

  Future<void> _requestAnalysisDetailsAPICall(
      RequestAnalysisController requestAnalysisWatch) async {
    await requestAnalysisWatch.requestAnalysisDetailsAPI(
      context,
      requestID: widget.requestAnalysisId ?? "",
    );
  }
}