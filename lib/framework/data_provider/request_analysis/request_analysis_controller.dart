import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/request_analysis/contract/request_analysis_repository.dart';
import '../../repository/request_analysis/model/new_request_analysis_response_model.dart';
import '../../repository/request_analysis/model/request_analysis_details_response_model.dart';
import '../../repository/request_analysis/model/request_analysis_list_resopnse_model.dart';
import '../../repository/request_analysis/repository/request_analysis_repository_builder.dart';

class RequestAnalysisController extends ChangeNotifier {
  // Changed from single File to List of Files for multiple image support
  List<File> pickedImages = [];

  String tabIndex = "0";
  String strMessage = "";
  String strMessageError = "";
  String strAnalysis = "";
  String strAnalysisError = "";
  bool isValidaAllFieldTrader = false;
  bool isValidaAllFieldRecommender = false;
  int pageNo = 1;

  clearProvider(bool isTabReset) {
    if (isTabReset) {
      tabIndex = "0";
    }
    pageNo = 1;
    pickedImages.clear(); // Clear list instead of single file
    strMessage = "";
    isValidaAllFieldTrader = false;
    strMessageError = "";
    requestAnalysisListData.clear();
    strAnalysis = "";
    strAnalysisError = "";
    notifyListeners();
  }

  /// Check Message Validation
  checkMessageValidation(BuildContext context, String value) {
    strMessage = value;
    strMessageError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strMessageError = "Key_MessageRequiredNote".localized;
    }

