import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/master/contract/master_repository.dart';
import '../../repository/master/model/get_subscription_package_list.dart';
import '../../repository/master/repository/master_repository_builder.dart';


class MasterController extends ChangeNotifier {
  ///---------------------------Api Properties--------------------------------///
  bool isLoading = false;
  bool isError = false;
  bool isLoadingForPagination = false;
  bool isHasMorePage = false;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  void updateIsLoadingForPagination(bool value) {
    isLoadingForPagination = value;
    notifyListeners();
  }

  final MasterRepository _masterRepository =
      MasterRepositoryBuilder.repository();

  GetSubscriptionPackageList? getSubscriptionPackageList;

  List<PackageList> packageList = [];

  /// Get Subscription list api
  Future<void> apiGetSubscriptionPackageList(BuildContext context,
      {String search = ""}) async {
    updateIsError(false);
    int pageNo = 1;

    if (isHasMorePage) {
      pageNo =
          int.parse(getSubscriptionPackageList!.data!.pageNumber.toString()) +
              1;
    } else {
      getSubscriptionPackageList = GetSubscriptionPackageList();
    }

    int currentPageNo = pageNo;

    (currentPageNo > 1)
        ? updateIsLoadingForPagination(true)
        : updateIsLoading(true);
    updateIsError(false);

    if (currentPageNo == 1) {
      packageList.clear();
    }

    Map<String, dynamic> request = {
      "page_number": pageNo.toString(),
    };

    Map<String, dynamic> requestWithSearch = {
      "page_number": pageNo.toString(),
      "search_query": search
    };

    ApiResult apiResult =
        await _masterRepository.apiMasterSubscriptionPackageList(
            context, search == "" ? request : requestWithSearch);

    apiResult.when(success: (data) {
      updateIsLoading(false);
      updateIsLoading(false);

      getSubscriptionPackageList = data as GetSubscriptionPackageList;
      if (getSubscriptionPackageList?.data?.packageList != null &&
          getSubscriptionPackageList?.data?.packageList?.isNotEmpty == true) {
        isHasMorePage = (int.parse(
                    getSubscriptionPackageList?.data?.totalPage.toString() ??
                        "") >
                int.parse(
                    getSubscriptionPackageList?.data?.pageNumber.toString() ??
                        ""))
            ? true
            : false;
        packageList.addAll(getSubscriptionPackageList?.data?.packageList ?? []);
      }

      (currentPageNo > 0)
          ? updateIsLoadingForPagination(false)
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
}
