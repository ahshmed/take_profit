import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/theme_const.dart';
import '../../../framework/data_provider/home/home_provider.dart';
import '../../../utils/const.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final List<BottomNavItem> items;
  final Function(int) onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardWatch = ref.watch(dashboardProvider);
    final selectedIndex = dashboardWatch.selectedIndex;
    final double width = MediaQuery.of(context).size.width;
    final double itemWidth = width / items.length;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Detect text direction
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    // Sizes for the design
    final double barHeight = 80.h;
    final double circleSize = 16.26.w;
    final double cutoutDepth = 12.h;
    final double iconSize = 22.w;

    // Calculate the actual visual index based on RTL
    final int visualIndex = isRTL ? (items.length - 1 - selectedIndex) : selectedIndex;

    return SizedBox(
      height: barHeight + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
              child: Container(color: Constant.clrTransparent,)),
          // Main bar with REAL transparent cutout hole
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _BottomNavClipper(
                centerX: itemWidth * visualIndex + (itemWidth / 2),
                circleSize: circleSize,
                cutoutDepth: cutoutDepth,
                barHeight: barHeight,
                bottomPadding: bottomPadding,
              ),
              child: Container(
                height: barHeight + bottomPadding,
                color: Constant.clrDarkByScaffoldTheme(context),
              ),
            ),
          ),

          // Purple circle - positioned in the cutout
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

          // Navigation items
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight + bottomPadding,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final bool isSelected = selectedIndex == index;
                  return Expanded(
                    child: _buildNavItem(
                      context,
                      item,
                      isSelected,
                          () => onTabSelected(index),
                      iconSize,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              color: isSelected ? Constant.clrPrimary : Constant.clrNavByTheme(context),
            ),
            SizedBox(height: 2.h),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected ? Constant.clrPrimary : Constant.clrNavByTheme(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily:Constant.fontFamily
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
}

class BottomNavItem {
  final String iconPath;
  final String label;
  final Widget screen;

  BottomNavItem({
    required this.iconPath,
    required this.label,
    required this.screen,
  });
}

/// Custom clipper that creates a REAL hole in the navigation bar
class _BottomNavClipper extends CustomClipper<Path> {
  final double centerX;
  final double circleSize;
  final double cutoutDepth;
  final double barHeight;
  final double bottomPadding;

  _BottomNavClipper({
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
    final double cx = centerX.clamp(circleSize, w - circleSize);
    final double circleRadius = circleSize / 2;

    final double notchWidth = circleRadius * 3;
    final double notchHeight = cutoutDepth * 1.5;

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
        cx - notchWidth, 0,
        cx - notchWidth, notchHeight,
        cx, notchHeight,
      )
    // Come back up on the right side
      ..cubicTo(
        cx + notchWidth, notchHeight,
        cx + notchWidth, 0,
        cx + notchWidth, 0,
      )
    // Line to top right
      ..lineTo(w, 0)
    // Line down to bottom right
      ..lineTo(w, h + bottomPadding)
    // Close the path
      ..close();

    // Create the inner circle path (the hole)
    final Path holePath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(cx, notchHeight / 2),
        radius: circleRadius + 1, // Slightly larger for smooth edges
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
  bool shouldReclip(covariant _BottomNavClipper oldClipper) {
    return oldClipper.centerX != centerX ||
        oldClipper.circleSize != circleSize ||
        oldClipper.cutoutDepth != cutoutDepth ||
        oldClipper.barHeight != barHeight ||
        oldClipper.bottomPadding != bottomPadding;
  }
}