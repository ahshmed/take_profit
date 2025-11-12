import 'package:flutter/material.dart';

class UserGuideController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;

  String urlPass = "";
  double progress = 0;

  updateURL(String status) {
    urlPass = status;
    notifyListeners();
  }

  updateProgressStatus(double status) {
    progress = status;
    notifyListeners();
  }

  updateLoadingStatus(bool status) {
    isLoading = status;
    notifyListeners();
  }

  clearProviderData() {
    urlPass = "";
    progress = 0;
    isLoading = false;
    isError = false;
    notifyListeners();
  }

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
}
