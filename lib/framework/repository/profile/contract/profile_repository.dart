

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class ProfileRepository {

  ///Profile API
  Future getProfileDetailAPI(BuildContext context);

  /// Update Personal Details
  Future updatePersonalDetailAPI(BuildContext context, FormData formData);

  /// Update Social Links
  Future updateSocialLinksAPI(BuildContext context, Map<String, dynamic> request);

  /// Update Mobile Number
  Future updateMobileAPI(BuildContext context, Map<String, dynamic> request);

  /// verify Mobile Number
  Future verifyMobileNumberAPI(BuildContext context, Map<String, dynamic> request);

  /// Update Email Address
  Future updateEmailAddressAPI(BuildContext context, Map<String, dynamic> request);

  /// Verify Email Address
  Future verifyEmailAddressAPI(BuildContext context, Map<String, dynamic> request);

  /// Resend Email OTP
  Future resendEmailOTPAPI(BuildContext context, Map<String, dynamic> request);

  /// Change Password
  Future changePasswordAPI(BuildContext context, Map<String, dynamic> request);

  /// Delete Account API
  Future deleteAccountAPI(BuildContext context);

  /// Update Settings
  Future updateSettingsAPI(BuildContext context, Map<String, dynamic> request);

}