    checkWholeValidation();
    notifyListeners();
  }

  setSelectedTabIndex(String value) {
    tabIndex = value;
    notifyListeners();
  }

  /// Add Image to List (supports multiple images)
  void addImage(File file) {
    if (!pickedImages.any((img) => img.path == file.path)) {
      pickedImages.add(file);
      notifyListeners();
    }
  }

  /// Update Single Image (for backward compatibility if needed)
  void updateImage(File value) {
    pickedImages.clear();
    pickedImages.add(value);
    notifyListeners();
  }

  /// Remove Image at Specific Index
  void removeImageAt(int index) {
    if (index >= 0 && index < pickedImages.length) {
      pickedImages.removeAt(index);
      notifyListeners();
    }
  }

  /// Remove All Images
  void removeImage() {
    pickedImages.clear();
    notifyListeners();
  }

  /// Get First Image (for backward compatibility)
  File? get pickedImage => pickedImages.isNotEmpty ? pickedImages.first : null;

  /// Check Analysis Validation
  checkAnalysisValidation(BuildContext context, String value) {
    strAnalysis = value;
    strAnalysisError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strAnalysisError = "Key_AnalysisRequiredNote".localized;
    }

    checkValidationForRequestRecommender();
    notifyListeners();
  }

  checkWholeValidation() {
    isValidaAllFieldTrader = (strMessage != "" && strMessageError == "");
  }

  checkValidationForRequestRecommender() {
    isValidaAllFieldRecommender = (strAnalysis != "" && strAnalysisError == "");
  }

  ///--------------------------API Properties---------------------------------///

  bool isLoading = false;
  bool isLoadingPagination = false;
  bool isError = false;
  bool isHasMorePage = false;

  /// Update Is Loading
  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Update Is Loading Pagination
  void updateIsLoadingPagination(bool value) {
    isLoadingPagination = value;
    notifyListeners();
  }

  /// Update Is Error
  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  final RequestAnalysisRepository _analysisRepository =
  RequestAnalysisRepositoryBuilder.repository();
  RequestAnalysisListResponseModel? requestAnalysisListResponseModel;
  List<RequestAnalysisList> requestAnalysisListData = [];

  /// Request Analysis Request List Api
  Future<void> requestAnalysisListAPI(BuildContext context,
      {required String status, required bool isHarMorePagee}) async {
    updateIsError(false);
    isHasMorePage = isHarMorePagee;
    if (isHasMorePage == true) {
      pageNo = int.parse(
          requestAnalysisListResponseModel?.data?.pageNumber.toString() ??
              "") +
          1;
    } else {
      pageNo = 1;
      requestAnalysisListResponseModel = RequestAnalysisListResponseModel();
    }

    (pageNo > 1) ? updateIsLoadingPagination(true) : updateIsLoading(true);
    updateIsError(false);

    if (pageNo == 1) {
      requestAnalysisListData.clear();
    }
    Map<String, dynamic> requestData = {
      "page_number": pageNo.toString(),
      "status": status.toString()
    };

    ApiResult apiResult = await _analysisRepository.getRequestAnalysisListAPI(
        context, requestData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);

      requestAnalysisListResponseModel =
      data as RequestAnalysisListResponseModel;

      if (requestAnalysisListResponseModel?.data?.requestAnalysisList != null &&
          requestAnalysisListResponseModel!
              .data!.requestAnalysisList!.isNotEmpty) {
        isHasMorePage = (int.parse(requestAnalysisListResponseModel!
            .data!.totalPage!
            .toString()) >
            int.parse(requestAnalysisListResponseModel!.data!.pageNumber
                .toString()))
            ? true
            : false;

        requestAnalysisListData.addAll(
            requestAnalysisListResponseModel?.data?.requestAnalysisList ?? []);
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

  CommonResponseModel commonResponseModel = CommonResponseModel();

  /// Complete Request Analysis For Recommender
  Future<void> completeAnalysisRequestAPI(BuildContext context,
      {required String requestID}) async {
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "request_id": requestID,
      "analysis_description": strAnalysis
    };

    ApiResult apiResult =
    await _analysisRepository.completeRequestAnalysis(context, request);

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

  NewRequestAnalysisResponseModel newRequestAnalysisResponseModel =
  NewRequestAnalysisResponseModel();

  /// New Request For Analysis - Updated to support multiple images
  Future<void> newRequestForAnalysisAPI(BuildContext context,
      {required String recommenderId}) async {
    updateIsLoading(true);
    updateIsError(false);

    FormData formDataForPhoto;
    List<MultipartFile> photosToSend = [];

    // Process multiple images
    if (pickedImages.isNotEmpty) {
      for (var image in pickedImages) {
        if (image.path.isNotEmpty) {
          String fileName = generateFileName() + "." + image.path.split(".").last;
          MultipartFile photo = await MultipartFile.fromFile(
            image.path,
            filename: fileName,
          );
          photosToSend.add(photo);
          showLog("photo $photo ${photo.runtimeType}");
        }
      }
    }

    // Create FormData with multiple images or single image based on API requirement
    // Option 1: If API accepts array of images
    formDataForPhoto = FormData.fromMap({
      "images": photosToSend.isNotEmpty ? photosToSend : null,
      "request_description": strMessage,
      "recommender_id": recommenderId.toString()
    });

    // Option 2: If API accepts single image (use first image)
    // Uncomment if your API only accepts single image
    /*
    formDataForPhoto = FormData.fromMap({
      "image": photosToSend.isNotEmpty ? photosToSend.first : null,
      "request_description": strMessage,
      "recommender_id": recommenderId.toString()
    });
    */

    FormData formData = FormData.fromMap({
      "request_description": strMessage,
      "recommender_id": recommenderId.toString()
    });

    ApiResult apiResult = await _analysisRepository.newRequestAnalysisAPI(
        context,
        photosToSend.isNotEmpty ? formDataForPhoto : formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      newRequestAnalysisResponseModel = data as NewRequestAnalysisResponseModel;

      if (newRequestAnalysisResponseModel.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, newRequestAnalysisResponseModel.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  /// Request Analysis Details
  RequestAnalysisDetailsResponseModel requestAnalysisDetailsResponseModel =
  RequestAnalysisDetailsResponseModel();

  Future<void> requestAnalysisDetailsAPI(BuildContext context,
      {required String requestID}) async {
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "request_id": requestID,
    };

    ApiResult apiResult =
    await _analysisRepository.requestAnalysisDetails(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      requestAnalysisDetailsResponseModel =
      data as RequestAnalysisDetailsResponseModel;

      if (requestAnalysisDetailsResponseModel.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, requestAnalysisDetailsResponseModel.message ?? "", null);
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