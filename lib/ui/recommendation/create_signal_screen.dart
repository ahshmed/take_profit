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
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/favorite/favorite_controller.dart';
import '../../framework/data_provider/favorite/favorite_provider.dart';
import '../../framework/data_provider/home/currencies_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';

import '../../framework/data_provider/recommender/create_signal_controller.dart';
import '../../framework/data_provider/recommender/recommender_provider.dart';
import '../../framework/repository/common/model/crypto_currency_response_model.dart';

import '../../framework/repository/signal/model/signal_list_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/image_picker_manager_new.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/common_search_bar.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';

class RiskModel {
  String riskLabel;
  String sendRiskLabel;

  RiskModel({required this.riskLabel, required this.sendRiskLabel});
}

class CreateSignalScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int step;
  final SignalList? signalData;

  const CreateSignalScreen(
      {Key? key, this.isEdit = false, this.step = 1, this.signalData})
      : super(key: key);

  @override
  ConsumerState<CreateSignalScreen> createState() => _CreateSignalScreenState();
}

class _CreateSignalScreenState extends ConsumerState<CreateSignalScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollControllerCurrencyList = ScrollController();
  Timer? timer;

  Timer? currencyTimer;
  final List<RiskModel> riskList = [
    RiskModel(riskLabel: "Key_low".localized, sendRiskLabel: 'low'),
    RiskModel(riskLabel: "Key_medium".localized, sendRiskLabel: 'medium'),
    RiskModel(riskLabel: "Key_high".localized, sendRiskLabel: 'high'),
  ];

  /// Text Controller
  TextEditingController searchCTR = TextEditingController();
  TextEditingController walletPRCTR = TextEditingController();
  TextEditingController priceCTR = TextEditingController();
  TextEditingController lossCTR = TextEditingController();
  TextEditingController valueCTR = TextEditingController();
  TextEditingController toRangeCTR = TextEditingController();
  TextEditingController fromRangeCTR = TextEditingController();
  TextEditingController analysisEnCTR = TextEditingController();

  /// Focus Node
  FocusNode searchFocus = FocusNode();
  FocusNode walletPRFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode lossFocus = FocusNode();
  FocusNode valueFocus = FocusNode();
  FocusNode toRangeFocus = FocusNode();
  FocusNode fromRangeFocus = FocusNode();
  FocusNode analysisFocusEn = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      WidgetsBinding.instance.addObserver(this);
      final signalWatch = ref.watch(createSignalProvider);
      final currenciesWatch = ref.watch(currenciesProvider);
      clearProviderData(signalWatch, currenciesWatch);
      showLog("${signalWatch.step}");
      signalWatch.setStep(widget.step);
      if (widget.isEdit) {
        initializeValueForEdit(signalWatch);
        if (signalWatch.step == 3) {
          initializeValueForEditTarget(signalWatch);
        }
        await urlToFile(widget.signalData?.chartImage ?? '');
      } else {
        await currencyAPI(currenciesWatch, "");
        await livePriceChangeFunction();

        walletPRFocus.addListener(() {
          signalWatch.checkWalletValidation(context, walletPRCTR.text);
        });
        priceFocus.addListener(() {
          signalWatch.checkPriceValidation(context, priceCTR.text);
        });
        lossFocus.addListener(() {
          signalWatch.checkLossValidation(context, lossCTR.text);
        });
        valueFocus.addListener(() {
          signalWatch.checkValueValidation(
              context,
              valueCTR.text,
              TargetModel(
                  type: "",
                  value: "",
                  from: "",
                  to: "",
                  fromError: "",
                  toError: "",
                  valueError: "",
                  targetID: ''));
        });
        fromRangeFocus.addListener(() {
          signalWatch.checkFromRangeValidation(
              context,
              fromRangeCTR.text,
              TargetModel(
                  type: "",
                  value: "",
                  from: "",
                  to: "",
                  fromError: "",
                  toError: "",
                  valueError: "",
                  targetID: ''));
        });
        toRangeFocus.addListener(() {
          signalWatch.checkToRangeValidation(
              context,
              toRangeCTR.text,
              TargetModel(
                  type: "",
                  value: "",
                  from: "",
                  to: "",
                  fromError: "",
                  toError: "",
                  valueError: "",
                  targetID: ''));
        });

        analysisEnCTR.text = widget.signalData?.description ?? "";
        analysisFocusEn.addListener(() {
          signalWatch.checkEnAnalysisValidation(
            context,
            analysisEnCTR.text,
          );
        });
      }
      _scrollControllerCurrencyList.addListener(() async {
        if (currenciesWatch.isHasMoreCurrencyList) {
          if (_scrollControllerCurrencyList.position.maxScrollExtent ==
              _scrollControllerCurrencyList.position.pixels) {
            if (currenciesWatch.isLoadingForPagination == false) {
              if ((int.parse(currenciesWatch
                  .currencyListResponseModel?.data?.pageNumber
                  ?.toString() ??
                  "0") !=
                  int.parse(currenciesWatch
                      .currencyListResponseModel?.data?.totalPage
                      .toString() ??
                      "0"))) {
                await currencyAPI(currenciesWatch, "");
              }
            }
          }
        }
      });
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
    if (timer != null) {
      timer!.cancel();
    }
    livePriceChangeFunction(isTimerStart: false);
    _scrollControllerCurrencyList.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Manual Dispose
  Future<void> clearProviderData(CreateSignalController signalWatch,
      CurrenciesScreenController currencyWatch) async {
    signalWatch.clearProvider();
    currencyWatch.clearProvider();
  }

  ///main body
  @override
  Widget build(BuildContext context) {
    final signalWatch = ref.watch(createSignalProvider);
    final currenciesWatch = ref.watch(currenciesProvider);

    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            if (signalWatch.step == 2 && widget.isEdit) {
              return true;
            } else if (signalWatch.step == 2) {
              signalWatch.setStep(1);
              return false;
            } else if (signalWatch.step == 3 && widget.isEdit) {
              return true;
            } else if (signalWatch.step == 3) {
              signalWatch.setStep(2);
              return false;
            } else if (signalWatch.step == 4) {
              signalWatch.setStep(3);
              return false;
            } else {
              Navigator.pop(context);
              return true;
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Constant.clrScaffoldBGByTheme(context),
            appBar: CommonAppBar(
              titleTextStyle: TextStyles.txtMedG16(context),
              isTitleCenter: false,
              title: "",
              appBar: AppBar(
                  backgroundColor: Constant.clrScaffoldBGByTheme(context),
                  toolbarHeight: 64.h),
              isDrawer: false,
              onPress: () {
                (signalWatch.step == 2 && widget.isEdit)
                    ? Navigator.pop(context)
                    : signalWatch.step == 2
                    ? signalWatch.setStep(1)
                    : (signalWatch.step == 3 && widget.isEdit)
                    ? Navigator.pop(context)
                    : signalWatch.step == 3
                    ? signalWatch.setStep(2)
                    : signalWatch.step == 4
                    ? signalWatch.setStep(3)
                    : Navigator.pop(context);
              },
            ),
            body: NoInternetBuilder(
              child: bodyWidget(),
            ),
            bottomNavigationBar: Visibility(
              visible: signalWatch.step != 1,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  bottom: getIsIOSPlatform() ? 34.h : 20.h,
                  top: 16.h,
                ),
                child: CommonButton(
                  isEnable: signalWatch.step == 2
                      ? signalWatch.isValidAllField
                      : signalWatch.step == 3
                      ? signalWatch.isValidTargetField
                      : true,
                  label: signalWatch.step == 2
                      ? (widget.isEdit)
                      ? getLocalValue('Key_SaveChanges')
                      : getLocalValue("Key_AddTarget")
                      : signalWatch.step == 3
                      ? (widget.isEdit)
                      ? getLocalValue("Key_SaveChanges")
                      : getLocalValue("Key_AddChartScreenShot")
                      : (widget.isEdit && signalWatch.step == 4)
                      ? getLocalValue("Key_UpdateSignal")
                      : signalWatch.step == 4
                      ? getLocalValue("Key_CreateSignal")
                      : "",
                  onTap: () async {
                    if (signalWatch.step == 2) {
                      clearStep2Data(signalWatch);
                      if (widget.isEdit) {
                        analysisEnCTR.text =
                            widget.signalData?.descriptionEn ?? "";
                        signalWatch.checkEnAnalysisValidation(
                            context, analysisEnCTR.text);
                        initializeValueForEditTarget(signalWatch);
                        await editSignalAPI(signalWatch);
                      }
                    } else if (signalWatch.step == 3) {
                      clearStep3Data(signalWatch);
                      if (widget.isEdit) {
                        analysisEnCTR.text =
                            widget.signalData?.descriptionEn ?? "";
                        signalWatch.checkEnAnalysisValidation(
                            context, analysisEnCTR.text);
                        await editSignalAPI(signalWatch);
                      } else {}
                    } else {
                      if (widget.isEdit) {
                        editSignalAPI(signalWatch);
                      } else {
                        createSignalAPI(signalWatch);
                      }
                    }
                  },
                  bgColor: Constant.clrPrimary,
                  labelColor: Constant.clrWhite,
                  textSize: 16.sp,
                ),
              ),
            ),
          ),
        ),
        DialogProgressBar(
            isLoading: signalWatch.isLoading || currenciesWatch.isLoading)
      ],
    );
  }

  ///widget body
  Widget bodyWidget() {
    final signalWatch = ref.watch(createSignalProvider);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            // Title
            Text(
              widget.isEdit
                  ? "Key_EditSignal".localized
                  : "Key_CreateSignal".localized,
              style: TextStyles.txtSemiG16(context)
                  .copyWith(fontWeight: Constant.fwSemiBold),
            ),
            SizedBox(height: 15.h),
            // Progress Bar
            _buildProgressBar(signalWatch.step),
            SizedBox(height: 20.h),
            // Step Content
            Expanded(
              child: signalWatch.step == 1
                  ? step1Widget(signalWatch)
                  : signalWatch.step == 2
                  ? step2Widget(signalWatch)
                  : signalWatch.step == 3
                  ? step3Widget(signalWatch)
                  : step4Widget(signalWatch),
            ),
          ],
        ),
      ),
    );
  }

  /// Progress Bar Widget
  Widget _buildProgressBar(int currentStep) {
    final totalSteps = 4;
    final progress = currentStep / totalSteps;

    return Container(
      height: 4.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Constant.clrSearchByTheme(context),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Constant.clrPrimary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  ///-------------Step:1------------
  Widget step1Widget(CreateSignalController signalWatch) {
    final currenciesWatch = ref.watch(currenciesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getLocalValue("Key_SelectCurrency"),
          style: TextStyles.txtSemiG16(context)
              .copyWith(fontWeight: Constant.fwSemiBold),
        ),
        SizedBox(height: 16.h),
        CommonSearchBar(
          controller: searchCTR,
          focusNode: searchFocus,
          elevation: 0,
          onChanged: (value) {
            showLog("Search Keyword - $value");
            if (timer != null) {
              timer!.cancel();
            }
            timer = Timer.periodic(const Duration(milliseconds: 750),
                    (timer) async {
                  timer.cancel();
                  if (isInternetConnectionOn) {
                    currenciesWatch.clearProvider();
                    showLog("search text");
                    hideKeyboard(context);
                    await currencyAPI(currenciesWatch, searchCTR.text);
                  }
                });
          },
          borderRadius: 11.r,
          hintText: "Key_SearchHere".localized,
        ),
        SizedBox(height: 16.h),
        listWidgetStep1(signalWatch),
        DialogProgressBar(
          isLoading: currenciesWatch.isLoadingForPagination,
          forPagination: true,
        ).paddingOnly(bottom: 40.h),
      ],
    );
  }

  ///-------------Step:2------------
  Widget step2Widget(CreateSignalController signalWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency Header Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Constant.clrHomeCardByTheme(context),
            ),
            child: Row(
              children: [
                CacheImage(
                  imageURL: widget.isEdit
                      ? widget.signalData?.currencyLogo ?? ""
                      : signalWatch.currencyData?.logo ?? "",
                  height: 49.31.w,
                  width: 49.32.w,
                  contentMode: BoxFit.cover,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isRTL
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isEdit
                            ? widget.signalData?.currencyName ?? ""
                            : signalWatch.currencyData?.name ?? "",
                        style: TextStyles.txtSemiBoldG14(context).copyWith(
                          fontWeight: Constant.fwSemiBold,
                          color: Constant.clrSigDetByTheme(context),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.isEdit
                            ? "${widget.signalData?.livePrice ?? ""} ${widget.signalData?.currencyCode ?? ""}"
                            : "${signalWatch.currencyData?.price ?? ""} ${signalWatch.currencyData?.currencyCode ?? ""}",
                        style: TextStyles.txtRegG12(context).copyWith(
                          color: Constant.clrSigDetEntByTheme(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            getLocalValue("Key_EnterDetail"),
            style: TextStyles.txtSemiG16(context)
                .copyWith(fontWeight: Constant.fwSemiBold),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  "%${"Key_PRWallet".localized}*",
                  style: TextStyles.txtSemiBoldG12(context),
                ),
              ),
              Expanded(
                child: Text(
                  "${"Key_SelectRisk".localized}*",
                  style: TextStyles.txtSemiBoldG12(context),
                ),
              )
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  height: 50.3,
                  contentPadding:
                  const EdgeInsets.only(left: 12,right: 12),
                  context: context,
                  myController: walletPRCTR,
                  myFocus: walletPRFocus,
                  textStyle: TextStyles.txtSemiBold14(context)
                      .copyWith(color: Constant.clrTextByTheme(context)),
                  bgColor: Constant.clrSearchByTheme(context),
                  textInputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (str) {
                    signalWatch.checkWalletValidation(context, str);
                  },
                  hintText: "%",
                  textInputAction: TextInputAction.done,
                  errorMessage: signalWatch.strWalletError,
                  marginNeed: false,
                  paddingNeed: false,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 51,
                      decoration: BoxDecoration(
                          color: Constant.clrSearchByTheme(context),
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(
                              color: signalWatch.selectedRisk != null
                                  ? Constant.clrSigDetDividerByTheme(context)
                                  : Constant.clrSigDetDividerByTheme(context),
                              width: 2)),
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: DropdownButton<RiskModel>(
                          dropdownColor: Constant.clrSearchByTheme(context),
                          borderRadius: BorderRadius.circular(10.r),
                          underline: const Offstage(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          hint: Text(
                            "Key_Select".localized,
                            style: TextStyles.txtSemiBold14(context).copyWith(
                                color: Constant.clrHeaderSubSignDetailsColor),
                          ),
                          isExpanded: true,
                          value: signalWatch.selectedRisk,
                          items: riskList.map((value) {
                            return DropdownMenuItem<RiskModel>(
                              value: value,
                              child: Text(
                                value.riskLabel,
                                style: TextStyles.txtSemiBold14(context)
                                    .copyWith(
                                    color: Constant.clrTextByTheme(context)),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            signalWatch.setSelectRisk(context, value!);
                          }),
                    ),
                    signalWatch.strWalletError != ""
                        ? SizedBox(height: 24.h)
                        : const SizedBox()
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            "Key_EntryPrice".localized,
            style: TextStyles.txtSemiBoldG12(context),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            contentPadding: EdgeInsets.only(left: 12,right: 12,),
            context: context,
            myController: priceCTR,
            myFocus: priceFocus,
            bgColor: Constant.clrSearchByTheme(context),
            textInputType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (str) {
              signalWatch.checkPriceValidation(context, str);
            },
            inputFormatters: [
              DecimalTextInputFormatter(decimalRange: maxDecimalPointsRange),
            ],
            hintText: getLocalValue("Key_EnterPrice"),
            textInputAction: TextInputAction.next,
            suffix: Container(
              height: 24.h,
              width: 34.w,
              padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
              child: Text(
                widget.isEdit
                    ? (widget.signalData?.currencyCode ?? "")
                    : (signalWatch.currencyData?.currencyCode ?? ""),
                style: TextStyles.txtMedium12(context)
                    .copyWith(color: Constant.clrHeaderSubSignDetailsColor),
              ),
            ),
            errorMessage: signalWatch.strPriceError,
            marginNeed: false,
            paddingNeed: false,
          ),
          SizedBox(height: 20.h),
          Text(
            "${"Key_StopLoss".localized}*",
            style: TextStyles.txtSemiBoldG12(context),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            context: context,
            myController: lossCTR,
            myFocus: lossFocus,
            bgColor: Constant.clrSearchByTheme(context),
            textInputType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              DecimalTextInputFormatter(decimalRange: maxDecimalPointsRange),
            ],
            onChanged: (str) {
              signalWatch.checkLossValidation(context, str);
            },
            hintText: getLocalValue("Key_EnterStopLoss"),
            textInputAction: TextInputAction.done,
            suffix: Container(
                height: 24.h,
                width: 34.w,
                padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
                child: Text(
                  widget.isEdit
                      ? (widget.signalData?.currencyCode ?? "")
                      : (signalWatch.currencyData?.currencyCode ?? ""),
                  style: TextStyles.txtMedium12(context)
                      .copyWith(color: Constant.clrHeaderSubSignDetailsColor),
                )),
            errorMessage: signalWatch.strLossError,
            marginNeed: false,
            paddingNeed: true,
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  ///-------------Step:3------------
  Widget step3Widget(CreateSignalController signalWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency Header Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Constant.clrHomeCardByTheme(context),
            ),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CacheImage(
                        imageURL: widget.isEdit
                            ? widget.signalData?.currencyLogo ?? ""
                            : signalWatch.currencyData?.logo ?? "",
                        height: 49.31.w,
                        width: 49.32.w,
                        contentMode: BoxFit.cover,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isRTL
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isEdit
                                  ? widget.signalData?.currencyName ?? ""
                                  : signalWatch.currencyData?.name ?? "",
                              style: TextStyles.txtSemiBoldG14(context).copyWith(
                                fontWeight: Constant.fwSemiBold,
                                color: Constant.clrSigDetByTheme(context),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.isEdit
                                  ? "${widget.signalData?.livePrice ?? ""} ${widget.signalData?.currencyCode ?? ""}"
                                  : "${signalWatch.currencyData?.price ?? ""} ${signalWatch.currencyData?.currencyCode ?? ""}",
                              style: TextStyles.txtRegG12(context).copyWith(
                                color: Constant.clrSigDetEntByTheme(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 97.w,
                        height: 23.h,
                        padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: signalWatch.selectedRisk?.sendRiskLabel == "low"
                              ? Constant.clrDarkGreenNew
                              : signalWatch.selectedRisk?.sendRiskLabel == "high"
                              ? Constant.clrDarkBlue
                              : Constant.clrDarkPurple,
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
                          signalWatch.selectedRisk?.sendRiskLabel == "low"
                              ? "Key_LowRisk".localized
                              : signalWatch.selectedRisk?.sendRiskLabel == "high"
                              ? "Key_HighRisk".localized
                              : "Key_MediumRisk".localized,
                          style: TextStyles.txtSemiBoldG10(context).copyWith(
                            fontWeight: Constant.fwRegular,
                            color: Constant.clrWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Constant.clrSigDetDividerByTheme(context)),
                _buildDetailsSection(signalWatch),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getLocalValue("Key_AddTarget"),
                style: TextStyles.txtSemiG16(context)
                    .copyWith(fontWeight: Constant.fwSemiBold),
              ),
              InkWell(
                onTap: () {
                  signalWatch.addTargetList("Fixed", "", "", "", '');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21.r),
                    color: Constant.clrPrimary.withOpacity(0.1),
                  ),
                  child: Text(
                    "+${getLocalValue("Key_AddNew")}",
                    style: TextStyles.txtMedium12(context)
                        .copyWith(color: Constant.clrPrimary),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 16.h),
          listWidgetAddTargetContent(signalWatch),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  /// Details Section for Step 3
  Widget _buildDetailsSection(CreateSignalController signalWatch) {
    return Column(
      children: [
        _buildDetailRow(
          label: "Key_EntryPrice".localized,
          value: "${signalWatch.strPrice} ${widget.isEdit ? (widget.signalData?.currencyCode ?? "") : (signalWatch.currencyData?.currencyCode ?? "")}",
          valueColor: Constant.clrSigDetEntByTheme(context),
        ),
        Divider(
            indent: 16,
            endIndent: 16,
            thickness: 1.08,
            color: Constant.clrSigDetDividerByTheme(context)),
        _buildDetailRow(
          label: "Key_StopLoss".localized,
          value: "${signalWatch.strLoss} ${widget.isEdit ? (widget.signalData?.currencyCode ?? "") : (signalWatch.currencyData?.currencyCode ?? "")}",
          valueColor: Constant.clrSignOutRColor,
        ),
        Divider(
            indent: 16,
            endIndent: 16,
            thickness: 1.08,
            color: Constant.clrSigDetDividerByTheme(context)),
        _buildDetailRow(
          label: "% ${"Key_OfWallet".localized}",
          value: "${signalWatch.strWallet}%",
          valueColor: Constant.clrTitlePageByTheme(context),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  /// Detail Row Widget
  Widget _buildDetailRow({
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

  ///-------------Step:4------------
  Widget step4Widget(CreateSignalController signalWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SingleChildScrollView(
      child: Padding(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency Header Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Constant.clrHomeCardByTheme(context),
              ),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CacheImage(
                          imageURL: widget.isEdit
                              ? widget.signalData?.currencyLogo ?? ""
                              : signalWatch.currencyData?.logo ?? "",
                          height: 49.31.w,
                          width: 49.32.w,
                          contentMode: BoxFit.cover,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: isRTL
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isEdit
                                    ? widget.signalData?.currencyName ?? ""
                                    : signalWatch.currencyData?.name ?? "",
                                style:
                                TextStyles.txtSemiBoldG14(context).copyWith(
                                  fontWeight: Constant.fwSemiBold,
                                  color: Constant.clrSigDetByTheme(context),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.isEdit
                                    ? "${widget.signalData?.livePrice ?? ""} ${widget.signalData?.currencyCode ?? ""}"
                                    : "${signalWatch.currencyData?.price ?? ""} ${signalWatch.currencyData?.currencyCode ?? ""}",
                                style: TextStyles.txtRegG12(context).copyWith(
                                  color: Constant.clrSigDetEntByTheme(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 97.w,
                          height: 23.h,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: signalWatch.selectedRisk?.sendRiskLabel ==
                                "low"
                                ? Constant.clrDarkGreenNew
                                : signalWatch.selectedRisk?.sendRiskLabel ==
                                "high"
                                ? Constant.clrDarkBlue
                                : Constant.clrDarkPurple,
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
                            signalWatch.selectedRisk?.sendRiskLabel == "low"
                                ? "Key_LowRisk".localized
                                : signalWatch.selectedRisk?.sendRiskLabel ==
                                "high"
                                ? "Key_HighRisk".localized
                                : "Key_MediumRisk".localized,
                            style: TextStyles.txtSemiBoldG10(context).copyWith(
                              fontWeight: Constant.fwRegular,
                              color: Constant.clrWhite,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Constant.clrSigDetDividerByTheme(context)),
                  _buildDetailsSection(signalWatch),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              getLocalValue("Key_Target"),
              style: TextStyles.txtSemiG16(context)
                  .copyWith(fontWeight: Constant.fwSemiBold),
            ),
            widgetListStep4(signalWatch),
            SizedBox(height: 24.h),
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
                  signalWatch.updateChartPic(file.path, file);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  height: 171.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Constant.clrSearchByTheme(context),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: signalWatch.chartPic == ""
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(Constant.icAddImage),
                      SizedBox(height: 8.h),
                      Text(
                        "Key_AddImage".localized,
                        style: TextStyles.txtMedium8(context).copyWith(
                            color: Constant.clrHeaderSubSignDetailsColor),
                      ),
                    ],
                  )
                      : Image.file(
                    File(signalWatch.chartPic),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 171.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              getLocalValue("Key_AddTechnicalAnalysisEn"),
              style: TextStyles.txtMedG16(context)
                  .copyWith(fontWeight: Constant.fwSemiBold),
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: Constant.clrSearchByTheme(context),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Consumer(builder: (context, ref, child) {
                final drawerWatch = ref.watch(drawerProvider);
                return CustomTextField(
                  height: 92.h,
                  context: context,
                  myController: analysisEnCTR,
                  myFocus: analysisFocusEn,
                  bgColor: Constant.clrSearchByTheme(context),
                  textInputType: TextInputType.multiline,
                  onChanged: (str) {
                    showLog("strAnalysisEn $str");
                    signalWatch.checkEnAnalysisValidation(context, str);
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(maxAboutUsLength),
                  ],
                  hintText: getLocalValue("Key_EnterHere"),
                  textInputAction: TextInputAction.newline,
                  errorMessage: signalWatch.strAnalysisErrorEn,
                  borderRadius: 12.r,
                  marginNeed: false,
                  paddingNeed: false,
                  maxLine: 7,
                  contentPadding: EdgeInsets.only(
                      right: drawerWatch.isEngEnable == true ? -20.w : 10.w,
                      left: drawerWatch.isEngEnable == true ? 10.w : -20.w,
                      top: 20),
                );
              }),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget listWidgetStep1(CreateSignalController signalWatch) {
    final currenciesWatch = ref.watch(currenciesProvider);
    final favouriteWatch = ref.watch(favoriteProvider);
    return Expanded(
      child: (currenciesWatch.currencyList?.isEmpty == true &&
          !currenciesWatch.isLoading)
          ? EmptyStateWidget(emptyStateFor: EmptyState.noSearchCurrencyFound)
          : ListView.builder(
        shrinkWrap: true,
        controller: _scrollControllerCurrencyList,
        itemCount: currenciesWatch.currencyList?.length ?? 0,
        padding: EdgeInsets.only(
            bottom: (MediaQuery.of(context).padding.bottom + 62).h),
        itemBuilder: (context, index) {
          final currencyObj = currenciesWatch.currencyList?[index];
          return InkWell(
            onTap: () {
              signalWatch.addCurrencyObj(currencyObj!);
              signalWatch.clearProvider();
              walletPRCTR.clear();
              priceCTR.clear();
              lossCTR.clear();
              signalWatch.setStep(2);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Constant.clrHomeCardByTheme(context),
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
                children: [
                  CacheImage(
                    imageURL: currencyObj?.logo ?? "",
                    height: 45.h,
                    width: 45.h,
                    contentMode: BoxFit.cover,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              currencyObj?.name ?? "",
                              style: TextStyles.txtSemiBoldG14(context)
                                  .copyWith(
                                fontWeight: Constant.fwSemiBold,
                                color: Constant.clrSigDetByTheme(context),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              currencyObj?.symbol ?? "",
                              style: TextStyles.txtRegG12(context).copyWith(
                                color:
                                Constant.clrHeaderSubSignDetailsColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${currencyObj?.price ?? ""} ${currencyObj?.currencyCode ?? ""}",
                          style: TextStyles.txtRegG12(context).copyWith(
                            color: Constant.clrSigDetEntByTheme(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: getUserStatus() == guest ? false : true,
                    child: InkWell(
                      onTap: () {
                        _manageFavourite(favouriteWatch,
                            currencyObj?.id ?? "", currenciesWatch);
                      },
                      child: CommonImageAsset(
                        strIcon: currencyObj?.isFavourite == "1"
                            ? Constant.icLike
                            : Constant.icUnLike,
                        height: 26.h,
                        width: 26.h,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget listWidgetAddTargetContent(CreateSignalController signalWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return ListView.builder(
      itemCount: signalWatch.targetList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
              var valueController = TextEditingController();
              var fromController = TextEditingController();
              var toController = TextEditingController();
              signalWatch.valueCtrList.add(valueController);
              signalWatch.fromCtrList.add(fromController);
              signalWatch.toCtrList.add(toController);

              var valueFocus = FocusNode();
              var fromFocus = FocusNode();
              var toFocus = FocusNode();
              signalWatch.valueFocusList.add(valueFocus);
              signalWatch.toFocusList.add(toFocus);
              signalWatch.fromFocusList.add(fromFocus);

              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Target ${index + 1}",
                          style: TextStyles.txtSemiBoldG14(context).copyWith(
                            fontWeight: Constant.fwSemiBold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (signalWatch.targetList.length > 1) {
                              signalWatch.removeTarget(index);
                            } else {
                              showMessageDialog(
                                  context,
                                  getLocalValue("Key_TargetValidationMSG"),
                                      () {});
                            }
                          },
                          child: Icon(
                            Icons.delete_outline,
                            color: Constant.clrSignOutRColor,
                            size: 22.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "${"Key_SelectType".localized}*",
                      style: TextStyles.txtSemiBoldG12(context),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            signalWatch.setType("Fixed", index);
                            signalWatch.toCtrList[index].text = "";
                            signalWatch.fromCtrList[index].text = "";
                            signalWatch.valueCtrList[index].text = "";
                            signalWatch.clearRangeValue(index);
                          },
                          child: Row(
                            children: [
                              Icon(
                                signalWatch.targetList[index].type == "Fixed"
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: signalWatch.targetList[index].type ==
                                    "Fixed"
                                    ? Constant.clrPrimary
                                    : Constant.clrHeaderSubSignDetailsColor,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Key_Fixed".localized,
                                style: TextStyles.txtRegG14(context),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 24.w),
                        InkWell(
                          onTap: () {
                            signalWatch.setType("Range", index);
                            signalWatch.toCtrList[index].text = "";
                            signalWatch.fromCtrList[index].text = "";
                            signalWatch.valueCtrList[index].text = "";
                            signalWatch.clearRangeValue(index);
                          },
                          child: Row(
                            children: [
                              Icon(
                                signalWatch.targetList[index].type == "Range"
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: signalWatch.targetList[index].type ==
                                    "Range"
                                    ? Constant.clrPrimary
                                    : Constant.clrHeaderSubSignDetailsColor,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Key_Range".localized,
                                style: TextStyles.txtRegG14(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Visibility(
                      visible: signalWatch.targetList[index].type == "Fixed",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${"Key_Value".localized}*",
                            style: TextStyles.txtSemiBoldG12(context),
                          ),
                          SizedBox(height: 12.h),
                          CustomTextField(
                            context: context,
                            myController: signalWatch.valueCtrList[index],
                            myFocus: signalWatch.valueFocusList[index],
                            bgColor: Constant.clrHomeCardByTheme(context),
                            textInputType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              DecimalTextInputFormatter(
                                  decimalRange: maxDecimalPointsRange),
                            ],
                            onChanged: (str) {
                              signalWatch.checkValueValidation(context, str,
                                  signalWatch.targetList[index]);
                              signalWatch.updateFixedValue(str, index);
                            },
                            hintText: "Key_EnterAmount".localized,
                            textInputAction: TextInputAction.done,
                            suffix: Container(
                              height: 24.h,
                              width: 24.h,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.w, vertical: 10.h),
                              child: Text(
                                widget.isEdit
                                    ? (widget.signalData?.currencyCode ?? "")
                                    : (signalWatch
                                    .currencyData?.currencyCode ??
                                    ""),
                                style: TextStyles.txtMedium12(context)
                                    .copyWith(
                                    color: Constant
                                        .clrHeaderSubSignDetailsColor),
                              ),
                            ),
                            errorMessage:
                            signalWatch.targetList[index].valueError,
                            marginNeed: false,
                            paddingNeed: false,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: signalWatch.targetList[index].type == "Range",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${"Key_From".localized}*",
                                  style: TextStyles.txtSemiBoldG12(context),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${"Key_To".localized}*",
                                  style: TextStyles.txtSemiBoldG12(context),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  context: context,
                                  myController:
                                  signalWatch.fromCtrList[index],
                                  myFocus: signalWatch.fromFocusList[index],
                                  bgColor: Constant.clrHomeCardByTheme(context),
                                  textInputType: const TextInputType
                                      .numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    DecimalTextInputFormatter(
                                        decimalRange: maxDecimalPointsRange),
                                  ],
                                  onChanged: (str) {
                                    signalWatch.checkFromRangeValidation(
                                        context,
                                        str,
                                        signalWatch.targetList[index]);
                                    signalWatch.updateRangeFrom(str, index);
                                  },
                                  textInputAction: TextInputAction.done,
                                  suffix: Container(
                                    height: 24.h,
                                    width: 24.h,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0.w, vertical: 10.h),
                                    child: Text(
                                      widget.isEdit
                                          ? (widget.signalData?.currencyCode ??
                                          "")
                                          : (signalWatch.currencyData
                                          ?.currencyCode ??
                                          ""),
                                      style: TextStyles.txtMedium12(context)
                                          .copyWith(
                                          color: Constant
                                              .clrHeaderSubSignDetailsColor),
                                    ),
                                  ),
                                  errorMessage: signalWatch
                                      .targetList[index].fromError,
                                  marginNeed: false,
                                  paddingNeed: true,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  context: context,
                                  myController: signalWatch.toCtrList[index],
                                  myFocus: signalWatch.toFocusList[index],
                                  bgColor: Constant.clrHomeCardByTheme(context),
                                  textInputType: const TextInputType
                                      .numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    DecimalTextInputFormatter(
                                        decimalRange: maxDecimalPointsRange),
                                  ],
                                  onChanged: (str) {
                                    signalWatch.checkToRangeValidation(
                                        context,
                                        str,
                                        signalWatch.targetList[index]);
                                    signalWatch.updateRangeTo(str, index);
                                  },
                                  textInputAction: TextInputAction.done,
                                  suffix: Container(
                                    height: 24.h,
                                    width: 24.h,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0.w, vertical: 10.h),
                                    child: Text(
                                      widget.isEdit
                                          ? (widget.signalData?.currencyCode ??
                                          "")
                                          : (signalWatch.currencyData
                                          ?.currencyCode ??
                                          ""),
                                      style: TextStyles.txtMedium12(context)
                                          .copyWith(
                                          color: Constant
                                              .clrHeaderSubSignDetailsColor),
                                    ),
                                  ),
                                  errorMessage:
                                  signalWatch.targetList[index].toError,
                                  marginNeed: false,
                                  paddingNeed: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
  }

  Widget widgetListStep4(CreateSignalController signalWatch) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: signalWatch.targetList.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final isRange = signalWatch.targetList[index].type != "Fixed";

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
                Center(
                  child: Text("${index + 1}",
                      style: TextStyles.txtMedG12(context)),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: isRTL
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        textDirection:
                        isRTL ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Text(
                            isRange
                                ? signalWatch.targetList[index].from
                                : signalWatch.targetList[index].value,
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
                            widget.isEdit
                                ? (widget.signalData?.currencyCode ?? "")
                                : (signalWatch.currencyData?.currencyCode ??
                                ""),
                            style: TextStyles.txtRegG12(context).copyWith(
                              color: Constant.clrSigDetEntByTheme(context),
                            ),
                          ),
                        ],
                      ),
                      if (isRange &&
                          signalWatch.targetList[index].to.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          textDirection:
                          isRTL ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Text(
                              signalWatch.targetList[index].to,
                              style: TextStyles.txtSemiG16(context).copyWith(
                                color: Constant.clrSigDetEntByTheme(context),
                                fontWeight: Constant.fwSemiBold,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                            SizedBox(width: 5),
                            Text(
                              widget.isEdit
                                  ? (widget.signalData?.currencyCode ?? "")
                                  : (signalWatch
                                  .currencyData?.currencyCode ??
                                  ""),
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
        },
      ),
    );
  }

  /// Currency list API Call
  Future<void> currencyAPI(
      CurrenciesScreenController currenciesWatch, String value) async {
    if (isInternetConnectionOn) {
      await currenciesWatch.currencyListAPI(context, value);
    }
  }

  /// Create Signal API Call
  Future<void> createSignalAPI(CreateSignalController signalWatch) async {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    if (isInternetConnectionOn) {
      await signalWatch.createSignalAPI(context);
      if (signalWatch.commonResponseModel?.status ==
          ApiEndPoints.apiStatus_200) {
        showMessageDialog(
            context, signalWatch.commonResponseModel?.message ?? "", () {
          signalWatch.setStep(1);
          myRecommendationWatch.updateSignalsSubTabIndex(1);
          signalWatch.apiSignalList(
              context,
              myRecommendationWatch.signalsSubTabSelectIndex == 0
                  ? "pending"
                  : "active",
              getUserEntityId());
          final recommenderWatch = ref.watch(recommenderProvider);
          recommenderWatch.apiAllSignalList(
              context,
              recommenderWatch.signalsSubTabSelectIndex == 0
                  ? "pending"
                  : "active",
              getUserEntityId());
          Navigator.pop(context);
        });
      }
    }
  }

  /// Edit Signal API Call
  Future<void> editSignalAPI(CreateSignalController signalWatch) async {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    if (isInternetConnectionOn) {
      await signalWatch.editSignalAPI(
          context,
          widget.signalData?.signalId ?? "",
          widget.signalData?.currencyId ?? "",
          signalWatch.strWallet,
          signalWatch.selectedRisk?.sendRiskLabel ?? "",
          signalWatch.strPrice,
          signalWatch.strLoss,
          signalWatch.imageFile ?? File(''),
          analysisEnCTR.text,
          widget.signalData?.status ?? "");
      if (signalWatch.commonResponseModel?.status ==
          ApiEndPoints.apiStatus_200) {
        if (mounted) {
          showMessageDialog(
              context,
              signalWatch.commonResponseModel?.message ?? "",
                  () => {
                signalWatch.apiSignalList(
                    context,
                    myRecommendationWatch.signalsSubTabSelectIndex == 0
                        ? "pending"
                        : "active",
                    getUserEntityId()),
                Navigator.pop(context),
                Navigator.pop(context),
                Navigator.pop(context)
              });
        }
      }
    }
  }

  void clearStep2Data(CreateSignalController signalWatch) {
    if (!(widget.isEdit)) {
      signalWatch.targetList.clear();
      signalWatch.fromCtrList.clear();
      signalWatch.toCtrList.clear();
      signalWatch.valueCtrList.clear();
      signalWatch.addTargetList("Fixed", "", "", "", '');
      signalWatch.setStep(3);
    }
  }

  void clearStep3Data(CreateSignalController signalWatch) {
    if (widget.isEdit) {
      // urlToFile(widget.signalData?.chartImage ?? "");
      // signalWatch.setStep(4);
    } else {
      signalWatch.clearStep4(true);
      analysisEnCTR.clear();
      signalWatch.setStep(4);
    }
  }

  Future<void> initializeValueForEdit(
      CreateSignalController signalWatch) async {
    walletPRCTR.text = widget.signalData?.walletPercentage ?? "";
    priceCTR.text = widget.signalData?.entryPrice ?? "";
    lossCTR.text = widget.signalData?.stopLoss ?? "";
    RiskModel selectedRisk = riskList
        .where((element) =>
    ((element.sendRiskLabel) == (widget.signalData?.riskFactor ?? '')))
        .first;
    signalWatch.setSelectRisk(context, selectedRisk);

    signalWatch.checkPriceValidation(
        context, widget.signalData?.entryPrice ?? "");
    signalWatch.checkLossValidation(context, widget.signalData?.stopLoss ?? "");
    signalWatch.checkWalletValidation(
        context, widget.signalData?.walletPercentage.toString() ?? '');
    int length = widget.signalData?.targets?.length ?? 0;
    signalWatch.targetList = [];
    signalWatch.valueCtrList = [];
    signalWatch.fromCtrList = [];
    signalWatch.toCtrList = [];
    for (int i = 0; i < length; i++) {
      String type = widget.signalData?.targets?[i].targetType == "fixed"
          ? "Fixed"
          : "Range";
      String value = widget.signalData?.targets?[i].targetType == "fixed"
          ? "${widget.signalData?.targets?[i].price}"
          : "";
      String from = widget.signalData?.targets?[i].targetType == "range"
          ? "${widget.signalData?.targets?[i].price}"
          : "";
      String to = widget.signalData?.targets?[i].targetType == "range"
          ? "${widget.signalData?.targets?[i].toPrice}"
          : "";
      String targetId = widget.signalData?.targets?[i].targetId ?? '';
      signalWatch.addTargetList(type, value, from, to, targetId);
      signalWatch.valueCtrList.add(TextEditingController(text: value));
      signalWatch.fromCtrList.add(TextEditingController(text: from));
      signalWatch.toCtrList.add(TextEditingController(text: to));
    }
  }

  Future<void> initializeValueForEditTarget(
      CreateSignalController signalWatch) async {
    int length = widget.signalData?.targets?.length ?? 0;
    signalWatch.targetList = [];
    signalWatch.valueCtrList = [];
    signalWatch.fromCtrList = [];
    signalWatch.toCtrList = [];
    for (int i = 0; i < length; i++) {
      String type = widget.signalData?.targets?[i].targetType == "fixed"
          ? "Fixed"
          : "Range";
      String value = widget.signalData?.targets?[i].targetType == "fixed"
          ? "${widget.signalData?.targets?[i].price}"
          : "";
      String from = widget.signalData?.targets?[i].targetType == "range"
          ? "${widget.signalData?.targets?[i].price}"
          : "";
      String to = widget.signalData?.targets?[i].targetType == "range"
          ? "${widget.signalData?.targets?[i].toPrice}"
          : "";
      String targetId = widget.signalData?.targets?[i].targetId ?? '';
      signalWatch.addTargetList(type, value, from, to, targetId);
      signalWatch.valueCtrList.add(TextEditingController(text: value));
      signalWatch.fromCtrList.add(TextEditingController(text: from));
      signalWatch.toCtrList.add(TextEditingController(text: to));
    }
  }

  /// Url To FIle Convert
  Future urlToFile(String imageUrl) async {
    showLog('Imafe Url From Create Signal $imageUrl');
    final signalWatch = ref.watch(createSignalProvider);
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File('$tempPath${rng.nextInt(100)}.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return signalWatch.updateChartPic(file.path, file);
  }

  /// Manage Favourite List
  Future _manageFavourite(FavoriteScreenController favoriteWatch, String id,
      CurrenciesScreenController currenciesWatch) async {
    if (isInternetConnectionOn) {
      await favoriteWatch.manageFavouriteApi(context, id);

      if (favoriteWatch.manageFavouriteResponseModel?.status ==
          ApiEndPoints.apiStatus_200) {
        for (int i = 0; i < (currenciesWatch.currencyList?.length ?? 0); i++) {
          if (currenciesWatch.currencyList?[i].id == id) {
            currenciesWatch.currencyList?[i].isFavourite?.contains("1") == true
                ? (currenciesWatch.currencyList?[i].isFavourite = "0")
                : (currenciesWatch.currencyList?[i].isFavourite = "1");
          }
        }
      }
    }
  }

  /// Get Crypto Currency Data Live
  Future<void> getCryptoCurrencyData(
      CommonController commonWatch,
      CurrenciesScreenController currenciesWatch,
      CreateSignalController createSignalWatch) async {
    if (!mounted) return;
    final signalWatch = ref.watch(createSignalProvider);
    if (isInternetConnectionOn) {
      if (mounted) {
        // await commonWatch.getCryptoCurrencyAPI(context);
      }
      if (commonWatch.cryptoCurrencyResponseModel.data != null ||
          commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
        /// Set Price in Main List Every secondsDelayForRealTimeAPICall seconds

        if (signalWatch.step == 1) {
          currenciesWatch.currencyList?.forEach((element1) {
            CryptoCurrencyData? currencyData = commonWatch
                .cryptoCurrencyResponseModel.data
                ?.where((element) =>
            element.id.toString() == element1.apiCurrencyId)
                .first;
            //showLog("currencyData ${currencyData?.name}");
            if (currencyData != null) {
              element1.price = currencyData.priceUsd;
            }
          });
        }

        /// To Update Price in Selected Currency Object
        if (createSignalWatch.currencyData != null) {
          CryptoCurrencyData? currencyData = commonWatch
              .cryptoCurrencyResponseModel.data
              ?.where((element) =>
          element.id.toString() ==
              createSignalWatch.currencyData?.apiCurrencyId)
              .first;

          if (currencyData != null) {
            createSignalWatch.currencyData?.price = currencyData.priceUsd;
          }
        }
      }
    }
    commonWatch.updateUi();
  }

  /// Live Price Changes
  Future<void> livePriceChangeFunction({bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      if (isTimerStart) {
        final commonWatch = ref.watch(commonProvider);
        final currenciesWatch = ref.watch(currenciesProvider);
        final createSignalWatch = ref.watch(createSignalProvider);

        /// Live Price Api Call every secondsDelayForRealTimeAPICall seconds
        currencyTimer = Timer.periodic(
            Duration(milliseconds: secondsDelayForRealTimeAPICall),
                (currencyTimer) async {
              if (!currenciesWatch.isLoading &&
                  !currenciesWatch.isLoadingForPagination &&
                  !createSignalWatch.isLoading &&
                  !createSignalWatch.isLoadingForPagination) {
                await getCryptoCurrencyData(
                    commonWatch, currenciesWatch, createSignalWatch);
              }
            });
        commonWatch.updateUi();
      } else {
        /// cancel Timer
        if (currencyTimer != null) {
          currencyTimer?.cancel();
        }
      }
    }
  }
}