import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/home/recommender_bio_controller.dart';
import '../../framework/repository/home/model/recommender_details_response_model.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/common_svg.dart';
import '../../utils/widgets/commonappbar.dart';
import '../my_subscription/choose_plan_screen.dart';

class RecommenderBioScreen extends ConsumerStatefulWidget {
  final RecommenderDetailData? recommenderDetailData;

  const RecommenderBioScreen({Key? key, required this.recommenderDetailData})
      : super(key: key);

  @override
  ConsumerState<RecommenderBioScreen> createState() =>
      _RecommenderBioScreenState();
}

class _RecommenderBioScreenState extends ConsumerState<RecommenderBioScreen>
    {
  ///-----Init----
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {});
    super.initState();
  }

  ///build widget
  @override
  Widget build(BuildContext context) {
    final recommenderBioWatch = ref.watch(recommenderBioProvider);
    return Scaffold(
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        title: getLocalValue("Key_RecommenderBio"),
        isTitleCenter: true,
        appBar: AppBar(
            backgroundColor: Constant.clrScaffoldBGByTheme(context), toolbarHeight: 64.h),
        isDrawer: false,
      ),
      body: NoInternetBuilder(child: bodyWidget(recommenderBioWatch)),
    );
  }

  ///body widget
  Widget bodyWidget(RecommenderBioScreenController recommenderBioWatch) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          recommenderDetailWidget(recommenderBioWatch),
          SizedBox(
            height: 15.h,
          ),
          recommenderBioWidget()
        ],
      ),
    );
  }

  ///Recommender Details Widget
  Widget recommenderDetailWidget(
      RecommenderBioScreenController recommenderBioWatch) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Constant.clrPrimary.withOpacity(0.2),
      padding: EdgeInsets.all(15.h),
      child: Column(
        children: [
          SizedBox(
            height: 10.h,
          ),
          SizedBox(
            height: 130.h,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: CacheImage(
                    imageURL: widget.recommenderDetailData?.profileImage ?? "",
                    height: 121.h,
                    width: 121.h,
                    contentMode: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 5.w,
                  right: 5.w,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: Constant.clrPrimary),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                    child: Text(
                      getLocalValue("Key_Recommender"),
                      textAlign: TextAlign.center,
                      style: TextStyles.txtRegular12
                          (context).copyWith(fontSize: 9.sp, color: Constant.clrWhite),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 17.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.recommenderDetailData?.name ?? "",
                style: TextStyles.txtMedium14(context).copyWith(
                  color: Constant.clrBlackWhiteByTheme(context),
                ),
              ).paddingOnly(right: 5.w),
              Visibility(
                visible: widget.recommenderDetailData?.isPremiumUser == '1',
                child: CommonSVG(
                  strIcon: Constant.svgPremiumUser,
                  height: 15.h,
                  width: 15.h,
                ),
              )
            ],
          ),
          Text(
            widget.recommenderDetailData?.trendingLabel ?? "",
            style: TextStyles.txtRegular12(context).copyWith(
              fontSize: 10.sp,
              color: Constant.clrDarkPurpleWhiteByTheme(context),
            ),
          ),
          SizedBox(
            height: 7.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: widget.recommenderDetailData?.facebookUrl != '',
                child: InkWell(
                  child: CommonImageAsset(
                    strIcon: Constant.icFacebook,
                    height: 24.h,
                    width: 24.h,
                    boxFit: BoxFit.cover,
                  ),
                  onTap: () async {
                    if (await canLaunchUrl(Uri.parse(
                        widget.recommenderDetailData?.facebookUrl ?? ""))) {
                      await launchUrl(Uri.parse(
                          widget.recommenderDetailData?.facebookUrl ?? ""));
                    }
                  },
                ).paddingOnly(right: 10.w),
              ),
              Visibility(
                visible: widget.recommenderDetailData?.twitterUrl != '',
                child: InkWell(
                  child: CommonImageAsset(
                    strIcon: Constant.icTwitterPrimary,
                    height: 24.h,
                    width: 24.h,
                    boxFit: BoxFit.cover,
                  ),
                  onTap: () async {
                    if (await canLaunchUrl(Uri.parse(
                        widget.recommenderDetailData?.twitterUrl ?? ""))) {
                      await launchUrl(Uri.parse(
                          widget.recommenderDetailData?.twitterUrl ?? ""));
                    }
                  },
                ).paddingOnly(right: 10.w),
              ),
              Visibility(
                visible: widget.recommenderDetailData?.instagramUrl != '',
                child: InkWell(
                  child: CommonImageAsset(
                    strIcon: Constant.icInstagram,
                    height: 24.h,
                    width: 24.h,
                    boxFit: BoxFit.cover,
                  ),
                  onTap: () async {
                    if (await canLaunchUrl(Uri.parse(
                        widget.recommenderDetailData?.instagramUrl ?? ""))) {
                      await launchUrl(Uri.parse(
                          widget.recommenderDetailData?.instagramUrl ?? ""));
                    }
                  },
                ).paddingOnly(right: 10.w),
              ),
              Visibility(
                visible: widget.recommenderDetailData?.websiteUrl != '',
                child: InkWell(
                  child: CommonImageAsset(
                    strIcon: Constant.icWeb,
                    height: 24.h,
                    width: 24.h,
                    boxFit: BoxFit.cover,
                  ),
                  onTap: () async {
                    if (await canLaunchUrl(Uri.parse(
                        widget.recommenderDetailData?.websiteUrl ?? ""))) {
                      await launchUrl(Uri.parse(
                          widget.recommenderDetailData?.websiteUrl ?? ""));
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
          Visibility(
            visible: ((widget.recommenderDetailData?.isSameUser != '1') &&
                (getUserEntityId() !=
                    widget.recommenderDetailData?.recommenderId)),
            child: InkWell(
              onTap: () {
                if (getUserStatus() == guest) {
                  getStartedDialog(context);
                } else if (widget.recommenderDetailData?.isSubscribed == "0") {
                  Route route = SlideRightPageRoute(
                    builder: (context) => ChoosePlanScreen(
                      fromScreen: ScreenName.RecommenderBioScreen,
                      recommenderID:
                          widget.recommenderDetailData?.recommenderId ?? "",
                    ),
                    settings: const RouteSettings(),
                  );
                  Navigator.push(context, route);
                }
              },
              child: Container(
                height: 36.h,
                width: 185.w,
                decoration: BoxDecoration(
                    color: widget.recommenderDetailData?.isSubscribed == "1"
                        ? Constant.clrWhite
                        : Constant.clrYellow,
                    borderRadius: BorderRadius.circular(30.r),
                    border: widget.recommenderDetailData?.isSubscribed == "1"
                        ? Border.all(color: Constant.clrGrey, width: 2.w)
                        : null),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonImageAsset(
                      strIcon: widget.recommenderDetailData?.isSubscribed == "1"
                          ? Constant.icFillStar
                          : Constant.icStar,
                      height: 17.h,
                      width: 17.h,
                      boxFit: BoxFit.cover,
                    ),
                    SizedBox(
                      width: 7.w,
                    ),
                    Text(
                      widget.recommenderDetailData?.isSubscribed == "1"
                          ? getLocalValue("Key_Subscribed")
                          : getLocalValue("Key_Subscribe"),
                      style: TextStyles.txtMedium12(context).copyWith(
                          color:
                              widget.recommenderDetailData?.isSubscribed == "1"
                                  ? Constant.clrYellow
                                  : Constant.clrWhite),
                    )
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.recommenderDetailData?.isSubscribed == "1"
                ? true
                : false,
            child: SizedBox(
              height: 6.h,
            ),
          ),
          Visibility(
            visible: widget.recommenderDetailData?.isSubscribed == "1"
                ? true
                : false,
            child: Text(
              "${getLocalValue("Key_Expires:")} ${widget.recommenderDetailData?.subscriptionEndDate}",
              style: TextStyles.txtRegular10(context).copyWith(color: Constant.clrBlackNew),
            ),
          ),
        ],
      ),
    );
  }

  ///Recommender Bio Widget
  Widget recommenderBioWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getLocalValue("Key_Bio"),
            style: TextStyles.txtMedium16(context).copyWith(
              color: Constant.clrBlackWhiteByTheme(context),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            widget.recommenderDetailData?.bio ?? "",
            style: TextStyles.txtRegular10(context).copyWith(
              color: Constant.clrBlackWhiteByTheme(context),
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
