import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/ui/home/helper/tab_clipper.dart';
import 'package:take_profit/ui/home/helper/tab_icon_data.dart';
import 'package:take_profit/ui/home/helper/tab_icons.dart';

import '../../../framework/data_provider/drawer/drawer_provider.dart';
import '../../../framework/data_provider/home/dashboard_screen_controller.dart';
import '../../../framework/data_provider/home/home_provider.dart';
import '../../../utils/const.dart';
import '../../../utils/darkmode/dark_provider.dart';
import '../../../utils/sliderightroute.dart';
import '../../../utils/theme_const.dart';
import '../../recommendation/create_signal_screen.dart';


class BottomBarView extends ConsumerStatefulWidget {
  const BottomBarView(
      {Key? key,
        required this.tabIconsList,
        required this.changeIndex,
        required this.addClick})
      : super(key: key);

  final Function(TabIconData index) changeIndex;
  final Function addClick;
  final List<TabIconData> tabIconsList;

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends ConsumerState<BottomBarView>  {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final darkModeWatch = ref.watch(darkProvider);
      final drawerWatch = ref.watch(drawerProvider);
      final dashboardWatch = ref.watch(dashboardProvider);
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Transform(
            transform: Matrix4.translationValues(0.0, 0.0, 0.0),
            child: PhysicalShape(
              color: Constant.clrScaffoldBGByTheme(context),
              elevation: 16.h,
              clipper: TabClipper(
                  radius: getUserStatus() == recommender ? 38.r : 0.r),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 80.h,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 4.h),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TabIcons(
                                tabIconData: widget.tabIconsList[0],
                                removeAllSelect: () {
                                  setRemoveAllSelection(
                                      widget.tabIconsList[0], dashboardWatch);
                                  widget.changeIndex(widget.tabIconsList[0]);
                                }),
                          ),
                          Expanded(
                            child: TabIcons(
                                tabIconData: widget.tabIconsList[1],
                                removeAllSelect: () {
                                  setRemoveAllSelection(
                                      widget.tabIconsList[1], dashboardWatch);
                                  widget.changeIndex(widget.tabIconsList[1]);
                                }),
                          ),
                          getUserStatus() == recommender
                              ? SizedBox(width: 64.w)
                              : const SizedBox(),
                          Expanded(
                            child: TabIcons(
                                fontSize: 8.sp,
                                tabIconData: widget.tabIconsList[2],
                                removeAllSelect: () {
                                  setRemoveAllSelection(
                                      widget.tabIconsList[2], dashboardWatch);
                                  widget.changeIndex(widget.tabIconsList[2]);
                                }),
                          ),
                          Expanded(
                            child: TabIcons(
                                tabIconData: widget.tabIconsList[3],
                                removeAllSelect: () {
                                  setRemoveAllSelection(
                                      widget.tabIconsList[3],
                                      dashboardWatch);
                                  widget.changeIndex(
                                      widget.tabIconsList[3]);
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
            ),
          ),
          getUserStatus() == recommender
              ? Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: 38 * 2,
              height: getIsIOSPlatform() ? 100.h : 110.h,
              child: Container(
                alignment: Alignment.topCenter,
                color: Constant.clrTransparent,
                child: SizedBox(
                  width: 38 * 2,
                  height: 38 * 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                    child: Container(
                      decoration: const BoxDecoration(
                        //color: clrWhiteNew,
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.1),
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onTap: () {
                            Route route = SlideRightPageRoute(
                              builder: (context) =>
                              const CreateSignalScreen(),
                              settings: const RouteSettings(),
                            );
                            Navigator.of(context).push(route);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(68.r),
                            ),
                            child: Image.asset(Constant.icRecommenderBottomIcon),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
              : const SizedBox(),
        ],
      );
    });
  }

  void setLibrary(DashboardScreenController dashboardWatch) {
    setRemoveAllSelection(widget.tabIconsList[2], dashboardWatch);
    widget.changeIndex(widget.tabIconsList[2]);
  }

  void setRemoveAllSelection(
      TabIconData tabIconData, DashboardScreenController dashboardWatch) {
    if (!mounted) return;
    for (var tab in widget.tabIconsList) {
      tab.isSelected = false;
      if (tabIconData.index == tab.index) {
        tab.isSelected = true;
      }
    }
  }
}
