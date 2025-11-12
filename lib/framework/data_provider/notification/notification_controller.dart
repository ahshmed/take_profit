import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/notification/contract/notification_repository.dart';
import '../../repository/notification/model/notificaiton_count_response_model.dart';
import '../../repository/notification/model/notification_list_response_model.dart';
import '../../repository/notification/repository/notification_repository_builder.dart';


class NotificationController extends ChangeNotifier {
  ///----------------------------- Api Integration ---------------------------///

  bool isLoading = false;
  bool isLoadingPagination = false;
  bool isError = false;
  bool isHasMorePage = false;

  ///Update Is Loading For Pagination
  void updateIsLoadingPagination(bool value) {
    isLoadingPagination = value;
    notifyListeners();
  }

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  final NotificationRepository _notificationRepository =
      NotificationRepositoryBuilder.repository();

  NotificationListResponseModel? notificationListResponseModel;

  List<NotificationList> notificationList = [];

  ///Subscription List Api
  Future<void> notificationListAPI(BuildContext context) async {
    updateIsError(false);
    int pageNo = 1;

    if (isHasMorePage) {
      pageNo = int.parse(
              notificationListResponseModel?.data?.pageNumber.toString() ??
                  "0") +
          1;
    } else {
      notificationListResponseModel = NotificationListResponseModel();
    }

    int currentPageNo = pageNo;

    (currentPageNo > 1)
        ? updateIsLoadingPagination(true)
        : updateIsLoading(true);
    updateIsError(false);

    if (currentPageNo == 1) {
      notificationList.clear();
    }

    Map<String, dynamic> request = {
      "page_number": pageNo.toString(),
    };

    ApiResult apiResult =
        await _notificationRepository.notificationListApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);

      notificationListResponseModel = data as NotificationListResponseModel;

      if (notificationListResponseModel?.data?.notificationList != null &&
          notificationListResponseModel?.data?.notificationList?.isNotEmpty ==
              true) {
        isHasMorePage = (int.parse(notificationListResponseModel
                        ?.data?.totalPage
                        ?.toString() ??
                    "0") >
                int.parse(notificationListResponseModel?.data?.pageNumber
                        .toString() ??
                    "0"))
            ? true
            : false;

        showLog("old list $notificationList");

        notificationList.addAll(
            notificationListResponseModel?.data?.notificationList ?? []);

        showLog("updated list $notificationList");
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

  NotificationCountResponseModel notificationCountResponseModel =
      NotificationCountResponseModel();

  /// Notification Count Detail  Api
  Future<void> notificationCountAPI(BuildContext context) async {
    updateIsLoading(true);
    updateIsError(false);

    ApiResult apiResult =
        await _notificationRepository.notificationCountApi(context);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      notificationCountResponseModel = data as NotificationCountResponseModel;

      if (notificationCountResponseModel.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, notificationCountResponseModel.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  CommonResponseModel commonResponseModel = CommonResponseModel();

  /// Notification Delete Api
  Future<void> notificationDeleteAPI(BuildContext context, String id) async {
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> req = {"id": id};

    ApiResult apiResult =
        await _notificationRepository.notificationDeleteAPI(context, req);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModel = data as CommonResponseModel;

      if (commonResponseModel.status == ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(context, commonResponseModel.message ?? "", null);
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
