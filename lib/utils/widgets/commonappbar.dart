import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/extension.dart';
import 'dart:math';

import '../../framework/data_provider/profile/profile_provider.dart';
import '../const.dart';
import '../theme_const.dart';
import 'common_svg.dart';


class CommonAppBar extends ConsumerWidget

    implements PreferredSizeWidget {
  String title;
  String subTitle;
  Function()? onPress;
  bool isTitleCenter = true;
  bool isLeading = true;
  bool isDrawer = false;
  bool isCenterAppIcon = false;
  final List<Widget>? action;
  final AppBar appBar;
  final Widget? leading;
  Color? titleColor;
  bool isPremiumIconRequired;
  final TextStyle? titleTextStyle;
  Color? backgroundColor;

  CommonAppBar(
      {super.key,
      required this.title,
      this.subTitle = "",
      this.onPress,
      this.isTitleCenter = true,
      required this.appBar,
      this.isLeading = true,
      this.isDrawer = false,
      this.isCenterAppIcon = false,
      this.action,
      this.leading,
      this.isPremiumIconRequired = false,
      this.titleColor,
      this.titleTextStyle,
      this.backgroundColor,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultTitleStyle = TextStyle(
      fontSize: 16.sp,
      color: titleColor ?? Constant.clrTitlePageByTheme(context),
      fontWeight: Constant.fwRegular,
      fontFamily: Constant.fontFamily
    );
    return AppBar(
      centerTitle: isTitleCenter,
      actionsPadding: EdgeInsets.zero,
      leading: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: leading ??
            (isLeading
                ? isDrawer
                    ? GestureDetector(
                        onTap: () {
                          showLog("-----On Tap Of Drawer Icon------");
                          ZoomDrawer.of(context)?.toggle.call();
                        },
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          padding: EdgeInsets.all(4.w),
                          child: Center(child: const _DrawerLeadingAvatar()),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
                        onPressed: onPress ??
                            () {
                              Navigator.pop(context);
                            },
                      )
                : const Offstage()),
      ),
      elevation: 0,
       actions: action ,
      backgroundColor: backgroundColor ?? appBar.backgroundColor ?? Constant.clrHomeScreenByTheme(context) ,//Constant.clrDarkByScaffoldTheme(context),
      titleSpacing:  4 ,
      title: isCenterAppIcon
          ? Image.asset(
        Constant.icAppIcon,
              color: Constant.clrWhiteBlackByTheme(context),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: (ref
                              .watch(profileProvider)
                              .profileDetailResponseModel
                              ?.data
                              ?.isPremiumUser ==
                          '1' &&
                      isPremiumIconRequired),
                  replacement: Text(
                    title,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.fade,
                    style: titleTextStyle ?? defaultTitleStyle,),
                  //   TextStyle(
                  //       fontSize: 16.sp,
                  //       color: titleColor ?? Constant.clrWhiteBlackByTheme(),
                  //       fontWeight: Constant.fwMedium),
                  // ),
                  child: Row(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          title,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: titleTextStyle ?? defaultTitleStyle,
                          // TextStyle(
                          //     fontSize: 16.sp,
                          //     color: titleColor ?? Constant.clrWhiteBlackByTheme(),
                          //     fontWeight: Constant.fwMedium),
                        ).paddingOnly(right: 5.w),
                      ),
                      CommonSVG(
                        strIcon: Constant.svgPremiumUser,
                        height: 15.h,
                        width: 15.h,
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: subTitle == "" ? false : true,
                  child: Text(
                    subTitle,
                    style: TextStyles.txtRegular10(context).copyWith(color: Constant.clrBlackNew),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}


class _DrawerLeadingAvatar extends ConsumerWidget {
  const _DrawerLeadingAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final String? imageUrl = profileState.profileDetailResponseModel?.data?.profileImage;

    // Sizes from requirements (use uniform scaling to keep circle perfectly round)
    final double avatarSize = 28.r;
    final double crownCircleSize = 22.58.r;
    final double crownWidth = 12.28.r;
    final double crownHeight = 10.02.r;

    final bool isGuestUser = getUserStatus() == guest;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final bool showGuestAvatar = isGuestUser || !hasImage;

    Widget avatar;
    if (showGuestAvatar) {
      avatar = SizedBox.square(
        dimension: avatarSize,
        child: ClipOval(
          child: Image.asset(
            Constant.icGuestN,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      );
    } else {
      avatar = SizedBox.square(
        dimension: avatarSize,
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              Constant.icGuestN,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          avatar,
          // if (showGuestAvatar)
          //   Positioned(
          //     // Place the glass button slightly OUTSIDE the avatar at the bottom-center
          //     bottom: - (crownCircleSize * 0.18),
          //     child: Container(
          //       width: crownCircleSize,
          //       height: crownCircleSize,
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: Colors.white.withValues(alpha: 0.18), // glassy fill
          //         border: Border.all(
          //           color: Colors.white.withValues(alpha: 0.55),
          //           width: 0.8,
          //         ),
          //       ),
          //       alignment: Alignment.center,
          //       child: Image.asset(
          //         Constant.icCrownN,
          //         width: crownWidth,
          //         height: crownHeight,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
