import 'package:flutter/material.dart';

abstract class AuthRepository {
  ///Login Api
  Future loginApi(BuildContext context, Map<String, dynamic> request);

  ///Forgot Password Api
  Future forgotPasswordApi(BuildContext context, Map<String, dynamic> request);

  ///Verify Email Api
  Future verifyOTPApi(BuildContext context, Map<String, dynamic> request);

  ///resend Email Api
  Future resendOTPApi(BuildContext context, Map<String, dynamic> request);

  ///Reset Password Api
  Future resetPasswordApi(BuildContext context, Map<String, dynamic> request);

  ///SignUp Api
  Future signupApi(BuildContext context, Map<String, dynamic> request);

  /// Social Login
  Future socialLoginAPI(BuildContext context, Map<String, dynamic> request);

  ///update device token Api
  Future updateDeviceTokenApi(
      BuildContext context, Map<String, dynamic> request);

  ///logout Api
  Future logoutApi(BuildContext context, Map<String, dynamic> request);

  ///complete profile Api
  Future completeProfileApi(BuildContext context, Map<String, dynamic> request);

  ///Switch Account Api
  Future switchAccountApi(BuildContext context, Map<String, dynamic> request);
}
