import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/master/model/get_subscription_package_list.dart';
import '../../repository/my_subscription/contract/my_subscription_repository.dart';
import '../../repository/my_subscription/model/recommender_subscription_packages_response_model.dart';
import '../../repository/my_subscription/repository/my_subscription_repository_builder.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/profile_details_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';
import '../auth/duration_controller.dart';


class EditSubscriptionAmountController extends ChangeNotifier {
  bool isValidate = false;
  bool isObscure = true;

  /// Plan List data From Duration Screen
  List<PackageList> planList = [];

  ///Text Editing Controller
  List<TextEditingController> amountCTR = <TextEditingController>[];

  ///Focus Node
  List<FocusNode> amountFocus = <FocusNode>[];

  updateIsObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  checkValidation() {
    isValidate = (subscriptionPackageList
        .every((element) => element.price != null && element.price != ''));
    showLog("isValidate $isValidate");
    notifyListeners();
  }

  clearProvider() {
    isValidate = false;
    amountFocus.clear();
    amountCTR.clear();
    subscriptionIdList.clear();
    isObscure = true;
    priceList.clear();

    notifyListeners();
  }

  ///----------------------------- Api Integration ---------------------------///

  bool isLoading = false;
  bool isError = false;
  bool isHasMorePage = false;
  bool isLoadingPagination = false;
  bool isLive = false;

  List<SubscriptionPackageList> subscriptionPackageList = [];

  List<PriceModel> priceList = [];
  List<String> subscriptionIdList = [];

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  updateWidget() {
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  ///Update Is Loading
  void updateIsLoadingPagination(bool value) {
    isLoadingPagination = value;
    notifyListeners();
  }

  ProfileDetailResponseModel? profileDetailResponseModel;

  final MySubscriptionRepository _mySubscriptionRepository =
      MySubscriptionRepositoryBuilder.repository();
  GetRecommenderSubscriptionPackagesResponseModel
      recommenderSubscriptionPackagesResponseModel =
      GetRecommenderSubscriptionPackagesResponseModel();

  addDataIntoList() {
    for (int i = 0; i < (subscriptionPackageList.length); i++) {
      amountCTR.add(
        TextEditingController(text: subscriptionPackageList[i].price),
      );
      amountFocus.add(FocusNode());
      priceList.add(
        PriceModel(price: subscriptionPackageList[i].price),
      );

      amountFocus[i].addListener(() {});
      subscriptionIdList
          .add(subscriptionPackageList[i].subscriptionPackageId ?? "");
    }
    checkValidation();
    notifyListeners();
  }

  ///Subscription List Api
  Future<void> recommenderSubscriptionPackageListApi(BuildContext context,
      {String? recommenderID}) async {
    updateIsError(false);
    int pageNo = 1;

    if (isHasMorePage) {
      pageNo = int.parse(recommenderSubscriptionPackagesResponseModel
                  .data?.pageNumber
                  .toString() ??
              "0") +
          1;
    } else {
      recommenderSubscriptionPackagesResponseModel =
          GetRecommenderSubscriptionPackagesResponseModel();
    }

    int currentPageNo = pageNo;

    (currentPageNo > 1)
        ? updateIsLoadingPagination(true)
        : updateIsLoading(true);
    updateIsError(false);

    if (currentPageNo == 1) {
      subscriptionPackageList.clear();
    }

    Map<String, dynamic> _req = {
      "page_number": currentPageNo.toString(),
      "recommender_id": recommenderID != "" ? recommenderID : getUserEntityId(),
      "version": appleVersion,
      "platform": appPlatform
    };

    ApiResult apiResult = await _mySubscriptionRepository
        .recommenderSubscriptionPackagesAPI(context, _req);

    apiResult.when(success: (data) async {
      updateIsLoading(false);

      recommenderSubscriptionPackagesResponseModel =
          data as GetRecommenderSubscriptionPackagesResponseModel;

      if(recommenderSubscriptionPackagesResponseModel.data != null){
        isLive = recommenderSubscriptionPackagesResponseModel.data!.forAppleReview != "1";
      }
      if (recommenderSubscriptionPackagesResponseModel
                  .data?.subscriptionPackageList !=
              null &&
          recommenderSubscriptionPackagesResponseModel
                  .data?.subscriptionPackageList?.isNotEmpty ==
              true) {
        isHasMorePage = (int.parse(recommenderSubscriptionPackagesResponseModel
                        .data?.totalPage
                        ?.toString() ??
                    "0") >
                int.parse(recommenderSubscriptionPackagesResponseModel
                        .data?.pageNumber
                        .toString() ??
                    "0"))
            ? true
            : false;

        subscriptionPackageList.addAll(
            recommenderSubscriptionPackagesResponseModel
                    .data?.subscriptionPackageList ??
                []);
        addDataIntoList();
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

  removeItemAtIndex(int index, SubscriptionPackageList item) {
    subscriptionPackageList.removeAt(index);
    amountCTR.removeAt(index);
    subscriptionIdList.removeAt(index);
    amountFocus.removeAt(index);
    priceList.removeAt(index);
    checkValidation();

    notifyListeners();
  }

  final ProfileRepository _profileRepository =
      ProfileRepositoryBuilder.repository();

  ///Update Profile Details Api
  Future<void> updateProfileAPI(BuildContext context) async {
    updateIsLoading(true);
    updateIsError(false);

    final List<Map<String, dynamic>> packageData = [];

    for (int i = 0; i < (subscriptionPackageList.length); i++) {
      packageData.add({
        "subscription_package_id":
            subscriptionPackageList[i].subscriptionPackageId,
        "price": subscriptionPackageList[i].price
      });
    }

    FormData formData;
    formData = FormData.fromMap({"packages": packageData});

    ApiResult apiResult =
        await _profileRepository.updatePersonalDetailAPI(context, formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      profileDetailResponseModel = data as ProfileDetailResponseModel;

      if (profileDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, profileDetailResponseModel?.message ?? "", () {});
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

/// subscription_package_id: "4",
///  package_name: "Quarterly Payment",
///  package_duration: "84",
///  interval: "Quarterly"
///
///
/// profile_package_id: "23",
/// subscription_package_id: "4",
/// package_name: "Quarterly Payment",
/// interval: "QUARTERLY",
/// package_duration: "84",
/// price: "77.00",
/// package_duration: "84",
/// currency: "KWD"
