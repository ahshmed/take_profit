import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/data_provider/profile/profile_screen_controller.dart';
import 'package:take_profit/framework/data_provider/profile/select_currency_screen_controller.dart';

import 'add_email_screen_controller.dart';
import 'add_social_link_screen_controller.dart';
import 'edit_profile_screen_controller.dart';
import 'edit_subscription_amount_controller.dart';



///Profile Provider
final profileProvider =
    ChangeNotifierProvider((ref) => ProfileScreenController());

/// Select Currency Screen Provider
final selectCurrencyScreenProvider =
    ChangeNotifierProvider((ref) => SelectCurrencyScreenController());

///Edit Profile Provider
final editProfileProvider =
    ChangeNotifierProvider((ref) => EditProfileScreenController());

///Add Email Provider
final addEmailProvider =
    ChangeNotifierProvider((ref) => AddEmailScreenController());

///Add Social Link Provider
final addSocialLinkProvider =
    ChangeNotifierProvider((ref) => AddSocialLinkScreenController());

///Edit Subscription Amount Provider
final editSubscriptionAmountProvider = ChangeNotifierProvider((ref) => EditSubscriptionAmountController());