// ignore_for_file: prefer_is_empty

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/favorite/favorite_controller.dart';
import '../../framework/data_provider/favorite/favorite_provider.dart';
import '../../framework/data_provider/home/currencies_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/search/search_currencies_screen_controller.dart';
import '../../framework/data_provider/search/search_provider.dart';
import '../../framework/repository/common/model/crypto_currency_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../currencies/currency_details_screen.dart';
import '../home/recommender_details_screen.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with WidgetsBindingObserver {
  ///Text Editing Controller
  TextEditingController searchCTR = TextEditingController();

  ///Focus Node
  FocusNode searchFocus = FocusNode();

  ScrollController scrollControllerCurrency = ScrollController();

  Timer? timer;
  Timer? currencyTimer;

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        WidgetsBinding.instance.addObserver(this);
        final searchCurrenciesWatch = ref.watch(searchCurrenciesProvider);
        final currenciesWatch = ref.watch(currenciesProvider);
        currenciesWatch.clearProviderForSearchScreen();
        searchCurrenciesWatch.clearProvider();

        /// Api Call
        await currencyAPI(currenciesWatch, "", isHasMorePage: false);

        await livePriceChangeFunction();

        /// Assign Listener to Scroll Controller
        scrollControllerCurrency.addListener(
          () async {
            if (currenciesWatch.isHasMoreCurrencyList) {
              if (scrollControllerCurrency.position.maxScrollExtent ==
                  scrollControllerCurrency.position.pixels) {
                if (int.parse(currenciesWatch
                        .currencySearchResponseModel!.data!.pageNumber
                        .toString()) !=
                    (int.parse(currenciesWatch
                        .currencySearchResponseModel!.data!.totalPage!
                        .toString()))) {
                  await currencyAPI(currenciesWatch, "", isHasMorePage: true);
                }
              }
            }
          },
        );
      },
    );
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
    scrollControllerCurrency.dispose();
    livePriceChangeFunction(isTimerStart: false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final searchCurrenciesWatch = ref.watch(searchCurrenciesProvider);
    final currenciesWatch = ref.watch(currenciesProvider);

    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, true);
            return true;
          },
          child: Scaffold(
            backgroundColor: Constant.clrScaffoldBGByTheme(context),
            appBar: CommonAppBar(
              title: getLocalValue("Key_Search"),
              appBar: AppBar(),
              isLeading: true,
              onPress: () {
                Navigator.pop(context, true);
              },
            ),
            body: NoInternetBuilder(child: bodyWidget(searchCurrenciesWatch)),
          ),
        ),
        DialogProgressBar(
          isLoading: currenciesWatch.isLoading,
        )
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(SearchCurrenciesScreenController searchCurrenciesWatch) {
    final currenciesWatch = ref.watch(currenciesProvider);
    final favouriteWatch = ref.watch(favoriteProvider);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: Consumer(builder: (context, ref, child) {
        final commonWatch = ref.watch(commonProvider);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              CustomTextField(
                context: context,
                myController: searchCTR,
                bgColor: Constant.clrDarkByScaffoldTheme(context),
                myFocus: searchFocus,
                leftPadding: 13.w,
                hintText: "${getLocalValue("Key_SearchHere")} ",
                onEditingComplete: () {
                  currenciesWatch.clearProvider();
                  currenciesWatch.updateIsSearch(true);
                  hideKeyboard(context);
                  currencyAPI(currenciesWatch, searchCTR.text,
                      isHasMorePage: false);
                },
                onChanged: (str) {
                  // showLog("Search Keyword - $str");
                  // if (timer != null) {
                  //   timer!.cancel();
                  // }
                  // timer = Timer.periodic(
                  //   Duration(milliseconds: searchDurationInMilliSeconds),
                  //   (timer) {
                  //     timer.cancel();
                  //     if (isInternetConnectionOn) {
                  //       showLog("search text");
                  //       currenciesWatch.clearProvider();
                  //       hideKeyboard(context);
                  //       currencyAPI(currenciesWatch, str, isHasMorePage: false);
                  //     }
                  //   },
                  // );
                },
                textInputAction: TextInputAction.done,
                prefix: CommonImageAsset(
                  strIcon: Constant.icSearchN,
                ),
                suffix: InkWell(
                  onTap: () {
                    searchCurrenciesWatch.clearProvider();
                    currencyAPI(currenciesWatch, "", isHasMorePage: false);
                    hideKeyboard(context);
                    searchCTR.clear();
                  },
                  child: CommonImageAsset(
                    strIcon: Constant.icClose,
                  ),
                ),
                paddingNeed: false,
                marginNeed: false,
                borderRadius: 10.r,
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getLocalValue("Key_Currencies"),
                    style: TextStyles.txtMedium12
                        (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
                  ),
                  Text(
                    (searchCTR.text != "" &&
                            (currenciesWatch.currencySearchResponseModel?.data
                                    ?.searchCurrencyList?.length !=
                                0) &&
                            !(currenciesWatch.isLoading) &&
                            currenciesWatch.isSearch)
                        ? "${currenciesWatch.currencySearchResponseModel?.data?.searchCurrencyList?.length} ${getLocalValue("Key_ResultFound")}"
                        : "",
                    style: TextStyles.txtMedium12(context).copyWith(
                      color: Constant.clrGreyNewDark,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              (currenciesWatch.currencySearchResponseModel?.data
                              ?.searchCurrencyList?.length ==
                          0 &&
                      !currenciesWatch.isLoading)
                  ? Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Center(
                          child: EmptyStateWidget(
                              emptyStateFor: EmptyState.noSearchFound),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: scrollControllerCurrency,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: currenciesWatch.searchCurrencyList?.length,
                        itemBuilder: (context, index) {
                          final currencyObj =
                              currenciesWatch.searchCurrencyList?[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.only(
                                left: 15.w,
                                bottom:
                                    ((currencyObj?.recommenders?.length ?? 0) >
                                            0)
                                        ? 2.h
                                        : 15.h,
                                right: 15.w,
                                top: 15.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Constant.clrDarkByScaffoldTheme(context),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await livePriceChangeFunction(
                                        isTimerStart: false);
                                    Route route = SlideRightPageRoute(
                                      builder: (context) =>
                                          CurrencyDetailScreen(
                                        seeAllScreen:
                                            SeeAllScreen.fromSearchScreen,
                                        currencyID: currencyObj?.id ?? "",
                                      ),
                                      settings: const RouteSettings(),
                                    );
                                    Navigator.of(context).push(route).then(
                                      (value) async {
                                        if (value == true) {
                                          await currencyAPI(currenciesWatch, "",
                                              isHasMorePage: false);
                                          await livePriceChangeFunction();
                                        }
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      CacheImage(
                                        imageURL: currencyObj?.logo ?? "",
                                        height: 50.h,
                                        width: 50.h,
                                        contentMode: BoxFit.contain,
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                currencyObj?.name ?? "",
                                                style: TextStyles.txtMedium14
                                                    (context).copyWith(
                                                  color: Constant.clrWhiteBlackByTheme(context),
                                                ),
                                                maxLines: 1,
                                              ),
                                              SizedBox(
                                                width: 5.h,
                                              ),
                                              Text(
                                                currencyObj?.symbol ?? "",
                                                style: TextStyles.txtMedium12
                                                    (context).copyWith(
                                                        color: Constant.clrBlackNew),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            (currencyObj?.price ?? "") +
                                                " " +
                                                (currencyObj?.currencyCode ??
                                                    ""),
                                            style: TextStyles.txtMedium12
                                                (context).copyWith(color: Constant.clrPrimary),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Visibility(
                                            visible: getUserStatus() == guest
                                                ? false
                                                : true,
                                            child: SizedBox(
                                              width: 25.w,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _manageFavourite(
                                                  favouriteWatch,
                                                  currencyObj?.id ?? "",
                                                  currenciesWatch);
                                            },
                                            child: Visibility(
                                              visible: getUserStatus() == guest
                                                  ? false
                                                  : true,
                                              child: CommonImageAsset(
                                                strIcon:
                                                    currencyObj?.isFavourite ==
                                                            "1"
                                                        ? Constant.icLike
                                                        : Constant.icUnLike,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      ((currencyObj?.recommenders?.length ??
                                              0) >
                                          0),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "Key_Recommenders".localized,
                                              style: TextStyles.txtRegular12
                                                  (context).copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),

                                      /// Recommender Data
                                      SizedBox(
                                        height: 90,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: currencyObj
                                                ?.recommenders?.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              final item = currencyObj
                                                  ?.recommenders?[index];
                                              return InkWell(
                                                onTap: () {
                                                  livePriceChangeFunction(
                                                      isTimerStart: false);
                                                  Route route =
                                                      SlideRightPageRoute(
                                                    builder: (context) =>
                                                        RecommenderDetailScreen(
                                                            recommenderID:
                                                                item?.recommenderId ??
                                                                    ""),
                                                    settings:
                                                        const RouteSettings(),
                                                  );
                                                  Navigator.push(context, route)
                                                      .then((value) {
                                                    livePriceChangeFunction();
                                                  });
                                                },
                                                child: SizedBox(
                                                  width: 75,
                                                  child: Column(
                                                    children: [
                                                      CacheImage(
                                                        imageURL:
                                                            item?.profileImage ??
                                                                "",
                                                        height: 45.h,
                                                        width: 45.h,
                                                        topLeftRadius: 5.r,
                                                        topRightRadius: 5.r,
                                                        bottomLeftRadius: 5.r,
                                                        bottomRightRadius: 5.r,
                                                      ),
                                                      SizedBox(
                                                        height: 10.h,
                                                      ),
                                                      Text(
                                                        item?.name ?? "",
                                                        overflow: TextOverflow
                                                            .visible,
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyles
                                                            .txtRegular12(context),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              SizedBox(
                height: 10.h,
              ),
              DialogProgressBar(
                isLoading: currenciesWatch.isLoadingForPagination,
                forPagination: true,
              ).paddingOnly(bottom: 40.h),
            ],
          ),
        );
      }),
    );
  }

  /// Currency list API Call
  Future<void> currencyAPI(
      CurrenciesScreenController currenciesWatch, String search,
      {required bool isHasMorePage}) async {
    if (isInternetConnectionOn) {
      currenciesWatch.isHasMoreCurrencyList = isHasMorePage;
      await currenciesWatch.searchCurrencyListAPI(context, search);
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
        /// Set Price in Main List Every 2 seconds
        currenciesWatch.searchCurrencyList?.forEach((element1) {
          CryptoCurrencyData? currencyData = commonWatch
              .cryptoCurrencyResponseModel.data
              ?.where((element) => element.id.toString()== element1.apiCurrencyId)
              .first;
          // showLog("currencyData ${currencyData?.name}");
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
        final currenciesWatch = ref.watch(currenciesProvider);

        /// Live Price Api Call every 2 seconds
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
        for (int i = 0;
            i < (currenciesWatch.searchCurrencyList?.length ?? 0);
            i++) {
          if (currenciesWatch.searchCurrencyList?[i].id == id) {
            currenciesWatch.searchCurrencyList?[i].isFavourite?.contains("1") ==
                    true
                ? (currenciesWatch.searchCurrencyList?[i].isFavourite = "0")
                : (currenciesWatch.searchCurrencyList?[i].isFavourite = "1");
          }
        }
      }
    }
  }
}
