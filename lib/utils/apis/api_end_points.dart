import 'dart:io';

enum Environment { local,staging, qa, production, test }

class ApiEndPoints {
  ///Server Environment
  static Environment environment = Environment.qa;

  ///Server URL
  static String serverUrl() {
    switch (environment) {
      //added by a.shaban 2025 oct 17 -- Environment.local
      case Environment.local:
        // Choose per platform and allow override via --dart-define=API_BASE_URL
        final override = const String.fromEnvironment('API_BASE_URL');
        final host = override.isNotEmpty
            ? override
            : (Platform.isAndroid
                ? 'http://10.0.2.2:8000' // Android emulator loopback to host
                : 'http://127.0.0.1:8000'); // iOS simulator loopback to host
        final url = '$host/api/customer';
        // Log selected base URL once to help diagnose Android emulator vs device
        // ignore: avoid_print
        final platform = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : Platform.operatingSystem);
        final overrideInfo = override.isNotEmpty ? ' (override via API_BASE_URL)' : '';
        print('[ApiEndPoints] Platform=$platform Using base URL: ' + url + overrideInfo);
        if (Platform.isAndroid && override.isEmpty) {
          // Guidance for physical devices when no override is provided
          // ignore: avoid_print
          print('[ApiEndPoints] Tip: On a physical Android device, 10.0.2.2 will NOT reach your host. Run with --dart-define=API_BASE_URL=http://<YOUR_LAN_IP>:8000 or use `adb reverse tcp:8000 tcp:8000` and 127.0.0.1.');
        }
        return url;
      case Environment.staging:
        return "http://cloud1.kodyinfotech.com:7000/take-profit/public/api/customer";
      case Environment.qa:
        return "https://test.tprofit.io/api/customer";
      case Environment.production:
        return "https://admin.tprofit.io/api/customer";
      case Environment.test:
        return "https://tp.vroad.co/public/api/customer";
    }
  }

  /// Base URL
  static String strBaseUrl = serverUrl();

  /*
  * ----- Api status
  * */
  static int apiStatus_200Int = 200; //success
  static String apiStatus_200 = "200"; //success
  static String apiStatus_201 = "201"; //success
  static String apiStatus_202 = "202"; //success for static page
  static String apiStatus_203 = "203"; //success
  static String apiStatus_205 = "205"; // for remaining step 2
  static String apiStatus_401 = "401"; //Invalid data
  static String apiStatus_404 = "404"; //Invalid data

  /*
  * ---- Static data to pass in api's
  * */

  /*
  * ----- End Points
  * */

  ///Common API
  static String countryList = strBaseUrl + "/country_list";
  static String subscriptionPackageList = strBaseUrl + "/subscription_package_list";

  /// Auth
  static String signup = strBaseUrl + '/signup';
  static String verifyOTP = strBaseUrl + '/verify_otp';
  static String resendOTP = strBaseUrl + '/resend_otp';
  static String login = strBaseUrl + '/login';
  static String socialLogin = strBaseUrl + '/social_login';
  static String forgotPassword = strBaseUrl + '/forgot_password';
  static String resetPassword = strBaseUrl + '/reset_password';
  static String logout = strBaseUrl + '/logout';
  static String updateDeviceToken = strBaseUrl + '/update_device_token';
  static String switchAccount = strBaseUrl + '/switch_account';

  /// CMS
  static String cmsPage = strBaseUrl + '/cms_content';

  /// Profile
  static String completeProfile = strBaseUrl + '/complete_account';
  static String profile = strBaseUrl + '/profile';
  static String updateProfile = strBaseUrl + '/update_profile';
  static String updateMobileNumber = strBaseUrl + '/update_mobile_number';
  static String verifyMobileNumber = strBaseUrl + '/verify_mobile_number';
  static String updateEmail = strBaseUrl + '/update_email';
  static String verifyEmail = strBaseUrl + '/verify_email';
  static String resendEmailOtp = strBaseUrl + '/resend_email_otp';
  static String changePassword = strBaseUrl + '/change_password';
  static String deleteAccount = strBaseUrl + '/delete_account';
  static String updateSettings = strBaseUrl + '/update_settings';

  /// Favourite
  static String favouriteList = strBaseUrl + '/favourite_list';
  static String manageFavourite = strBaseUrl + '/manage_favourites';

  /// Support
  static String supportApi = strBaseUrl + '/contact_us';

  /// master
  static String currencyListApi = strBaseUrl + '/currency_list';
  static String currencyDetailApi = strBaseUrl + '/currency_details';
  static String searchCurrencyApi = strBaseUrl + '/currency_search';

  /// Home
  static String trendingListApi = strBaseUrl + '/trending_recommender_list';
  static String recommenderDetailApi = strBaseUrl + '/recommender_details';
  static String recommenderListApi = strBaseUrl + '/home_recommender_list';

  ///signal
  static String createSignalApi = strBaseUrl + '/new_signal';
  static String signalListApi = strBaseUrl + '/signal_list';
  static String allSignalListApi = strBaseUrl + '/all_signal_list';
  static String editSignalApi = strBaseUrl + '/edit_signal';
  static String closeSignalApi = strBaseUrl + '/close_signal';
  static String signalDetails = strBaseUrl + '/signal_details';
  static String enableSignalNotification = strBaseUrl + '/signal_enable_notification';

  /// Closed All Signals
  static String closeAllSignal = strBaseUrl + "/close_all_signal";

  /// Social
  static String socialList = strBaseUrl + '/social_list';
  static String addNewSocialApi = strBaseUrl + '/new_social';
  static String editSocialApi = strBaseUrl + '/edit_social';

  /// BTC Scenario
  static String scenarioList = strBaseUrl + '/scenario_list';
  static String newScenario = strBaseUrl + '/new_scenario';
  static String editScenario = strBaseUrl + '/edit_scenario';

  /// Subscription
  static String subscriptionList(int pageNo) =>
      strBaseUrl + "/subscription_list?page=$pageNo";
  static String cancelSubscription = strBaseUrl + "/unsubscribe_package";
  static String recommenderSubscriptionPackages =
      strBaseUrl + "/recommender_subscription_packages";
  static String revenue = strBaseUrl + "/revenue";

  ///Payment
  static String initiatePaymentForSubscription =
      strBaseUrl + "/initiate_payment";
  static String initiatePaymentForRequestAnalysis =
      strBaseUrl + "/initiate_request_analysis_payment";

  /// Request analysis
  static String requestAnalysisList = strBaseUrl + "/request_analysis_list";
  static String newRequestAnalysis = strBaseUrl + "/new_request_analysis";
  static String completeRequestAnalysis =
      strBaseUrl + "/complete_request_analysis";
  static String requestAnalysisDetails =
      strBaseUrl + "/request_analysis_details";

  /// Notification
  static String notificationList = strBaseUrl + "/notification_list";
  static String notificationCount = strBaseUrl + "/notification_count";
  static String notificationDelete = strBaseUrl + "/delete_notification";

  /// Crypto Currency
  static String cryptoCurrency = strBaseUrl + "/setting_list";

  // static String cryptoCurrency = "https://api.takeproft.com/assets.php?passcode=6f4ad177a041e0453c6e5f178c3e769c3e2ced3f4946654a11ebdadfcbe0f508";

  /// Home Recommender
  static String homeRecommenderDetails = strBaseUrl + "/home_recommender_details";

  /// Crypto Currency
  static String checkForUpdate = strBaseUrl + "/versions";
}
