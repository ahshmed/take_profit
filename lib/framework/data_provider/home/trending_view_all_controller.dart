import 'package:flutter/material.dart';

import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/home/contract/home_repository.dart';
import '../../repository/home/model/trending_list_response_model.dart';
import '../../repository/home/repository/home_repository_bulder.dart';


class TrendingViewAllScreenController extends ChangeNotifier {
  /// ---------------------------- Api Integration ---------------------------------///

  bool isLoading = false;
  bool isError = false;
  bool isLoadingPagination = false;
  bool isHasMorePage = false;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  ///Update Is Loading
  void updateIsLoadingPagination(bool value) {
    isLoadingPagination = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  final HomeRepository _homeRepository = HomeRepositoryBuilder.repository();

  TrendingListResponseModel? trendingListResponseModel;
  List<TrendingList> trendingList = [];

  ///Trending list Api
  Future<void> trendingListAPI(BuildContext context, String pageNo) async {
    updateIsError(false);
    int pageNo = 1;

    if (isHasMorePage) {
      pageNo =
          int.parse(trendingListResponseModel!.data!.pageNumber.toString()) + 1;
    } else {
      pageNo = 1;
      trendingListResponseModel = TrendingListResponseModel();
    }

    (pageNo > 1) ? updateIsLoadingPagination(true) : updateIsLoading(true);
    updateIsError(false);

    if (pageNo == 1) {
      trendingList.clear();
    }

    Map<String, dynamic> request = {"page_number": pageNo.toString()};

    ApiResult apiResult =
        await _homeRepository.trendingListApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);

      trendingListResponseModel = data as TrendingListResponseModel;

      if (trendingListResponseModel?.data?.trendingList != null &&
          trendingListResponseModel?.data?.trendingList?.isNotEmpty == true) {
        isHasMorePage = (int.parse(
                    trendingListResponseModel?.data?.totalPage?.toString() ??
                        "") >
                int.parse(
                    trendingListResponseModel?.data?.pageNumber.toString() ??
                        ""))
            ? true
            : false;

        trendingList.addAll(trendingListResponseModel?.data?.trendingList
            as List<TrendingList>);
        showLog(
            "trendingList ${trendingList.length} \n ${trendingListResponseModel?.data?.trendingList}");
      }

      (pageNo > 0) ? updateIsLoadingPagination(false) : updateIsLoading(false);
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }
}
