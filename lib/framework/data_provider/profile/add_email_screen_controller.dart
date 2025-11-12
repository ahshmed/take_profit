import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/profile_details_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';


class AddEmailScreenController extends ChangeNotifier {
  String strEmail = "";
  String strEmailError = "";

  bool isValidate = false;

  ///Check validation
  void checkValidation() {
    isValidate = (strEmail != "" &&
        strEmailError == "" );
  }

  ///Check Email Validation
  void checkEmailValidation(BuildContext context, String value) {
    strEmail = value;
    strEmailError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strEmailError = getLocalValue("Key_PleaseEnterEmailAddress");
    }else if(!isEmailValid(value)){
      strEmailError = getLocalValue("Key_EmailIsInvalid");
    }
    checkValidation();
    notifyListeners();
  }



  void clearProvider() {
    strEmail = "";
    strEmailError = "";
    isValidate = false;
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

  final ProfileRepository _profileRepository = ProfileRepositoryBuilder.repository();

  ProfileDetailResponseModel? updateEmailResponseModel;

  ///Update Email Api
  Future<void> updateEmailApi(BuildContext context) async {
    updateEmailResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "email": strEmail
    };

    ApiResult apiResult = await _profileRepository.updateEmailAddressAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
     updateEmailResponseModel = data as ProfileDetailResponseModel;

      if(updateEmailResponseModel?.status == ApiEndPoints.apiStatus_200.toString()){
        // saveLocalData(KEY_USER_DATA, loginResponseModel?.data);
        // saveLocalData(KEY_USER_ACCESS_TOKEN, loginResponseModel?.data?.token);
        // saveLocalData(KEY_USER_STATUS, loginResponseModel?.data?.userType);
      }
      else
        {
          updateIsError(true);
          if(updateEmailResponseModel?.status == ApiEndPoints.apiStatus_201.toString()){
            showMessageDialog(context, updateEmailResponseModel?.message ?? "", (){
              // Route route = SlideRightPageRoute(builder: (context) => SignUpScreen(isRecommender: getUserStatus() == recommender ? true : false), settings: const RouteSettings());
              // Navigator.of(context).pushReplacement(route);
            });
          }
        }

    },
        failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();

    }

}
