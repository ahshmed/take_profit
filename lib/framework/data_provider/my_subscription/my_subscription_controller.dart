import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/my_subscription/contract/my_subscription_repository.dart';
import '../../repository/my_subscription/model/subscription_list_response_model.dart';
import '../../repository/my_subscription/repository/my_subscription_repository_builder.dart';


class MySubscriptionController extends ChangeNotifier {
  void clearProvider() {
    subscriptionList.clear();
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

  final MySubscriptionRepository _mySubscriptionRepository =
      MySubscriptionRepositoryBuilder.repository();
  SubscriptionListResponseModel? subscriptionListResponseModel;
  List<SubscriptionList> subscriptionList = [];

  ///Subscription List Api
  Future<void> subscriptionListApi(BuildContext context) async {
    updateIsError(false);
    int pageNo = 1;

    if (isHasMorePage) {
      pageNo = pageNo + 1;
    } else {
      subscriptionListResponseModel = SubscriptionListResponseModel();
    }

    int currentPageNo = pageNo;

    (currentPageNo > 1)
        ? updateIsLoadingPagination(true)
        : updateIsLoading(true);
    updateIsError(false);

    if (currentPageNo == 1) {
      subscriptionList.clear();
    }

    ApiResult apiResult = await _mySubscriptionRepository.subscriptionListAPI(
        context, currentPageNo);

    apiResult.when(success: (data) async {
      updateIsLoading(false);

      subscriptionListResponseModel = data as SubscriptionListResponseModel;

      if (subscriptionListResponseModel?.data?.subscriptionList != null &&
          subscriptionListResponseModel?.data?.subscriptionList?.isNotEmpty ==
              true) {
        isHasMorePage = (int.parse(subscriptionListResponseModel
                        ?.data?.totalPage
                        ?.toString() ??
                    "0") >
                int.parse(subscriptionListResponseModel?.data?.pageNumber
                        .toString() ??
                    "0"))
            ? true
            : false;

        showLog("old list $subscriptionList");

        subscriptionList.addAll(
            subscriptionListResponseModel?.data?.subscriptionList ?? []);

        showLog("updated list $subscriptionList");
      }
      (currentPageNo > 0)
          ? updateIsLoadingPagination(false)
          : updateIsLoading(false);
    }, failure: (NetworkExceptions error) {
      (pageNo == 1) ? updateIsLoading(false) : updateIsLoadingPagination(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  CommonResponseModel? cancelSubscriptionResponseModel;

  ///Cancel Subscription Api
  Future<void> cancelSubscriptionApi(BuildContext context,
      {String? recommenderId}) async {
    cancelSubscriptionResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "recommender_id": recommenderId,
    };

    ApiResult apiResult =
        await _mySubscriptionRepository.cancelSubscriptionAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      cancelSubscriptionResponseModel = data as CommonResponseModel;

      if (cancelSubscriptionResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, cancelSubscriptionResponseModel?.message ?? "", null);
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
