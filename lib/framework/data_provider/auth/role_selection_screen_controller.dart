// import 'package:flutter/material.dart';
// import 'package:trader/utils/const.dart';
//
// class RoleSelectionScreenController extends ChangeNotifier {
//   String titleName = signIn;
//   bool isRecommender = false;
//   bool isRoleSelected = false;
//   bool isValidate = false;
//
//   updateTitle(String title) {
//     titleName = title;
//     notifyListeners();
//   }
//
//   updateRoleStatus(bool value) {
//     isRoleSelected = true;
//     isRecommender = value;
//     checkValidation();
//     notifyListeners();
//   }
//
//   checkValidation() {
//     isValidate = isRoleSelected;
//   }
//
//   clearProvider() {
//     isRoleSelected = false;
//     isRecommender = false;
//     isValidate = false;
//     notifyListeners();
//   }
//
//   clearProviderWithName() {
//     titleName = signIn;
//     isValidate = false;
//     isRoleSelected = false;
//     isRecommender = false;
//     notifyListeners();
//   }
// }
