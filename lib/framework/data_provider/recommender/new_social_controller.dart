import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../../utils/file_download_manager.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/social/contract/social_repository.dart';
import '../../repository/social/model/social_list_response_model.dart';
import '../../repository/social/repository/social_repository_builder.dart';


class NewSocialController extends ChangeNotifier {
  String strDescriptionEn = "";
  String strDescriptionErrorEn = "";

  bool isValidate = false;
  int descriptionCountEn = 0;
  File? imgFile;

  ///Check validation
  void checkValidation() {
    isValidate = (strDescriptionEn != "" &&
        strDescriptionErrorEn == "" &&
        imgFile != null);
  }

  File? getImageList() => imgFile;
  Future<void> addImage(File val) async {
    imgFile = val;
    checkValidation();
    notifyListeners();
  }

  Future<void> removeImage() async {
    imgFile = null;
    checkValidation();
    notifyListeners();
  }

  ///Check en Description Validation
  void checkEnDescriptionValidation(BuildContext context, String value) {
    strDescriptionEn = value;
    strDescriptionErrorEn = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strDescriptionErrorEn = getLocalValue("Key_PleaseEnterDescriptionEn");
    }
    descriptionCountEn = value.length;
    checkValidation();
    notifyListeners();
  }

  void clearProvider() {
    strDescriptionEn = "";
    strDescriptionErrorEn = "";

    descriptionCountEn = 0;
    isValidate = false;
    imgFile = null;
    notifyListeners();
  }

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

  final SocialRepository _socialRepository =
      SocialRepositoryBuilder.repository();

  CommonResponseModel? commonResponseModelAdd;
  CommonResponseModel? commonResponseModelEdit;

  ///Add new Social Api
  Future<void> addNewSocialAPI(BuildContext context) async {
    commonResponseModelAdd = null;
    updateIsLoading(true);
    updateIsError(false);

    MultipartFile? socialImg;

    FormData formData;
    if (imgFile != null) {
      String fileName =
          "${generateFileName()}.${(imgFile?.path ?? "").split(".").last}";
      MultipartFile photo =
          await MultipartFile.fromFile(imgFile?.path ?? "", filename: fileName);
      socialImg = photo;
      showLog("photo $photo ${photo.runtimeType}");
    }

    formData = FormData.fromMap({
      "description:en": strDescriptionEn,
      "description:ar": strDescriptionEn,
      "image": socialImg
    });

    ApiResult apiResult =
        await _socialRepository.addNewSocialApi(context, formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModelAdd = data as CommonResponseModel;

      if (commonResponseModelAdd?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(context, commonResponseModelAdd?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  ///Edit Social Api
  Future<void> editSocialAPI(BuildContext context, String socialID) async {
    commonResponseModelEdit = null;
    updateIsLoading(true);
    updateIsError(false);

    MultipartFile? socialImg;

    FormData formData;
    if (imgFile != null && imgFile?.path != "") {
      String fileName =
          "${generateFileName()}.${(imgFile?.path ?? "").split(".").last}";
      MultipartFile photo =
          await MultipartFile.fromFile(imgFile?.path ?? "", filename: fileName);
      socialImg = photo;
      showLog("photo $photo ${photo.runtimeType}");
    }

    formData = FormData.fromMap({
      "social_id": socialID,
      "description:en": strDescriptionEn,
      "description:ar": strDescriptionEn,
      "image": socialImg
    });

    ApiResult apiResult =
        await _socialRepository.editSocialApi(context, formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      commonResponseModelEdit = data as CommonResponseModel;

      if (commonResponseModelEdit?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        socialImg = null;
      } else {
        updateIsError(true);
        showMessageDialog(
            context, commonResponseModelEdit?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  SocialListResponseModel? socialListResponseModel;
  List<SignalList>? socialList = [];

  ///Social List API
  Future<void> socialListApi(
      BuildContext context, String date, String recommenderID) async {
    updateIsError(false);

    int pageNo = 1;

    if (isHasMorePage) {
      pageNo = pageNo + 1;
    } else {
      socialListResponseModel = SocialListResponseModel();
    }

    int currentPageNo = pageNo;

    (currentPageNo > 1)
        ? updateIsLoadingPagination(true)
        : updateIsLoading(true);
    updateIsError(false);

    if (currentPageNo == 1) {
      socialList?.clear();
    }

    Map<String, dynamic> request = {
      "page_number": pageNo.toString(),
      "date": date,
      "recommender_id": recommenderID
    };

    ApiResult apiResult =
        await _socialRepository.socialListApi(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);

      socialListResponseModel = data as SocialListResponseModel;

      if (socialListResponseModel?.data?.signalList != null &&
          socialListResponseModel!.data!.signalList!.isNotEmpty) {
        isHasMorePage = (int.parse(
                    socialListResponseModel!.data!.totalPage!.toString()) >
                int.parse(socialListResponseModel!.data!.pageNumber.toString()))
            ? true
            : false;
        socialList?.addAll(socialListResponseModel?.data?.signalList ?? []);
      }
      (currentPageNo > 0)
          ? updateIsLoadingPagination(false)
          : updateIsLoading(false);
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showLog("error message $errorMsg");
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  convertStringToFile(String? value) async {
    imgFile = null;
    String? image;
    if (value != null) {
      image = value;
      updateIsLoading(true);
    }

    var storeImage = await FileDownloadManager.instance
        .downloadImage(image.toString(), "${generateFileName()}.jpg");
    if (storeImage != null) {
      imgFile = storeImage;
    }
    updateIsLoading(false);
    notifyListeners();
  }
}
