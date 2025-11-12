import 'package:flutter/material.dart';

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/my_subscription/contract/my_subscription_repository.dart';
import '../../repository/my_subscription/model/revenue_chart_response_model.dart';
import '../../repository/my_subscription/repository/my_subscription_repository_builder.dart';

class MyRevenueController extends ChangeNotifier {
  List<MonthModel> monthList = [
    MonthModel(1, "Key_January"),
    MonthModel(2, "Key_February"),
    MonthModel(3, "Key_March"),
    MonthModel(4, "Key_April"),
    MonthModel(5, "Key_May"),
    MonthModel(6, "Key_June"),
    MonthModel(7, "Key_July"),
    MonthModel(8, "Key_August"),
    MonthModel(9, "Key_September"),
    MonthModel(10,"Key_October"),
    MonthModel(11,"Key_November"),
    MonthModel(12,"Key_December"),
  ];
  List<int> yearList = [];

  int selectedYear = DateTime.now().year;

  void generateYears() {
    if (yearList.isEmpty) {
      int year = DateTime.now().year;
      yearList.add(year);
      yearList.add((year - 1));
      yearList.add((year - 2));
      yearList.add((year - 3));
    }
    selectedYear = DateTime.now().year;
    notifyListeners();
  }

  void updateSelectedYear(int year) {
    selectedYear = year;
    notifyListeners();
  }

  int selectedMonthId = DateTime.now().month;
  MonthModel? selectedMonth;

  ///Update Selected Month Value
  void updateSelectedMonth(MonthModel month) {
    selectedMonth = month;
    selectedMonthId = month.id;
    notifyListeners();
  }

  void clearProvider() {
    selectedMonth = null;
    notifyListeners();
  }

  ///---------------------------API Properties-------------------------------///

  bool isLoading = false;
  bool isError = false;

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

  final MySubscriptionRepository _mySubscriptionRepository =
      MySubscriptionRepositoryBuilder.repository();

  RevenueChartResponseModel? revenueChartResponseModel;

  ///Cancel Subscription Api
  Future<void> revenueChartAPI(BuildContext context,
      {String? year, String? month}) async {
    revenueChartResponseModel = null;
    updateIsLoading(true);
    updateIsError(false);

    Map<String, dynamic> request = {
      "month": selectedMonthId,
      "year": selectedYear
    };

    ApiResult apiResult =
        await _mySubscriptionRepository.revenueChartAPI(context, request);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      revenueChartResponseModel = data as RevenueChartResponseModel;

      if (revenueChartResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
      } else {
        updateIsError(true);
        showMessageDialog(
            context, revenueChartResponseModel?.message ?? "", null);
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

class MonthModel {
  final int id;
  final String monthName;

  MonthModel(this.id, this.monthName);
}
