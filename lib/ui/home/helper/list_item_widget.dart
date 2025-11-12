import 'dart:math';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../../framework/data_provider/drawer/drawer_controller.dart';
import '../../../framework/data_provider/drawer/drawer_provider.dart';
import '../../../utils/const.dart';
import '../../../utils/theme_const.dart';
import '../../../utils/widgets/cache_image.dart';
import '../../../utils/widgets/common_image_asset.dart';
import '../../../utils/widgets/common_svg.dart';

class ListItemWidget extends StatelessWidget  {
  String? imageName;
  String? title;
  String? recommenderId;
  bool showData;
  String? currencyCode;
  String? subtitle;
  String? entryPrice;
  String? livePrice;
  String? stopLoss;
  bool? activeItem;
  String? riskType;
  String? inProfitStatus;
  String? inProfitLabel;
  String? userType;
  String? isSameUser;

  ListItemWidget(
      {Key? key,
      this.userType = "guest",
      this.imageName,
      required this.showData,
      required this.recommenderId,
      this.currencyCode,
      this.stopLoss,
      this.entryPrice,
      this.livePrice,
      this.title,
      this.subtitle,
      this.activeItem = true,
      this.inProfitStatus,
      this.inProfitLabel,
      required this.isSameUser,
      this.riskType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, widget) {
      final drawerWatch = ref.watch(drawerProvider);
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: (showData ||
                getUserEntityId() == recommenderId ||
                isSameUser == '1')
            ? cardWidget(drawerWatch,context)
            : Blur(
                borderRadius: BorderRadius.circular(10.r),
                blurColor: Constant.clrDarkByScaffoldTheme(context).withOpacity(0.2),
                child: cardWidget(drawerWatch,context),
              ),
      );
    });
  }

  Widget cardWidget(CustomDrawerController drawerWatch,BuildContext context) {
    return Card(
      color: activeItem == false
          ? Constant.clrPrimaryLight.withOpacity(0.2)
          : Constant.clrDarkByScaffoldTheme(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      elevation: 0,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 15.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CacheImage(
                      imageURL: imageName.toString(),
                      height: 45.h,
                      width: 45.h,
                      contentMode: BoxFit.fill,
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toString(),
                            style: TextStyles.txtMedium14(context).copyWith(
                              color: Constant.clrWhiteBlackByTheme(context),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                subtitle.toString(),
                                style: TextStyles.txtMedium12(context).copyWith(
                                  color: Constant.clrWhiteBlackNewByTheme(context),
                                ),
                              ),
                              SizedBox(
                                width: 25.w,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Visibility(
                                      visible: inProfitStatus == 'in_loss' ||
                                          inProfitStatus == 'in_profit',
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                            color: riskType == "medium"
                                                ? Constant.clrDarkPurple
                                                : riskType == "high"
                                                    ? Constant.clrDarkBlue
                                                    : Constant.clrDarkGreenNew),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7.w, vertical: 3.h),
                                        child: Text(
                                          (riskType == "medium")
                                              ? 'Key_MediumRisk'.localized
                                              : (riskType == "high")
                                                  ? 'Key_HighRisk'.localized
                                                  : 'Key_LowRisk'.localized,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyles.txtRegular12
                                              (context).copyWith(
                                                  fontSize: 8.sp,
                                                  color: Constant.clrWhite),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          color: inProfitStatus == 'in_loss' ||
                                                  inProfitStatus ==
                                                      'closed_in_loss'
                                              ? Constant.clrLightRed
                                              : Constant.clrDarkGreen),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 7.w, vertical: 3.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CommonImageAsset(
                                            strIcon:
                                                inProfitStatus == 'in_loss' ||
                                                        inProfitStatus ==
                                                            'closed_in_loss'
                                                    ? Constant.icLoss
                                                    : Constant.icProfit,
                                            clrImg: Constant.clrWhite,
                                          ),
                                          SizedBox(
                                            width: 4.w,
                                          ),
                                          Text(
                                            inProfitLabel ?? '',
                                            textAlign: TextAlign.center,
                                            style: TextStyles.txtRegular12
                                                (context).copyWith(
                                                    fontSize: 8.sp,
                                                    color: Constant.clrWhite),
                                          ),
                                        ],
                                      ),
                                    ).paddingOnly(right: 20.w),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 26.w,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Key_LivePrice".localized,
                          style: TextStyles.txtRegular10(context).copyWith(
                            color: Constant.clrBlackWhiteByTheme(context),
                          ),
                        ),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            text: livePrice.toString(),
                            style: TextStyles.txtMedium12(context).copyWith(
                              color: Constant.clrBlackWhiteByTheme(context),
                            ),
                            children: [
                              const TextSpan(text: " "),
                              TextSpan(
                                text: currencyCode,
                                style: TextStyles.txtMedium12(context).copyWith(
                                    color: Constant.clrBlackWhiteByTheme(context),
                                    fontWeight: Constant.fwLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          "Key_EntryPrice".localized,
                          style: TextStyles.txtRegular10(context).copyWith(
                            color: Constant.clrBlackWhiteByTheme(context),
                          ),
                        ),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            text: entryPrice.toString(),
                            style: TextStyles.txtMedium12(context).copyWith(
                              color: Constant.clrBlackWhiteByTheme(context),
                            ),
                            children: [
                              const TextSpan(text: " "),
                              TextSpan(
                                text: currencyCode,
                                style: TextStyles.txtMedium12(context).copyWith(
                                    color: Constant.clrBlackWhiteByTheme(context),
                                    fontWeight: Constant.fwLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          "Key_StopLoss".localized,
                          style: TextStyles.txtRegular10(context).copyWith(
                            color: Constant.clrBlackWhiteByTheme(context),
                          ),
                        ),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            text: stopLoss.toString(),
                            style: TextStyles.txtMedium12(context).copyWith(
                              color: Constant.clrBlackWhiteByTheme(context),
                            ),
                            children: [
                              const TextSpan(text: " "),
                              TextSpan(
                                text: currencyCode,
                                style: TextStyles.txtMedium12(context).copyWith(
                                    color: Constant.clrBlackWhiteByTheme(context),
                                    fontWeight: Constant.fwLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 20.h,
            right: drawerWatch.isEngEnable == false ? 0.w : 15.w,
            left: drawerWatch.isEngEnable == false ? 15.w : 0.w,
            child: Align(
              alignment: drawerWatch.isEngEnable == false
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26.h / 2 - 26.h / 18),
                child: Transform.rotate(
                  angle: (drawerWatch.isEngEnable == false) ? pi : 0,
                  child: CommonSVG(strIcon: Constant.svgForward, boxFit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
