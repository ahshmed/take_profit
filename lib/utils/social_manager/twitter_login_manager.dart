/*
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:twitter_login/twitter_login.dart';

import '../const.dart';

class TwitterLoginManager {
  TwitterLoginManager._privateConstructor();

  static final TwitterLoginManager instance =
      TwitterLoginManager._privateConstructor();

  final twitterLogin = TwitterLogin(
      apiKey: apikey_twitter,
      apiSecretKey: secretkey_twitter,
      redirectURI: redirectionUrl_twitter);

  /// sign in with twitter
  Future signInWithTwitter(
      BuildContext context,
      Function(TwitterDataModel twitterDataModel) resultCallBack,
      Function(dynamic error) failureCallBack) async {
    final authResultV1 = await twitterLogin.loginV2();
    // final authResultV2 = await twitterLogin.loginV2();
    showLog("${authResultV1.status}");
    if (authResultV1.status == TwitterLoginStatus.loggedIn) {
      try {
        final userDetails = authResultV1.user;
        showLog("User Details From twitter ${userDetails?.name}");

        /// save all the data
        String name = userDetails!.name;
        String uid = userDetails.id.toString();
        String email = userDetails.email;
        String imageUrl = userDetails.thumbnailImage;
        String token = authResultV1.authToken ?? "";
        String provider = "TWITTER";

        List<String> strFullName = name.split(" ");
        String strFName = strFullName.first;
        String strLName = strFullName.last;

        showLog("twitter name $name");
        showLog("twitter name $strFName");
        showLog("twitter name $strLName");
        showLog("twitter id $uid");
        showLog("twitter email $email");
        showLog("twitter image $imageUrl");
        showLog("twitter token $token");

        if (uid != "") {
          TwitterDataModel model = TwitterDataModel(
              strFName, strLName, email, imageUrl, uid, token, provider);
          resultCallBack(model);
        }
      } catch (error) {
        showMessageDialog(context, error.toString(), () {});
      }
    } else {
      // String errorCode = "Some unexpected error while trying to sign in";
      // showMessageDialog(context, errorCode, () {});
    }
  }

  // Future login() async {
  //   final twitterLogin = TwitterLogin(
  //       apiKey: apikey_twitter,
  //       apiSecretKey: secretkey_twitter,
  //       redirectURI: "takeproftsocialauth://");
  //   final authResult = await twitterLogin.login();
  //   switch (authResult.status) {
  //     case TwitterLoginStatus.loggedIn:
  //
  //       /// success
  //       showLog('====== Login success ======');
  //       showLog(authResult.authToken ?? "");
  //       showLog(authResult.authTokenSecret ?? "");
  //       showLog("${authResult.user?.id}");
  //       showLog(authResult.user?.name ?? "");
  //       showLog(authResult.user?.email ?? "");
  //       showLog(authResult.user?.thumbnailImage ?? "");
  //       break;
  //     case TwitterLoginStatus.cancelledByUser:
  //
  //       /// cancel
  //       showLog('====== Login cancel ======');
  //       break;
  //     case TwitterLoginStatus.error:
  //     case null:
  //
  //       /// error
  //       showLog('====== Login error ======');
  //       break;
  //   }
  // }
  //
  // Future loginV2() async {
  //   final twitterLogin = TwitterLogin(
  //       apiKey: apikey_twitter,
  //       apiSecretKey: secretkey_twitter,
  //       redirectURI: "takeproftsocialauth://");
  //
  //   final authResult = await twitterLogin.loginV2();
  //   switch (authResult.status) {
  //     case TwitterLoginStatus.loggedIn:
  //
  //       /// success
  //       showLog('====== Login success ======');
  //       break;
  //     case TwitterLoginStatus.cancelledByUser:
  //
  //       /// cancel
  //       showLog('====== Login cancel ======');
  //       break;
  //     case TwitterLoginStatus.error:
  //     case null:
  //
  //       /// error
  //       showLog('====== Login error ======');
  //       break;
  //   }
  // }
}

class TwitterDataModel {
  String firstName;
  String lastName;
  String email;
  String imageUrl;
  String uid;
  String token;
  String provider;

  TwitterDataModel(this.firstName, this.lastName, this.email, this.imageUrl,
      this.uid, this.token, this.provider);
}

*/
/*
------------------- Usage of twitter Login Manager -------------------
*//*


*/
/*
TwitterLoginManager.instance.signInWithTwitter(context, (twitterDataModel) {
//Result Call Back
showLog("twitter Data Model - twitterDataModel");
}, (error) {
//Failure Call Back
showLog("Error - $error");
});
 */
