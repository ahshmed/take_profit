import 'package:flutter/cupertino.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/cms/contract/cms_repository.dart';
import '../../repository/cms/model/cms_response_model.dart';
import '../../repository/cms/repository/cms_repository_builder.dart';


class CMSScreenController extends ChangeNotifier {
  void clearProvider() {
    notifyListeners();
  }

  ///-----------------------------API Properties------------------------------///

  final CmsRepository _cmsRepository = CmsRepositoryBuilder.repository();

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

  CmsResponseModel? cmsResponseModel;

  ///Resend Email Otp Api
  Future<void> cmsPageAPI(BuildContext context, String slug) async {
    cmsResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {"slug": slug};

    ApiResult apiResult = await _cmsRepository.cmsPageAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      cmsResponseModel = data as CmsResponseModel;

      if (cmsResponseModel?.status == ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(context, cmsResponseModel?.message ?? "", null);
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
