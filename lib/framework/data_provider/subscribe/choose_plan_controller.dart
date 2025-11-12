import 'package:flutter/material.dart';

class ChoosePlanController extends ChangeNotifier {
  int? selectedPlanIndex;

  String? profilePackageID;
  String? profilePackageIdAmount;

  clearProvider() {
    selectedPlanIndex = null;
    notifyListeners();
  }

  setSelectedPlanIndex(int value, String packageID, String packageAmount) {
    profilePackageID = packageID;
    profilePackageIdAmount = packageAmount;
    selectedPlanIndex = value;
    notifyListeners();
  }
}
