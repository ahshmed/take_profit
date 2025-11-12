// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/home/helper/tab_icon_data.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../../framework/data_provider/drawer/drawer_provider.dart';
import '../../../framework/data_provider/home/home_provider.dart';
import '../../../framework/data_provider/profile/profile_provider.dart';
import '../../../utils/theme_const.dart';
import '../../../utils/widgets/cache_image.dart';


class TabIcons extends ConsumerStatefulWidget {
  const TabIcons(
      {Key? key,
        required this.tabIconData,
        required this.removeAllSelect,
        this.fontSize})
      : super(key: key);

  final TabIconData tabIconData;
  final Function removeAllSelect;
  final double? fontSize;

  @override
  _TabIconsState createState() => _TabIconsState();
}

class _TabIconsState extends ConsumerState<TabIcons>
    with TickerProviderStateMixin {
  @override
  void initState() {
    widget.tabIconData.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        widget.removeAllSelect();
        widget.tabIconData.animationController!.reverse();
      }
    });
    super.initState();
  }

  void setAnimation() {
    widget.tabIconData.animationController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final profileWatch = ref.watch(profileProvider);
      final dashboardWatch = ref.watch(dashboardProvider);
      final drawerWatch = ref.watch(drawerProvider);
      return AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: InkWell(
            splashColor: Constant.clrTransparent,
            focusColor: Constant.clrTransparent,
            highlightColor: Constant.clrTransparent,
            hoverColor: Constant.clrTransparent,
            onTap: () {
              if (!widget.tabIconData.isSelected) {
                setAnimation();
              }
            },
            child: IgnorePointer(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  ScaleTransition(
                    alignment: Alignment.center,
                    scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                        CurvedAnimation(
                            parent: widget.tabIconData.animationController ??
                                AnimationController(
                                  vsync: this,
                                  duration: const Duration(milliseconds: 100),
                                ),
                            curve: const Interval(0.1, 1.0,
                                curve: Curves.fastOutSlowIn))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (widget.tabIconData.index == 3)
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(35.h / 2 - 35.h / 18),
                          child: CacheImage(
                            imageURL: profileWatch
                                .profileDetailResponseModel
                                ?.data
                                ?.profileImage ??
                                "",
                            isProfileImg: true,
                            height: 35.h,
                            width: 35.h,
                          ),
                        )
                            : widget.tabIconData.isSelected
                            ? widget.tabIconData.selectedImagePath
                            : widget.tabIconData.imagePath,
                        SizedBox(
                          height: 9.h,
                        ),
                        Text(
                          widget.tabIconData.name.localized,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          style: TextStyles.txtRegular10(context).copyWith(
                              fontSize: widget.fontSize ?? 10,
                              color: widget.tabIconData.isSelected
                                  ? Constant.clrPrimary
                                  : Constant.clrWhiteBlackByTheme(context)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
