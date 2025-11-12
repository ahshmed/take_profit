// import 'package:flutter/material.dart';
//
// class FacebookLoginManager {
//   FacebookLoginManager._privateConstructor();
//
//   static final FacebookLoginManager instance = FacebookLoginManager._privateConstructor();
//
//   Future<void> facebookLoginAPI(
//       BuildContext context,
//       Function(FacebookDataModel facebookDataModel) resultCallBack,
//       Function(dynamic error) failureCallBack) async {
//     showLog("Start Facebook Login Process");
//
//     try {
//       final facebookAuth = FacebookAuth.instance;
//       showLog("Create facebook instance object");
//       final result = await facebookAuth.login(permissions: ["public_profile", "email"]);
//       showLog("Get result from facebook");
//
//       if((result.accessToken?.token ?? "") != ""){
//         Map data = await facebookAuth.getUserData();
//         showLog("User Data - $data");
//
//         String token = result.accessToken?.token ?? "";
//         String strUniqueID = data["id"].toString();
//         String strEmail = data["email"].toString();
//         List<String> arrName = data["name"].toString().split(" ");
//         String strFName = arrName.first;
//         String strLName = arrName.isNotEmpty ? arrName.last : "";
//         String strProfileImage = data["picture"]["data"]["url"].toString();
//
//         showLog("FB Token - $token");
//         showLog("FB Id - $strUniqueID");
//         showLog("FB Email - $strEmail");
//         showLog("FB F Name - $strFName");
//         showLog("FB L Name - $strLName");
//         showLog("FB Profile Image - $strProfileImage");
//
//         FacebookDataModel dataModel = FacebookDataModel(token, strUniqueID, strEmail, strFName, strLName, strProfileImage);
//         facebookAuth.logOut();
//         resultCallBack(dataModel);
//       }
//     }
//     catch(error) {
//       showLog("Facebook Auth Error - ${error.toString()}");
//     }
//   }
// }
//
// class FacebookDataModel {
//   String token;
//   String facebookId;
//   String email;
//   String firstName;
//   String lastName;
//   String profilePhoto;
//
//   FacebookDataModel(this.token, this.facebookId, this.email, this.firstName, this.lastName, this.profilePhoto);
// }
//
// /*
// ------------------- Usage of Facebook Login Manager -------------------
// */
//
// /*
// FacebookLoginManager.instance.facebookLoginAPI(context, (model) {
// //Result Call Back
// showLog("Facebook Data Model - $model");
// }, (error) {
// //Failure Call Back
// showLog("Error - $error");
// });
//  */
