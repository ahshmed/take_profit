import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/profile_details_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';


class AddSocialLinkScreenController extends ChangeNotifier {
  String strFacebookLink = "";
  String strFacebookLinkError = "";

  String strTwitterLink = "";
  String strTwitterLinkError = "";

  String strInstagramLink = "";
  String strInstagramLinkError = "";

  String strWebLink = "";
  String strWebLinkError = "";

  bool isValidate = false;

  Pattern patternFacebook = r'(?:(?:http|https):\/\/)?(?:www.)?facebook.com';
  Pattern patternTwitter = r'(?:(?:http|https):\/\/)?(?:www.)?twitter.com';
  Pattern patternInstagram = r'(?:(?:http|https):\/\/)?(?:www.)?instagram.com';
  Pattern patternWebsite =
      r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)';

  /// Validation of url for Strict use of https
  /// r'^(http(s):\/\/.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$'
  /// Validation of Url for strict use of http or https
  /// r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)'

  ///Check validation
  checkValidation() {
    isValidate = ((strFacebookLink != "" && strFacebookLinkError == "") ||
        (strInstagramLink != "" && strInstagramLinkError == "") ||
        (strTwitterLink != "" && strTwitterLinkError == "") ||
        (strWebLink != "" && strWebLinkError == ""));
  }

  clearFacebook() {
    strFacebookLink = "";
    strFacebookLinkError = "";
    checkValidation();
    notifyListeners();
  }

  clearTwitter() {
    strTwitterLink = "";
    strTwitterLinkError = "";
    checkValidation();
    notifyListeners();
  }

  clearInstagram() {
    strInstagramLink = "";
    strInstagramLinkError = "";
    checkValidation();
    notifyListeners();
  }

  clearWeb() {
    strWebLink = "";
    strWebLinkError = "";
    checkValidation();
    notifyListeners();
  }

  ///Check Facebook Link Validation
  void checkFacebookLinkValidation(BuildContext context, String value) {
    strFacebookLink = value;
    strFacebookLinkError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strFacebookLinkError =
          getLocalValue("Key_PleaseEnterFacebookLinkAddress");
    } else if (!isValidPattern(value, patternFacebook)) {
      strFacebookLinkError = getLocalValue("Key_FacebookLinkIsInvalid");
    }
    checkValidation();
    notifyListeners();
  }

  ///Check Twitter Link Validation
  void checkTwitterLinkValidation(BuildContext context, String value) {
    strTwitterLink = value;
    strTwitterLinkError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strTwitterLinkError = getLocalValue("Key_PleaseEnterTwitterLinkAddress");
    } else if (!isValidPattern(value, patternTwitter)) {
      strTwitterLinkError = getLocalValue("Key_TwitterLinkIsInvalid");
    }
    checkValidation();
    notifyListeners();
  }

  ///Check Instagram Link Validation
  void checkInstagramLinkValidation(BuildContext context, String value) {
    strInstagramLink = value;
    strInstagramLinkError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strInstagramLinkError =
          getLocalValue("Key_PleaseEnterInstagramLinkAddress");
    } else if (!isValidPattern(value, patternInstagram)) {
      strInstagramLinkError = getLocalValue("Key_InstagramLinkIsInvalid");
    }
    checkValidation();
    notifyListeners();
  }

  ///Check Web Link Validation
  void checkWebLinkValidation(BuildContext context, String value) {
    strWebLink = value;
    strWebLinkError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strWebLinkError = getLocalValue("Key_PleaseEnterWebLinkAddress");
    } else if (!isValidPattern(value, patternWebsite)) {
      strWebLinkError = getLocalValue("Key_WebLinkIsInvalid");
    }
    checkValidation();
    notifyListeners();
  }

  void clearProvider() {
    strFacebookLink = "";
    strFacebookLinkError = "";

    strTwitterLink = "";
    strTwitterLinkError = "";

    strInstagramLink = "";
    strInstagramLinkError = "";

    strWebLink = "";
    strWebLinkError = "";
    isValidate = false;
    notifyListeners();
  }

  ///-----------------------------API Properties-------------------------------///

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

  final ProfileRepository _profileRepository =
      ProfileRepositoryBuilder.repository();

  ProfileDetailResponseModel? profileDetailResponseModel;

  ///Profile Details Api
  Future<void> updateProfileAPI(BuildContext context) async {
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "facebook_url": (strFacebookLink != "")
          /* ? ((strFacebookLink.contains("https://") ||
                  strFacebookLink.contains("http://"))*/
          ? strFacebookLink
          /* : "http://$strFacebookLink")*/
          : "",
      "twitter_url": (strTwitterLink != "")
          /*  ? ((strTwitterLink.contains("https://") ||
                  strTwitterLink.contains("http://"))*/
          ? strTwitterLink
          /* : "http://$strTwitterLink")*/
          : "",
      "instagram_url": (strInstagramLink != "")
          /* ? ((strInstagramLink.contains("https://") ||
                  strInstagramLink.contains("http://"))*/
          ? strInstagramLink
          /*: "http://$strInstagramLink")*/
          : "",
      "website_url": (strWebLink != "")
          /* ? ((strWebLink.contains("https://") || strWebLink.contains("http://"))*/
          ? strWebLink
          /* : "http://$strWebLink")*/
          : "",
    };

    ApiResult apiResult =
        await _profileRepository.updateSocialLinksAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      profileDetailResponseModel = data as ProfileDetailResponseModel;

      if (profileDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, profileDetailResponseModel?.message ?? "", null);
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
