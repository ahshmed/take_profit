// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/home/currencies_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/search/search_currencies_screen_controller.dart';
import '../../framework/data_provider/search/search_provider.dart';
import '../../framework/repository/currencies/model/currencies_response_model.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';

class SearchCurrenciesScreen extends ConsumerStatefulWidget {
  final String? userId;

  // final List<CurrencyList> sItemList;

  const SearchCurrenciesScreen({
    Key? key,
    this.userId,
    /*required this.sItemList*/
  }) : super(key: key);

  @override
  ConsumerState<SearchCurrenciesScreen> createState() =>
      _SearchCurrenciesScreenState();
}

class _SearchCurrenciesScreenState extends ConsumerState<SearchCurrenciesScreen>
     {
  TextEditingController searchCTR = TextEditingController();
  FocusNode searchFocus = FocusNode();

  Timer? timer;

  // Timer? currencyTimer;

  int searchLength = 0;

  ScrollController scrollController = ScrollController();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final searchCurrenciesWatch = ref.watch(searchCurrenciesProvider);
      final currenciesWatch = ref.watch(currenciesProvider);
      searchCurrenciesWatch.clearProvider();
      currenciesWatch.clearProvider();

      currencyListApi(
          searchCurrenciesWatch, currenciesWatch, "", widget.userId, true);
      // setItemInSelectedCurrencyList(currenciesWatch);

      scrollController.addListener(() {
        if (currenciesWatch.isHasMoreCurrencyList) {
          if (scrollController.position.maxScrollExtent ==
              scrollController.position.pixels) {
            if ((int.parse(currenciesWatch
                        .currencyListResponseModel?.data?.pageNumber
                        ?.toString() ??
                    "0") !=
                int.parse(
                  currenciesWatch.currencyListResponseModel?.data?.totalPage
                          .toString() ??
                      "0",
                ))) {
              if (currenciesWatch.isLoadingForPagination == false) {
                currencyListApi(searchCurrenciesWatch, currenciesWatch, "",
                    widget.userId, true);
              }
            }
          }
        }
      });
    });
  }

  // setItemInSelectedCurrencyList(CurrenciesScreenController currenciesWatch) {
  //   for (int i = 0; i < widget.sItemList.length; i++) {
  //     currenciesWatch.selectedItem.add(widget.sItemList[i].id.toString());
  //   }
  //   currenciesWatch.cItemList.addAll(widget.sItemList);
  // }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    scrollController.dispose();
    super.dispose();
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final searchCurrenciesWatch = ref.watch(searchCurrenciesProvider);
    final currenciesWatch = ref.watch(currenciesProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue("Key_SearchCurrencies"),
            appBar: AppBar(),
            isLeading: true,
          ),
          body: NoInternetBuilder(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                hideKeyboard(context);
              },
              child: bodyWidget(searchCurrenciesWatch),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
                left: 20.w,
                top: 8.h,
                right: 20.w,
                bottom: getIsIOSPlatform()
                    ? 20.h
                    : (MediaQuery.of(context).viewPadding.bottom + 8).h),
            child: CommonButton(
              onTap: () {
                Navigator.pop(context, currenciesWatch.cItemList);
              },
              label: getLocalValue("Key_Done"),
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              borderRadius: 30.r,
              isEnable: currenciesWatch.cItemList.isNotEmpty,
            ),
          ),
        ),
        DialogProgressBar(isLoading: currenciesWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(SearchCurrenciesScreenController searchCurrenciesWatch) {
    final currenciesWatch = ref.watch(currenciesProvider);
    return Consumer(builder: (context, ref, child) {
      final commonWatch = ref.watch(commonProvider);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
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
              onChanged: (str) {
                currenciesWatch.clearProvider();

                showLog("Search Keyword - $str");
                if (timer != null) {
                  timer!.cancel();
                }

                if (str.isNotEmpty) {
                  timer = Timer.periodic(
                      Duration(milliseconds: searchDurationInMilliSeconds),
                      (timer) {
                    timer.cancel();
                    hideKeyboard(context);
                    currenciesWatch.currencyList?.clear();
                    currencyListApi(searchCurrenciesWatch, currenciesWatch, str,
                        widget.userId, true);
                  });
                }

                searchLength = str.length;
              },
              textInputAction: TextInputAction.done,
              prefix: CommonImageAsset(
                strIcon: Constant.icSearchN,
              ),
              suffix: InkWell(
                onTap: () {
                  searchCurrenciesWatch.clearProvider();
                  searchCTR.text = "";
                  currenciesWatch.currencyList?.clear();
                  currenciesWatch.selectedItem.clear();
                  currencyListApi(searchCurrenciesWatch, currenciesWatch, "",
                      widget.userId, true);
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
            Align(
              alignment: Alignment.topRight,
              child: Text(
                "${currenciesWatch.selectedItem.length} ${getLocalValue("Key_Selected")}",
                style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrGreyNew),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                itemCount: currenciesWatch.currencyList?.length,
                itemBuilder: (context, index) {
                  final item = currenciesWatch.currencyList?[index];
                  return InkWell(
                    onTap: () {
                      currenciesWatch.addRemoveItemInSelectedList(
                          currenciesWatch.currencyList?[index].id.toString() ??
                              "",
                          currenciesWatch.currencyList?[index] as CurrencyList);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(15.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Constant.clrDarkByScaffoldTheme(context),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: CacheImage(
                              imageURL: item?.logo ?? "",
                              height: 45.h,
                              width: 45.h,
                              contentMode: BoxFit.contain,
                            ),
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item?.name ?? "",
                                  style: TextStyles.txtMedium14
                                      (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  item?.symbol ?? "",
                                  style: TextStyles.txtMedium12
                                      (context).copyWith(color: Constant.clrBlackNew),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Visibility(
                            visible: currenciesWatch.selectedItem.contains(
                                    currenciesWatch.currencyList?[index].id
                                            .toString() ??
                                        "")
                                ? true
                                : false,
                            child: CommonImageAsset(
                              strIcon: Constant.icSelected,
                              clrImg: Constant.clrDialogBGByTheme(context),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            DialogProgressBar(
              isLoading: currenciesWatch.isLoadingForPagination,
              forPagination: true,
            ).paddingOnly(bottom: 40.h)
          ],
        ),
      );
    });
  }

  ///Currency List Api
  Future currencyListApi(
      SearchCurrenciesScreenController selectCurrencyWatch,
      CurrenciesScreenController currenciesWatch,
      String searchQuery,
      String? userId,
      bool recommenderRequired) async {
    if (isInternetConnectionOn) {
      await currenciesWatch.currencyListAPI(context, searchQuery);
      if (currenciesWatch.currencyListResponseModel != null) {
        selectCurrencyWatch
            .fillCurrencyList(currenciesWatch.currencyListResponseModel);
      }
    }
  }
//
// /// Get Crypto Currency Data Live
// Future<void> getCryptoCurrencyData(
//   CommonController commonWatch,
//   SearchCurrenciesScreenController selectCurrencyWatch,
// ) async {
//   if (mounted) {
//     await commonWatch.getCryptoCurrencyAPI(context);
//   }
//   if (commonWatch.cryptoCurrencyResponseModel.data != null ||
//       commonWatch.cryptoCurrencyResponseModel.data?.isNotEmpty == true) {
//     /// Set Price in Main List Every 2 seconds
//     selectCurrencyWatch.currencyList?.forEach((element1) {
//       CryptoCurrencyData? currencyData = commonWatch
//           .cryptoCurrencyResponseModel.data
//           ?.where((element) => element.id == element1.apiCurrencyId)
//           .first;
//
//       if (currencyData != null) {
//         element1.price = currencyData.priceUsd;
//       }
//     });
//   }
// }
//
// /// Live Price Changes
// Future<void> livePriceChangeFunction({bool isTimerStart = true}) async {
//   if (isTimerStart) {
//     final commonWatch = ref.watch(commonProvider);
//     final searchCurrenciesWatch = ref.watch(searchCurrenciesProvider);
//
//     /// Live Price Api Call every 2 seconds
//     currencyTimer =
//         Timer.periodic(Duration(milliseconds: secondsDelayForRealTimeAPICall),
//             (currencyTimer) async {
//       await getCryptoCurrencyData(commonWatch, searchCurrenciesWatch);
//     });
//     commonWatch.updateUi();
//   } else {
//     /// cancel Timer
//     if (currencyTimer != null) {
//       currencyTimer?.cancel();
//     }
//   }
// }
}
