import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../const.dart';


class GoogleLoginManager {
  GoogleLoginManager._privateConstructor();

  static final GoogleLoginManager instance = GoogleLoginManager._privateConstructor();

  Future<void> googleLoginAPI(
      BuildContext context,
      Function(GoogleDataModel googleDataModel) resultCallBack,
      Function(dynamic error) failureCallBack) async {

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>['email'],
    );

    GoogleSignInAccount? user = googleSignIn.currentUser;

    String token = "";
    showLog("User Data from Google : $user");

    try {
      if (user == null) {
        // Sign in if no current user
        user = await googleSignIn.signIn();

        if (user == null) {
          failureCallBack("Login canceled by user");
          return;
        }
      }

      // Get authentication tokens
      final GoogleSignInAuthentication googleKey = await user.authentication;

      token = googleKey.accessToken ?? "";
      final String? idToken = googleKey.idToken;

      showLog("accessToken: $token");
      showLog("idToken: $idToken");
      showLog("displayName: ${user.displayName}");
      showLog("id: ${user.id}");
      showLog("email: ${user.email}");
      showLog("photoUrl: ${user.photoUrl}");

      // Process user data
      String strUniqueID = user.id;
      String strEmail = user.email ?? "";
      List<String> strFullName = (user.displayName ?? "").split(" ");
      String strFName = strFullName.isNotEmpty ? strFullName.first : "";
      String strLName = strFullName.length > 1 ? strFullName.sublist(1).join(" ") : "";
      String strPhoto = user.photoUrl ?? "";

      // Create data model
      GoogleDataModel googleDataModel = GoogleDataModel(
        token: token,
        googleId: strUniqueID,
        email: strEmail,
        firstName: strFName,
        lastName: strLName,
        profilePhoto: strPhoto,
        idToken: idToken ?? "",
      );

      // Sign out after getting data (maintaining your original behavior)
      await googleSignIn.signOut();

      resultCallBack(googleDataModel);

    } catch (error) {
      showLog("Google login error: $error");
      await googleSignIn.signOut();
      failureCallBack(error);
    }
  }

  // Additional utility methods for v6.1.5
  Future<GoogleSignInAccount?> getCurrentUser() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    return googleSignIn.currentUser;
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    return googleSignIn.currentUser != null;
  }
}

class GoogleDataModel {
  final String token;
  final String googleId;
  final String email;
  final String firstName;
  final String lastName;
  final String profilePhoto;
  final String idToken;

  GoogleDataModel({
    required this.token,
    required this.googleId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profilePhoto,
    required this.idToken,
  });

  // For backward compatibility with your original constructor
  GoogleDataModel.legacy(
      this.token,
      this.googleId,
      this.email,
      this.firstName,
      this.lastName,
      this.profilePhoto,
      ) : idToken = '';

  @override
  String toString() {
    return 'GoogleDataModel{token: $token, googleId: $googleId, email: $email, firstName: $firstName, lastName: $lastName, profilePhoto: $profilePhoto, idToken: $idToken}';
  }
}