import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/profile_details_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';


class ProfileScreenController extends ChangeNotifier {
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

  final ProfileRepository _profileRepository =
      ProfileRepositoryBuilder.repository();

  ProfileDetailResponseModel? profileDetailResponseModel;

  ///Profile Details Api
  Future<void> profileAPI(BuildContext context) async {
    // profileDetailResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    ApiResult apiResult = await _profileRepository.getProfileDetailAPI(context);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      profileDetailResponseModel = data as ProfileDetailResponseModel;

      if (profileDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        saveLocalData(
            KEY_USER_IMAGE, profileDetailResponseModel?.data?.profileImage);
        //appsFlyer.setCustomerUserId(profileDetailResponseModel?.data?.id ?? '');
      } else {
        updateIsError(true);
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
