import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:take_profit/framework/repository/signal/model/signal_list_response_model.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/home/contract/home_repository.dart';
import '../../repository/home/model/recommender_details_response_model.dart';
import '../../repository/home/repository/home_repository_bulder.dart';
import '../../repository/signal/contract/signal_repository.dart';
import '../../repository/signal/model/all_signal_list_response_model.dart';

import '../../repository/signal/repository/signal_repository_builder.dart';


class RecommenderScreenController extends ChangeNotifier {
  int mainTabSelectIndex = 0;
  int signalsSubTabSelectIndex = 1;
  int socialSubTabSelectIndex = 0;
  bool isSubscribed = false;
  String? selectDateStr;
  DateTime selectDate2 = DateTime.now();
  DateTime todayDate = DateTime.now();
  String currentSelectedMonth =
      DateFormat.MMMM(getAppLanguage()).format(DateTime.now());
  String currentSelectedYear =
      DateFormat.y(getAppLanguage()).format(DateTime.now());

  bool isRotate = false;
  int currentIndex = 0;

  // String? selectedMonth;

  void setIsRotate(bool isRotate) {
    this.isRotate = isRotate;
    notifyListeners();
  }

  void updateCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  /// update Main Tab Index
  void updateMainTabIndex(int index) {
    mainTabSelectIndex = index;
    notifyListeners();
  }

