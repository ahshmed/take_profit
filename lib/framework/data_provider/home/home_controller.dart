import 'package:flutter/material.dart';

import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/home/contract/home_repository.dart';
import '../../repository/home/model/home_recommender_details_response_model.dart';
import '../../repository/home/model/recommender_list_response_model.dart';
import '../../repository/home/repository/home_repository_bulder.dart';


class HomeScreenController extends ChangeNotifier {
  int selectedIndex = 1; //New
  int selectedGenreIndex = 0;

  int recommenderTabSelectIndex = 0;

  List<String> recommenderTabList = [
    "Key_All",
    "Key_Matched",
    "Key_Subscribed"
  ];

  /// update Recommender Tab Index
  updateRecommenderTabIndex(int index) {
    recommenderTabSelectIndex = index;
    notifyListeners();
  }

  void clearProvider() {
    recommenderTabSelectIndex = 0;
    recommenderList.clear();
    isHasMorePage = false;
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

  final HomeRepository _homeRepository = HomeRepositoryBuilder.repository();
  RecommenderListResponseModel? recommenderListResponseModel;
  List<TrendingList> recommenderList = [];

  ///Recommender List Api
  Future<void> recommenderListApi(BuildContext context,
      {String? type, String? userId}) async {
    updateIsError(false);
    int pageNo = 1;

    if (isHasMorePage == true) {
      pageNo = int.parse(
              recommenderListResponseModel?.data?.pageNumber.toString() ??
                  "0") +
          1;
      showLog("Page Number Value From Api Call $pageNo");
    } else {
      pageNo = 1;
      recommenderListResponseModel = RecommenderListResponseModel();
    }

    (pageNo > 1) ? updateIsLoadingPagination(true) : updateIsLoading(true);
    updateIsError(false);

    if (pageNo == 1) {
      recommenderList.clear();
    }

    Map<String, dynamic> _request = {
      "page_number": pageNo.toString(),
      "type": type,
      "user_id": userId
    };

    ApiResult apiResult =
        await _homeRepository.recommenderListApi(context, _request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);

      recommenderListResponseModel = data as RecommenderListResponseModel;

      if (recommenderListResponseModel?.data?.trendingList != null &&
          recommenderListResponseModel?.data?.trendingList?.isNotEmpty ==
              true) {
        isHasMorePage = (int.parse(
                    recommenderListResponseModel?.data?.totalPage?.toString() ??
                        "0") >
                int.parse(
                    recommenderListResponseModel?.data?.pageNumber.toString() ??
                        "0"))
            ? true
            : false;

        recommenderList.addAll(recommenderListResponseModel?.data?.trendingList
            as List<TrendingList>);
      }
      (pageNo > 0) ? updateIsLoadingPagination(false) : updateIsLoading(false);
    }, failure: (NetworkExceptions error) {
      (pageNo == 1) ? updateIsLoading(false) : updateIsLoadingPagination(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  /// Home Recommender Details API
  HomeRecommenderDetailsResponseModel? homeRecommenderDetailsResponseModel;

  Future<void> homeRecommenderDetailsApi(BuildContext context) async {
    updateIsError(false);
    updateIsLoading(true);

    ApiResult apiResult =
        await _homeRepository.homeRecommenderDetailsApi(context);

    apiResult.when(success: (data) async {
      updateIsLoading(false);

      homeRecommenderDetailsResponseModel =
          data as HomeRecommenderDetailsResponseModel;
    }, failure: (NetworkExceptions error) {
      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }
}
