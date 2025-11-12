import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/data_provider/auth/sign_in_screen_controller.dart';
import 'package:take_profit/framework/data_provider/auth/sign_up_bank_screen_controller.dart';
import 'package:take_profit/framework/data_provider/auth/sign_up_screen_controller.dart';
import 'package:take_profit/framework/data_provider/auth/sign_up_subscription_amount_screen_controller.dart';

import 'create_password_screen_controller.dart';
import 'duration_controller.dart';
import 'forgot_password_screen_controller.dart';
import 'otp_screen_controller.dart';


// /// Role Selection Screen Provider
// final roleSelectionProvider = ChangeNotifierProvider.autoDispose(
//     (ref) => RoleSelectionScreenController());

/// Sign in screen Provider
final signInProvider =
    ChangeNotifierProvider((ref) => SignInScreenController());

/// Forgot Password screen Provider
final forgotPasswordScreenProvider =
    ChangeNotifierProvider((ref) => ForgotPasswordScreenController());

/// OTP Screen Provider
final otpScreenProvider =
    ChangeNotifierProvider((ref) => OTPScreenController());

/// Create Password Screen Provider
final createPasswordScreenProvider =
    ChangeNotifierProvider((ref) => CreatePasswordScreenController());

/// Sign Up Screen Provider
final signUpScreenProvider =
    ChangeNotifierProvider((ref) => SignUpScreenController());

/// Sign Up Bank details Screen Provider
final signUpBankDetailScreenProvider =
    ChangeNotifierProvider((ref) => SignUpBankDetailsScreenController());

/// Sign Up Subscription Amount Screen Provider
final signUpSubscriptionAmountProvider =
    ChangeNotifierProvider((ref) => SignUpSubscriptionAmountScreenController());

final durationProvider = ChangeNotifierProvider((ref) => DurationController());
