import 'package:flutter/material.dart';

import '../../../utils/const.dart';

class SignUpSubscriptionAmountScreenController extends ChangeNotifier {
  String strAmount = "";
  String strAmountError = "";
  bool isValidate = false;
  bool isObscure = true;

  void updateIsObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void checkValidation() {
    isValidate = (strAmount != "" && strAmountError == "");
  }

  void clearProvider() {
    isValidate = false;
    strAmount = "";
    strAmountError = "";
    isObscure = true;
    notifyListeners();
  }

  ///Check Amount validation
  void checkAmountValidation(BuildContext context, String value) {
    strAmount = value;
    strAmountError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strAmountError = getLocalValue("Key_PleaseEnterAmount");
    }

    checkValidation();
    notifyListeners();
  }
}
