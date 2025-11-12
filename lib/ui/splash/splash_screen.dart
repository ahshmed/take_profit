import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:take_profit/utils/theme_const.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import 'package:video_player/video_player.dart';

import '../select_market/select_market_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>  {
  bool _videoReady = false;
  bool _navigated = false; // ensure we only navigate once
  late VideoPlayerController _videoController;
  
  void _onVideoEnd() async {
    // Don’t navigate if an update dialog is required/visible
    final commonWatch = ref.read(commonProvider);
    if (commonWatch.askForUpdate) {
      return; // Update UI will be shown; user will update or skip
    }

    if (_navigated) return;
    _navigated = true;

    // Reuse your existing flow but add a 3s delay after video end
    await Future.delayed(const Duration(seconds: 1));
    await goNext(skipDelay: true);
  }
  FirebaseMessaging? firebaseMessaging;

  ///Firebase configuration methods
  Future<void> firebaseConfiguration() async {
    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await firebaseMessaging!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    /// Prompts the user for notification permissions.
    await firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    firebaseMessaging!.getToken().then((token) {
      showLog("FCM token $token");
      print("FCM token $token");
      print("user Access Token \n ${getUserAccessToken()}");
      saveLocalData(KEY_FCM_DEVICE_TOKEN, token);
    });
  }

  @override
  void dispose() {
    try {
      _videoController.dispose();
    } catch (_) {}
    super.dispose();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.clrWhite,
      body: widgetBody(),
    );
  }

  ///Init State
  @override
  void initState() {
    super.initState();
    // Prepare the video immediately
    _videoController = VideoPlayerController.asset('assets/video/splash_video.mp4')
      ..setVolume(0.0)
      ..setLooping(false);
    _videoController.initialize().then((_) {
      if (!mounted) return;
      setState(() => _videoReady = true);
      _videoController.play();

      // When the video finishes, try to go next (if no update UI is being shown)
      _videoController.addListener(() {
        final v = _videoController.value;
        if (v.isInitialized &&
            !v.isPlaying &&
            v.position >= v.duration &&
            !_navigated) {
          _onVideoEnd();
        }
      });
    });

    // Post-frame: perform update check
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final commonWatch = ref.read(commonProvider);
      // Temporarily bypass app update checks
      commonWatch.updateAskForUpdate(false);
      // If the video already ended, proceed
      if (_videoReady) {
        final v = _videoController.value;
        if (v.isInitialized &&
            !v.isPlaying &&
            v.position >= v.duration &&
            !_navigated) {
          _onVideoEnd();
        }
      }
    });
  }
  

  Future<void> goNext({bool skipDelay = false}) async {
    final commonWatch = ref.watch(commonProvider);
    String userToken = getUserAccessToken();
    firebaseMessaging = FirebaseMessaging.instance;
    firebaseConfiguration();

    showLog("User token $userToken");
    int delayDuration = skipDelay ? 0 : 2000; // 2 Seconds by default

    if (isInternetConnectionOn) {
      // For Get Url For Realtime Currency Price
      await commonWatch.getUrlForCryptoCurrencyPrice(context);
    }

    // Called when User Token is not Empty
    if (userToken != "") {
      delayDuration = skipDelay ? 0 : 1500; // 1.5 Seconds

      // Update User Token
      final loginWatch = ref.watch(signInProvider);
      if (isInternetConnectionOn) {
        await loginWatch.updateDeviceTokenApi(context);
      }

      // For Displaying Profile Data in Drawer
      final profileWatch = ref.watch(profileProvider);
      if (isInternetConnectionOn) {
        await profileWatch.profileAPI(context);
        saveLocalData(KEY_USER_STATUS,
            profileWatch.profileDetailResponseModel?.data?.userType);
      }
    }

    Future.delayed(Duration(milliseconds: delayDuration), () {
      // UPDATED: Check if first time user and navigate accordingly
      if (isFirstTimeUser()) {
        // First time user - show ChooseMarketScreen
        Route route = SlideRightPageRoute(
            builder: (context) => const SelectMarketScreen(),
            settings: const RouteSettings());
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
      } else {
        // Returning user - use existing navigation
        setNavigationRedirection(context);
      }
    });
    if (getIsIOSPlatform()) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      iosVersion = int.parse((iosInfo.systemVersion ?? "").split(".").first);
    }
  }

  /// widget body
  Widget widgetBody() {
    final commonWatch = ref.watch(commonProvider);
    return Stack(
      children: [
        commonWatch.askForUpdate
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            50.verticalSpace,
                            CommonImageAsset(
                              strIcon: Constant.icLogoDark,
                              width: 200.h,
                              boxFit: BoxFit.contain,
                            ),
                            50.verticalSpace,
                            SizedBox(
                              height: 200.h,
                              child: SvgPicture.asset(Constant.icUpdate, width: 200.h),
                            ),
                            22.verticalSpace,
                            Text(
                              commonWatch.versionUpdateStatus ==
                                      VersionUpdateStatus.required
                                  ? getLocalValue("Key_Update_Required")
                                  : getLocalValue("Key_Update_Optional"),
                              style: TextStyles.txtRegular16(context).copyWith(
                                  color: Constant.clrWhiteBlackByTheme(context), height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    CommonButton(
                      label: getLocalValue("Key_Update"),
                      onTap: () async {
                        await launchUrl(
                          Uri.parse(getIsIOSPlatform()
                              ? "https://apps.apple.com/app/id6471070700"
                              : "https://play.google.com/store/apps/details?id=com.takeproft.trader"),
                          mode: LaunchMode.externalApplication,
                        );
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                      bgColor: Constant.clrPrimary,
                      labelColor: Constant.clrWhite,
                    ),
                    16.verticalSpace,
                    if (commonWatch.versionUpdateStatus ==
                        VersionUpdateStatus.optional)
                      InkWell(
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          commonWatch.updateAskForUpdate(false);
                          saveLocalData(
                              KEY_SKIP_VERSION, commonWatch.versionNumber);
                          goNext();
                        },
                        child: Text(
                          getLocalValue("Key_Skip_1"),
                          style: TextStyles.txtRegular16
                              (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      height: 28.h,
                    ),
                  ],
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (_videoReady)
                    Center(
                      child: AspectRatio(
                        aspectRatio: (_videoController.value.isInitialized && _videoController.value.aspectRatio > 0)
                            ? _videoController.value.aspectRatio
                            : (9 / 16),
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  else
                    Container(color: Constant.clrWhite),

                ],
              ),
      ],
    );
  }
}
