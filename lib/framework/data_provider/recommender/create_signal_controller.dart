import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:take_profit/framework/repository/signal/model/signal_list_response_model.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../../ui/recommendation/create_signal_screen.dart';
import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/currencies/model/currencies_response_model.dart';
import '../../repository/signal/contract/signal_repository.dart';
import '../../repository/signal/model/all_signal_list_response_model.dart' as all_signal;
import '../../repository/signal/model/signal_details_response_model.dart' as signal_details;
import '../../repository/stock/model/stock_model.dart';

import '../../repository/signal/repository/signal_repository_builder.dart';

class CreateSignalController extends ChangeNotifier {
  int step = 1;

  var valueCtrList = <TextEditingController>[];
  var fromCtrList = <TextEditingController>[];
  var toCtrList = <TextEditingController>[];

  var valueFocusList = <FocusNode>[];
  var fromFocusList = <FocusNode>[];
  var toFocusList = <FocusNode>[];

  var valueErrorList = <String>[];
  var fromErrorList = <String>[];
  var toErrorList = <String>[];

  ///step:1
  CurrencyList? currencyData;

  /// step:2
  RiskModel? selectedRisk;
  bool isValidAllField = false;
  String strWallet = "";
  String strWalletError = "";
  String strPrice = "";
  String strPriceError = "";
  String strLoss = "";
  String strLossError = "";
  String strAnalysisEn = "";
  String strAnalysisErrorEn = "";
  bool currentSignalNotificationEnabled = true;
  bool notificationLoading = false;

  /// step-3
  String type = "Fixed";
  List<TargetModel> targetList = [
    TargetModel(
        type: "Fixed",
        value: "",
        from: "",
        to: "",
        fromError: "",
        toError: "",
        valueError: "",
        targetID: '')
  ];
  bool isValidTargetField = false;

  ///step-4
  bool checkImageValidation = false;
  String chartPic = "";
  File? imageFile;

  updateNotificationLoading(val) {
    notificationLoading = val;
    notifyListeners();
  }

  setCurrentSignalNotificationEnabled(bool value) {
    currentSignalNotificationEnabled = value;
    notifyListeners();
  }

  updateCurrentSignalNotificationStatus(
      {required bool enabled,
        required String signalId,
        required BuildContext context}) async {
    updateIsError(false);

    Map<String, dynamic> _request = {
      "signal_id": signalId,
      "enable_notification": enabled ? 1 : 0,
    };

    updateNotificationLoading(true);

    ApiResult apiResult =
    await _signalRepository.enableSignalNotification(context, _request);

    apiResult.when(success: (data) {
      setCurrentSignalNotificationEnabled(enabled);
      updateNotificationLoading(false);
    }, failure: (NetworkExceptions error) {
      updateNotificationLoading(false);
      updateIsError(true);
      String errorMsg = NetworkExceptions.getErrorMessage(error);
      error.whenOrNull(notFound: (String reason, Response? response) {
        final CommonResponseModel errorResponse =
        commonResponseModelFromJson(response.toString());
        errorMsg = errorResponse.message ?? "error";
      });
      showMessageDialog(context, errorMsg, () {});
    });
    notifyListeners();
  }

  updateChartPic(String photoFile, File file) async {
    chartPic = photoFile;
    showLog('imageUrl $chartPic');
    imageFile = file;
    if (chartPic.isNotEmpty) {
      checkImageValidation = true;
    } else {
      checkImageValidation = false;
    }
    notifyListeners();
  }

  addTargetList(
      String type, String value, String from, String to, String targetId) {
    targetList.add(TargetModel(
        type: type,
        value: value,
        from: from,
        to: to,
        fromError: "",
        toError: "",
        valueError: "",
        targetID: targetId));
    checkTargetValidation();
    notifyListeners();
  }

  removeTarget(int index) {
    targetList.removeAt(index);
    checkTargetValidation();
    notifyListeners();
  }

  clearRangeValue(int index) {
    targetList[index].to = "";
    targetList[index].from = "";
    targetList[index].value = "";
    checkTargetValidation();
    notifyListeners();
  }

  setStep(int value) {
    step = value;
    showLog("step:  ------- $step");
    notifyListeners();
  }

