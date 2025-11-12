// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:take_profit/ui/drawer/page_structure.dart';
import 'package:take_profit/ui/drawer/revenue_screen.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../utils/const.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../home/recommender_details_screen.dart';
import '../home/signals_details_screen.dart';
import '../recommendation/my_recommendation_screen.dart';
import '../request_analysis/request_analysis_details_screen.dart';
import '../request_analysis/request_analysis_screen.dart';
import 'custom_drawer.dart';


const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Top-level background notification tap handler required by flutter_local_notifications
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (payload != null) {
    // Keep it simple: just log/print. Avoid accessing UI/context from background isolate.
    debugPrint("[Notifications] Background tap payload: $payload");
    // If needed, you could persist this payload for later handling on app resume.
  }
}

class DrawerMenu extends ConsumerStatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends ConsumerState<DrawerMenu> {
  FirebaseMessaging? firebaseMessaging;

  int currentPos = 0;
  DateTime? currentBackPressTime;
  bool isNewReqPopOpened = false;
  final _drawerController = ZoomDrawerController();

  ///Init
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      firebaseMessaging = FirebaseMessaging.instance;
      final drawerWatch = ref.watch(drawerProvider);
      drawerWatch.updateUi();
      await initLocalNotification();
      await initFCMNotification();
    });
  }

  /// Build
  @override
  Widget build(BuildContext context) {
    final drawerWatch = ref.watch(drawerProvider);
    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: const CustomDrawer(),
      mainScreen: const MainScreen(),
      openCurve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 550),
      showShadow: true,
      drawerShadowsBackgroundColor: Constant.colorPrimary,
      slideWidth: MediaQuery.of(context).size.width * (0.70),
      mainScreenScale: 0.35,
      mainScreenTapClose: true,
      borderRadius: 20.r,
      angle: -1,
      menuScreenWidth: double.infinity,
      isRtl: ref.watch(drawerProvider).isEngEnable == true ? false : true,
      moveMenuScreen: false,
      style: DrawerStyle.defaultStyle,
      mainScreenAbsorbPointer: true,
    );
  }

  ///Firebase push notification
  ///Initialize local notification
  Future<void> initLocalNotification() async {
    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
      );

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings("@drawable/ic_app_logo");

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );


    /// Received Notification click event after click on local notification
    await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      // This is the new callback for notification tap
      final String? payload = notificationResponse.payload;
      if (payload != null) {
        showLog("XXXXXXXXXX...........payload......$payload");
        Map<String, dynamic> data = jsonDecode(payload);
        _onReceiveNotification(data);
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  ///Initialize firebase notification
  Future<void> initFCMNotification() async {
    ///Received Notification click event after App killed state
    firebaseMessaging!.getInitialMessage().then((message) {
      if (message != null) {
        RemoteNotification? notification = message.notification;
        showLog(
            "....getInitialMessage.....data...........${json.encode(message.data)}");
        _onReceiveNotification(message.data);
      }
    });

    /// when app is running in foreground so need to fire local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLog(
          "when app is running in foreground so need to fire local notification");
      RemoteNotification? notification = message.notification;
      showLog("Create notification object");

      if (notification != null) {
        showLog(
            "....onMessage.....data...........${json.encode(message.data)}");

        var androidNotificationDetailsNormal = AndroidNotificationDetails(
            channel.id, channel.name,
            channelDescription: channel.description,
            playSound: true,
            importance: Importance.max,
            icon: "@drawable/ic_app_logo",
            color: Constant.clrPrimary);

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: androidNotificationDetailsNormal,
              // iOS: const IOSNotificationDetails(),
            ),
            payload: jsonEncode(message.data));
      }
    });

    ///Received Notification click event after background notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      showLog(
          "....onMessageOpenedApp.....data...........${json.encode(message.data)}");
      _onReceiveNotification(message.data);
    });
  }

  ///Notification tap event method
  _onReceiveNotification(Map<String, dynamic> message) async {
    showLog("_onReceiveNotification Called++++++++++");
    showLog("Push Data - $message");

    var slug = message['slug'];
    String id = message['data_id'];
    String recommenderId = message['recommender_id'] ?? "130";
    showLog("slug $slug");

    /// Trader Slugs Navigation
    if (getUserStatus() == trader) {
      if (slug.toString() ==
          NotificationSlugTrader.signal_update.toString().split(".").last) {
        /// Signal Update Trader
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  signalData: null,
                  signalId: id,
                  seeAllScreen: SeeAllScreen.fromRecommenderDetailsActive,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.signal_close.toString().split(".").last) {
        /// Single Signal Close Trader
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  signalData: null,
                  signalId: id,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.all_signal_close.toString().split(".").last) {
        /// All Signal Close Trader
        Route route = SlideRightPageRoute(
            builder: (context) => RecommenderDetailScreen(
                  recommenderID: recommenderId,
                  notificationTraderSlug:
                      NotificationSlugTrader.all_signal_close,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.new_scenario.toString().split(".").last) {
        /// New Scenario Trader
        Route route = SlideRightPageRoute(
            builder: (context) => RecommenderDetailScreen(
                  recommenderID: recommenderId,
                  notificationTraderSlug: NotificationSlugTrader.new_scenario,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.sub_stop_loss_signal
              .toString()
              .split(".")
              .last) {
        /// Sub Stop Loss Signal Trader
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  signalData: null,
                  signalId: id,
                  seeAllScreen: SeeAllScreen.fromRecommenderDetailsClosed,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.tp_target_trader_alert
              .toString()
              .split(".")
              .last) {
        /// Tp Target trader Alert Trader
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
              recommenderID: recommenderId,
              signalData: null,
              signalId: id,
              seeAllScreen: SeeAllScreen.fromRecommenderDetailsActive,
            ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.tp_target_sub_trader_alert
              .toString()
              .split(".")
              .last) {
        /// Tp Target Sub Trader Alert Trader
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
              recommenderID: recommenderId,
              signalData: null,
              signalId: id,
              seeAllScreen: SeeAllScreen.fromRecommenderDetailsActive,
            ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.request_completed.toString().split(".").last) {
        /// Request Completed Trader
        Route route = SlideRightPageRoute(
            builder: (context) => const RequestAnalysisScreen(
                  notificationTraderSlug:
                      NotificationSlugTrader.request_completed,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.request_refunded.toString().split(".").last) {
        /// Request Refunded Trader
        Route route = SlideRightPageRoute(
            builder: (context) => RequestAnalysisDetailsScreen(
                requestAnalysisData: null,
                notificationSlugTrader: NotificationSlugTrader.request_refunded,
                requestAnalysisId: id),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.signal_create.toString().split(".").last || slug.toString() ==
          NotificationSlugTrader.signal_activate.toString().split(".").last) {
        /// Signal Create Trader
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  signalData: null,
                  signalId: id,
                  seeAllScreen: SeeAllScreen.fromRecommenderDetailsActive,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.update_social_post
              .toString()
              .split(".")
              .last) {
        /// Update Social Post Trader
        Route route = SlideRightPageRoute(
            builder: (context) => RecommenderDetailScreen(
                recommenderID: recommenderId,
                notificationTraderSlug:
                    NotificationSlugTrader.update_social_post),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.tp_target_trader_achieve_alert
              .toString()
              .split(".")
              .last) {
        /// Tp Target Trader Achieve Alert Trader
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  signalData: null,
                  signalId: id,
                  recommenderID: recommenderId,
                  seeAllScreen: SeeAllScreen.fromRecommenderDetailsActive,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugTrader.new_social_post.toString().split(".").last) {
        ///New Social Post Trader
        Route route = SlideRightPageRoute(
            builder: (context) => RecommenderDetailScreen(
                recommenderID: recommenderId,
                notificationTraderSlug: NotificationSlugTrader.new_social_post),
            settings: const RouteSettings());
        Navigator.push(context, route);
      }
    }

    /// Recommender Slugs Navigation
    else {
      if (slug.toString() ==
          NotificationSlugRecommender.stop_loss_signal
              .toString()
              .split(".")
              .last) {
        /// Stop Loss Signal  Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  signalData: null,
                  signalId: id,
                  seeAllScreen: SeeAllScreen.fromRecommenderDetailsClosed,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.tp_target_alert
              .toString()
              .split(".")
              .last) {
        /// Tp Target Alert Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  seeAllScreen: SeeAllScreen.fromMyRecommenderSignalActive,
                  signalData: null,
                  signalId: id,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.signal_close.toString().split(".").last) {
        /// Signal close Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  signalData: null,
                  signalId: id,
                  seeAllScreen: SeeAllScreen.fromRecommenderDetailsClosed,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.new_scenario.toString().split(".").last) {
        /// New Scenario Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => RecommenderDetailScreen(
                  recommenderID: recommenderId,
                  notificationSlugRecommender:
                      NotificationSlugRecommender.new_scenario,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.new_request.toString().split(".").last) {
        /// New Request Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => const RequestAnalysisScreen(
                  notificationSlugRecommender:
                      NotificationSlugRecommender.new_request,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.request_completed
              .toString()
              .split(".")
              .last) {
        ///Request Completed Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => const RequestAnalysisScreen(
                  notificationSlugRecommender:
                      NotificationSlugRecommender.request_completed,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.request_refunded
              .toString()
              .split(".")
              .last) {
        /// Request Refunded Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => RequestAnalysisDetailsScreen(
                requestAnalysisData: null,
                notificationSlugRecommender:
                    NotificationSlugRecommender.request_refunded,
                requestAnalysisId: id),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.payment_recieved
              .toString()
              .split(".")
              .last) {
        /// Payment Received Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => const MyRevenue(
                  isFromDrawer: false,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.tp_target_achieve_alert
              .toString()
              .split(".")
              .last) {
        /// Tp Target Achieve Alert Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => SignalDetailsScreen(
                  signalData: null,
                  signalId: id,
                  recommenderID: recommenderId,
                  seeAllScreen: SeeAllScreen.fromRecommenderDetailsClosed,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.new_trader_sub
              .toString()
              .split(".")
              .last) {
        /// New Trader Sub
        Route route = SlideRightPageRoute(
            builder: (context) => RecommenderDetailScreen(
                  recommenderID: recommenderId,
                ),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.all_signal_close_recommender
              .toString()
              .split(".")
              .last) {
        /// Tp Target Achieve Alert Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => const MyRecommendationSignalScreen(
                isFromBottom: false, selectedSignalIndex: 2),
            settings: const RouteSettings());
        Navigator.push(context, route);
      } else if (slug.toString() ==
          NotificationSlugRecommender.all_signal_close_failed
              .toString()
              .split(".")
              .last) {
        /// All Signal Close Failed Recommender
        Route route = SlideRightPageRoute(
            builder: (context) => const MyRecommendationSignalScreen(
                isFromBottom: false, selectedSignalIndex: 1),
            settings: const RouteSettings());
        Navigator.push(context, route);
      }
    }
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final drawerWatch = ref.watch(drawerProvider);
    return ValueListenableBuilder<DrawerState>(
      valueListenable: ZoomDrawer.of(context)!.stateNotifier,
      builder: (context, state, child) {
        return AbsorbPointer(
          absorbing: state != DrawerState.closed,
          child: child,
        );
      },
      child: const PageStructure(),
    );
  }
}
