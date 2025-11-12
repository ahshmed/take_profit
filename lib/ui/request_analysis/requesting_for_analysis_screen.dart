import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/payment/payment_controller.dart';
import '../../framework/data_provider/payment/payment_provider.dart';
import '../../framework/data_provider/request_analysis/request_analsis_provider.dart';
import '../../framework/data_provider/request_analysis/request_analysis_controller.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/image_picker_manager_new.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../payment/payment_screen.dart';

class RequestingForAnalysisScreen extends ConsumerStatefulWidget {
  final String recommenderID;
  final ScreenName fromScreen;

  const RequestingForAnalysisScreen({
    Key? key,
    required this.recommenderID,
    required this.fromScreen,
  }) : super(key: key);

  @override
  ConsumerState<RequestingForAnalysisScreen> createState() =>
      _RequestingForAnalysisScreenState();
}

class _RequestingForAnalysisScreenState
    extends ConsumerState<RequestingForAnalysisScreen> {
  final TextEditingController _messageCTR = TextEditingController();
  final FocusNode _messageFocus = FocusNode();
  static const int _maxCharacters = 500;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final requestWatch = ref.read(requestAnalysisProvider);
      requestWatch.clearProvider(false);
      _messageFocus.addListener(() {
        requestWatch.checkMessageValidation(context, _messageCTR.text);
      });
    });
  }

  @override
  void dispose() {
    _messageCTR.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestWatch = ref.watch(requestAnalysisProvider);
    final paymentWatch = ref.watch(paymentProvider);

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Constant.clrBasicByTheme(context),
          appBar: CommonAppBar(
            appBar: AppBar(),
            title: "requesting for analysis",
            isTitleCenter: false,
            backgroundColor: Constant.clrBasicByTheme(context),
          ),
          body: NoInternetBuilder(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => hideKeyboard(context),
              child: _buildBody(requestWatch),
            ),
          ),
          bottomNavigationBar: _buildBottomButton(paymentWatch, requestWatch),
        ),
        DialogProgressBar(
          isLoading: requestWatch.isLoading || paymentWatch.isLoading,
        ),
      ],
    );
  }

  Widget _buildBody(RequestAnalysisController requestWatch) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          _buildMessageSection(requestWatch),
          SizedBox(height: 32.h),
          _buildScreenshotSection(requestWatch),
          SizedBox(height: 100.h), // Space for bottom button
        ],
      ),
    );
  }

  /// Message Input Section
  Widget _buildMessageSection(RequestAnalysisController requestWatch) {
    final currentLength = _messageCTR.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Key_Message".localized,
          style: TextStyles.txtSemiBoldG14(context).copyWith(
           fontWeight:Constant.fwSemiBold,
            color: Color(0xFF1A1A1A),
          ),
          ),

        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: requestWatch.strMessageError.isNotEmpty
                  ? Colors.red
                  : Constant.clrTextBorderGColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.02),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _messageCTR,
                focusNode: _messageFocus,
                maxLines: 10,
                maxLength: _maxCharacters,
                style: TextStyles.txtRegG12(context).copyWith(color: Color(0xFF1A1A1A),),
                decoration: InputDecoration(
                  hintText: "Key_TypeHere".localized,
                  hintStyle: TextStyles.txtRegG12(context).copyWith(color:Constant.clrHintGColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  counterText: "",
                ),
                onChanged: (value) {
                  requestWatch.checkMessageValidation(context, value);
                  setState(() {}); // Update character counter
                },
              ),
              // Character Counter
              Container(
                padding: EdgeInsets.only(
                  right: 16.w,
                  bottom: 12.h,
                ),
                alignment: Alignment.centerRight,
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
        ),
        if (requestWatch.strMessageError.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              requestWatch.strMessageError,
              style: TextStyles.txtRegG12(context).copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Screenshot Upload Section
  Widget _buildScreenshotSection(RequestAnalysisController requestWatch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "Key_AddScreenShot".localized,
            style: TextStyles.txtSemiG16(context).copyWith(
              fontWeight: Constant.fwSemiBold,
              color: Constant.clrTitleUploadByTheme(context),
            ),
            children: [
              TextSpan(
                text: "Key_Optional".localized,
                style: TextStyles.txtMedGI12(context).copyWith(
                  color: Constant.clrSubTitleUploadGColor,
              ),)
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildImageUploadArea(requestWatch),
        SizedBox(height: 16.h),
        if (requestWatch.pickedImages.isNotEmpty)
          _buildImagePreviewList(requestWatch),
      ],
    );
  }

  /// Image Upload Area with Dashed Border
  Widget _buildImageUploadArea(RequestAnalysisController requestWatch) {
    return InkWell(
      onTap: () => _pickImage(requestWatch),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 90.h,
        decoration: BoxDecoration(
          color: Constant.clrCardCurrGColor,
          borderRadius: BorderRadius.circular(12.r),
          // border: Border.all(
          //   //color: Color(0xFFE0E0E0),
          //   width: 1,
          //   strokeAlign: BorderSide.strokeAlignInside,
          // ),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: Color(0xFFBDBDBD),
            strokeWidth: 2,
            dashWidth: 8,
            dashSpace: 4,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 35.sp,
                  color: Constant.clrIconUploadGColor,
                ),
                SizedBox(height: 12.h),
                Text(
                  "Key_UploadHere".localized,
                  style: TextStyles.txtMedG10(context).copyWith(
                    color: Constant.clrTextUploadBColor,

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Image Preview List
  Widget _buildImagePreviewList(RequestAnalysisController requestWatch) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: requestWatch.pickedImages.asMap().entries.map((entry) {
        final index = entry.key;
        final image = entry.value;
        return _buildImagePreviewItem(image, index, requestWatch);
      }).toList(),
    );
  }

  /// Individual Image Preview Item
  Widget _buildImagePreviewItem(
      File image,
      int index,
      RequestAnalysisController requestWatch,
      ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Color(0xFFE0E0E0),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.r),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -6.h,
          right: -6.w,
          child: GestureDetector(
            onTap: () => requestWatch.removeImageAt(index),
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.15),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                size: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:0.6),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                "Photo ${index + 1}",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: getAppLanguage() == 'ar'
                      ? 'Almarai-Regular'
                      : 'Gilroy-Medium',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom Button
  Widget _buildBottomButton(
      PaymentController paymentWatch,
      RequestAnalysisController requestWatch,
      ) {
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
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: requestWatch.isLoading
          ? Center(
        child: DialogProgressBar(
          isLoading: true,
          forPagination: true,
        ),
      )
          : CommonButton(
        label: "Key_SendNow".localized,

        textSize: 16.sp,
        onTap: () async {
          await _handleSubmit(paymentWatch, requestWatch);
        },
        isEnable: requestWatch.isValidaAllFieldTrader,
        height: 56.h,
        bgColor: Color(0xFF6366F1),
        labelColor: Colors.white,
        borderColor: Color(0xFF6366F1),
      ),
    );
  }

  /// Handle Image Picking
  Future<void> _pickImage(RequestAnalysisController requestWatch) async {
    File? file = await ImagePickerManagerNew.instance.openPicker(
      context,
      cropNeed: false,
    );

    if (file != null && file.path.isNotEmpty) {
      requestWatch.addImage(file);
    }
  }

  /// Handle Form Submission
  Future<void> _handleSubmit(
      PaymentController paymentWatch,
      RequestAnalysisController requestWatch,
      ) async {
    await _newRequestForAnalysisAPICall(paymentWatch, requestWatch);
  }

  Future<void> _newRequestForAnalysisAPICall(
      PaymentController paymentWatch,
      RequestAnalysisController requestAnalysisWatch,
      ) async {
    await requestAnalysisWatch.newRequestForAnalysisAPI(
      context,
      recommenderId: widget.recommenderID,
    );

    if (requestAnalysisWatch.newRequestAnalysisResponseModel.status ==
        ApiEndPoints.apiStatus_200) {
      await _paymentForSubscriptionAPICall(paymentWatch, requestAnalysisWatch);
    }
  }

  Future<void> _paymentForSubscriptionAPICall(
      PaymentController paymentWatch,
      RequestAnalysisController requestAnalysisWatch,
      ) async {
    await paymentWatch.paymentForRequestAnalysisApi(
      context,
      orderId: requestAnalysisWatch
          .newRequestAnalysisResponseModel.data?.orderId
          .toString() ??
          "",
    );

    if (paymentWatch.paymentResponseModel.status ==
        ApiEndPoints.apiStatus_200) {
      Route route = SlideRightPageRoute(
        builder: (context) => PaymentScreen(
          fromScreen: widget.fromScreen,
          paymentUrl: paymentWatch.paymentResponseModel.data?.paymentUrl
              .toString(),
          paymentAmount: requestAnalysisWatch
              .newRequestAnalysisResponseModel.data?.amount
              .toString() ??
              "",
          orderId: requestAnalysisWatch
              .newRequestAnalysisResponseModel.data?.orderId
              .toString(),
        ),
        settings: const RouteSettings(),
      );
      Navigator.push(context, route);
    }
  }
}

/// Custom Painter for Dashed Border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
              size.width - strokeWidth, size.height - strokeWidth),
          Radius.circular(12),
        ),
      );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        dashPath.addPath(extractPath, Offset.zero);
        distance = nextDistance + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}