  addCurrencyObj(CurrencyList data) {
    currencyData = data;
    notifyListeners();
  }

  ///Set Selected Risk
  void setSelectRisk(BuildContext context, RiskModel value) {
    selectedRisk = value;
    checkWholeValidation();
    notifyListeners();
  }

  ///Check wallet Validation
  checkWalletValidation(BuildContext context, String value) {
    strWallet = value;
    strWalletError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    showLog("removeWhiteSpace Wallet $removeWhiteSpace");
    if (removeWhiteSpace.isEmpty) {
      strWalletError = "Key_WalletValidation".localized + "%";
    } else if (removeWhiteSpace == "0") {
      strWalletError = "Key_WalletValidationMSG".localized + "%";
    } else if (double.parse(removeWhiteSpace) > 100) {
      strWalletError = "Key_WalletAmountGreaterValidation".localized + "%";
    }
    checkWholeValidation();
    notifyListeners();
  }

  ///Check Price Validation
  checkPriceValidation(BuildContext context, String value) {
    strPrice = value;
    strPriceError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    /*if (removeWhiteSpace.isEmpty) {
      strPriceError = "Key_PriceValidation".localized;
    } else */
    if (removeWhiteSpace == "0") {
      strPriceError = "Key_PriceValidationMSG".localized;
    }
    checkWholeValidation();
    notifyListeners();
  }

