import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/home/dashboard_screen_controller.dart';
import '../../framework/data_provider/select_market/market_providers.dart';
import '../../framework/repository/select_market/market_model.dart';
import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/extension/string_extension.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../drawer/drawer_menu.dart';
import '../home/dashboard_screen.dart';

class SelectMarketScreen extends ConsumerStatefulWidget {
  const SelectMarketScreen({super.key});

  @override
  ConsumerState<SelectMarketScreen> createState() => _ChooseMarketScreenState();
}

class _ChooseMarketScreenState extends ConsumerState<SelectMarketScreen> {
  @override
  Widget build(BuildContext context) {
    final marketState = ref.watch(selectMarketProvider);

    return Scaffold(
      backgroundColor: Colors.white, // Adjust based on your theme
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Section with Stack for overlapping images
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Main Background Image
                  Container(
                    width: 375.w,
                    height: 183.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15.r),
                        bottomRight: Radius.circular(15.r),
                      ),
                      image: DecorationImage(
                        image: AssetImage(Constant.icSelectMarketMain),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Sub Image positioned in the middle bottom
                  Positioned(
                    bottom: -2.h, // This will make it overlap slightly with the content below
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        Constant.icSelectMarketSub,
                        fit: BoxFit.contain,
                        height:97.39 ,
                        width: 130,
                      ),
                    ),
                  ),
                ],
              ),

              // Add extra space to account for the overlapping image
              SizedBox(height: 40.h), // Increased from 25.h to 40.h to accommodate the overlapping image

              // Title Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  getLocalValue("Key_SMarketHeader"),
                  style: TextStyles.txtSemiG24(context).copyWith(
                    fontWeight: Constant.fwMedium,
                    color: Constant.clrSigDetByTheme(context),
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              // Description Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  getLocalValue("Key_SMarketBody"),
                  style: TextStyles.txtRegG14(context).copyWith(
                      color: Constant.clrSelectLabelColor
                  ), // Adjust color based on theme

                ),
              ),

              SizedBox(height: 25.h),

              // Market Cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  children: [
                    // US Market Card
                    _buildMarketCard(
                      market: marketState.markets.firstWhere(
                            (m) => m.id == 'us_market',
                        orElse: () =>
                            Market(
                              id: 'us_market',
                              title: 'US Market Signals',
                              description: 'Stay ahead with real-time signals from top U.S. stock movers and trends.',
                              imagePath: Constant.icUsMarketLogo,
                            ),
                      ),
                      onTap: () {
                        ref.read(selectMarketProvider.notifier).selectMarket(
                          marketState.markets.firstWhere(
                                (m) => m.id == 'us_market',
                            orElse: () =>
                                Market(
                                  id: 'us_market',
                                  title: 'US Market',
                                  description: 'Stock market signals and analysis for US markets',
                                  imagePath: 'assets/images/us_market.png',
                                ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 15.h),

                    // Crypto Signals Card
                    _buildMarketCard(
                      market: marketState.markets.firstWhere(
                            (m) => m.id == 'crypto_signals',
                        orElse: () =>
                            Market(
                              id: 'crypto_signals',
                              title: 'Crypto Signals',
                              description: 'Cryptocurrency trading signals and market analysis',
                              imagePath: Constant.icCryptoLogo,
                            ),
                      ),
                      onTap: () {
                        ref.read(selectMarketProvider.notifier).selectMarket(
                          marketState.markets.firstWhere(
                                (m) => m.id == 'crypto_signals',
                            orElse: () =>
                                Market(
                                  id: 'crypto_signals',
                                  title: 'Crypto Signals',
                                  description: 'Get instant updates on major crypto shifts, breakouts, and market alerts.',
                                  imagePath: Constant.icCryptoLogo,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Continue Button (optional)
              if (marketState.selectedMarket != null) ...[
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (marketState.selectedMarket != null) {
                          // FIXED: Save the selection AND set first time user to false
                          ref.read(selectMarketProvider.notifier).selectMarket(
                              marketState.selectedMarket!
                          );

                          // CRITICAL FIX: Mark that user has completed market selection
                          setFirstTimeUser(false);

                          // Navigate to dashboard and force tab reset to home
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                                (route) => false,
                          );

                          // Reset to home tab (index 0)
                          Future.delayed(const Duration(milliseconds: 100), () {
                            ref.read(dashboardProvider).updateSelectedIndex(0);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constant.clrPrimary, // Your primary color
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                          getLocalValue("Key_Continue"),
                          style: TextStyles.txtSemiG16(context).copyWith(
                              fontWeight: Constant.fwRegular,
                              color: Constant.clrButtonByTheme(context))
                      ),

                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketCard({
    required Market market,
    required VoidCallback onTap,
  }) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 345.w,
        height: 120.15.h,
        decoration: BoxDecoration(
          color: market.isSelected ? Constant.clrMarketColor : Constant.clrWhite,
          borderRadius: BorderRadius.circular(15.r),
          border: market.isSelected
              ? Border.all(color: Constant.clrMarketSelectColor, width: 2.w)
              : null,
        ),
        child: Stack(
          children: [
            // Content Row
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Market Image
                  Container(
                    width: 53.25.w,
                    height: 53.25.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                      // Replace with your actual image loading logic
                      color: Constant.clrWhite,
                    ),
                    child: market.imagePath.isNotEmpty
                        ? Image.asset(
                      market.imagePath,
                      fit: BoxFit.none,
                      height: market.id == 'crypto_signals' ? 53.25.h : 28.h,
                      width: market.id == 'crypto_signals' ? 53.25.w : 28.w,
                    )
                        : Icon(
                      Icons.business,
                      size: 30.w,
                      color: market.isSelected ? Colors.white : Colors
                          .grey[600],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          market.title,
                          style: TextStyles.txtSemiBold18(context).copyWith(
                              fontWeight: Constant.fwMedium,
                              color: market.isSelected ? Constant.clrWhite : Constant.clrSelectMarketByTheme(context)
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Description
                        Text(
                          market.description,
                          style: TextStyles.txtRegG12(context).copyWith(
                              fontWeight: Constant.fwLight,
                              color: market.isSelected ? Constant.clrWhite : Constant.clrSelectMarketByTheme(context)
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selection Circle (Top Right/Left)
            Positioned(
              top: 12.w,
              left: isRtl ? 12.w : null, // Positioned on the left for RTL languages
              right: isRtl ? null : 12.w, // Positioned on the right for LTR languages
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: market.isSelected ? Constant.clrMarketSelectColor : Colors.transparent,
                  border: Border.all(
                    color: market.isSelected ? Constant.clrMarketSelectColor : Colors.grey,
                    width: 2.w,
                  ),
                  shape: BoxShape.circle,
                ),
                child: market.isSelected
                    ? Icon(
                  Icons.check,
                  size: 16.w,
                  color: Constant.clrWhite,
                )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMarketSelection(Market selectedMarket) {
    // Save the market selection and set user status
    setSelectedMarket(selectedMarket.id);
    setFirstTimeUser(false);
    saveLocalData(KEY_USER_STATUS, guest);

    // Navigate to the main app screen
    Route route = SlideRightPageRoute(
      builder: (context) => const DrawerMenu(), // Your main app screen
      settings: const RouteSettings(),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }
}