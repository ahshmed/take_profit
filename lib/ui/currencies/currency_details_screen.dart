// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/favorite/favorite_controller.dart';
import '../../framework/data_provider/favorite/favorite_provider.dart';
import '../../framework/data_provider/home/currencies_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/repository/common/model/crypto_currency_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';

class CurrencyDetailScreen extends ConsumerStatefulWidget {
  final SeeAllScreen? seeAllScreen;
  final String currencyID;

  const CurrencyDetailScreen(
      {Key? key, this.seeAllScreen, required this.currencyID})
      : super(key: key);

  @override
  ConsumerState<CurrencyDetailScreen> createState() =>
      _CurrencyDetailScreenState();
}

class _CurrencyDetailScreenState extends ConsumerState<CurrencyDetailScreen>
    with WidgetsBindingObserver {
  Timer? currencyTimer;

  ///-----Init----
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      WidgetsBinding.instance.addObserver(this);
      final currenciesWatch = ref.watch(currenciesProvider);
      currenciesWatch.clearCurrencyData();
      currenciesWatch.updateIsLoading(true);
      await currencyDetailAPI(currenciesWatch);
      await livePriceChangeFunction();
      currenciesWatch.updateIsLoading(false);
    });
    super.initState();
  }

  ///LifeCycle State
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    showLog('AppLifecycleState :- $state');
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await livePriceChangeFunction(isTimerStart: false);
      showLog("currency timer ${currencyTimer?.isActive}");
    } else if (state == AppLifecycleState.resumed) {
      await livePriceChangeFunction();
      showLog("currency timer ${currencyTimer?.isActive}");
    }
  }

  @override
  void dispose() {
    livePriceChangeFunction(isTimerStart: false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///build widget
  @override
  Widget build(BuildContext context) {
    final currenciesWatch = ref.watch(currenciesProvider);
    final favoriteWatch = ref.watch(favoriteProvider);

    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, true);
            return true;
          },
          child: Consumer(builder: (context, ref, child) {
            final commonWatch = ref.watch(commonProvider);
            return Scaffold(
              backgroundColor: Constant.clrBasicByTheme(context),
              appBar: CommonAppBar(
                isTitleCenter: false,
                titleTextStyle: TextStyles.txtMedG16(context),
                onPress: () {
                  Navigator.pop(context, true);
                },
                title: "${currenciesWatch.currencyDetailResponseModel?.data?.name ?? ''} ${currenciesWatch.currencyDetailResponseModel?.data?.symbol ?? ''}",
                appBar: AppBar(
                    backgroundColor: Constant.clrBasicByTheme(context), toolbarHeight: 64.h),
                isDrawer: false,
                // action: [
                //   Visibility(
                //     visible: getUserStatus() == guest ? false : true,
                //     child: IconButton(
                //       onPressed: () {
                //         _manageFavourite(
                //             favoriteWatch,
                //             currenciesWatch
                //                 .currencyDetailResponseModel?.data?.id ??
                //                 "",
                //             currenciesWatch);
                //       },
                //       icon: CommonImageAsset(
                //         strIcon: currenciesWatch.currencyDetailResponseModel
                //             ?.data?.isFavourite ==
                //             "1"
                //             ? Constant.icFavN
                //             : Constant.icUnFavN,
                //         width: 21.62.h,
                //         height: 19.h,
                //         boxFit: BoxFit.contain,
                //       ),
                //     ),
                //   ),
                //   SizedBox(
                //     width: 12.w,
                //   ),
                // ],
              ),
              body: NoInternetBuilder(
                child: (favoriteWatch.isLoading || currenciesWatch.isLoading)
                    ? const Offstage()
                    : bodyWidget(),
              ),
            );
          }),
        ),
        DialogProgressBar(
            isLoading: currenciesWatch.isLoading || favoriteWatch.isLoading)
      ],
    );
  }

  ///body widget
  Widget bodyWidget() {
    final currenciesWatch = ref.watch(currenciesProvider);
    final currencyDetailData = currenciesWatch.currencyData;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // First Chart Image
            Container(
              width: 343.h,
              height: 241.h,
              decoration: BoxDecoration(
                color: isDarkMode ? Constant.clrBlackOrigin : Constant.clrWhite,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  'assets/images/image1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 20.h),
             Row(children: [

               // Live Price Section
               Text(
                 getLocalValue("Key_LivePrice"),
                 style: TextStyles.txtSemiBoldG20(context).copyWith(
                   fontWeight: Constant.fwRegular,
                   color: Constant.clrWhiteBlackByTheme(context),
                 ),
               ),
               SizedBox(width: 8.h),

               Text(
                 "${currencyDetailData?.price ?? ""} ${currencyDetailData?.currencyCode ?? ""}",
                 style: TextStyles.txtRegG14(context).copyWith(
                   fontSize: 16.h,
                   color: Constant.clrWhiteBlackByTheme(context),
                 ),
               ),

             ],),

            SizedBox(height: 24.h),

            // Second Chart Image
            Container(
              width: double.infinity,
              height: 250.h,
              decoration: BoxDecoration(
                color: isDarkMode ? Constant.clrBlackOrigin : Constant.clrWhite,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.asset(
                  'assets/images/image2.png',
                  fit: BoxFit.contain,
                  width: 345,
                  height: 171,
                ),
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Currency list API Call
  Future<void> currencyDetailAPI(
      CurrenciesScreenController currenciesWatch) async {
    if (isInternetConnectionOn) {
      await currenciesWatch.currencyDetailAPI(context, widget.currencyID);
    }
  }

  /// Get Crypto Currency Data Live
  Future<void> getCryptoCurrencyData(CommonController commonWatch,
      CurrenciesScreenController currenciesWatch) async {
    if (isInternetConnectionOn) {
      if (mounted) {
        // await commonWatch.getCryptoCurrencyAPI(context);
      }
      if (commonWatch.cryptoCurrencyResponseModel.data != null ||
          commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
        /// Set Price in Main List Every  secondsDelayForRealTimeAPICall seconds
        CryptoCurrencyData? currencyData = commonWatch
            .cryptoCurrencyResponseModel.data
            ?.where((element) =>
        element.id.toString() ==
            currenciesWatch.currencyData?.apiCurrencyId)
            .first;
        if (currencyData != null) {
          currenciesWatch.currencyData?.price = currencyData.priceUsd;
        }
      }
    }
  }

  /// Live Price Changes
  Future<void> livePriceChangeFunction({bool isTimerStart = true}) async {
    if (isInternetConnectionOn) {
      if (isTimerStart) {
        final commonWatch = ref.watch(commonProvider);
        final currenciesWatch = ref.watch(currenciesProvider);

        /// Live Price Api Call every secondsDelayForRealTimeAPICall seconds
        currencyTimer = Timer.periodic(
            Duration(milliseconds: secondsDelayForRealTimeAPICall),
                (currencyTimer) async {
              if (!currenciesWatch.isLoadingForPagination &&
                  !currenciesWatch.isLoading) {
                await getCryptoCurrencyData(commonWatch, currenciesWatch);
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

  /// Manage Favourite List
  Future _manageFavourite(FavoriteScreenController favoriteWatch, String id,
      CurrenciesScreenController currenciesWatch) async {
    if (isInternetConnectionOn) {
      await favoriteWatch.manageFavouriteApi(context, id);

      if (favoriteWatch.manageFavouriteResponseModel?.status ==
          ApiEndPoints.apiStatus_200) {
        currencyDetailAPI(currenciesWatch);
      }
    }
  }
}