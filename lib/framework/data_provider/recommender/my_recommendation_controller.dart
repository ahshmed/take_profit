import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/recommender/contract/recommender_repository.dart';
import '../../repository/recommender/model/btc_scenarios_list_response_model.dart';
import '../../repository/recommender/repository/recommender_repository_bulder.dart';


class MyRecommendationScreenController extends ChangeNotifier {
  int mainTabSelectIndex = 0;
  int signalsSubTabSelectIndex = 1;
  int socialSubTabSelectIndex = 0;
  bool isSubscribed = false;
  String? selectDateStr;
  DateTime todayDate = DateTime.now();
  DateTime selectDate2 = DateTime.now();
  String currentSelectedMonth =
      DateFormat.MMMM(getAppLanguage()).format(DateTime.now());
  String currentSelectedYear =
      DateFormat.y(getAppLanguage()).format(DateTime.now());

  /// update Main Tab Index
  updateMainTabIndex(int index) {
    mainTabSelectIndex = index;
    notifyListeners();
  }

  updateDate(DateTime date2) {
    selectDateStr = getCustomFormatDateFromDateTime(date2, "dd MMM yyyy");
    selectDate2 = date2;
    currentSelectedMonth = DateFormat.MMMM(getAppLanguage()).format(date2);
    currentSelectedYear = DateFormat.y(getAppLanguage()).format(date2);
    notifyListeners();
  }

  updateWidget() {
    notifyListeners();
  }

  ///update isSubscribed
  updateIsSubscribed(bool value) {
    isSubscribed = value;
    notifyListeners();
  }

  /// update Signals Sub Tab Index
  updateSignalsSubTabIndex(int index) {
    signalsSubTabSelectIndex = index;
    notifyListeners();
  }

  /// update Social Sub Tab Index
  updateSocialSubTabIndex(int index) {
    socialSubTabSelectIndex = index;
    notifyListeners();
  }

  // Dynamic tab list based on selected market
  // US Market: Only Signals tab
  // Crypto: All three tabs (Signals, BTC Scenarios, Social)
  List<String> get mainTabList {
    final selectedMarket = getSelectedMarket();
    final bool isUSMarket = selectedMarket == 'us_market';

    if (isUSMarket) {
      return ["Key_Recommendations"]; // Only Signals for US Market
    } else {
      return ["Key_Recommendations", "Key_BTCScenarios", "Key_Social"]; // All tabs for Crypto
    }
  }

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

  clearProvider() {
    mainTabSelectIndex = 0;
    signalsSubTabSelectIndex = 1;
    socialSubTabSelectIndex = 0;
    signalList?.clear();
    selectDate2 = DateTime.now();
    todayDate = DateTime.now();
    isHasMorePage = false;
    notifyListeners();
  }

  clearDate() {
    selectDateStr = null;
    todayDate = DateTime.now();
    selectDate2 = DateTime.now();
    currentSelectedMonth = DateFormat.MMMM(getAppLanguage()).format(DateTime.now());
    currentSelectedYear = DateFormat.y(getAppLanguage()).format(DateTime.now());

    notifyListeners();
  }

  /// ---------------------------- Api Integration ---------------------------------///

  bool isLoading = false;
  bool isLoadingPagination = false;
  bool isError = false;
  bool isHasMorePage = false;

  ///Update Is Loading
  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  ///Update Is Loading
  void updateIsLoadingPagination(bool value) {
    isLoadingPagination = value;
    notifyListeners();
  }

  ///Update Is Error
  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  final RecommenderRepository recommenderRepository =
      RecommenderRepositoryBuilder.repository();

  BtcScenariosListResponseModel? btcScenariosListResponseModel;
  List<SignalList>? signalList = [];
  List<BTCImage>? btcImageList = [];
  List<String>? imageString = [];

  ///BTC Scenarios List Api
  Future<void> getBTCScenariosListApi(
      BuildContext context, String? recommenderID) async {
    if(isLoadingPagination == false) {
      updateIsError(false);
      int pageNo = 1;

      if (isHasMorePage) {
        pageNo = int.parse(
            btcScenariosListResponseModel?.data?.pageNumber.toString() ??
                "0") +
            1;
      } else {
        btcScenariosListResponseModel = BtcScenariosListResponseModel();
      }

      (pageNo > 1) ? updateIsLoadingPagination(true) : updateIsLoading(true);
      updateIsError(false);

      if (pageNo == 1) {
        signalList?.clear();
        btcImageList?.clear();
        imageString?.clear();
      }

      Map<String, dynamic> _request = {
        "page_number": pageNo.toString(),
        "recommender_id": recommenderID
      };

      ApiResult apiResult =
      await recommenderRepository.btcScenariosListApi(context, _request);

      apiResult.when(success: (data) async {
        updateIsLoading(false);

        btcScenariosListResponseModel = data as BtcScenariosListResponseModel;

        if (btcScenariosListResponseModel?.data?.signalList != null &&
            btcScenariosListResponseModel!.data!.signalList!.isNotEmpty) {
          isHasMorePage = (int.parse(btcScenariosListResponseModel
              ?.data?.totalPage
              ?.toString() ??
              "") >
              int.parse(btcScenariosListResponseModel?.data?.pageNumber
                  .toString() ??
                  ""))
              ? true
              : false;

          signalList
              ?.addAll(btcScenariosListResponseModel?.data?.signalList ?? []);

          for (int i = 0; i < (signalList?.length ?? 0); i++) {
            btcImageList?.addAll(signalList?[i].images as List<BTCImage>);
          }

          for (int i = 0; i < (btcImageList?.length ?? 0); i++) {
            imageString?.add(btcImageList?[i].image.toString() ?? "");
          }
        }

        (pageNo > 0) ? updateIsLoadingPagination(false) : updateIsLoading(
            false);
      }, failure: (NetworkExceptions error) {
        (pageNo == 1) ? updateIsLoading(false) : updateIsLoadingPagination(
            false);
        updateIsError(true);

        String errorMsg = NetworkExceptions.getErrorMessage(error);
        showMessageDialog(context, errorMsg, null);
      });
      notifyListeners();
    }
  }
}