  void updateDate(DateTime date2) {
    selectDateStr = getCustomFormatDateFromDateTime(date2, "dd MMM yyyy");
    selectDate2 = date2;
    currentSelectedMonth = DateFormat.MMMM(getAppLanguage()).format(date2);
    currentSelectedYear = DateFormat.y(getAppLanguage()).format(date2);
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  ///update isSubscribed
  void updateIsSubscribed(bool value) {
    isSubscribed = value;
    notifyListeners();
  }

  /// update Signals Sub Tab Index
  void updateSignalsSubTabIndex(int index) {
    signalsSubTabSelectIndex = index;
    notifyListeners();
  }

  /// update Social Sub Tab Index
  void updateSocialSubTabIndex(int index) {
    socialSubTabSelectIndex = index;
    notifyListeners();
  }

  ///-----------------------------Year Dropdown End--------------------------///

  List<String> mainTabList = [
    "Key_Recommendations",
    "Key_BTCScenarios",
    "Key_Social"
  ];

  List<String> signalSubTabList = ["Key_Pending", "Key_Active", "Key_Closed"];

  List<String> socialSubTabList = [
    "Key_Today",
    "Key_Yesterday",
    "Key_SelectDate"
  ];

  List<String> imageList = [
    "assets/images/ic_btc_img1.png",
    "assets/images/ic_btc_img2.png",
    "assets/images/ic_btc_img3.png",
    "assets/images/ic_btc_img1.png",
    "assets/images/ic_btc_img2.png",
  ];

  void clearProvider() {
    isLoading = false;
    isError = false;
    isHasMoreSignalList = false;
    //mainTabSelectIndex = 0;
    //signalsSubTabSelectIndex = 1;
    //socialSubTabSelectIndex = 0;
    selectDate2 = DateTime.now();
    todayDate = DateTime.now();
    notifyListeners();
  }

  void clearSignalData() {
    pageNo = 1;
    activeSignalList.clear();
    closedSignalList.clear();
    pendingSignalList.clear();
    isLoading = false;
    isError = false;
    isHasMoreSignalList = false;
    notifyListeners();
  }

  void clearDate() {
    selectDateStr = null;
    todayDate = DateTime.now();
    selectDate2 = DateTime.now();
    currentSelectedMonth =
        DateFormat.MMMM(getAppLanguage()).format(DateTime.now());
    currentSelectedYear = DateFormat.y(getAppLanguage()).format(DateTime.now());
    notifyListeners();
  }

  /// ---------------------------- Api Integration ---------------------------------///

  bool isLoading = false;
  bool isError = false;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  final HomeRepository _homeRepository = HomeRepositoryBuilder.repository();

  RecommenderDetailResponseModel? recommenderDetailResponseModel;

  ///Recommender Detail  Api
  Future<void> recommenderDetailAPI(
      BuildContext context, String recommenderID) async {
    recommenderDetailResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "recommender_id": recommenderID,
      "user_id": getUserEntityId()
    };

    ApiResult apiResult =
        await _homeRepository.recommenderDetailApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      recommenderDetailResponseModel = data as RecommenderDetailResponseModel;

      if (recommenderDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, recommenderDetailResponseModel?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  /// ---------------------------- Api Integration ---------------------------------///

  bool isHasMoreSignalList = false;
  bool isLoadingForPagination = false;
  int pageNo = 1;
  List<SignalList> activeSignalList = [];
  List<SignalList> closedSignalList = [];
  List<SignalList> pendingSignalList = [];

  void isLoadingForPaginationUpdate(bool val) {
    isLoadingForPagination = val;
    notifyListeners();
  }

  final SignalRepository _signalRepository =
      SignalRepositoryBuilder.repository();

  CommonResponseModel? commonResponseModel;
  SignalListResponseModel? signalListResponseModel;

  /// signal list api
  Future<void> apiSignalList(
      BuildContext context, String status, String recommenderID) async {
    updateIsError(false);
    showLog('apic all status $status');
    if (isHasMoreSignalList) {
      pageNo = int.parse(
              signalListResponseModel?.data?.pageNumber.toString() ?? "") +
          1;
    } else {
      isHasMoreSignalList = false;
      pageNo = 1;
      status == 'active' ? activeSignalList.clear() : status == 'closed' ? closedSignalList.clear() : pendingSignalList.clear();

      signalListResponseModel = SignalListResponseModel();
    }

    (pageNo > 1) ? isLoadingForPaginationUpdate(true) : updateIsLoading(true);
    updateIsError(false);

    if (pageNo == 1) {
      signalListResponseModel = SignalListResponseModel();
      status == 'active' ? activeSignalList.clear() : status == 'closed' ? closedSignalList.clear() : pendingSignalList.clear();
    }

    Map<String, dynamic> request = {
      "page_number": pageNo.toString(),
      "status": status,
      "recommender_id": recommenderID,
      "user_id": getUserEntityId(),
    };

    ApiResult apiResult =
        await _signalRepository.signalListApi(context, request);

    apiResult.when(success: (data) {
      updateIsLoading(false);

      signalListResponseModel = data as SignalListResponseModel;
      if (signalListResponseModel?.data?.signalList?.isNotEmpty == true) {
        isHasMoreSignalList = (int.parse(
                    signalListResponseModel?.data?.totalPage?.toString() ??
                        "") >
                int.parse(
                    signalListResponseModel?.data?.pageNumber.toString() ?? ""))
            ? true
            : false;

        status == 'active'
            ? activeSignalList
                .addAll(signalListResponseModel?.data?.signalList ?? [])
            : status == 'closed' ? closedSignalList
                .addAll(signalListResponseModel?.data?.signalList ?? [])
            : pendingSignalList
                .addAll(signalListResponseModel?.data?.signalList ?? []);
      }
      (pageNo > 0)
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

  AllSignalListResponseModel? allSignalListResponseModel;

  /// All signal list api
  Future<void> apiAllSignalList(
      BuildContext context, String status, String recommenderID) async {
    Map<String, dynamic> request = {
      "status": status,
      "recommender_id": recommenderID,
      "last_page_number": pageNo,
      "user_id": getUserEntityId(),
    };

    ApiResult apiResult =
        await _signalRepository.allSignalListAPI(context, request);

    apiResult.when(success: (data) {
      allSignalListResponseModel = data as AllSignalListResponseModel;
      final list = allSignalListResponseModel?.data?.signalList ?? [];
      if (list.isNotEmpty) {
        if (status == 'active') {
          activeSignalList
            ..clear()
            ..addAll(list);
        } else if (status == 'closed') {
          closedSignalList
            ..clear()
            ..addAll(list);
        } else {
          pendingSignalList
            ..clear()
            ..addAll(list);
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
}