  ///Check loss Validation
  checkLossValidation(BuildContext context, String value) {
    strLoss = value;
    strLossError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strLossError = "Key_StopLossValidation".localized;
    } else if (removeWhiteSpace == "0") {
      strLossError = "Key_StopLossValidationMSG".localized;
    }
    checkWholeValidation();
    notifyListeners();
  }

  ///Check value Validation
  checkValueValidation(BuildContext context, String value, TargetModel model) {
    model.value = value;
    model.valueError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      model.valueError = "Key_ValueValidation".localized;
    } else if (removeWhiteSpace.isEmpty) {
      model.valueError = "Key_ValueValidationMSG".localized;
    }
    checkTargetValidation();
    notifyListeners();
  }

  ///Check fromRange Validation
  checkFromRangeValidation(
      BuildContext context, String value, TargetModel model) {
    model.from = value;
    model.fromError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      model.fromError = "Key_FromRangeValidation".localized;
    } else if (removeWhiteSpace.isEmpty) {
      model.fromError = "Key_FromRangeValidation".localized;
    }
    checkTargetValidation();
    notifyListeners();
  }

  ///Check toRange Validation
  checkToRangeValidation(
      BuildContext context, String value, TargetModel model) {
    model.to = value;
    model.toError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      model.toError = "Key_ToRangeErrorValidation".localized;
    } else if (removeWhiteSpace.isEmpty) {
      model.toError = "Key_ToRangeErrorValidation".localized;
    }
    checkTargetValidation();
    notifyListeners();
  }

  ///Add technical Analysis English
  void checkEnAnalysisValidation(BuildContext context, String value) {
    strAnalysisEn = value;
    // strAnalysisErrorEn = "";

    // String removeWhiteSpace = value.replaceAll(" ", "");
    // if (removeWhiteSpace.isEmpty) {
    //   // strAnalysisErrorEn = getLocalValue("Key_AddTechnicalAnalysisEnMsg");
    // }
    checkWholeValidation();
    notifyListeners();
  }

  checkWholeValidation() {
    isValidAllField = (selectedRisk != null &&
        strWallet != "" &&
        strWalletError == "" &&
        //strPrice != "" &&
        strPriceError == "" &&
        strLoss != "" &&
        strLossError == "");
  }

  checkTargetValidation() {
    for (int i = 0; i < targetList.length; i++) {
      if (targetList[i].type == "Fixed") {
        if (targetList[i].valueError != "" || targetList[i].value == "") {
          isValidTargetField = false;
          break;
        } else {
          isValidTargetField = true;
        }
      } else {
        if (targetList[i].toError != "" ||
            targetList[i].to == "" ||
            targetList[i].fromError != "" ||
            targetList[i].from == "") {
          isValidTargetField = false;
          break;
        } else {
          isValidTargetField = true;
        }
      }
    }
    notifyListeners();
  }

  setType(String value, int index) {
    targetList.elementAt(index).type = value;
    checkTargetValidation();
    notifyListeners();
  }

  updateFixedValue(String value, int index) {
    targetList.elementAt(index).value = value;
    checkTargetValidation();
    notifyListeners();
  }

  updateRangeFrom(String value, int index) {
    targetList.elementAt(index).from = value;
    checkTargetValidation();
    notifyListeners();
  }

  updateRangeTo(String value, int index) {
    targetList.elementAt(index).to = value;
    checkTargetValidation();
    notifyListeners();
  }

  void clearProvider() {
    selectedRisk = null;
    isValidAllField = false;
    type = "Fixed";
    step = 1;
    strWallet = "";
    strWalletError = "";
    strPrice = "";
    strPriceError = "";
    strLoss = "";
    strLossError = "";
    strAnalysisEn = "";
    strAnalysisErrorEn = "";
    checkImageValidation = false;
    chartPic = "";
    pageNo = 1;
    isHasMoreSignalList = false;
    isLoadingForPagination = false;
    isLoading = false;

    // Clear all signal lists
    activeSignalList.clear();
    closedSignalList.clear();
    pendingSignalList.clear();

    notifyListeners();
  }

  /// ---------------------------- Api Integration ---------------------------------///

  bool isLoading = false;
  bool isError = false;
  bool isHasMoreSignalList = false;
  bool isLoadingForPagination = false;
  int pageNo = 1;
  List<SignalList> activeSignalList = [];
  List<SignalList> closedSignalList = [];
  List<SignalList> pendingSignalList = [];

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  void isLoadingForPaginationUpdate(bool val) {
    isLoadingForPagination = val;
    notifyListeners();
  }

  final SignalRepository _signalRepository =
  SignalRepositoryBuilder.repository();

  CommonResponseModel? commonResponseModel;
  SignalListResponseModel? signalListResponseModel;

  /// Generate dummy US Market stock signals for testing
  List<SignalList> _generateDummyUSMarketSignals(String status) {
    final stockList = StockModel.getMockStockList();
    final dummySignals = <SignalList>[];

    // Create 5-6 dummy signals based on stock data
    for (int i = 0; i < 6 && i < stockList.length; i++) {
      final stock = stockList[i];
      final currentPrice = double.parse(stock.price.replaceAll('\$', '').replaceAll(',', ''));

      // Generate entry price (slightly different from current)
      final entryPrice = status == 'active'
          ? currentPrice * (stock.isPositiveChange ? 0.97 : 1.03)
          : currentPrice * 0.95;

      // Generate stop loss (5-10% below entry)
      final stopLoss = entryPrice * 0.92;

      // Generate targets (5%, 10%, 15% above entry)
      final targets = [
        Target(
          targetId: '1',
          targetType: status == 'closed' ? 'achieved' : 'pending',
          price: '${(entryPrice * 1.05).toStringAsFixed(2)} USDT',
          toPrice: '',
          rawPrice: (entryPrice * 1.05).toStringAsFixed(2),
        ),
        Target(
          targetId: '2',
          targetType: status == 'closed' ? 'achieved' : 'pending',
          price: '${(entryPrice * 1.10).toStringAsFixed(2)} USDT',
          toPrice: '',
          rawPrice: (entryPrice * 1.10).toStringAsFixed(2),
        ),
        Target(
          targetId: '3',
          targetType: 'pending',
          price: '${(entryPrice * 1.15).toStringAsFixed(2)} USDT',
          toPrice: '',
          rawPrice: (entryPrice * 1.15).toStringAsFixed(2),
        ),
      ];

      dummySignals.add(SignalList(
        signalId: 'dummy_${stock.ticker}_$i',
        currencyId: stock.ticker,
        apiCurrencyId: stock.ticker,
        currencyCode: stock.ticker,
        currencyName: stock.companyName,
        currencySymbol: stock.ticker,
        currencyLogo: '', // Stock icons can be added later
        walletPercentage: ['5', '10', '15', '20'][i % 4],
        riskFactor: stock.buyStatus == 'Strong Buy'
            ? 'Low'
            : stock.buyStatus == 'Sell'
                ? 'High'
                : 'Medium',
        riskFactorLabel: '',
        profitStatus: status == 'active'
            ? (stock.isPositiveChange ? 'profit' : 'loss')
            : (i % 2 == 0 ? 'profit' : 'loss'),
        profitLabel: '',
        livePrice: currentPrice.toStringAsFixed(2),
        entryPrice: entryPrice.toStringAsFixed(2),
        stopLoss: stopLoss.toStringAsFixed(2),
        chartImage: '',
        description: 'US Market ${stock.ticker} - ${stock.buyStatus}',
        descriptionEn: 'US Market ${stock.ticker} - ${stock.buyStatus}',
        descriptionAr: 'سوق الأسهم الأمريكي ${stock.ticker} - ${stock.buyStatus}',
        status: status,
        targets: targets,
        livePriceFromBinance: false,
        enableNotification: 1,
      ));
    }

    return dummySignals;
  }

  /// signal list api
  Future<void> apiSignalList(
      BuildContext context, String status, String recommenderID) async {
    updateIsError(false);
    showLog('apic all status $status');

    // Check if US Market is selected - use dummy data
    final selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    if (isUSMarket) {
      // Use dummy US Market stock signals
      updateIsLoading(true);

      // Clear existing lists
      if (status == 'active') {
        activeSignalList.clear();
      } else if (status == 'closed') {
        closedSignalList.clear();
      } else {
        pendingSignalList.clear();
      }

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate and add dummy stock signals
      final dummySignals = _generateDummyUSMarketSignals(status);
      if (status == 'active') {
        activeSignalList.addAll(dummySignals.where((s) => s.profitStatus == 'profit' || s.profitStatus == 'loss'));
      } else if (status == 'closed') {
        closedSignalList.addAll(dummySignals);
      } else {
        pendingSignalList.addAll(dummySignals);
      }

      isHasMoreSignalList = false; // No pagination for dummy data
      updateIsLoading(false);
      return; // Exit early, don't call real API
    }

    // Original crypto signal logic below
    if (isHasMoreSignalList) {
      pageNo = int.parse(
          signalListResponseModel?.data?.pageNumber.toString() ?? "1") +
          1;
    } else {
      isHasMoreSignalList = false;
      pageNo = 1;
      if (status == 'active') {
        activeSignalList.clear();
      } else if (status == 'closed') {
        closedSignalList.clear();
      } else {
        pendingSignalList.clear();
      }

      signalListResponseModel = SignalListResponseModel();
    }

    (pageNo > 1) ? isLoadingForPaginationUpdate(true) : updateIsLoading(true);
    updateIsError(false);

    if (pageNo == 1) {
      signalListResponseModel = SignalListResponseModel();
      if (status == 'active') {
        activeSignalList.clear();
      } else if (status == 'closed') {
        closedSignalList.clear();
      } else {
        pendingSignalList.clear();
      }
    }

    Map<String, dynamic> _request = {
      "page_number": pageNo.toString(),
      "status": status,
      "recommender_id": recommenderID,
      "user_id": getUserEntityId(),
    };

    ApiResult apiResult =
    await _signalRepository.signalListApi(context, _request);

    apiResult.when(success: (data) {
      updateIsLoading(false);

      signalListResponseModel = data as SignalListResponseModel;
      if (signalListResponseModel?.status == ApiEndPoints.apiStatus_200) {
        if (signalListResponseModel?.data?.totalPage != null &&
            signalListResponseModel?.data?.pageNumber != null) {
          isHasMoreSignalList = (int.parse(
              signalListResponseModel?.data?.totalPage?.toString() ??
                  "0") >
              int.parse(
                  signalListResponseModel?.data?.pageNumber.toString() ??
                      "0"))
              ? true
              : false;
        }

        // Fixed: Added explicit type casting
        final signalList = (signalListResponseModel?.data?.signalList ?? []).cast<SignalList>();

        if (status == 'active') {
          activeSignalList.addAll(signalList);
        } else if (status == 'closed') {
          closedSignalList.addAll(signalList);
        } else {
          pendingSignalList.addAll(signalList);
        }
      }
      (pageNo > 1)
          ? isLoadingForPaginationUpdate(false)
          : updateIsLoading(false);
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);
      String errorMsg = NetworkExceptions.getErrorMessage(error);
      error.whenOrNull(notFound: (String reason, Response? response) {
        final CommonResponseModel errorResponse =
        commonResponseModelFromJson(response.toString());
        errorMsg = errorResponse.message ?? "error";
      });
      showMessageDialog(context, errorMsg, () {});
    });
    notifyListeners();
  }

  all_signal.AllSignalListResponseModel? allSignalListResponseModel;

  /// All signal list api
  Future<void> apiAllSignalList(
      BuildContext context, String status, String recommenderID) async {
    Map<String, dynamic> _request = {
      "status": status,
      "recommender_id": recommenderID,
      "last_page_number": pageNo,
      "user_id": getUserEntityId(),
    };

    ApiResult apiResult =
    await _signalRepository.allSignalListAPI(context, _request);

    apiResult.when(success: (data) {
      allSignalListResponseModel = data as all_signal.AllSignalListResponseModel;
      if (allSignalListResponseModel?.status == ApiEndPoints.apiStatus_200) {
        // Clear the appropriate list based on status
        if (status == 'active') {
          activeSignalList.clear();
        } else if (status == 'closed') {
          closedSignalList.clear();
        } else {
          pendingSignalList.clear();
        }

        // Fixed: Added explicit type casting
        final signalList = (allSignalListResponseModel?.data?.signalList ?? []).cast<SignalList>();

        if (status == 'active') {
          activeSignalList.addAll(signalList);
        } else if (status == 'closed') {
          closedSignalList.addAll(signalList);
        } else {
          pendingSignalList.addAll(signalList);
        }

        showLog("Active Signal length  ${activeSignalList.length}");
        showLog("Closed Signal length  ${closedSignalList.length}");
        showLog("Pending Signal length  ${pendingSignalList.length}");
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);
      String errorMsg = NetworkExceptions.getErrorMessage(error);
      error.whenOrNull(notFound: (String reason, Response? response) {
        final CommonResponseModel errorResponse =
        commonResponseModelFromJson(response.toString());
        errorMsg = errorResponse.message ?? "error";
      });
      showLog("error in api all signal  $errorMsg");
      //   showMessageDialog(context, errorMsg, () {});
    });
    notifyListeners();
  }

  ///Create Signal Api
  Future<void> createSignalAPI(BuildContext context) async {
    commonResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    String strSignalStatus = "pending";
    String removeWhiteSpace = strPrice.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strPrice = currencyData?.price ?? "0";
      strSignalStatus = "active";
    } else if (double.parse(removeWhiteSpace) <=
        double.parse(currencyData?.price ?? "0")) {
      strSignalStatus = "active";
    }

    MultipartFile? chartPhoto;
    List<Map<String, dynamic>> lists = [];

    for (int i = 0; i < targetList.length; i++) {
      if (targetList[i].type == "Fixed") {
        lists.add({
          "target_type": "fixed",
          "price": targetList[i].value,
          "target_id": targetList[i].targetID,
        });
      } else {
        lists.add({
          "target_type": "range",
          "price": targetList[i].from,
          "to_price": targetList[i].to,
          "target_id": targetList[i].targetID,
        });
      }

      showLog("targetListCreate  ${targetList.length}");
      showLog("targetList $lists");
    }

    FormData formData;
    if (imageFile?.path != null && imageFile!.path.isNotEmpty) {
      String fileName = generateFileName() +
          "." +
          (imageFile?.path ?? "").split(".").last;
      MultipartFile photo = await MultipartFile.fromFile(
          imageFile?.path ?? "",
          filename: fileName);
      chartPhoto = photo;
      showLog("photo $photo ${photo.runtimeType}");
    }

    formData = FormData.fromMap({
      "currency_id": currencyData?.id ?? "",
      "wallet_percentage": strWallet,
      "risk_factor": selectedRisk?.sendRiskLabel.toString(),
      "entry_price": strPrice,
      "stop_loss": strLoss,
      "chart_image": chartPhoto,
      "description:en": strAnalysisEn,
      "description:ar": strAnalysisEn,
      "targets": lists,
      "status": strSignalStatus,
    });

    ApiResult apiResult =
    await _signalRepository.createSignalApi(context, formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModel = data as CommonResponseModel;

      if (commonResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        // Success handling
      } else {
        updateIsError(true);
        showMessageDialog(context, commonResponseModel?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  ///close Detail Api
  Future<void> closeSignalAPI(BuildContext context, String signalID) async {
    commonResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {"signal_id": signalID};

    ApiResult apiResult =
    await _signalRepository.closeSignalApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModel = data as CommonResponseModel;

      if (commonResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        // Success handling
      } else {
        updateIsError(true);
        showMessageDialog(context, commonResponseModel?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  /// Signal Details Api
  signal_details.SignalDetailsResponseModel signalDetailsResponseModel =
  signal_details.SignalDetailsResponseModel();

  Future<void> signalDetailsAPI(BuildContext context, String signalID) async {
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {"signal_id": signalID};

    ApiResult apiResult =
    await _signalRepository.signalDetailsAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      signalDetailsResponseModel = data as signal_details.SignalDetailsResponseModel;

      if (signalDetailsResponseModel.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        // Success handling
      } else {
        updateIsError(true);
        showMessageDialog(
            context, signalDetailsResponseModel.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  ///Edit Signal Api
  Future<void> editSignalAPI(
      BuildContext context,
      String signalId,
      String currencyId,
      String wallet,
      String risk,
      String price,
      String loss,
      File img,
      String analysisEn,
      String status,
      ) async {
    showLog("chart img $img");
    commonResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    MultipartFile? chartPhoto;
    List<Map<String, dynamic>> lists = [];

    for (int i = 0; i < targetList.length; i++) {
      if (targetList[i].type == "Fixed") {
        lists.add({
          "target_type": "fixed",
          "price": targetList[i].value,
          "target_id": targetList[i].targetID,
        });
      } else {
        lists.add({
          "target_type": "range",
          "price": targetList[i].from,
          "to_price": targetList[i].to,
          "target_id": targetList[i].targetID,
        });
      }

      showLog("target-list Edit  ${targetList.length}");
      showLog("targetlist $lists");
    }

    FormData formData;
    if (img.path != "") {
      String fileName = generateFileName() + "." + (img.path).split(".").last;
      MultipartFile photo =
      await MultipartFile.fromFile(img.path, filename: fileName);
      chartPhoto = photo;
    }

    formData = FormData.fromMap({
      "signal_id": signalId,
      "currency_id": currencyId,
      "wallet_percentage": wallet,
      "risk_factor": risk,
      "entry_price": price,
      "stop_loss": loss,
      "chart_image": chartPhoto,
      "description:en": analysisEn,
      "description:ar": analysisEn,
      "targets": lists,
      "status": status,
    });

    ApiResult apiResult =
    await _signalRepository.editSignalApi(context, formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModel = data as CommonResponseModel;

      if (commonResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        // Success handling
      } else {
        updateIsError(true);
        showMessageDialog(context, commonResponseModel?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  clearStep4(bool isClearImage) {
    chartPic = "";
    if (isClearImage) {
      imageFile = File("");
    }

    strAnalysisErrorEn = "";
    strAnalysisEn = "";
    notifyListeners();
  }

  /// Close All Signal Api
  Future<void> closeAllSignalApi(BuildContext context) async {
    updateIsLoading(true);
    updateIsError(false);

    ApiResult apiResult = await _signalRepository.closedAllSignalApi(context);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModel = data as CommonResponseModel;

      if (commonResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        showMessageDialog(context, commonResponseModel?.message ?? "", null);
      } else {
        updateIsError(true);
        showMessageDialog(context, commonResponseModel?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  // Helper methods for better type safety
  int getActiveSignalCount() => activeSignalList.length;
  int getClosedSignalCount() => closedSignalList.length;
  int getPendingSignalCount() => pendingSignalList.length;

  List<SignalList> getActiveSignals() => activeSignalList;
  List<SignalList> getClosedSignals() => closedSignalList;
  List<SignalList> getPendingSignals() => pendingSignalList;
}

class TargetModel {
  String type;
  String value;
  String from;
  String to;
  String valueError;
  String fromError;
  String toError;
  String targetID;

  TargetModel({
    required this.type,
    required this.value,
    required this.from,
    required this.to,
    required this.fromError,
    required this.toError,
    required this.targetID,
    required this.valueError,
  });
}