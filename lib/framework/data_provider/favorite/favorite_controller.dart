import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/favourite/contract/favourite_repository.dart';
import '../../repository/favourite/model/favourite_response_model.dart';
import '../../repository/favourite/repository/favourite_repository_bulder.dart';

class FavoriteScreenController extends ChangeNotifier {
  void clearProvider() {
    isLoading = false;
    isLoadingPagination = false;
    isError = false;

    isHasMorePage = false;

    favouriteResponseModel = null;
    arrFavourite = [];
    manageFavouriteResponseModel = null;

    notifyListeners();
  }

  bool isLoading = false;
  bool isLoadingPagination = false;
  bool isError = false;
  bool isHasMorePage = false;
  int pageNo = 1;

  ///Update Is Loading
  void updateIsLoading(bool value) {
    isLoading = value;
    showLog('isLoading $isLoading');
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

  final FavouriteRepository _favouriteRepository =
      FavouriteRepositoryBuilder.repository();

  FavouriteResponseModel? favouriteResponseModel;
  List<FavouriteData>? arrFavourite = [];

  Future<void> getFavouriteListApi(BuildContext context) async {
    showLog("isHasMorePage $isHasMorePage");
    updateIsError(false);
    if (isHasMorePage) {
      pageNo =
          int.parse(favouriteResponseModel?.data?.pageNumber.toString() ?? "") +
              1;
    } else {
      pageNo = 1;
      favouriteResponseModel = FavouriteResponseModel();
    }

    (pageNo > 1) ? updateIsLoadingPagination(true) : updateIsLoading(true);
    updateIsError(false);

    if (pageNo == 1) {
      arrFavourite?.clear();
    }

    Map<String, dynamic> _request = {
      "page_number": pageNo.toString(),
    };

    ApiResult apiResult =
        await _favouriteRepository.favouriteListApi(context, _request);

    apiResult.when(success: (data) {
      updateIsLoading(false);
      updateIsLoading(false);

      favouriteResponseModel = data as FavouriteResponseModel;
      if (favouriteResponseModel?.data?.favouriteList != null &&
          favouriteResponseModel?.data?.favouriteList?.isNotEmpty == true) {
        isHasMorePage = (int.parse(
                    favouriteResponseModel?.data?.totalPage?.toString() ?? "") >
                int.parse(
                    favouriteResponseModel?.data?.pageNumber.toString() ?? ""))
            ? true
            : false;
        arrFavourite?.addAll(favouriteResponseModel?.data?.favouriteList ?? []);
      }
      (pageNo > 0) ? updateIsLoadingPagination(false) : updateIsLoading(false);
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

  CommonResponseModel? manageFavouriteResponseModel;

  /// Manage Favourite Api
  Future<void> manageFavouriteApi(BuildContext context, String id) async {
    manageFavouriteResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> _request = {"currency_id": id};

    ApiResult apiResult =
        await _favouriteRepository.manageFavouriteApi(context, _request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      manageFavouriteResponseModel = data as CommonResponseModel;

      if (manageFavouriteResponseModel?.status == ApiEndPoints.apiStatus_200) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, manageFavouriteResponseModel?.message ?? "", null);
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
