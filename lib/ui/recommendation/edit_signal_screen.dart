// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/recommender/create_signal_controller.dart';
import '../../framework/data_provider/recommender/edit_signal_controller.dart';
import '../../framework/data_provider/recommender/recommender_provider.dart';
import '../../framework/repository/common/model/crypto_currency_response_model.dart';
import '../../framework/repository/signal/model/signal_list_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/image_picker_manager_new.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import 'create_signal_screen.dart';

class EditSignalScreen extends ConsumerStatefulWidget {
  final SignalList? signalListData;

  const EditSignalScreen({Key? key, required this.signalListData})
      : super(key: key);

  @override
  ConsumerState<EditSignalScreen> createState() => _EditSignalScreenState();
}

class _EditSignalScreenState extends ConsumerState<EditSignalScreen>
    with WidgetsBindingObserver {
  ///TextEditing Controller
  TextEditingController technicalAnalysisEnCTR = TextEditingController();

  ///Focus Node
  FocusNode technicalAnalysisEnFocus = FocusNode();

  Timer? currencyTimer;

  ///-----Init----
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      WidgetsBinding.instance.addObserver(this);
      final editSignalWatch = ref.watch(editSignalProvider);
      final signalWatch = ref.watch(createSignalProvider);
      editSignalWatch.clearProvider();
      initializeValueForEditTarget(signalWatch);

      livePriceChangeFunction();
      technicalAnalysisEnCTR.text = widget.signalListData?.description ?? "";
      editSignalWatch.checkEnTechnicalAnalysisValidation(
          context, technicalAnalysisEnCTR.text);

      technicalAnalysisEnFocus.addListener(() {
        editSignalWatch.checkEnTechnicalAnalysisValidation(
            context, technicalAnalysisEnCTR.text);
      });
      await urlToFile(widget.signalListData?.chartImage ?? "");
    });
  }

  ///LifeCycle State
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    showLog('AppLifecycleState :- $state');
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await livePriceChangeFunction(isTimerStart: false);
      showLog("currency timer ${currencyTimer?.isActive}");
    } else if (state == AppLifecycleState.resumed) {
      await livePriceChangeFunction(isTimerStart: true);
      showLog("currency timer ${currencyTimer?.isActive}");
    }
  }

  @override
  void dispose() {
    super.dispose();
    livePriceChangeFunction(isTimerStart: false);
    WidgetsBinding.instance.removeObserver(this);
  }

  ///build widget
  @override
  Widget build(BuildContext context) {
    final signalWatch = ref.watch(createSignalProvider);

    return Stack(
      children: [
        Scaffold(
            backgroundColor: Constant.clrScaffoldBGByTheme(context),
            appBar: CommonAppBar(
              title: getLocalValue("Key_EditSignal"),
              titleTextStyle: TextStyles.txtMedG16(context),
              isTitleCenter: false,
              appBar: AppBar(
                  backgroundColor: Constant.clrScaffoldBGByTheme(context),
                  toolbarHeight: 64.h),
              isDrawer: false,
            ),
            body: NoInternetBuilder(child: bodyWidget()),
            bottomNavigationBar: bottomWidget()),
        DialogProgressBar(isLoading: signalWatch.isLoading)
      ],
    );
  }

  ///body widget
  Widget bodyWidget() {
    final editSignalWatch = ref.watch(editSignalProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency Header Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.13),
                color: Constant.clrHomeCardByTheme(context),
              ),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  _buildCurrencyHeader(),
                  Divider(color: Constant.clrSigDetDividerByTheme(context)),
                  _buildPriceDetailsSection(),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Edit Details Section
            _buildEditDetailsSection(),

            SizedBox(height: 24.h),

            // Target Section
            targetListWidget(),

            SizedBox(height: 24.h),

            // Chart Screenshot
            chartScreenShotWidget(editSignalWatch),

            SizedBox(height: 24.h),

            // Technical Analysis
            technicalAnalysisWidget(editSignalWatch),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  /// Currency Header with Logo, Name, and Risk Badge
  Widget _buildCurrencyHeader() {
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
            imageURL: widget.signalListData?.currencyLogo ?? "",
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
                  widget.signalListData?.currencyName ?? "",
                  style: TextStyles.txtSemiBoldG14(context).copyWith(
                    fontWeight: Constant.fwSemiBold,
                    color: Constant.clrSigDetByTheme(context),
                  ),
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
            ),
          ),
          // Risk Badge
          Container(
            width: 97.w,
            height: 23.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: widget.signalListData?.riskFactorLabel == "Medium Risk"
                  ? Constant.clrDarkPurple
                  : widget.signalListData?.riskFactorLabel == "High Risk"
                  ? Constant.clrDarkBlue
                  : Constant.clrDarkGreenNew,
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
              widget.signalListData?.riskFactorLabel ?? "",
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
      return Column(
        children: [
          _buildPriceDetailRow(
            label: "Key_EntryPrice".localized,
            value:
            "${widget.signalListData?.entryPrice ?? ""} ${"Key_USDT".localized}",
            valueColor: Constant.clrSigDetEntByTheme(context),
          ),
          Divider(
              indent: 16,
              endIndent: 16,
              thickness: 1.08,
              color: Constant.clrSigDetDividerByTheme(context)),
          _buildPriceDetailRow(
            label: "Key_StopLoss".localized,
            value:
            "${widget.signalListData?.stopLoss ?? ""} ${"Key_USDT".localized}",
            valueColor: Constant.clrSignOutRColor,
          ),
          Divider(
              indent: 16,
              endIndent: 16,
              thickness: 1.08,
              color: Constant.clrSigDetDividerByTheme(context)),
          _buildPriceDetailRow(
            label: "Key_LivePrice".localized,
            value:
            "${widget.signalListData?.livePrice ?? ""} ${"Key_USDT".localized}",
            valueColor: Constant.clrNotifSelectBColor,
          ),
          Divider(
              indent: 16,
              endIndent: 16,
              thickness: 1.08,
              color: Constant.clrSigDetDividerByTheme(context)),
          _buildPriceDetailRow(
            label: "% ${"Key_OfWallet".localized}",
            value: "${widget.signalListData?.walletPercentage ?? ""}%",
            valueColor: Constant.clrTitlePageByTheme(context),
          ),
          SizedBox(height: 16.h),
        ],
      );
    });
  }

  /// Individual Price Detail Row
  Widget _buildPriceDetailRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
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
        ],
      ),
    );
  }

  /// Edit Details Section
  Widget _buildEditDetailsSection() {
    return Consumer(builder: (context, ref, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Key_Details".localized,
                style: TextStyles.txtSemiG16(context)
                    .copyWith(fontWeight: Constant.fwSemiBold),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  final signalWatch = ref.watch(createSignalProvider);
                  signalWatch.setStep(2);

                  Route route = SlideRightPageRoute(
                      builder: (context) => CreateSignalScreen(
                        isEdit: true,
                        step: 2,
                        signalData: widget.signalListData,
                      ),
                      settings: const RouteSettings());
                  Navigator.of(context).push(route);
                },
                child: Text(
                  "Key_EditDetails".localized,
                  style: TextStyles.txtRegular12(context)
                      .copyWith(color: Constant.clrPrimary),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  ///target List widget
  Widget targetListWidget() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              getLocalValue("Key_Target"),
              style: TextStyles.txtSemiG16(context)
                  .copyWith(fontWeight: Constant.fwSemiBold),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                final signalWatch = ref.watch(createSignalProvider);
                signalWatch.setStep(3);

                Route route = SlideRightPageRoute(
                    builder: (context) => CreateSignalScreen(
                        isEdit: true,
                        step: 3,
                        signalData: widget.signalListData),
                    settings: const RouteSettings());
                Navigator.of(context).push(route);
              },
              child: Text(
                getLocalValue("Key_EditTarget"),
                style: TextStyles.txtRegular12(context)
                    .copyWith(color: Constant.clrPrimary),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.signalListData?.targets?.length ?? 0,
          itemBuilder: (context, index) {
            final item = widget.signalListData?.targets?[index];
            return _buildTargetItem(item, index, isRTL);
          },
        ),
      ],
    );
  }

  /// Individual Target Item
  Widget _buildTargetItem(dynamic item, int index, bool isRTL) {
    final isRange = item?.targetType == "range";
    final price = item?.price ?? "";
    final toPrice = item?.toPrice ?? "";

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Constant.clrSearchByTheme(context),
        borderRadius: BorderRadius.circular(15.r),
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
                      textDirection: TextDirection.ltr,
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.signalListData?.currencyCode ?? "",
                      style: TextStyles.txtRegG12(context).copyWith(
                        color: Constant.clrSigDetEntByTheme(context),
                      ),
                    ),
                  ],
                ),
                if (isRange && toPrice.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Row(
                    textDirection:
                    isRTL ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(
                        "$toPrice",
                        style: TextStyles.txtSemiG16(context).copyWith(
                          color: Constant.clrSigDetEntByTheme(context),
                          fontWeight: Constant.fwSemiBold,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      SizedBox(width: 5),
                      Text(
                        widget.signalListData?.currencyCode ?? "",
                        style: TextStyles.txtRegG12(context).copyWith(
                          color: Constant.clrSigDetEntByTheme(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chart Screenshot Widget with Edit Functionality
  Widget chartScreenShotWidget(EditSignalScreenController editSignalWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getLocalValue("Key_ChartScreenshot"),
          style: TextStyles.txtMedG16(context)
              .copyWith(fontWeight: Constant.fwSemiBold),
        ),
        SizedBox(height: 16.h),
        InkWell(
          onTap: () async {
            File? file = await ImagePickerManagerNew.instance
                .openPicker(context, cropNeed: false);
            if (file != null) {
              editSignalWatch.updateChartPic(file.path, file);
            }
          },
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 5.w, top: 5.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 171.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Constant.clrSearchByTheme(context),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: editSignalWatch.chartPic != ""
                        ? Image.file(
                      File(editSignalWatch.chartPic),
                      height: 171.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(Constant.icAddImage),
                        SizedBox(height: 8.h),
                        Text(
                          "Key_AddImage".localized,
                          style: TextStyles.txtMedium8(context)
                              .copyWith(color: Constant.clrGreyNew),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: editSignalWatch.chartPic != "",
                child: Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      editSignalWatch.updateChartPic("", File(''));
                    },
                    child: CommonImageAsset(
                      strIcon: Constant.icCancel,
                      height: 18.h,
                      width: 18.h,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  ///technical analysis widget
  Widget technicalAnalysisWidget(EditSignalScreenController editSignalWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final currentLength = technicalAnalysisEnCTR.text.length;
    const int maxCharacters = 3000;

    return Consumer(builder: (context, ref, child) {
      final drawerWatch = ref.watch(drawerProvider);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getLocalValue("Key_TechnicalAnalysisEn"),
            style: TextStyles.txtMedG16(context)
                .copyWith(fontWeight: Constant.fwSemiBold),
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: editSignalWatch.strTechnicalAnalysisErrorEn.isNotEmpty
                    ? Colors.red
                    : Constant.clrTextBorderGColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: technicalAnalysisEnCTR,
                  focusNode: technicalAnalysisEnFocus,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 12,
                  maxLines: null,
                  maxLength: maxCharacters,
                  style: TextStyles.txtRegG12(context).copyWith(
                    color: const Color(0xFF1A1A1A),
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: getLocalValue("Key_EnterHere"),
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
                    editSignalWatch.checkEnTechnicalAnalysisValidation(
                        context, value);
                    setState(() {});
                  },
                ),
                // Character counter
                Container(
                  padding: EdgeInsets.only(right: 16.w, bottom: 12.h),
                  alignment: Alignment.centerRight,
                  child: Text(
                    "$currentLength/$maxCharacters",
                    style: TextStyles.txtRegG12(context).copyWith(
                      color: currentLength > maxCharacters
                          ? Colors.red
                          : Constant.clrHintGColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  ///bottom Widget
  Widget bottomWidget() {
    final signalWatch = ref.watch(createSignalProvider);
    final editSignalWatch = ref.watch(editSignalProvider);

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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: CommonButton(
        label: getLocalValue("Key_UpdateSignal"),
        textSize: 16.sp,
        onTap: () async {
          editSignalApi(signalWatch, editSignalWatch);
        },
        height: 56.h,
        bgColor: Constant.clrPrimary,
        labelColor: Constant.clrWhite,
        borderColor: Constant.clrPrimary,
      ),
    );
  }

  Future<dynamic> urlToFile(String imageUrl) async {
    showLog("from Edit Signal ScreenimageUrl $imageUrl");
    final editSignalWatch = ref.watch(editSignalProvider);
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(tempPath + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    editSignalWatch.tempChartFile = file;
    return editSignalWatch.updateChartPic(file.path, file);
  }

  Future<void> editSignalApi(CreateSignalController signalWatch,
      EditSignalScreenController editSignalWatch) async {
    await signalWatch.editSignalAPI(
      context,
      widget.signalListData?.signalId ?? "",
      widget.signalListData?.currencyId ?? "",
      widget.signalListData?.walletPercentage ?? "",
      widget.signalListData?.riskFactor ?? "",
      widget.signalListData?.entryPrice ?? "",
      widget.signalListData?.stopLoss ?? "",
      editSignalWatch.chartFile,
      editSignalWatch.strTechnicalAnalysisEn,
      widget.signalListData?.status ?? "",
    );
    if (signalWatch.commonResponseModel?.status == ApiEndPoints.apiStatus_200) {
      showMessageDialog(
          context,
          signalWatch.commonResponseModel?.message ?? "",
              () => {
            Navigator.of(context).pop(),
            Navigator.of(context).pop(),
            signalWatch.apiSignalList(context, "active", getUserEntityId())
          });
    }
  }

  Future<void> initializeValueForEditTarget(
      CreateSignalController signalWatch) async {
    int length = widget.signalListData?.targets?.length ?? 0;
    signalWatch.targetList = [];
    signalWatch.valueCtrList = [];
    signalWatch.fromCtrList = [];
    signalWatch.toCtrList = [];
    for (int i = 0; i < length; i++) {
      String type = widget.signalListData?.targets?[i].targetType == "fixed"
          ? "Fixed"
          : "Range";
      String value = widget.signalListData?.targets?[i].targetType == "fixed"
          ? "${widget.signalListData?.targets?[i].price}"
          : "";
      String from = widget.signalListData?.targets?[i].targetType == "range"
          ? "${widget.signalListData?.targets?[i].price}"
          : "";
      String to = widget.signalListData?.targets?[i].targetType == "range"
          ? "${widget.signalListData?.targets?[i].toPrice}"
          : "";
      String targetId = widget.signalListData?.targets?[i].targetId ?? "";
      signalWatch.addTargetList(type, value, from, to, targetId);
      signalWatch.valueCtrList.add(TextEditingController(text: value));
      signalWatch.fromCtrList.add(TextEditingController(text: from));
      signalWatch.toCtrList.add(TextEditingController(text: to));
    }
  }

  /// Get Crypto Currency Data Live
  Future<void> getCryptoCurrencyData(CommonController commonWatch) async {
    if (isInternetConnectionOn) {
      if (mounted) {
        // await commonWatch.getCryptoCurrencyAPI(context);
      }
      if (commonWatch.cryptoCurrencyResponseModel.data != null ||
          commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
        /// Set Price in Main List Every secondsDelayForRealTimeAPICall seconds
        CryptoCurrencyData? currencyData = commonWatch
            .cryptoCurrencyResponseModel.data
            ?.where((element) =>
        element.id.toString() ==
            widget.signalListData?.apiCurrencyId)
            .first;
        // showLog("currencyData ${currencyData?.name}");
        if (currencyData != null) {
          widget.signalListData?.livePrice = currencyData.priceUsd;
        }
      }
      commonWatch.updateUi();
    }
  }

  /// Live Price Changes
  Future<void> livePriceChangeFunction({bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      if (isTimerStart) {
        final commonWatch = ref.watch(commonProvider);
        final signalWatch = ref.watch(createSignalProvider);

        /// Live Price Api Call every secondsDelayForRealTimeAPICall seconds
        currencyTimer = Timer.periodic(
            Duration(milliseconds: secondsDelayForRealTimeAPICall),
                (timer) async {
              await getCryptoCurrencyData(commonWatch);
            });
      } else {
        /// cancel Timer
        if (currencyTimer != null) {
          currencyTimer?.cancel();
        }
      }
    }
  }
}