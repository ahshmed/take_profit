import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/favorite/favorite_controller.dart';
import '../../framework/data_provider/favorite/favorite_provider.dart';
import '../../framework/repository/common/model/crypto_currency_response_model.dart';
import '../../framework/repository/favourite/model/favourite_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';

class FavoriteDetailScreen extends ConsumerStatefulWidget {
  final FavouriteData favData;

  const FavoriteDetailScreen({Key? key, required this.favData})
      : super(key: key);

  @override
  ConsumerState<FavoriteDetailScreen> createState() =>
      _FavoriteDetailScreenState();
}

class _FavoriteDetailScreenState extends ConsumerState<FavoriteDetailScreen>
    with  WidgetsBindingObserver {
  Timer? currencyTimer;

  ///-----Init----
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
      livePriceChangeFunction();
    });
    super.initState();
  }

  ///LifeCycle State
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    showLog('AppLifecycleState :- $state');
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await livePriceChangeFunction(isTimerStart: false);
      showLog("currency timer ${currencyTimer?.isActive}");
    } else if (state == AppLifecycleState.resumed) {
      await livePriceChangeFunction(isTimerStart: true);
      showLog("currency timer ${currencyTimer?.isActive}");
    }
  }

  @override
  void dispose() {
    super.dispose();
    livePriceChangeFunction(isTimerStart: false);
    WidgetsBinding.instance.removeObserver(this);
  }

  ///build widget
  @override
  Widget build(BuildContext context) {
    final favoriteWatch = ref.watch(favoriteProvider);
    // ignore: unused_local_variable
    final darkModeWatch = ref.watch(darkProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            titleColor: Constant.clrBlackNew,
            isTitleCenter: true,
            title: getLocalValue("Key_CurrencyDetail"),
            appBar: AppBar(backgroundColor: Constant.clrWhiteNew, toolbarHeight: 64.h),
            isDrawer: false,
            action: [
              IconButton(
                  onPressed: () {
                    _manageFavourite(
                        favoriteWatch, widget.favData.currencyId ?? "");
                  },
                  icon: CommonImageAsset(
                    strIcon: Constant.icLike,
                    width: 35.h,
                    height: 35.h,
                    boxFit: BoxFit.cover,
                  )),
              SizedBox(
                width: 12.w,
              ),
            ],
          ),
          body: NoInternetBuilder(child: bodyWidget()),
        ),
        DialogProgressBar(isLoading: favoriteWatch.isLoading)
      ],
    );
  }

  ///body widget
  Widget bodyWidget() {
    return Consumer(builder: (context, ref, child) {
      final commonWatch = ref.watch(commonProvider);
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CacheImage(
              imageURL: widget.favData.logo ?? "",
              height: 144.h,
              width: 144.h,
              contentMode: BoxFit.contain,
            ).paddingOnly(top: 10.h),
            SizedBox(
              height: 20.h,
            ),
            Text(
              widget.favData.name ?? "",
              style: TextStyles.txtMedium24
                  (context).copyWith(fontSize: 22.sp, color: Constant.clrWhiteBlackByTheme(context)),
            ),
            Text(
              widget.favData.symbol ?? "",
              style: TextStyles.txtMedium18
                  (context).copyWith(color: Constant.clrWhiteBlackNewByTheme(context)),
            ),
            SizedBox(
              height: 32.h,
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Constant.clrBlackOrigin : Constant.clrWhite,
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                children: [
                  Text(
                    getLocalValue("Key_LivePrice"),
                    style: TextStyles.txtMedium14(context).copyWith(
                        fontSize: 13.sp, color: Constant.clrWhiteBlackNewByTheme(context)),
                  ),
                  SizedBox(
                    height: 7.h,
                  ),
                  Text(
                    (widget.favData.price ?? "") +
                        " " +
                        (widget.favData.currencyCode ?? ""),
                    style: TextStyles.txtMedium18(context).copyWith(color: Constant.clrPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Manage Favourite List
  Future _manageFavourite(
      FavoriteScreenController favoriteWatch, String id) async {
    if (isInternetConnectionOn) {
      await favoriteWatch.manageFavouriteApi(context, id);

      if (favoriteWatch.manageFavouriteResponseModel?.status ==
          ApiEndPoints.apiStatus_200) {
        Navigator.pop(context, true);
      }
    }
  }

  /// Get Crypto Currency Data Live
  Future<void> getCryptoCurrencyData(
    CommonController commonWatch,
    FavoriteScreenController favoriteWatch,
  ) async {
    if (isInternetConnectionOn) {
      if (mounted) {
        // await commonWatch.getCryptoCurrencyAPI(context);
      }
      if (commonWatch.cryptoCurrencyResponseModel.data != null ||
          commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
        /// Set Price in Main List Every secondsDelayForRealTimeAPICall seconds
        CryptoCurrencyData? currencyData = commonWatch
            .cryptoCurrencyResponseModel.data
            ?.where((element) => element.id.toString() == widget.favData.apiCurrencyId)
            .first;
        if (currencyData != null) {
          widget.favData.price = currencyData.priceUsd;
        }
      }
    }
  }

  /// Live Price Changes
  Future<void> livePriceChangeFunction({bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      if (isTimerStart) {
        final commonWatch = ref.watch(commonProvider);
        final favoriteWatch = ref.watch(favoriteProvider);

        /// Live Price Api Call every secondsDelayForRealTimeAPICall seconds
        currencyTimer =
            Timer.periodic(Duration(milliseconds: secondsDelayForRealTimeAPICall),
                (currencyTimer) async {
          if (!favoriteWatch.isLoading && !favoriteWatch.isLoadingPagination) {
            await getCryptoCurrencyData(commonWatch, favoriteWatch);
          }
        });
        commonWatch.updateUi();
      } else {
        /// cancel Timer
        if (currencyTimer != null) {
          currencyTimer?.cancel();
        }
      }
    }
  }
}
