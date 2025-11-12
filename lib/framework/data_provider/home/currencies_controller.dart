import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/currencies/contract/currencies_repository.dart';
import '../../repository/currencies/model/currencies_detail_response_model.dart';
import '../../repository/currencies/model/currencies_response_model.dart';
import '../../repository/currencies/model/currency_search_response_model.dart';
import '../../repository/currencies/repository/currencies_repository_bulder.dart';


class CurrenciesScreenController extends ChangeNotifier {
  List<String> selectedItem = [];
  List<CurrencyList> cItemList = [];

  CurrencyData? currencyData;

  void addRemoveItemInSelectedList(String value, CurrencyList model) {
    if (selectedItem.contains(value)) {
      selectedItem.remove(value);
      cItemList.remove(model);
    } else {
      selectedItem.add(value);
      cItemList.add(model);

      showLog("selectedItem List $selectedItem ${selectedItem.length}");
    }

    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  void clearProvider() {
    pageNo = 1;
    isLoading = false;
    isError = false;
    selectedItem.clear();
    cItemList.clear();
    currencyData = null;
    isHasMoreCurrencyList = false;
    isLoadingForPagination = false;
    currencyList?.clear();
    isSearch = false;
    notifyListeners();
  }

  void clearCurrencyData() {
    currencyDetailResponseModel = null;
    currencyData = null;
    notifyListeners();
  }

  void clearProviderForSearchScreen() {
    pageNo = 1;
    isLoading = false;
    isError = false;
    isHasMoreCurrencyList = false;
    isLoadingForPagination = false;
    searchCurrencyList?.clear();
    notifyListeners();
  }

  /// ---------------------------- Api Integration ---------------------------------///

  bool isLoading = false;
  bool isSearch = false;
  bool isError = false;
  bool isHasMoreCurrencyList = false;
  bool isLoadingForPagination = false;
  int pageNo = 1;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsSearch(bool value) {
    isSearch = value;
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

  final CurrenciesRepository _currenciesRepository =
      CurrenciesRepositoryBuilder.repository();

  CurrencyListResponseModel? currencyListResponseModel;
  List<CurrencyList>? currencyList = [];

  CurrencyDetailResponseModel? currencyDetailResponseModel;

  /// Currency list api
  Future<void> currencyListAPI(BuildContext context, String searchText) async {
    showLog("isHasMoreCurrencyList $isHasMoreCurrencyList");
    updateIsError(false);
    if (isHasMoreCurrencyList) {
      pageNo = int.parse(
              currencyListResponseModel?.data?.pageNumber.toString() ?? "") +
          1;
    } else {
      pageNo = 1;
      currencyListResponseModel = CurrencyListResponseModel();
    }

    (pageNo > 1) ? isLoadingForPaginationUpdate(true) : updateIsLoading(true);
    updateIsError(false);

    if (pageNo == 1) {
      currencyList?.clear();
      selectedItem.clear();
    }

    Map<String, dynamic> _request = {
      "page_number": pageNo.toString(),
      "search_query": searchText,
      "user_id": getUserEntityId(),
    };

    ApiResult apiResult =
        await _currenciesRepository.currencyListApi(context, _request);

    apiResult.when(success: (data) {
      updateIsLoading(false);
      updateIsLoading(false);

      currencyListResponseModel = data as CurrencyListResponseModel;
      if (currencyListResponseModel?.data?.currencyList != null &&
          currencyListResponseModel?.data?.currencyList?.isNotEmpty == true) {
        isHasMoreCurrencyList = (int.parse(
                    currencyListResponseModel?.data?.totalPage?.toString() ??
                        "") >
                int.parse(
                    currencyListResponseModel?.data?.pageNumber.toString() ??
                        ""))
            ? true
            : false;
        currencyList
            ?.addAll(currencyListResponseModel?.data?.currencyList ?? []);
      }
      (pageNo > 0)
          ? isLoadingForPaginationUpdate(false)
          : updateIsLoading(false);
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
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

  ///Currency Search Api
  ///
  CurrencySearchResponseModel? currencySearchResponseModel;

  List<SearchCurrencyList>? searchCurrencyList = [];

  Future<void> searchCurrencyListAPI(
      BuildContext context, String searchText) async {
    updateIsError(false);

    if (isHasMoreCurrencyList) {
      pageNo = pageNo + 1;
    } else {
      pageNo = 1;
      currencySearchResponseModel = CurrencySearchResponseModel();
    }

    (pageNo > 1) ? isLoadingForPaginationUpdate(true) : updateIsLoading(true);
    updateIsError(false);

    if (pageNo == 1) {
      searchCurrencyList?.clear();
    }

    Map<String, dynamic> _request = {
      "page_number": pageNo.toString(),
      "search_query": searchText,
    };

    ApiResult apiResult =
        await _currenciesRepository.searchCurrencyListApi(context, _request);

    apiResult.when(success: (data) {
      updateIsLoading(false);
      updateIsLoading(false);

      currencySearchResponseModel = data as CurrencySearchResponseModel;
      if (currencySearchResponseModel?.data?.searchCurrencyList != null &&
          currencySearchResponseModel!.data!.searchCurrencyList!.isNotEmpty) {
        isHasMoreCurrencyList = (int.parse(
                    currencySearchResponseModel!.data!.totalPage!.toString()) >
                int.parse(
                    currencySearchResponseModel!.data!.pageNumber.toString()))
            ? true
            : false;

        searchCurrencyList?.addAll(
            currencySearchResponseModel?.data?.searchCurrencyList ?? []);
      }
      (pageNo > 0)
          ? isLoadingForPaginationUpdate(false)
          : updateIsLoading(false);
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
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

  ///Currency Detail Api
  Future<void> currencyDetailAPI(
      BuildContext context, String currencyID) async {
    currencyDetailResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "currency_id": currencyID,
      "user_id": getUserEntityId()
    };

    ApiResult apiResult =
        await _currenciesRepository.currencyDetailApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      currencyDetailResponseModel = data as CurrencyDetailResponseModel;

      if (currencyDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        currencyData = currencyDetailResponseModel?.data;
      } else {
        updateIsError(true);
        showMessageDialog(
            context, currencyDetailResponseModel?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }
}
