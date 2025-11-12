import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../../utils/file_download_manager.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/recommender/contract/recommender_repository.dart';
import '../../repository/recommender/model/btc_scenarios_list_response_model.dart';
import '../../repository/recommender/repository/recommender_repository_bulder.dart';


class NewBTCScenariosController extends ChangeNotifier {
  String strDescriptionEn = "";
  String strDescriptionErrorEn = "";
  // String strDescriptionAr = "";
  // String strDescriptionErrorAr = "";
  bool isValidate = false;
  List<File> imgFile = [];


  ///Check validation
  void checkValidation() {
    isValidate = (strDescriptionEn != "" &&
        strDescriptionErrorEn == "" &&
        /*strDescriptionAr != "" &&
        strDescriptionErrorAr == "" &&*/
        imgFile.isNotEmpty);
  }

  List<File> getImageList() => imgFile;
  addImage(File val) async {
    imgFile.add(val);
    checkValidation();
    notifyListeners();
  }

  removeImage(int index) async {
    imgFile.removeAt(index);
    checkValidation();
    notifyListeners();
  }

  ///Check  Description Validation
  void checkEnDescriptionValidation(BuildContext context, String value) {
    strDescriptionEn = value;
    strDescriptionErrorEn = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strDescriptionErrorEn = getLocalValue("Key_PleaseEnterDescriptionEn");
    }
    checkValidation();
    notifyListeners();
  }

  // ///Check  Description Validation
  // void checkArDescriptionValidation(BuildContext context, String value) {
  //   strDescriptionAr = value;
  //   strDescriptionErrorAr = "";
  //
  //   String removeWhiteSpace = value.replaceAll(" ", "");
  //   if (removeWhiteSpace.isEmpty) {
  //     strDescriptionErrorAr = getLocalValue("Key_PleaseEnterDescriptionAr");
  //   }
  //   checkValidation();
  //   notifyListeners();
  // }

  void clearProvider() {
    strDescriptionEn = "";
    strDescriptionErrorEn = "";
    // strDescriptionAr = "";
    // strDescriptionErrorAr = "";
    isValidate = false;
    imgFile.clear();
    notifyListeners();
  }

  /// ---------------------------- Api Integration ---------------------------------///

  bool isLoading = false;
  bool isError = false;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  final RecommenderRepository recommenderRepository =
      RecommenderRepositoryBuilder.repository();
  CommonResponseModel? editBTCScenarioResponseModel;

  ///Edit BTC Scenario Api
  Future<void> editBTCScenariosApi(
      BuildContext context, String? scenarioId) async {
    editBTCScenarioResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    List<MultipartFile> arrStorePhotos = [];
    for (File fileModel in imgFile) {
      File fileCompress = await compressImageFile(fileModel);

      String fileName = fileCompress.path.split(".").last;

      arrStorePhotos
          .add(await MultipartFile.fromFile(fileCompress.path, filename: fileName));
    }

    FormData formData = FormData.fromMap({
      "scenario_id": scenarioId,
      "description:en": strDescriptionEn,
      "description:ar": strDescriptionEn,
      "images[]": arrStorePhotos
    });

    ApiResult apiResult =
        await recommenderRepository.editBTCScenariosApi(context, formData);

    apiResult.when(success: (data) async {
      showLog("in success part");
      updateIsLoading(false);
      editBTCScenarioResponseModel = data as CommonResponseModel;

      if (editBTCScenarioResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        // saveLocalData(KEY_USER_DATA, loginResponseModel?.data);
        showMessageDialog(
            context, editBTCScenarioResponseModel?.message.toString() ?? "",
            () {
          Navigator.pop(context);
        });
      }else{
        showMessageDialog(
            context, editBTCScenarioResponseModel?.message.toString() ?? "",
                () {
              // Navigator.pop(context);
            });
      }
    }, failure: (NetworkExceptions error) {
      showLog("in fail part");
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  CommonResponseModel? newBTCScenarioResponseModel;

  ///New BTC Scenario Api
  Future<void> newBTCScenariosApi(BuildContext context) async {
    newBTCScenarioResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    List<MultipartFile> arrStorePhotos = [];

    for (File file in imgFile) {
      File fileCompress = await compressImageFile(file);
      String fileName =
          "${generateFileName()}.${fileCompress.path.split(".").last}";
      arrStorePhotos.add(
        await MultipartFile.fromFile(fileCompress.path, filename: fileName),
      );
    }

    FormData formData = FormData.fromMap({
      "description:en": strDescriptionEn,
      "description:ar": strDescriptionEn,
      "images[]": arrStorePhotos
    });

    ApiResult apiResult =
        await recommenderRepository.newBTCScenariosApi(context, formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      newBTCScenarioResponseModel = data as CommonResponseModel;

      if (newBTCScenarioResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        showMessageDialog(context, newBTCScenarioResponseModel?.message ?? "",
            () {
          Navigator.pop(context);
        });
      } else {
        updateIsError(true);
        showMessageDialog(
            context, newBTCScenarioResponseModel?.message ?? "", null);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  // Directory? directory;
  // late String filePathAndName;
  // String imageDirectoryName = "/images";
  // File? imageFile;
  //
  // Future<File?> downloadImage(String imgUrl, String nameWithExt) async {
  //   showLog("downloadImage imgUrl : $imgUrl");
  //   // var response = await get(imgUrl);
  //   var response = await http.get(Uri.parse(imgUrl));
  //   directory = await getApplicationDocumentsDirectory();
  //   var firstPath = directory!.path + imageDirectoryName;
  //   filePathAndName = directory!.path + '$imageDirectoryName/$nameWithExt';
  //   await Directory(firstPath).create(recursive: true);
  //   File file2 = File(filePathAndName);
  //   file2.writeAsBytesSync(response.bodyBytes);
  //   showLog("downloadImage file imgUrl : $filePathAndName");
  //   showLog("--->1 : ${directory!.path}");
  //   showLog("--->2: ${directory!.absolute.path}");
  //
  //   showLog("converted file image :- $filePathAndName");
  //   imageFile = File(filePathAndName);
  //   showLog("File Object From Downloaded File - $imageFile");
  //
  //   return imageFile;
  // }

  List<String>? comingList = [];

  bool isLoadingForImage = false;

  updateLoadingValue(bool value) {
    isLoadingForImage = value;
    notifyListeners();
  }

  convertStringToFile(List<BTCImage>? value) async {
    imgFile.clear();
    comingList?.clear();
    for (int i = 0; i < (value?.length ?? 0); i++) {
      comingList?.add(value?[i].image.toString() ?? "");
    }
    for (int i = 0; i < (comingList?.length ?? 0); i++) {
      var storeImage = await FileDownloadManager.instance.downloadImage(
          comingList?[i].toString() ?? "", "${generateFileName()}_$i.jpg");
      imgFile.add(storeImage!);
    }
    updateLoadingValue(false);
    // value?.forEach((element) { imgFile.add(File(element));});
    // showLog("converted list ${imgFile}");
    notifyListeners();
  }
}
