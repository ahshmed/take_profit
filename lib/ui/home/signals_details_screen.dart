import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/framework/data_provider/home/recommender_controller.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/recommender/create_signal_controller.dart';
import '../../framework/data_provider/recommender/recommender_provider.dart';
import '../../framework/repository/common/model/crypto_currency_response_model.dart';
import '../../framework/repository/signal/model/signal_details_response_model.dart';
import '../../framework/repository/signal/model/signal_list_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../recommendation/edit_signal_screen.dart';
import 'chart_screenshot_screen.dart';

class SignalDetailsScreen extends ConsumerStatefulWidget {
  final SeeAllScreen? seeAllScreen;
  final SignalList? signalData;
  final String? recommenderID;
  final String? signalId;

  const SignalDetailsScreen({
    Key? key,
    this.seeAllScreen,
    required this.signalData,
    this.recommenderID,
    this.signalId = "",
  }) : super(key: key);

  @override
  ConsumerState<SignalDetailsScreen> createState() =>
      _SignalDetailsScreenState();
}

class _SignalDetailsScreenState extends ConsumerState<SignalDetailsScreen>
    with WidgetsBindingObserver {
  SignalData? signalData;
  Timer? currencyTimer;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      WidgetsBinding.instance.addObserver(this);
      final signalWatch = ref.read(createSignalProvider);

      if (widget.signalData != null) {
        signalWatch.setCurrentSignalNotificationEnabled(
            widget.signalData!.enableNotification == 1);
      }

      if (widget.signalId != "" && widget.signalData == null) {
        await _signalDetailsAPICall(signalWatch);
        signalWatch.setCurrentSignalNotificationEnabled(
            signalData?.enableNotification == 1);
      }

      await _livePriceChangeFunction();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await _livePriceChangeFunction(isTimerStart: false);
    } else if (state == AppLifecycleState.resumed) {
      await _livePriceChangeFunction(isTimerStart: true);
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _livePriceChangeFunction(isTimerStart: false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signalWatch = ref.watch(createSignalProvider);
    final recommenderWatch = ref.watch(recommenderProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result)  {
        if(!didPop) {
          Navigator.pop(context);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Constant.clrScaffoldBGByTheme(context),
            appBar: _buildAppBar(signalWatch, recommenderWatch),
            body: NoInternetBuilder(
              child: _buildBody(),
            ),
            bottomNavigationBar: _shouldShowBottomButtons()
                ? _buildBottomButtons()
                : const Offstage(),
          ),
          DialogProgressBar(isLoading: signalWatch.isLoading),
        ],
      ),
    );
  }

  /// Build AppBar with notification toggle
  PreferredSizeWidget _buildAppBar(CreateSignalController signalWatch,
      RecommenderScreenController recommenderWatch,) {
    final showNotification = (recommenderWatch
        .recommenderDetailResponseModel?.data?.isSubscribed ==
        "1" ||
        getUserEntityId() == widget.recommenderID) &&
        getUserStatus() != guest;

    return CommonAppBar(
      appBar: AppBar(
        backgroundColor: Constant.clrScaffoldBGByTheme(context),
        toolbarHeight: 64.h,
      ),
      title: _isClosedSignal()
          ? getLocalValue("Key_ClosedSignalDetail")
          : getLocalValue("Key_SignalDetail"),
      titleTextStyle: TextStyles.txtMedG16(context),
      isTitleCenter: false,
      isDrawer: false,
      action: showNotification
          ? [
        Transform.scale(
              scale: 0.8,
        child:Switch(
          value: signalWatch.currentSignalNotificationEnabled,
          activeTrackColor:Constant.clrDetailsScreenSwitchBColor ,
          inactiveTrackColor: Constant.clrHeaderSubSignDetailsColor,
          onChanged: (val) {
            signalWatch.updateCurrentSignalNotificationStatus(
              context: context,
              enabled: val,
              signalId: widget.signalData?.signalId ?? "0",
            );
          },
        )),
        SizedBox(width: 4.w),
        signalWatch.notificationLoading
            ? SizedBox(
          width: 24.w,
          height: 24.w,
          child: FittedBox(
            child: CircularProgressIndicator(
              color: Constant.clrDetailsScreenSwitchBColor,
            ),
          ),
        )
            : (signalWatch.currentSignalNotificationEnabled
            // if notification are on , show the Image asset
            ?Image.asset(
          Constant.icNotifSignDetN,
          //color:Constant.clrDetailsScreenSwitchBColor,
          width: 25.14.w,
          height: 21.91.w,
        )
        //if notification are off , show the off Icon
        :Image.asset(
          Constant.icNotificationNoBorderN,
          color:Constant.clrSubTitleUploadGColor,

          width: 25.14.w,
          height: 21.91.w,
        )
        ),
        SizedBox(width: 16.w),
      ]
          : null,
    );
  }

  /// Main Body
  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.13),
                color: Constant.clrHomeCardByTheme(context),),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                _buildCurrencyHeader(),
                Divider(color: Constant.clrSigDetDividerByTheme(context),),
                _buildPriceDetailsSection(),
              ],
            ),
          ),

          _buildTargetSection(),
          SizedBox(height: 24.h),
          _buildChartSection(),
          SizedBox(height: 24.h),
          if (_hasTechnicalAnalysis()) _buildTechnicalAnalysisSection(),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  /// Currency Header with Logo, Name, and Risk Badge
  Widget _buildCurrencyHeader() {
    final currencyName = _getCurrencyName();
    final currencyCode = _getCurrencyCode();
    final currencyLogo = _getCurrencyLogo();
    final riskLabel = _getRiskLabel();
    final timestamp = _getFormattedTimestamp();
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsets.only(
        left: isRTL ? 0 : 16.w,
        right: isRTL ? 16.w : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency Logo
          CacheImage(
            imageURL: currencyLogo,
            height: 49.31.w,
            width: 49.32.w,
            contentMode: BoxFit.cover,
          ),
          SizedBox(width: 16.w),
          // Currency Info
          Expanded(
            child: Column(
              crossAxisAlignment: isRTL
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  "$currencyName ($currencyCode)",
                  style: TextStyles.txtSemiBoldG14(context).copyWith(
                    fontWeight: Constant.fwSemiBold,
                    color: Constant.clrSigDetByTheme(context),
                  ),
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),
                SizedBox(height: 4.h),
                Text(
                  timestamp,
                  style: TextStyles.txtMedGI12(context).copyWith(
                    fontSize: 11.sp,
                    color: Constant.clrHeaderSubSignDetailsColor,
                  ),
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
            ),
          ),
          // Risk Badge - Position flips for RTL
          Container(
            width: 97.w,
            height: 23.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getRiskBadgeColor(riskLabel),
              borderRadius: isRTL
                  ? BorderRadius.only(
                topLeft: Radius.circular(0.r),
                topRight: Radius.circular(12.r),
                bottomLeft: Radius.circular(0.r),
                bottomRight: Radius.circular(12.r),
              )
                  : BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(0.r),
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(0.r),
              ),
            ),
            child: Text(
              riskLabel,
              style: TextStyles.txtSemiBoldG10(context).copyWith(
                fontWeight: Constant.fwRegular,
                color: Constant.clrWhite,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Price Details Section (Entry, Stop Loss, Live Price, Wallet)
  Widget _buildPriceDetailsSection() {
    return Consumer(builder: (context, ref, child) {
      final entryPrice = _getEntryPrice();
      final stopLoss = _getStopLoss();
      final livePrice = _getLivePrice();
      final currencyCode = _getCurrencyCode();
      final walletPercentage = _getWalletPercentage();

      return Column(
        children: [
          _buildPriceDetailRow(
            label: "Key_EntryPrice".localized,
            value: "$entryPrice ${"Key_USDT".localized}",
            valueColor: Constant.clrSigDetEntByTheme(context),
            onCopy: () => copyToClipboard(context, entryPrice),
            infoMessage: "The entry price is the recommended price point at which you should enter the trade. This is the optimal price level based on technical analysis.",
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            thickness: 1.08,
              color: Constant.clrSigDetDividerByTheme(context)
          ),
          _buildPriceDetailRow(
            label: "Key_StopLoss".localized,
            value: "$stopLoss ${"Key_USDT".localized}",
            valueColor: Constant.clrSignOutRColor,
            onCopy: () => copyToClipboard(context, stopLoss),
            infoMessage: "The stop loss is a predefined price level where you should exit the trade to limit potential losses. Setting a stop loss helps protect your capital from significant drawdowns.",
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            thickness: 1.08,
              color: Constant.clrSigDetDividerByTheme(context)
          ),
          _buildPriceDetailRow(
            label: "Key_LivePrice".localized,
            value: "$livePrice ${"Key_USDT".localized}",
            valueColor: Constant.clrNotifSelectBColor,
            onCopy: () => copyToClipboard(context, livePrice),
            infoMessage: "The live price shows the current real-time market price of the cryptocurrency. This updates automatically to help you track price movements.",
          ),
          Divider(
            indent: 16,
            endIndent: 16,
            thickness: 1.08,
              color: Constant.clrSigDetDividerByTheme(context)
          ),
          _buildPriceDetailRow(
            label: "% ${"Key_OfWallet".localized}",
            value: "$walletPercentage%",
            valueColor: Constant.clrTitlePageByTheme(context),
            showCopy: false,
            infoMessage: "This represents the recommended percentage of your total wallet balance to allocate for this trade. Proper position sizing helps manage risk effectively.",
          ),
          SizedBox(height: 16),
        ],
      );
    });
  }

  /// Individual Price Detail Row
  Widget _buildPriceDetailRow({
    required String label,
    required String value,
    required Color valueColor,
    VoidCallback? onCopy,
    bool showCopy = true,
    String? infoMessage,
  }) {
    final GlobalKey infoIconKey = GlobalKey();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      decoration: BoxDecoration(
        //color: Constant.clrHomeCardByTheme(context),
        //borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyles.txtSemiBoldG12(context).copyWith(
              color: valueColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyles.txtRegG14(context).copyWith(
              color: valueColor,
            ),
          ),
          SizedBox(width: 12.w),
          InkWell(
            key: infoIconKey,
            onTap: () {
              if (infoMessage != null && infoMessage.isNotEmpty) {
                _showInfoPopup(context, infoMessage, infoIconKey);
              }
            },
            child: Icon(
              Icons.info_outline,
              size: 20.sp,
              color: Constant.clrSignDetailsInfColor,
            ),
          ),
          if (showCopy) SizedBox(width: 8.w),
          if (showCopy)
            InkWell(
              onTap: onCopy,
              child: Icon(
                Icons.copy_outlined,
                size: 20.sp,
                color: Constant.clrSignDetailsCopyColor,
              ),
            ),
        ],
      ),
    );
  }


  /// Target Section
  Widget _buildTargetSection() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Consumer(builder: (context, ref, child) {
      final targets = _getTargets();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // crossAxisAlignment: isRTL
        //     ? CrossAxisAlignment.end
        //     : CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            "Key_Target".localized,
            style: TextStyles.txtSemiG16(context).copyWith(fontWeight: Constant.fwSemiBold),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: targets.length,
            itemBuilder: (context, index) {
              final target = targets[index];
              return _buildTargetItem(target, index);
            },
          ),
        ],
      );
    });
  }

  /// Individual Target Item
  Widget _buildTargetItem(dynamic target, int index) {
    final GlobalKey infoIconKey = GlobalKey();
    final isRange = target.targetType == "range";
    final price = target.price ?? "";
    final toPrice = target.toPrice ?? "";
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final isAchieved = index == 0;
    final achievementText = isAchieved ? "Target 1 achieved at 8% profit" : null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Constant.clrSearchByTheme(context),//Constant.clrDetailsScreenTargetColor,
        borderRadius: BorderRadius.circular(15.r),
        //border: Border.all(color: Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Target Number Badge
          Center(
            child: Text("${index + 1}", style: TextStyles.txtMedG12(context)),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            height: 40.h,
            child: VerticalDivider(
              width: 1.w,
              thickness: 1.08,
              color: Constant.clrSigDetDividerByTheme(context),
            ),
          ),
          SizedBox(width: 12.w),
          // Target Price(s)
          Expanded(
            child: Column(
              crossAxisAlignment: isRTL
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Text(
                      "$price",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.txtSemiG16(context).copyWith(
                        color: Constant.clrSigDetEntByTheme(context),
                        fontWeight: Constant.fwSemiBold,
                      ),
                      textDirection: TextDirection.ltr, // Numbers are always LTR
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Key_USD".localized,
                      style: TextStyles.txtRegG12(context).copyWith(
                        color: Constant.clrSigDetEntByTheme(context),
                      ),
                    ),
                  ],
                ),
                if (isRange && toPrice.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Row(
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(
                        "$toPrice",
                        style: TextStyles.txtSemiG16(context).copyWith(
                          color: Constant.clrSigDetEntByTheme(context),
                          fontWeight: Constant.fwSemiBold,
                        ),
                        textDirection: TextDirection.ltr, // Numbers are always LTR
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Key_USD".localized,
                        style: TextStyles.txtRegG12(context).copyWith(
                          color: Constant.clrSigDetEntByTheme(context),
                        ),
                      ),
                    ],
                  ),
                ],
                if (achievementText != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    achievementText,
                    style: TextStyles.txtRegIG11(context).copyWith(
                      color: Constant.clrSignDetailsAchColor,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Icons in reverse order for RTL
          if (isRTL) ...[
            InkWell(
              onTap: () => copyToClipboard(context, price),
              child: Icon(
                Icons.copy_outlined,
                size: 20.sp,
                color: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              key: infoIconKey,
              onTap: () {
                final targetMessage = isRange
                    ? "Target ${index + 1} is a range target. You should aim to take profit between $price and $toPrice USD. Consider taking partial profits at different levels within this range."
                    : "Target ${index + 1} is a fixed price target. Consider taking profit when the price reaches $price USD. You can take full or partial profits at this level.";

                _showInfoPopup(context, targetMessage, infoIconKey);
              },
              child: Icon(
                Icons.info_outline,
                size: 20.sp,
                color: Constant.clrSignDetailsInfColor,
              ),
            ),
          ] else ...[
            InkWell(
              key: infoIconKey,
              onTap: () {
                final targetMessage = isRange
                    ? "Target ${index + 1} is a range target. You should aim to take profit between $price and $toPrice USD. Consider taking partial profits at different levels within this range."
                    : "Target ${index + 1} is a fixed price target. Consider taking profit when the price reaches $price USD. You can take full or partial profits at this level.";

                _showInfoPopup(context, targetMessage, infoIconKey);
              },
              child: Icon(
                Icons.info_outline,
                size: 20.sp,
                color: Constant.clrSignDetailsInfColor,
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: () => copyToClipboard(context, price),
              child: Icon(
                Icons.copy_outlined,
                size: 20.sp,
                color: Color(0xFF3B82F6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Chart Screenshot Section
  Widget _buildChartSection() {
    final GlobalKey infoIconKey = GlobalKey();
    final chartImage = _getChartImage();
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: isRTL
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Text(
              "Key_ChartScreenshot".localized,
              style: TextStyles.txtMedG16(context).copyWith(
                fontWeight: Constant.fwSemiBold,
              ),
            ),
            const Spacer(),
            InkWell(
              key: infoIconKey,
              onTap: () {
                _showInfoPopup(
                  context,
                  "This chart screenshot provides a visual representation of the technical analysis behind this signal. It shows key support and resistance levels, trends, and patterns used to determine the entry and target prices.",
                  infoIconKey,
                );
              },
              child: Icon(
                Icons.info_outline,
                size: 20.sp,
                color: Constant.clrSignDetailsInfColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Chart Screenshot Image - Hidden per user request
        // InkWell with image2.png removed
      ],
    );
  }

  /// Technical Analysis Section
  Widget _buildTechnicalAnalysisSection() {
    final description = _getTechnicalAnalysis();
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // crossAxisAlignment: isRTL
      //     ? CrossAxisAlignment.end
      //     : CrossAxisAlignment.start,
      children: [
        Text(
          getLocalValue("Key_TechnicalAnalysisEn"),
          style: TextStyles.txtMedG16(context).copyWith(
            fontWeight: Constant.fwSemiBold,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Constant.clrSearchByTheme(context),
            borderRadius: BorderRadius.circular(12.r),
            //border: Border.all(color: Color(0xFFE5E7EB), width: 1),
          ),
          child: Text(
            description,
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyles.txtRegG14(context)

          ),
        ),
      ],
    );
  }

  /// Bottom Buttons (Close Signal & Edit)
  Widget _buildBottomButtons() {
    if (getUserEntityId() != widget.recommenderID) {
      return const Offstage();
    }

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
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
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
              labelColor: Color(0xFF1A1A1A),
              borderColor: Color(0xFFE5E7EB),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CommonButton(
              label: getLocalValue("Key_Edit"),
              textSize: 16.sp,
              onTap: () => _navigateToEditSignal(),
              height: 56.h,
              bgColor: Color(0xFF6366F1),
              labelColor: Colors.white,
              borderColor: Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Helper Methods ====================

  bool _isClosedSignal() {
    return widget.seeAllScreen == SeeAllScreen.fromRecommenderDetailsClosed ||
        widget.seeAllScreen == SeeAllScreen.fromMyRecommenderSignalClosed;
  }

  bool _shouldShowBottomButtons() {
    return widget.seeAllScreen == SeeAllScreen.fromMyRecommenderSignalActive ||
        widget.seeAllScreen == SeeAllScreen.fromRecommenderDetailsActive ||
        widget.seeAllScreen == SeeAllScreen.fromMyRecommenderSignalPending ||
        widget.seeAllScreen == SeeAllScreen.fromRecommenderDetailsPending;
  }

  String _getCurrencyName() =>
      (widget.signalData != null)
          ? widget.signalData?.currencyName ?? ""
          : signalData?.currencyName ?? "";

  String _getCurrencyCode() =>
      (widget.signalData != null)
          ? widget.signalData?.currencyCode ?? ""
          : signalData?.currencyCode ?? "";

  String _getCurrencyLogo() =>
      (widget.signalData != null)
          ? widget.signalData?.currencyLogo ?? ""
          : signalData?.currencyLogo ?? "";

  String _getRiskLabel() =>
      (widget.signalData != null)
          ? widget.signalData?.riskFactorLabel ?? ""
          : signalData?.riskFactorLabel ?? "";

  String _getPercentageChange() => "1.26%"; // Mock - replace with actual

  String _getFormattedTimestamp() =>
      "01/11/2022 14:35"; // Mock - replace with actual

  String _getEntryPrice() =>
      (widget.signalData != null)
          ? widget.signalData?.entryPrice ?? ""
          : signalData?.entryPrice ?? "";

  String _getStopLoss() =>
      (widget.signalData != null)
          ? widget.signalData?.stopLoss ?? ""
          : signalData?.stopLoss ?? "";

  String _getLivePrice() =>
      (widget.signalData != null)
          ? widget.signalData?.livePrice ?? ""
          : signalData?.livePrice ?? "";

  String _getWalletPercentage() =>
      (widget.signalData != null)
          ? widget.signalData?.walletPercentage ?? ""
          : signalData?.walletPercentage ?? "";

  String _getChartImage() =>
      (widget.signalData != null)
          ? widget.signalData?.chartImage ?? ""
          : signalData?.chartImage ?? "";

  String _getTechnicalAnalysis() =>
      (widget.signalData != null)
          ? widget.signalData?.descriptionEn ?? ""
          : signalData?.descriptionEn ?? "";

  bool _hasTechnicalAnalysis() {
    final description = _getTechnicalAnalysis();
    return description.isNotEmpty;
  }

  List<dynamic> _getTargets() =>
      (widget.signalData != null)
          ? widget.signalData?.targets ?? []
          : signalData?.targets ?? [];

  Color _getRiskBadgeColor(String riskLabel) {
    if (riskLabel.toLowerCase().contains("high")) {
      return Color(0xFFEF4444); // Red
    } else if (riskLabel.toLowerCase().contains("medium")) {
      return Color(0xFF10B981); // Green
    } else {
      return Color(0xFF3B82F6); // Blue
    }
  }

  void _openChartFullScreen(String chartImage) {
    _livePriceChangeFunction(isTimerStart: false);
    Route route = SlideRightPageRoute(
      builder: (context) => ChartScreenShotScreen(chartImage: chartImage),
      settings: const RouteSettings(),
    );
    Navigator.push(context, route).then((_) {
      _livePriceChangeFunction();
    });
  }

  void _showCloseSignalConfirmation() {
    showConfirmationDialog(
      context,
      '',
      getLocalValue("Key_CloseSignal"),
      getLocalValue("Key_CloseSignalConfirmMsg"),
          (isPositive) {
        if (isPositive == true && mounted) {
          _apiCloseSignal();
        }
      },
      dialogInsidePadding: EdgeInsets.all(15.h),
      borderRadius: 16.r,
      titleTextStyle: TextStyles.txtMedium24(context).copyWith(
          color: Constant.clrTextMainFontByTheme(context), fontSize: 22.sp),
      titleTxtPadding: EdgeInsets.only(top: 10.h, bottom: 5.h),
      messageTextStyle:
      TextStyles.txtMedium14(context).copyWith(color: Constant.clrBlackNew),
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

  void _navigateToEditSignal() {
    _livePriceChangeFunction(isTimerStart: false);
    Route route = SlideRightPageRoute(
      builder: (context) => EditSignalScreen(signalListData: widget.signalData),
      settings: const RouteSettings(),
    );
    Navigator.of(context).push(route).then((_) {
      _livePriceChangeFunction();
    });
  }



  /// Show Info Popup Dialog
  void _showInfoPopup(
      BuildContext context,
      String message,
      GlobalKey iconKey,
      ) {
    // Remove existing overlay if any
    _overlayEntry?.remove();

    // Get the position of the info icon
    final RenderBox? renderBox =
    iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final iconSize = renderBox.size;

    // Calculate triangle height
    final triangleHeight = 8.h;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black.withValues(alpha: 0.3),
          child: GestureDetector(
            onTap: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
            },
            child: Stack(
              children: [
                // Popup Box
                Positioned(
                  top: offset.dy + iconSize.height + triangleHeight - 1,
                  left: 20.w,
                  right: 20.w,
                  child: GestureDetector(
                    onTap: () {}, // Prevent dismissing when tapping popup
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF6B7280),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Message Text
                          Padding(
                            padding: EdgeInsets.only(right: 30.w),
                            child: Text(
                              message,
                              style: TextStyles.txtRegG14(context).copyWith(
                                fontSize: 13.sp,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ),

                          // Close Button
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                _overlayEntry?.remove();
                                _overlayEntry = null;
                              },
                              child: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Triangle pointing to the icon
                Positioned(
                  top: offset.dy + iconSize.height,
                  left: offset.dx + (iconSize.width / 2) - 8.w,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: Size(16.w, triangleHeight),
                      painter: _TrianglePointer(color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
  Future<void> _apiCloseSignal() async {
    final signalWatch = ref.read(createSignalProvider);
    final myRecommendationWatch = ref.read(myRecommendationProvider);
    final recommenderWatch = ref.read(recommenderProvider);

    await signalWatch.closeSignalAPI(
        context, widget.signalData?.signalId ?? "");

    if (signalWatch.commonResponseModel?.status == ApiEndPoints.apiStatus_200) {
      recommenderWatch.updateSignalsSubTabIndex(2);
      myRecommendationWatch.updateSignalsSubTabIndex(2);
      Navigator.pop(context, true);
      await signalWatch.apiSignalList(context, "closed", getUserEntityId());
    }
  }

  Future<void> _signalDetailsAPICall(CreateSignalController signalWatch) async {
    await signalWatch.signalDetailsAPI(context, widget.signalId ?? "");
    if (signalWatch.signalDetailsResponseModel.status ==
        ApiEndPoints.apiStatus_200) {
      signalData = signalWatch.signalDetailsResponseModel.data;
    }
  }

  Future<void> _getCryptoCurrencyData(CommonController commonWatch) async {
    if (isInternetConnectionOn) {
      if (mounted) {
        // await commonWatch.getCryptoCurrencyAPI(context);
      }

      if (commonWatch.cryptoCurrencyResponseModel.data != null ||
          commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
        CryptoCurrencyData? currencyData = commonWatch
            .cryptoCurrencyResponseModel.data
            ?.where((element) =>
        element.id.toString() ==
            ((widget.signalData != null)
                ? widget.signalData?.apiCurrencyId
                : signalData?.apiCurrencyId))
            .first;

        if (currencyData != null && !_isClosedSignal()) {
          signalData?.livePrice = currencyData.priceUsd;
          widget.signalData?.livePrice = currencyData.priceUsd;
        }
      }
      commonWatch.updateUi();
    }
  }

  Future<void> _livePriceChangeFunction({bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      if (isTimerStart) {
        final commonWatch = ref.read(commonProvider);

        currencyTimer = Timer.periodic(
          Duration(milliseconds: secondsDelayForRealTimeAPICall),
              (timer) async {
            await _getCryptoCurrencyData(commonWatch);
          },
        );
        commonWatch.updateUi();
      } else {
        currencyTimer?.cancel();
      }
    }
  }
}

// Triangle pointer painter
class _TrianglePointer extends CustomPainter {
  final Color color;
  final bool pointUp;

  _TrianglePointer({required this.color, this.pointUp = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (pointUp) {
      // Triangle pointing UP (for popup below icon)
      path
        ..moveTo(size.width / 2, 0) // Top center (point)
        ..lineTo(0, size.height) // Bottom left
        ..lineTo(size.width, size.height) // Bottom right
        ..close();
    } else {
      // Triangle pointing DOWN (for popup above icon)
      path
        ..moveTo(size.width / 2, size.height) // Bottom center (point)
        ..lineTo(0, 0) // Top left
        ..lineTo(size.width, 0) // Top right
        ..close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}