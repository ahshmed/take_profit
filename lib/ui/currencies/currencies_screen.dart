// ignore_for_file: unused_local_variable
import 'dart:async';

import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../framework/data_provider/common/common_controller.dart';
import '../../framework/data_provider/favorite/favorite_controller.dart';
import '../../framework/data_provider/favorite/favorite_provider.dart';
import '../../framework/data_provider/home/currencies_controller.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/notification/notification_controller.dart';
import '../../framework/data_provider/notification/notification_provider.dart';
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
import '../notification/notification_screen.dart';
import 'currency_details_screen.dart';

class CurrenciesScreen extends ConsumerStatefulWidget {
  final bool isDrawer;

  const CurrenciesScreen({super.key, required this.isDrawer});

  @override
  ConsumerState<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends ConsumerState<CurrenciesScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollControllerCurrencyList = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _currencyTimer;
  Timer? _searchDebounceTimer;

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      WidgetsBinding.instance.addObserver(this);
      _initializeScreen();
    });
  }

  /// Initialize screen data and listeners
  Future<void> _initializeScreen() async {
    final currenciesWatch = ref.read(currenciesProvider);
    final commonWatch = ref.read(commonProvider);
    final notificationWatch = ref.read(notificationProvider);

    currenciesWatch.clearProvider();
    commonWatch.clearProvider();

    // Initial API calls
    await _fetchCurrencies(currenciesWatch, false);
    await _startLivePriceUpdates();
    _notificationCountAPICall(notificationWatch);

    // Setup scroll listener for pagination
    _setupScrollListener();
  }

  /// Setup scroll listener for pagination
  void _setupScrollListener() {
    _scrollControllerCurrencyList.addListener(() async {
      final currenciesWatch = ref.read(currenciesProvider);

      if (!currenciesWatch.isHasMoreCurrencyList) return;
      if (_scrollControllerCurrencyList.position.maxScrollExtent !=
          _scrollControllerCurrencyList.position.pixels) return;

      final currentPage = int.parse(
          currenciesWatch.currencyListResponseModel?.data?.pageNumber
              ?.toString() ??
              "0");
      final totalPages = int.parse(
          currenciesWatch.currencyListResponseModel?.data?.totalPage
              .toString() ??
              "0");

      if (currentPage != totalPages &&
          !currenciesWatch.isLoadingForPagination) {
        await _fetchCurrencies(currenciesWatch, true);
      }
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    showLog('AppLifecycleState :- $state');

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await _startLivePriceUpdates(isStart: false);
    } else if (state == AppLifecycleState.resumed) {
      await _startLivePriceUpdates(isStart: true);
    }
  }

  @override
  void dispose() {
    _scrollControllerCurrencyList.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _searchDebounceTimer?.cancel();
    _startLivePriceUpdates(isStart: false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationWatch = ref.watch(notificationProvider);
    final currenciesWatch = ref.watch(currenciesProvider);

    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            if (!widget.isDrawer) {
              Navigator.pop(context, true);
            }
            return !widget.isDrawer;
          },
          child: Scaffold(
            backgroundColor: Constant.clrBasicByTheme(context),
            appBar: _buildAppBar(notificationWatch),
            body: NoInternetBuilder(
              child: GestureDetector(
                onTap: () => hideKeyboard(context),
                behavior: HitTestBehavior.opaque,
                child: _buildBody(currenciesWatch),
              ),
            ),
          ),
        ),
        DialogProgressBar(
          isLoading: currenciesWatch.isLoading || notificationWatch.isLoading,
        ),
      ],
    );
  }

  /// Build AppBar with consistent padding
  PreferredSizeWidget _buildAppBar(NotificationController notificationWatch) {
    return CommonAppBar(
      isTitleCenter: false,
      title: getLocalValue("Key_Currencies"),
      titleTextStyle: TextStyles.txtSemiBold18(context).copyWith(
        fontWeight: Constant.fwLight,
      ),
      onPress: () => Navigator.pop(context, true),
      appBar: AppBar(
        backgroundColor: Constant.clrBasicByTheme(context),
        toolbarHeight: 64.h,
        elevation: 0,
      ),
      backgroundColor: Constant.clrBasicByTheme(context),
      isDrawer: widget.isDrawer,
      action: [
        if (widget.isDrawer && getUserStatus() != guest)
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: IconButton(
              onPressed: () => _navigateToNotifications(notificationWatch),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(39.81.h, 39.81.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              splashRadius: 18,
              icon: _buildNotificationIcon(notificationWatch),
            ),
          ),
      ],
    );
  }

  /// Build notification icon with badge
  Widget _buildNotificationIcon(NotificationController notificationWatch) {
    final hasNotifications = notificationWatch
        .notificationCountResponseModel.data?.count != '0' &&
        notificationWatch.notificationCountResponseModel.data != null;

    if (!hasNotifications) {
      return Image.asset(
        Constant.icNotificationN,
        width: 39.81.h,
        height: 39.81.h,
        color: Constant.clrTitlePageByTheme(context),
      );
    }

    return badge.Badge(
      position: badge.BadgePosition.topEnd(top: 1, end: 6),
      badgeStyle: const badge.BadgeStyle(
        badgeColor: Colors.red,
        padding: EdgeInsets.all(4),
        elevation: 0,
      ),
      badgeContent: Text(
        notificationWatch.notificationCountResponseModel.data?.count ?? '',
        style: TextStyles.txtRegular10(context).copyWith(color: Constant.clrWhite),
      ),
      child: Image.asset(
        Constant.icNotificationN,
        width: 39.81.h,
        height: 39.81.h,
        color: Constant.clrTitlePageByTheme(context),      ),
    );
  }

  /// Navigate to notifications
  void _navigateToNotifications(NotificationController notificationWatch) {
    Route route = SlideRightPageRoute(
      builder: (context) => const NotificationScreen(),
      settings: const RouteSettings(),
    );
    Navigator.of(context).push(route).then((value) {
      if (value == true) {
        _notificationCountAPICall(notificationWatch);
      }
    });
  }

  /// Build body with search and list
  Widget _buildBody(CurrenciesScreenController currenciesWatch) {
    final isEmpty = currenciesWatch.currencyList?.isEmpty == true &&
        !currenciesWatch.isLoading;

    if (isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: EmptyStateWidget(emptyStateFor: EmptyState.noCurrencyFound),
      );
    }

    return Column(
      children: [
        _buildSearchBar(currenciesWatch),
        Expanded(child: _buildCurrencyList(currenciesWatch)),
        if (currenciesWatch.isLoadingForPagination)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: DialogProgressBar(
              isLoading: true,
              forPagination: true,
            ),
          ),
      ],
    );
  }

  /// Build search bar with consistent padding
  Widget _buildSearchBar(CurrenciesScreenController currenciesWatch) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 10.h),
      child: CustomTextField(
        context: context,
        myController: _searchController,
        bgColor: Constant.clrDarkByScaffoldTheme(context),
        myFocus: _searchFocus,
        leftPadding: 13.w,
        hintText: "${getLocalValue("Key_SearchHere...")} ",
        onChanged: _onSearchChanged,
        onEditingComplete: () {
          hideKeyboard(context);
          _performSearch(currenciesWatch);
        },
        textInputAction: TextInputAction.search,
        prefix: Icon(
          Icons.search,
          color: Constant.clrTitlePageByTheme(context),
          size: 24.h,
        ),
        suffix: _searchController.text.isNotEmpty
            ? IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.grey.shade400,
            size: 20.h,
          ),
          onPressed: () {
            _searchController.clear();
            setState(() {
              _isSearching = false;
            });
          },
        )
            : null,
        paddingNeed: false,
        marginNeed: false,
        borderRadius: 10.r,
      ),
    );
  }

  /// Handle search text changes with debouncing
  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.isNotEmpty;
    });

    _searchDebounceTimer?.cancel();

    if (value.isEmpty) {
      _clearSearch(ref.read(currenciesProvider));
      return;
    }

    _searchDebounceTimer = Timer(
      Duration(milliseconds: searchDurationInMilliSeconds),
          () {
        if (mounted) {
          _performSearch(ref.read(currenciesProvider));
        }
      },
    );
  }

  /// Perform search
  Future<void> _performSearch(
      CurrenciesScreenController currenciesWatch) async {
    if (!isInternetConnectionOn) return;

    hideKeyboard(context);
    currenciesWatch.clearProvider();
    await currenciesWatch.currencyListAPI(
        context, _searchController.text.trim());
  }

  /// Clear search
  Future<void> _clearSearch(CurrenciesScreenController currenciesWatch) async {
    _searchController.clear();
    hideKeyboard(context);
    setState(() => _isSearching = false);
    currenciesWatch.clearProvider();
    await _fetchCurrencies(currenciesWatch, false);
  }

  /// Build currency list with consistent padding
  Widget _buildCurrencyList(CurrenciesScreenController currenciesWatch) {
    final favoriteWatch = ref.watch(favoriteProvider);

    return ListView.builder(
      controller: _scrollControllerCurrencyList,
      physics: const BouncingScrollPhysics(),
      itemCount: currenciesWatch.currencyList?.length ?? 0,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 0,
        bottom: widget.isDrawer ? 90.h : 20.h,
      ),
      itemBuilder: (context, index) {
        final currencyObj = currenciesWatch.currencyList?[index];
        return _buildCurrencyCard(currencyObj, favoriteWatch, currenciesWatch);
      },
    );
  }

  /// Build individual currency card
  Widget _buildCurrencyCard(
      currencyObj,
      FavoriteScreenController favoriteWatch,
      CurrenciesScreenController currenciesWatch,
      ) {
    return InkWell(
      onTap: () =>
          _navigateToCurrencyDetail(currencyObj?.id ?? "", currenciesWatch),
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Card(
          color: Constant.clrDCardSearchByTheme(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Row(
              children: [
                CacheImage(
                  imageURL: currencyObj?.logo ?? "",
                  height: 45.h,
                  width: 45.h,
                  contentMode: BoxFit.cover,
                  bgColor: Constant.clrDCardSearchByTheme(context),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${currencyObj?.price ?? ""} ${currencyObj?.currencyCode ?? ""}",
                        maxLines: 1,
                        style: TextStyles.txtGilroyRegular16(context)
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              currencyObj?.name ?? "",
                              // style: TextStyles.txtRegG14(context).copyWith(
                              //   color: Constant.clrTitlePageByTheme(),
                              // ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            currencyObj?.symbol ?? "",
                            // style: TextStyles.txtRegG14(context).copyWith(
                            //   color: Constant.clrTitlePageByTheme(),
                            // ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                // if (getUserStatus() != guest) ...[
                //   SizedBox(width: 15.w),
                //   InkWell(
                //     onTap: () => _manageFavourite(
                //       favoriteWatch,
                //       currencyObj?.id ?? "",
                //       currenciesWatch,
                //     ),
                //     child: CommonImageAsset(
                //       strIcon: currencyObj?.isFavourite == "1"
                //           ? Constant.icFavN
                //           : Constant.icUnFavN,
                //       height: 19.h,
                //       width: 21.62.h,
                //       boxFit: BoxFit.cover,
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to currency detail
  Future<void> _navigateToCurrencyDetail(
      String currencyId,
      CurrenciesScreenController currenciesWatch,
      ) async {
    await _startLivePriceUpdates(isStart: false);

    Route route = SlideRightPageRoute(
      builder: (context) => CurrencyDetailScreen(
        seeAllScreen: SeeAllScreen.fromCurrencyScreen,
        currencyID: currencyId,
      ),
      settings: const RouteSettings(),
    );

    final result = await Navigator.push(context, route);

    await _startLivePriceUpdates(isStart: true);

    if (result == true) {
      await _fetchCurrencies(currenciesWatch, false);
    }
  }

  /// Fetch currencies API
  Future<void> _fetchCurrencies(
      CurrenciesScreenController currenciesWatch,
      bool isHasMorePage,
      ) async {
    if (!isInternetConnectionOn) return;

    currenciesWatch.isHasMoreCurrencyList = isHasMorePage;
    currenciesWatch.updateWidget();

    final searchQuery = _isSearching ? _searchController.text.trim() : "";
    await currenciesWatch.currencyListAPI(context, searchQuery);
  }

  /// Manage favourite
  Future<void> _manageFavourite(
      FavoriteScreenController favoriteWatch,
      String id,
      CurrenciesScreenController currenciesWatch,
      ) async {
    if (!isInternetConnectionOn) return;

    await favoriteWatch.manageFavouriteApi(context, id);

    if (favoriteWatch.manageFavouriteResponseModel?.status ==
        ApiEndPoints.apiStatus_200) {
      final index = currenciesWatch.currencyList
          ?.indexWhere((element) => element.id == id);

      if (index != null && index != -1) {
        final isFavourite =
            currenciesWatch.currencyList?[index].isFavourite == "1";
        currenciesWatch.currencyList?[index].isFavourite =
        isFavourite ? "0" : "1";
        currenciesWatch.updateWidget();
      }
    }
  }

  /// Notification count API call
  Future<void> _notificationCountAPICall(
      NotificationController notificationWatch,
      ) async {
    if (getUserStatus() == guest) return;
    if (!isInternetConnectionOn) return;

    await notificationWatch.notificationCountAPI(context);
  }

  /// Get crypto currency live data
  Future<void> _getCryptoCurrencyData(
      CommonController commonWatch,
      CurrenciesScreenController currenciesWatch,
      ) async {
    if (!isInternetConnectionOn || !mounted) return;

    final cryptoData = commonWatch.cryptoCurrencyResponseModel.data;
    if (cryptoData == null || cryptoData.isEmpty) return;

    for (var currency in currenciesWatch.currencyList ?? []) {
      try {
        final currencyData = cryptoData.firstWhere(
              (element) => element.id.toString() == currency.apiCurrencyId,
        );
        currency.price = currencyData.priceUsd;
      } catch (e) {
        // Currency not found in crypto data, skip
        continue;
      }
    }

    commonWatch.updateUi();
  }

  /// Start/stop live price updates
  Future<void> _startLivePriceUpdates({bool isStart = true}) async {
    if (!isInternetConnectionOn) return;

    if (isStart) {
      final commonWatch = ref.read(commonProvider);
      final currenciesWatch = ref.read(currenciesProvider);

      _currencyTimer?.cancel();
      _currencyTimer = Timer.periodic(
        Duration(milliseconds: secondsDelayForRealTimeAPICall),
            (timer) async {
          if (!currenciesWatch.isLoading &&
              !currenciesWatch.isLoadingForPagination) {
            await _getCryptoCurrencyData(commonWatch, currenciesWatch);
          }
        },
      );
    } else {
      _currencyTimer?.cancel();
      _currencyTimer = null;
    }
  }
}