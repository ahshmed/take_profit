import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:take_profit/ui/home/home_screen.dart';
import 'package:take_profit/ui/splash/splash_screen.dart';
import 'package:take_profit/utils/const.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:take_profit/utils/dark_theme_style.dart';
import 'package:take_profit/utils/darkmode/dark_provider.dart';
import 'package:take_profit/utils/theme_const.dart';

/// To verify things are working, check out the native platform logs.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  showLog('Handling a background message ${message.messageId}');
  RemoteNotification? notification = message.notification;
  showLog(
      "..._firebaseMessagingBackgroundHandler.....notification.......body....${notification?.body ?? ""}");
  showLog(
      "...._firebaseMessagingBackgroundHandler.....notification.......title....${notification?.title ?? ""}");
}

///Set Firebase Options
FirebaseOptions setFirebaseOption() {
  if (getIsIOSPlatform()) {
    return const FirebaseOptions(
        apiKey: 'AIzaSyDLj3SuKMOl-0oOKP4bQ_hUlpFCM9_41nc',
        appId: '1:880001631618:ios:79495810b1cbb188af7b9b',
        messagingSenderId: '880001631618',
        projectId: 'takeproft-408d5');
  } else {
    return const FirebaseOptions(
        apiKey: 'AIzaSyBeBZqewLM562cfGkaRmK867LeGwkgQgC4',
        appId: '1:880001631618:android:182c92f628df3b84af7b9b',
        messagingSenderId: '880001631618',
        projectId: 'takeproft-408d5');
  }
}

Future<void> requestTrackingPermission() async {
  final status = await AppTrackingTransparency.requestTrackingAuthorization();
  if (status == TrackingStatus.authorized) {
    print("Tracking authorized");
  } else {
    print("Tracking denied or restricted");
  }
}

/*final appsFlyer = AppsflyerSdk(AppsFlyerOptions(
  afDevKey: "dev_key_placeholder",
  appId: '123456789',
  showDebug: true,
));*/

/*void trackEvent(String eventName, Map<String, dynamic> parameters) {
  try{
    appsFlyer.setCustomerUserId(getUserEntityId());
  } catch(_){}
  appsFlyer.logEvent(eventName, parameters);
}*/

Timer? currencyTimerHome;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: setFirebaseOption());
  await requestTrackingPermission();
  //await appsFlyer.initSdk();
  await EasyLocalization.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('userBox');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,

        /// Color for Android
        statusBarBrightness: Brightness.light,

        /// Dark == white status bar -- for IOS.
        statusBarIconBrightness: Brightness.dark

        /// color for Android
        ),
  );
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const <Locale>[
          Locale('ar'),
          Locale('en'),
        ],
        useOnlyLangCode: true,
        startLocale: const Locale('ar'),
        path: 'lang',
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // AppTranslationsDelegate _newLocaleDelegate = const AppTranslationsDelegate(newLocale: Locale("en"));

  /// init method
  @override
  void initState() {
    super.initState();
    // _newLocaleDelegate = const AppTranslationsDelegate(newLocale: Locale("en"));
    // application.onLocaleChanged = onLocaleChange;
    // onLocaleChange(const Locale("en", ""));
    // getSelectedLanguage(() => {});

    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        //final darkModeController = ref.watch(darkProvider);

        ///Dark Mode Object
        //var brightness = SchedulerBinding.instance.window.platformBrightness;
        // bool isDarkMode = getIsAppThemeDark() ?? //brightness == Brightness.dark;
        // false;
        //darkModeController.updateIsDarkMode(false, isDarkMode);
      },
    );
  }

  /// dispose method
  @override
  void dispose() {
    Hive.box('userBox').compact();
    Hive.close();
    currencyTimerHome?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeController = ref.watch(darkProvider);
    final isDarkMode = darkModeController.darkTheme;

    debugPrint("=== MyApp rebuilding with dark mode: $isDarkMode ===");

    /// Orientation Portrait
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    /// Theme For Status Bar & Navigation Bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,

          /// Color for Android
          systemNavigationBarColor: isDarkMode ? Constant.clrDarkBlue : Constant.clrWhite,
          systemNavigationBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,

          /// Color for iOS
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark

          /// Color for Android
          ),
    );

    return ScreenUtilInit(
      designSize: const Size(375, 815),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Constant.appName,
        navigatorKey: NavigationService.navigatorKey,
        // set property
        //theme: ThemeData(

          //use dynamic theme
          theme:Styles.themeData(false),
          darkTheme: Styles.themeData(true),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // highlightColor: Constant.clrTransparent,
            // splashColor: Constant.clrTransparent,
            // // buttonTheme: ButtonThemeData(buttonColor: clrPrimary,),
            // fontFamily: getAppLanguage() == 'en' ? "Gilroy" : "Almarai",
        //),
        // theme: Styles.themeData(
        //   darkModeWatch.darkTheme,
        //   context,
        // ),
        supportedLocales: EasyLocalization.of(context)!.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        locale: EasyLocalization.of(context)!.locale,
        home: const SplashScreen(),
      ),
    );
  }
}
