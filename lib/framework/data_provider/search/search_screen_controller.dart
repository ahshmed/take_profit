// import 'package:flutter/material.dart';
// import 'package:trader/framework/data_provider/profile/select_currency_screen_controller.dart';
// import 'package:trader/utils/const.dart';
// import 'package:trader/utils/theme_const.dart';
//
// class SearchScreenController extends ChangeNotifier {
//   String strSearch = "";
//   String strSearchError = "";
//   bool isValidate = false;
//   List<int> selectedList = [];
//   List<ListModel> itemList = [
//     ListModel(
//         icon: Constant().icBitcoinIcon,
//         title: "Bitcoin",
//         subTitle: "BTC",
//         isSelected: false),
//     ListModel(
//         icon: Constant().icEthereumIcon,
//         title: "Ethereum",
//         subTitle: "BNB",
//         isSelected: false),
//     ListModel(
//         icon: Constant().icBitcoinIcon,
//         title: "Binance Coin",
//         subTitle: "BNB",
//         isSelected: false),
//     ListModel(
//         icon: Constant().icEthereumIcon,
//         title: "Tether",
//         subTitle: "BTC",
//         isSelected: false)
//   ];
//
//   checkSearchValidation(String value) {
//     strSearch = value;
//     strSearchError = "";
//
//     String removeWhiteSpace = value.replaceAll(" ", "");
//     if (removeWhiteSpace.isEmpty) {
//       strSearchError = getLocalValue("");
//     }
//     checkValidation();
//     notifyListeners();
//   }
//
//   updateSelectedItem(int index, ListModel list) {
//     itemList[index].isSelected = !itemList[index].isSelected;
//     if (list.isSelected == false) {
//       selectedList.remove(index);
//     } else {
//       selectedList.add(index);
//     }
//     notifyListeners();
//   }
//
//   checkValidation() {
//     isValidate = (strSearch != "" && strSearchError == "");
//   }
//
//   clearProvider() {
//     strSearch = "";
//     strSearchError = "";
//     isValidate = false;
//     notifyListeners();
//   }
// }
