import 'package:flutter/material.dart';

import '../../repository/master/model/get_subscription_package_list.dart';


class DurationController extends ChangeNotifier {
  bool isLoading = false;

  bool isValidForPriceList = false;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  ///Text Editing Controller
  List<TextEditingController> amountCTR = <TextEditingController>[];

  ///Focus Node
  List<FocusNode> amountFocus = <FocusNode>[];

  List<PackageList>? selectedPlanList = [];

  List<PackageList>? tempSelectedPlanList = [];

  List<PriceModel> priceList = [];
  List<PackageList>? planList = [];

  void clearProvider() {
    selectedPlanList?.clear();
    tempSelectedPlanList?.clear();
    planList?.clear();
    amountCTR.clear();
    amountFocus.clear();
    priceList.clear();
    notifyListeners();
  }

  void addDataIntoList() {
    notifyListeners();
  }

  void updateSelectedPlan(int index, PackageList item) {
    if (tempSelectedPlanList?.contains(item) == true) {
      tempSelectedPlanList?.remove(item);
    } else {
      tempSelectedPlanList?.add(item);
    }
    notifyListeners();
  }

  void addItemsInSelectedList() {
    /// remove Item where Name of packge already contain by selectedPlanList
    for (int i = 0; i < (tempSelectedPlanList?.length ?? 0); i++) {
      /// To Remove Alredy Selected plans in list
      selectedPlanList?.removeWhere((element) =>
          tempSelectedPlanList?[i].packageName == element.packageName);

      /// to Remove Price From List
      // priceList.retainWhere((element) => tempSelectedPlanList?[i].subscriptionPackageId == element.subscriptionPackageId);

    }

    selectedPlanList?.addAll(tempSelectedPlanList!);

    final oldLength = ((selectedPlanList?.length ?? 0) - amountCTR.length);
    for (int i = 0; i < (oldLength); i++) {
      amountCTR.add(TextEditingController());
      amountFocus.add(FocusNode());
      priceList.add(PriceModel());
      amountFocus[i].addListener(() {});
    }
    checkValidationForPriceList();
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  void removeItemAtIndex(int index, PackageList item) {
    selectedPlanList?.removeAt(index);
    amountCTR.removeAt(index);
    amountFocus.removeAt(index);
    priceList.removeAt(index);
    for (int pl = 0; pl < (planList?.length ?? 0); pl++) {
      if (planList?[pl].subscriptionPackageId == item.subscriptionPackageId) {
        tempSelectedPlanList?.remove(item);
      }
    }
    checkValidationForPriceList();
    notifyListeners();
  }

  bool checkValidationForPriceList() {
    bool isAdd = false;
    for (int i = 0; i < amountCTR.length; i++) {
      if (amountCTR[i].text.isNotEmpty) {
        isAdd = true;
      } else {
        isAdd = false;
        break;
      }
    }
    if (isAdd == true) {
      return true;
    }
    return false;
  }
}

class PriceModel {
  String? price;
  String? subscriptionPackageId;

  PriceModel({this.price, this.subscriptionPackageId});
}
