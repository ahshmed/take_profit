// ignore_for_file: unused_local_variable
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/favorite/favorite_controller.dart';
import '../../framework/data_provider/favorite/favorite_provider.dart';
import '../../framework/repository/common/model/crypto_currency_response_model.dart';
import '../../framework/repository/favourite/model/favourite_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../currencies/currencies_screen.dart';
import 'favorite_detail_screen.dart';


class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen>
    with  WidgetsBindingObserver {
  Timer? currencyTimer;

  ScrollController scrollController = ScrollController();

  ///-----Init----
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      WidgetsBinding.instance.addObserver(this);
      final favoriteWatch = ref.watch(favoriteProvider);
      favoriteWatch.clearProvider();
      await _getFavouriteList(favoriteWatch);
      await livePriceChangeFunction();

      scrollController.addListener(() async {
        if (favoriteWatch.isHasMorePage) {
          if (scrollController.position.maxScrollExtent ==
              scrollController.position.pixels) {
            if ((int.parse(favoriteWatch
                        .favouriteResponseModel?.data?.pageNumber
                        ?.toString() ??
                    "0") !=
                int.parse(favoriteWatch.favouriteResponseModel?.data?.totalPage
                        .toString() ??
                    "0"))) {
              await _getFavouriteList(favoriteWatch);
            }
          }
        }
      });
    });
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
    final darkModeWatch = ref.watch(darkProvider);
    final drawerWatch = ref.watch(drawerProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue("Key_MyFavorite"),
            isTitleCenter: true,
            appBar: AppBar(backgroundColor: Constant.clrWhiteNew, toolbarHeight: 64.h),
            isDrawer: true,
          ),
          body: NoInternetBuilder(child: bodyWidget(favoriteWatch)),
        ),
        DialogProgressBar(isLoading: favoriteWatch.isLoading)
      ],
    );
  }

  ///body widget
  Widget bodyWidget(FavoriteScreenController favoriteWatch) {
    return (favoriteWatch.isLoading &&
            favoriteWatch.favouriteResponseModel?.data == null)
        ? Container()
        : (favoriteWatch.arrFavourite?.isEmpty == true)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmptyStateWidget(emptyStateFor: EmptyState.noFavouriteFound)
                      .paddingOnly(bottom: 20.h),
                  CommonButton(
                          width: 140.w,
                          height: 40.h,
                          label: "Key_AddFavourite".localized,
                          onTap: () {
                            Route route = SlideRightPageRoute(
                                builder: (context) =>
                                    const CurrenciesScreen(isDrawer: false),
                                settings: const RouteSettings());

                            Navigator.push(context, route).then((value) {
                              if (value != null) {
                                if (value != null && value == true) {
                                  _getFavouriteList(favoriteWatch,
                                      removeOld: true);

                                  livePriceChangeFunction();
                                }
                              }
                            });
                          },
                          bgColor: Constant.clrPrimary,
                          labelColor: Constant.clrWhite)
                      .paddingOnly(bottom: 40.h)
                ],
              )
            : Consumer(builder: (context, ref, child) {
                final commonWatch = ref.watch(commonProvider);
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: favoriteWatch.arrFavourite?.length,
                          controller: scrollController,
                          padding: EdgeInsets.only(
                              bottom:
                                  (MediaQuery.of(context).padding.bottom + 62)
                                      .h),
                          itemBuilder: (context, index) {
                            FavouriteData _dataObj =
                                favoriteWatch.arrFavourite![index];

                            return InkWell(
                              onTap: () async {
                                livePriceChangeFunction(isTimerStart: false);
                                Route route = SlideRightPageRoute(
                                  builder: (context) =>
                                      FavoriteDetailScreen(favData: _dataObj),
                                  settings: const RouteSettings(),
                                );
                                await Navigator.of(context)
                                    .push(route)
                                    .then((value) {
                                  if (value != null && value == true) {
                                    _getFavouriteList(favoriteWatch,
                                        removeOld: true);

                                    livePriceChangeFunction();
                                  }
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: Card(
                                  color: Constant.clrDarkByScaffoldTheme(context),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  elevation: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(15.w),
                                    child: Row(
                                      children: [
                                        CacheImage(
                                          imageURL: _dataObj.logo ?? "",
                                          height: 45.h,
                                          width: 45.h,
                                          contentMode: BoxFit.fill,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// Icon, Name, Symbol
                                            Row(
                                              children: [
                                                Text(
                                                  _dataObj.name ?? "",
                                                  style: TextStyles.txtMedium14
                                                      (context).copyWith(
                                                    color:
                                                    Constant.clrWhiteBlackByTheme(context),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ),
                                                Text(
                                                  _dataObj.symbol ?? "",
                                                  style: TextStyles.txtMedium12
                                                      (context).copyWith(
                                                          color: Constant.clrBlackNew),
                                                ),
                                              ],
                                            ),

                                            /// Live Price
                                            Text(
                                              (_dataObj.price ?? "") +
                                                  " " +
                                                  (_dataObj.currencyCode ?? ""),
                                              maxLines: 1,
                                              style: TextStyles.txtMedium12
                                                  (context).copyWith(
                                                      color: Constant.clrDarkPurple),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Visibility(
                                          visible: getUserStatus() == guest
                                              ? false
                                              : true,
                                          child: SizedBox(
                                            width: 25.w,
                                          ),
                                        ),
                                        Visibility(
                                          visible: getUserStatus() == guest
                                              ? false
                                              : true,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: InkWell(
                                              onTap: () {
                                                _manageFavourite(favoriteWatch,
                                                    _dataObj.currencyId ?? "");
                                              },
                                              child: CommonImageAsset(
                                                strIcon: Constant.icLike,
                                                height: 26.h,
                                                width: 26.h,
                                                boxFit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      DialogProgressBar(
                        isLoading: favoriteWatch.isLoadingPagination,
                        forPagination: true,
                      )
                    ],
                  ),
                );
              });
  }

  /// Get Favourite List
  Future _getFavouriteList(FavoriteScreenController favoriteWatch,
      {bool removeOld = false}) async {
    if (removeOld) {
      favoriteWatch.isHasMorePage = false;
    }
    if (isInternetConnectionOn) {
      await favoriteWatch.getFavouriteListApi(context);
    }
  }

  /// Manage Favourite List
  Future _manageFavourite(
      FavoriteScreenController favoriteWatch, String id) async {
    if (isInternetConnectionOn && !favoriteWatch.isLoading) {
      await favoriteWatch.manageFavouriteApi(context, id);

      if (favoriteWatch.manageFavouriteResponseModel?.status ==
          ApiEndPoints.apiStatus_200) {
        await _getFavouriteList(favoriteWatch, removeOld: true);
      }
    }
  }

  /// Get Crypto Currency Data Live
  Future<void> getCryptoCurrencyData(CommonController commonWatch,
      FavoriteScreenController favoriteWatch) async {
    if (isInternetConnectionOn) {
      if (mounted) {
        // await commonWatch.getCryptoCurrencyAPI(context);
      }
      if (commonWatch.cryptoCurrencyResponseModel.data != null ||
          commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
        /// Set Price in Main List Every secondsDelayForRealTimeAPICall seconds

        favoriteWatch.arrFavourite?.forEach((element1) {
          CryptoCurrencyData? currencyData = commonWatch
              .cryptoCurrencyResponseModel.data
              ?.where(
                  (element) => element.id.toString() == element1.apiCurrencyId)
              .first;
          if (currencyData != null) {
            element1.price = currencyData.priceUsd;
          }
        });
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
        currencyTimer = Timer.periodic(
            Duration(milliseconds: secondsDelayForRealTimeAPICall),
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
