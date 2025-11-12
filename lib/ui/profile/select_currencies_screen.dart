import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/sign_up_bank_screen_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/profile/select_currency_screen_controller.dart';
import '../../framework/repository/currencies/model/currencies_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/empty_state_widget.dart';
import '../drawer/drawer_menu.dart';
import '../search/search_currencies_screen.dart';

class SelectCurrencyScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;
  final String? userId;

  const SelectCurrencyScreen(
      {Key? key, this.isFromProfile = false, this.userId})
      : super(key: key);

  @override
  ConsumerState<SelectCurrencyScreen> createState() =>
      _SelectCurrencyScreenState();
}

class _SelectCurrencyScreenState extends ConsumerState<SelectCurrencyScreen>
     {
  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final selectCurrencyWatch = ref.watch(selectCurrencyScreenProvider);
      selectCurrencyWatch.clearProvider();
      // currencyListApi(selectCurrencyWatch, currenciesWatch);
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final selectCurrencyWatch = ref.watch(selectCurrencyScreenProvider);
    final currenciesWatch = ref.watch(currenciesProvider);
    final signUpBankDetailWatch = ref.watch(signUpBankDetailScreenProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: /*!widget.isFromProfile
              ? null
              : */
              CommonAppBar(
            title: '',
            appBar: AppBar(),
            isLeading: true,
          ),
          body: NoInternetBuilder(
            child: bodyWidget(selectCurrencyWatch),
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
                if (widget.isFromProfile) {
                  Navigator.pop(context);
                } else {
                  final signUpBankDetailWatch =
                      ref.watch(signUpBankDetailScreenProvider);
                  _completeProfileAPI(signUpBankDetailWatch);
                }
              },
              label: widget.isFromProfile
                  ? getLocalValue("Key_Save")
                  : getLocalValue("Key_Done"),
              isEnable: selectCurrencyWatch.sItemList.isNotEmpty,
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              borderRadius: 30.r,
            ),
          ),
        ),
        DialogProgressBar(
            isLoading:
                currenciesWatch.isLoading || signUpBankDetailWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(SelectCurrencyScreenController selectCurrencyWatch) {
    // final currenciesWatch = ref.watch(currenciesProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getLocalValue("Key_FavoriteCurrencies"),
                style: TextStyles.txtMedium24(context).copyWith(color: Constant.clrPrimary),
              ).paddingOnly(top: 20.h),
              SizedBox(
                height: 5.h,
              ),
              Text(
                getLocalValue(
                    "Key_SelectTheCurrenciesToProceedForYourTraderAccount"),
                style: TextStyles.txtRegular12(context),
              ),
              SizedBox(
                height: 25.h,
              ),
            ],
          ),
          InkWell(
            onTap: () {
              Route route = SlideRightPageRoute(
                  builder: (context) => SearchCurrenciesScreen(
                        userId: widget
                            .userId, /*sItemList: selectCurrencyWatch.sItemList*/
                      ),
                  settings: const RouteSettings());
              Navigator.of(context).push(route).then((value) {
                if (value != null) {
                  List<CurrencyList> valueList = value;
                  selectCurrencyWatch.sItemList.removeWhere((element1) =>
                      valueList.any((element) =>
                          element.apiCurrencyId == element1.apiCurrencyId));

                  selectCurrencyWatch.updateWidget();
                  selectCurrencyWatch.sItemList.addAll(value);
                  selectCurrencyWatch.updateWidget();
                }
              });
            },
            child: Container(
              width: Constant.infiniteSize,
              padding: EdgeInsets.only(
                  left: 23.w, top: 15.h, right: 23.w, bottom: 15.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Constant.clrScaffoldBGByTheme(context),
                border: Border.all(color: Constant.clrGrey),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CommonImageAsset(
                    strIcon: Constant.icSearchN,
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  Text(
                    "${getLocalValue("Key_SearchHere")} ",
                    style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrGrey),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Visibility(
            visible: selectCurrencyWatch.sItemList.isNotEmpty,
            replacement: Expanded(
                child: EmptyStateWidget(
                    emptyStateFor: EmptyState.emptyFavouriteCurrency)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 15.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Constant.clrBlackNewLightPurpleByTheme(context),
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 4,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: selectCurrencyWatch.sItemList.length,
                itemBuilder: (context, index) {
                  // selectCurrencyWatch.removeFromList(index);
                  return Container(
                    padding: EdgeInsets.all(7.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Constant.clrScaffoldBGByTheme(context),
                    ),
                    child: Row(
                      children: [
                        CacheImage(
                          imageURL:
                              selectCurrencyWatch.sItemList[index].logo ?? "",
                          height: 20.h,
                          width: 20.h,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            selectCurrencyWatch.sItemList[index].name ?? "",
                            maxLines: 1,
                            style:
                                TextStyles.txtMedium8(context).copyWith(fontSize: 10.sp),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            selectCurrencyWatch.removeFromList(index);
                          },
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            child: CommonImageAsset(
                              strIcon: Constant.icClose,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Login API
  Future _completeProfileAPI(
      SignUpBankDetailsScreenController completeProfileWatch) async {
    final currenciesWatch = ref.watch(currenciesProvider);
    if (isInternetConnectionOn) {
      await completeProfileWatch.completeProfileApi(context, widget.userId, "",
          currencyList: currenciesWatch.selectedItem);
      if (completeProfileWatch.completeProfileModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        saveLocalData(KEY_USER_ENTITY_ID, widget.userId);

        showLog(
            "token ${completeProfileWatch.completeProfileModel?.data?.token}");
        showLog(
            completeProfileWatch.completeProfileModel?.data?.token.toString() ??
                "");
        final dashboardWatch = ref.watch(dashboardProvider);
        dashboardWatch.clearProvider();

        /// For Displaying Profile Data in Drawer
        final profileWatch = ref.watch(profileProvider);
        await profileWatch.profileAPI(context);
        saveLocalData(KEY_USER_STATUS,
            profileWatch.profileDetailResponseModel?.data?.userType);
        saveLocalData(KEY_USER_ACCESS_TOKEN,
            completeProfileWatch.completeProfileModel?.data?.token);

        Route route = SlideRightPageRoute(
            builder: (context) => const DrawerMenu(),
            settings: const RouteSettings());
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
      }
    }
  }
}
