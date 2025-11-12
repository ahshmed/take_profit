import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/theme_const.dart';
import '../../../framework/data_provider/home/home_provider.dart';
import '../../../utils/const.dart';
import '../../../utils/sliderightroute.dart';
import '../../recommendation/create_signal_screen.dart';
import 'custom_bottom_nav_bar.dart';

/// Recommender Bottom Navigation Bar with center floating button
/// Styled to match the new CustomBottomNavBar design
class RecommenderBottomNavBar extends ConsumerWidget {
  final List<BottomNavItem> items;
  final Function(int) onTabSelected;

  const RecommenderBottomNavBar({
    super.key,
    required this.items,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardWatch = ref.watch(dashboardProvider);
    final selectedIndex = dashboardWatch.selectedIndex;
    final double width = MediaQuery.of(context).size.width;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Detect text direction
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    // Sizes for the design (matching CustomBottomNavBar)
    final double barHeight = 80.h;
    final double circleSize = 16.26.w;
    final double cutoutDepth = 12.h;
    final double iconSize = 22.w;
    final double centerButtonSize = 76.w;

    // For recommender mode: 2 tabs on left, center button, 2 tabs on right
    // Total 5 positions for layout calculation
    final double itemWidth = width / 5;

    // Calculate visual index for the purple circle indicator
    int visualIndex;
    if (selectedIndex <= 1) {
      // Tabs 0 and 1 are on the left
      visualIndex = isRTL ? (1 - selectedIndex) : selectedIndex;
    } else {
      // Tabs 2 and 3 are on the right side of center button
      // Skip position 2 (center button position)
      visualIndex = isRTL ? (4 - selectedIndex) : (selectedIndex + 1);
    }

    return SizedBox(
      height: barHeight + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Transparent background
          Positioned.fill(
            child: Container(color: Constant.clrTransparent),
          ),

          // Main bar with center cutout for floating button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _RecommenderBottomNavClipper(
                centerX: width / 2,
                circleSize: centerButtonSize,
                cutoutDepth: 20.h,
                barHeight: barHeight,
                bottomPadding: bottomPadding,
              ),
              child: Container(
                height: barHeight + bottomPadding,
                color: Constant.clrDarkByScaffoldTheme(context),
              ),
            ),
          ),

          // Purple circle indicator - positioned in the cutout
          AnimatedPositioned(
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeInOut,
            bottom: barHeight - (circleSize / 2) + bottomPadding,
            left: itemWidth * visualIndex + (itemWidth / 2) - (circleSize / 2),
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: Constant.clrPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Navigation items (4 tabs in 2+2 layout with center space)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight + bottomPadding,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(
                children: _buildTabItems(context, selectedIndex, iconSize),
              ),
            ),
          ),

          // Center floating button
          _buildCenterButton(context, bottomPadding),
        ],
      ),
    );
  }

  /// Build tab items with 2+2 layout and center space
  List<Widget> _buildTabItems(
      BuildContext context,
      int selectedIndex,
      double iconSize,
      ) {
    return [
      // Left tabs (0, 1)
      Expanded(
        child: _buildNavItem(
          context,
          items[0],
          selectedIndex == 0,
              () => onTabSelected(0),
          iconSize,
        ),
      ),
      Expanded(
        child: _buildNavItem(
          context,
          items[1],
          selectedIndex == 1,
              () => onTabSelected(1),
          iconSize,
        ),
      ),
      // Center space for floating button
      SizedBox(width: 64.w),
      // Right tabs (2, 3)
      Expanded(
        child: _buildNavItem(
          context,
          items[2],
          selectedIndex == 2,
              () => onTabSelected(2),
          iconSize,
        ),
      ),
      Expanded(
        child: _buildNavItem(
          context,
          items[3],
          selectedIndex == 3,
              () => onTabSelected(3),
          iconSize,
        ),
      ),
    ];
  }

  /// Build individual navigation item (matching CustomBottomNavBar style)
  Widget _buildNavItem(
      BuildContext context,
      BottomNavItem item,
      bool isSelected,
      VoidCallback onTap,
      double iconSize,
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              item.iconPath,
              width: iconSize,
              height: iconSize,
              color: isSelected
                  ? Constant.clrPrimary
                  : Constant.clrNavByTheme(context),
            ),
            SizedBox(height: 2.h),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected
                    ? Constant.clrPrimary
                    : Constant.clrNavByTheme(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: Constant.fontFamily,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build center floating button for creating signals
  Widget _buildCenterButton(BuildContext context, double bottomPadding) {
    return Positioned(
      bottom: bottomPadding,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 76.w,
          height: getIsIOSPlatform() ? 100.h : 110.h,
          child: Container(
            alignment: Alignment.topCenter,
            color: Constant.clrTransparent,
            child: SizedBox(
              width: 76.w,
              height: 76.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(38.w),
                    onTap: () {
                      Route route = SlideRightPageRoute(
                        builder: (context) => const CreateSignalScreen(),
                        settings: const RouteSettings(),
                      );
                      Navigator.of(context).push(route);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(38.w),
                      ),
                      child: Image.asset(
                        Constant.icRecommenderBottomIcon,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom clipper for recommender mode (fixed center cutout)
class _RecommenderBottomNavClipper extends CustomClipper<Path> {
  final double centerX;
  final double circleSize;
  final double cutoutDepth;
  final double barHeight;
  final double bottomPadding;

  _RecommenderBottomNavClipper({
    required this.centerX,
    required this.circleSize,
    required this.cutoutDepth,
    required this.barHeight,
    required this.bottomPadding,
  });

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = barHeight;
    final double cx = centerX;
    final double circleRadius = circleSize / 2;

    final double notchWidth = circleRadius * 1.5;
    final double notchHeight = cutoutDepth * 2;

    // Create the outer path (the navigation bar shape)
    final Path outerPath = Path()
    // Start from bottom left
      ..moveTo(0, h + bottomPadding)
    // Line up to top left
      ..lineTo(0, 0)
    // Line to start of notch
      ..lineTo(cx - notchWidth, 0)
    // Create smooth notch curve (going down)
      ..cubicTo(
        cx - notchWidth,
        0,
        cx - notchWidth,
        notchHeight,
        cx,
        notchHeight,
      )
    // Come back up on the right side
      ..cubicTo(
        cx + notchWidth,
        notchHeight,
        cx + notchWidth,
        0,
        cx + notchWidth,
        0,
      )
    // Line to top right
      ..lineTo(w, 0)
    // Line down to bottom right
      ..lineTo(w, h + bottomPadding)
    // Close the path
      ..close();

    // Create the inner circle path (the hole for the center button)
    final Path holePath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(cx, notchHeight / 2),
        radius: circleRadius + 2, // Slightly larger for smooth edges
      ));

    // Subtract the hole from the outer path to create a real cutout
    final Path finalPath = Path.combine(
      PathOperation.difference,
      outerPath,
      holePath,
    );

    return finalPath;
  }

  @override
  bool shouldReclip(covariant _RecommenderBottomNavClipper oldClipper) {
    return oldClipper.centerX != centerX ||
        oldClipper.circleSize != circleSize ||
        oldClipper.cutoutDepth != cutoutDepth ||
        oldClipper.barHeight != barHeight ||
        oldClipper.bottomPadding != bottomPadding;
  }
}