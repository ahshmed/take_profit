import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/payment/contract/payment_repository.dart';
import '../../repository/payment/model/paymet_response_model.dart';
import '../../repository/payment/repository/payment_repository_builder.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/payment/contract/payment_repository.dart';
import '../../repository/payment/model/paymet_response_model.dart';
import '../../repository/payment/repository/payment_repository_builder.dart';


class PaymentController with ChangeNotifier {
  bool isLoading = false;
  bool isError = false;

  String urlPass = "";
  double progress = 0;

  void updateURL(String status) {
    urlPass = status;
    notifyListeners();
  }

  void updateProgressStatus(double status) {
    progress = status;
    notifyListeners();
  }

  void updateLoadingStatus(bool status) {
    isLoading = status;
    notifyListeners();
  }

  void clearProviderData() {
    urlPass = "";
    progress = 0;
    isLoading = false;
    isError = false;
    notifyListeners();
  }

  ///Update Is Loading
  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  ///Update Is Error
  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  PaymentRepository paymentRepository = PaymentRepositoryBuilder.repository();

  PaymentResponseModel paymentResponseModel = PaymentResponseModel();

  ///  Payment For Request Analysis
  Future<void> paymentForRequestAnalysisApi(BuildContext context,
      {required String orderId}) async {
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> requestData = {"order_id": orderId, "version": appleVersion, "platform": appPlatform};

    ApiResult apiResult = await paymentRepository.paymentForRequestAnalysisAPI(
        context, requestData);
    updateIsLoading(false);
    apiResult.when(success: (data) async {
      updateIsLoading(false);
      paymentResponseModel = data as PaymentResponseModel;

      if (paymentResponseModel.status == ApiEndPoints.apiStatus_200.toString()) {
        updateIsError(false);
      } else {
        updateIsError(true);
        showMessageDialog(
            context, paymentResponseModel.message ?? '', () {
          Navigator.pop(context, true);
        });
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  /// Payment For Subscription
  Future<void> paymentForSubscriptionApi(BuildContext context,
      {required String profilePackageID}) async {
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> requestData = {"profile_package_id": profilePackageID, "version": appleVersion, "platform": appPlatform};

    ApiResult apiResult =
        await paymentRepository.paymentForSubscriptionAPI(context, requestData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      paymentResponseModel = data as PaymentResponseModel;

      if (paymentResponseModel.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(context, paymentResponseModel.message ?? "", null);
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
