import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../const.dart';

class AppleLoginManager {
  AppleLoginManager._privateConstructor();

  static final AppleLoginManager instance =
      AppleLoginManager._privateConstructor();

  Future<void> appleLoginAPI(
      BuildContext context,
      Function(AppleDataModel appleDataModel) resultCallBack,
      Function(dynamic error) failureCallBack) async {
    AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    if (credential.identityToken != null) {
      String token = credential.identityToken ?? "";
      String uniqueId = credential.userIdentifier ?? "";
      String firstName = credential.givenName ?? "";
      String lastName = credential.familyName ?? "";
      String email = credential.email ?? "";

      showLog("Sign in with Apple");
      showLog("$credential");

      if (uniqueId != "") {
        AppleDataModel model =
            AppleDataModel(token, uniqueId, email, firstName, lastName, "");
        resultCallBack(model);
      } else {
        failureCallBack(null);
      }
    } else {
      failureCallBack(null);
    }
  }
}

class AppleDataModel {
  String token;
  String appleId;
  String email;
  String firstName;
  String lastName;
  String profilePhoto;

  AppleDataModel(this.token, this.appleId, this.email, this.firstName,
      this.lastName, this.profilePhoto);
}

/*
------------------- Usage of Apple Login Manager -------------------
*/

/*
AppleLoginManager.instance.appleLoginAPI(context, (appleDataModel) {
//Result Call Back
showLog("Apple Data Model - appleDataModel");
}, (error) {
//Failure Call Back
showLog("Error - $error");
});
 */
