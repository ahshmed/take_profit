import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/common_response_model.dart';
import '../../repository/home/contract/home_repository.dart';
import '../../repository/home/model/home_recommender_details_response_model.dart';
import '../../repository/home/repository/home_repository_bulder.dart';


class HomeScreenController extends ChangeNotifier {
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

  void clearProvider() {
    isLoading = false;
    isError = false;
    notifyListeners();
  }


  final HomeRepository _homeRepository = HomeRepositoryBuilder.repository();

  HomeRecommenderDetailsResponseModel? homeRecommenderDetailsResponseModel;

  ///Recommender Detail  Api
  Future<void> homeRecommenderDetailsApi(BuildContext context) async {
    homeRecommenderDetailsResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    ApiResult apiResult =
        await _homeRepository.homeRecommenderDetailsApi(context);

    apiResult.when(success: (data) {
      updateIsLoading(false);
      homeRecommenderDetailsResponseModel =
          data as HomeRecommenderDetailsResponseModel;
      if (homeRecommenderDetailsResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(context, homeRecommenderDetailsResponseModel?.message ?? '', null);
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
