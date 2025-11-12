// ignore_for_file: unused_local_variable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/data_provider/notification/notification_controller.dart';
import '../../framework/data_provider/notification/notification_provider.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/profile/profile_screen_controller.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/common_svg.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../auth/create_password_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/sign_up_bank_details_screen.dart';
import '../drawer/drawer_menu.dart';
import 'add_email_screen.dart';
import 'add_social_links.dart';
import 'edit_profile_screen.dart';
import 'edit_subscription_amount_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (getUserStatus() == guest) {
        getStartedDialog(context);
        final drawerWatch = ref.read(drawerProvider);
        drawerWatch.updateDrawerPosition(0);
      }
    },);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final profileWatch = ref.watch(profileProvider);
      final notificationWatch = ref.watch(notificationProvider);
      notificationCountAPICall(notificationWatch);
      profileAPI(profileWatch);
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final profileWatch = ref.watch(profileProvider);
    final darkModeWatch = ref.watch(darkProvider);
    final drawerWatch = ref.watch(drawerProvider);
    final notificationWatch = ref.watch(notificationProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue("Key_Menu"),
            titleTextStyle: TextStyles.txtMedG16(context),
            subTitle: "",
            isTitleCenter: false,
            appBar: AppBar(
                backgroundColor: Constant.clrScaffoldBGByTheme(context),
                toolbarHeight: 64.h),
            //isDrawer: true,
            leading: IconButton(
                onPressed: (){
                  ZoomDrawer.of(context)?.toggle.call();
                },
                icon: Transform.rotate(
                    angle: (getAppLanguage() == 'ar')? pi :0,
                    child: Icon(Icons.arrow_back_ios) ,
                )
            ),
            action: [
              // Sign Out Button in AppBar
              TextButton(
                onPressed: () {
                  _showSignOutDialog(context);
                },
                child: Row(children: [

                    Text(
                       getLocalValue("Key_SignOut"),
                       style: TextStyles.txtMedG12(context).copyWith(
                       color: Constant.clrSignOutRColor,
                         ),
                    ),
                  SizedBox(width: 5.w),
                  Icon(
                    Icons.logout,
                    color: Constant.clrSignOutRColor,
                    size: 18.h,

                  ),
                ],),

              ),
              SizedBox(width: 10.w),
            ],
          ),
          body: NoInternetBuilder(
            child: bodyWidget(profileWatch),
          ),
        ),
        DialogProgressBar(
          isLoading: profileWatch.isLoading || notificationWatch.isLoading,
        ),
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(ProfileScreenController profileWatch) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: (MediaQuery.of(context).padding.bottom + 8).h),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30.h),
            // Profile Header
            _buildProfileHeader(profileWatch),
            SizedBox(height: 40.h),

            // Profile Settings Section
            _buildProfileSettingsSection(profileWatch),

            SizedBox(height: 30.h),

            // Additional Sections for Recommender
            if (getUserStatus() == recommender) ...[
              //_buildMobileAndEmailSection(profileWatch),
              SizedBox(height: 20.h),
              _buildBankDetailsSection(profileWatch),
              SizedBox(height: 20.h),
              _buildSubscriptionSection(profileWatch),
              SizedBox(height: 20.h),
              _buildSocialLinksSection(profileWatch),
            ] else ...[
              //_buildMobileAndEmailSection(profileWatch),
            ],

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  /// Profile Header with Avatar, Name and Email
  Widget _buildProfileHeader(ProfileScreenController profileWatch) {
    return Column(
      children: [
        // Profile Avatar
        Stack(
          children: [
            Container(
              height: 120.h,
              width: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Constant.clrPrimary.withValues(alpha: 0.2),
                  width: 3.w,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60.r),
                child: (profileWatch.profileDetailResponseModel?.data
                    ?.profileImage !=
                    '')
                    ? CacheImage(
                  imageURL: profileWatch
                      .profileDetailResponseModel?.data?.profileImage ??
                      "",
                  isProfileImg: true,
                  height: 100.h,
                  width: 100.h,
                  contentMode: BoxFit.cover,
                )
                    : CommonImageAsset(
                  strIcon: Constant.icProfileImage,
                  height: 100.h,
                  width: 100.h,
                ),
              ),
            ),
            // Premium Badge
            if (profileWatch.profileDetailResponseModel?.data?.isPremiumUser ==
                '1')
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Constant.clrPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Constant.clrScaffoldBGByTheme(context),
                      width: 2.w,
                    ),
                  ),
                  child: CommonSVG(
                    strIcon: Constant.svgPremiumUser,
                    height: 16.h,
                    width: 16.h,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),

        // Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                profileWatch.profileDetailResponseModel?.data?.name ?? "",
                style: TextStyles.txtSemiBoldG20(context).copyWith(
                  color: Constant.clrWhiteBlackByTheme(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Email
        Text(
          profileWatch.profileDetailResponseModel?.data?.email ??
              profileWatch.profileDetailResponseModel?.data?.mobileNumber ?? "",
          style: TextStyles.txtRegular14(context).copyWith(
            color: Constant.clrBlackNew.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Profile Settings Section
  Widget _buildProfileSettingsSection(ProfileScreenController profileWatch) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Constant.clrDarkByScaffoldTheme(context),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w, top: 20.h, bottom: 12.h),
            child: Text(
              getLocalValue("Key_ProfileSettings").toUpperCase(),
              style: TextStyles.txtSemiG16(context).copyWith(
              ),
            ),
          ),

          // Edit Profile
          _buildSettingsItem(
           // icon: Icons.person_outline,
            title: getLocalValue("Key_EditProfile"),
            onTap: () {
              Route route = SlideRightPageRoute(
                builder: (context) => EditProfileScreen(
                    profileData: profileWatch.profileDetailResponseModel?.data),
                settings: const RouteSettings(),
              );
              Navigator.of(context).push(route);
            },
          ),

          Divider(
            height: 1.h,
            thickness: 1.h,
            color: Constant.clrBlackNew.withValues(alpha:0.1),
            indent: 20.w,
            endIndent: 20.w,
          ),

          // Change Password
          _buildSettingsItem(
            //icon: Icons.lock_outline,
            title: getLocalValue("Key_ChangePassword"),
            onTap: () {
              Route route = SlideRightPageRoute(
                builder: (context) => const CreatePasswordScreen(
                  isFromProfile: true,
                  userId: '',
                ),
                settings: const RouteSettings(),
              );
              Navigator.of(context).push(route);
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Settings Item Widget
  Widget _buildSettingsItem({
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Row(
          children: [
            // Icon(
            //   icon,
            //   color: Constant.clrWhiteBlackByTheme(),
            //   size: 24.h,
            // ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                title,
                style: TextStyles.txtMedG14(context).copyWith(
                  color: Constant.clrWhiteBlackByTheme(context),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Constant.clrTitlePageByTheme(context),
              size: 24.h,
            ),
          ],
        ),
      ),
    );
  }

  // /// Mobile and Email Section
  // Widget _buildMobileAndEmailSection(ProfileScreenController profileWatch) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 20.w),
  //     decoration: BoxDecoration(
  //       color: Constant.clrDarkByScaffoldTheme(),
  //       borderRadius: BorderRadius.circular(15.r),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: EdgeInsets.only(left: 20.w, top: 20.h, bottom: 15.h),
  //           child: Text(
  //             getLocalValue("Key_MobileAndEmail").toUpperCase(),
  //             style: TextStyles.txtMedium12(context).copyWith(
  //               color: Constant.clrBlackNew.withValues(alpha:0.5),
  //               letterSpacing: 0.5,
  //             ),
  //           ),
  //         ),
  //
  //         // Mobile Number
  //         Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 20.w),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       getLocalValue("Key_MobileNumber"),
  //                       style: TextStyles.txtRegular12(context).copyWith(
  //                         color: Constant.clrBlackNew,
  //                       ),
  //                     ),
  //                     SizedBox(height: 5.h),
  //                     Text(
  //                       profileWatch.profileDetailResponseModel?.data
  //                           ?.mobileNumber ??
  //                           "",
  //                       style: TextStyles.txtMedium14(context).copyWith(
  //                         color: Constant.clrWhiteBlackByTheme(),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               InkWell(
  //                 onTap: () {
  //                   Route route = SlideRightPageRoute(
  //                     builder: (context) => ForgotPasswordScreen(
  //                         isFromProfile: true,
  //                         profileData: profileWatch
  //                             .profileDetailResponseModel?.data),
  //                     settings: const RouteSettings(),
  //                   );
  //                   Navigator.of(context).push(route);
  //                 },
  //                 child: Padding(
  //                   padding: EdgeInsets.all(8.h),
  //                   child: Text(
  //                     getLocalValue("Key_Edit"),
  //                     style: TextStyles.txtMedium12(context).copyWith(
  //                       color: Constant.clrPrimary,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //
  //         SizedBox(height: 15.h),
  //
  //         // Email
  //         Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 20.w),
  //           child: (profileWatch.profileDetailResponseModel?.data?.email == '')
  //               ? InkWell(
  //             onTap: () {
  //               Route route = SlideRightPageRoute(
  //                 builder: (context) => AddEmailScreen(
  //                     profileData: profileWatch
  //                         .profileDetailResponseModel?.data,
  //                     isEmailUpdate: false),
  //                 settings: const RouteSettings(),
  //               );
  //               Navigator.of(context).push(route);
  //             },
  //             child: Padding(
  //               padding: EdgeInsets.only(bottom: 15.h),
  //               child: Text(
  //                 "Key_AddEmail".localized,
  //                 style: TextStyles.txtRegular12(context).copyWith(
  //                   color: Constant.clrPrimary,
  //                   decoration: TextDecoration.underline,
  //                 ),
  //               ),
  //             ),
  //           )
  //               : Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       getLocalValue("Key_EmailAddress"),
  //                       style: TextStyles.txtRegular12(context).copyWith(
  //                         color: Constant.clrBlackNew,
  //                       ),
  //                     ),
  //                     SizedBox(height: 5.h),
  //                     Text(
  //                       profileWatch.profileDetailResponseModel?.data
  //                           ?.email ??
  //                           "",
  //                       style: TextStyles.txtMedium14(context).copyWith(
  //                         color: Constant.clrWhiteBlackByTheme(),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               InkWell(
  //                 onTap: () {
  //                   Route route = SlideRightPageRoute(
  //                     builder: (context) => AddEmailScreen(
  //                         profileData: profileWatch
  //                             .profileDetailResponseModel?.data,
  //                         isEmailUpdate: true),
  //                     settings: const RouteSettings(),
  //                   );
  //                   Navigator.of(context).push(route);
  //                 },
  //                 child: Padding(
  //                   padding: EdgeInsets.all(8.h),
  //                   child: Text(
  //                     getLocalValue("Key_Edit"),
  //                     style: TextStyles.txtMedium12(context).copyWith(
  //                       color: Constant.clrPrimary,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //
  //         SizedBox(height: 20.h),
  //       ],
  //     ),
  //   );
  // }

  /// Bank Details Section
  Widget _buildBankDetailsSection(ProfileScreenController profileWatch) {
    final itemData = profileWatch.profileDetailResponseModel?.data;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Constant.clrDarkByScaffoldTheme(context),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getLocalValue("Key_BankDetails").toUpperCase(),
                  style: TextStyles.txtMedium12(context).copyWith(
                    color: Constant.clrBlackNew.withValues(alpha:0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Route route = SlideRightPageRoute(
                      builder: (context) => SignUpBankDetailScreen(
                        userID: getUserEntityId(),
                        isRecommender: true,
                        profileData: itemData,
                      ),
                      settings: const RouteSettings(),
                    );
                    Navigator.push(context, route).then((value) {
                      if (value == true) {
                        profileAPI(profileWatch);
                      }
                    });
                  },
                  child: Text(
                    getLocalValue("Key_Edit"),
                    style: TextStyles.txtMedium12(context).copyWith(
                      color: Constant.clrPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildBankDetailItem(
                        label: "Key_Name".localized,
                        value: itemData?.accountName ?? "",
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: _buildBankDetailItem(
                        label: "Key_BankName".localized,
                        value: itemData?.bankName ?? "",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                _buildBankDetailItem(
                  label: "Key_AccountNumber".localized,
                  value: itemData?.accountNumber ?? "",
                ),
                SizedBox(height: 15.h),
                _buildBankDetailItem(
                  label: "Key_IBANCode".localized,
                  value: itemData?.ibanCode ?? "",
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildBankDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.txtRegular12(context).copyWith(
            color: Constant.clrBlackNew,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: TextStyles.txtMedium14(context).copyWith(
            color: Constant.clrWhiteBlackByTheme(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Subscription Section
  Widget _buildSubscriptionSection(ProfileScreenController profileWatch) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        gradient: LinearGradient(
          colors: [
            Constant.clrPrimary,
            Constant.clrPrimary.withValues(alpha:0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Constant.clrWhite,
                  size: 40.h,
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getLocalValue("Key_SubscriptionPlan"),
                        style: TextStyles.txtRegular12(context).copyWith(
                          color: Constant.clrWhite.withValues(alpha:0.9),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "${profileWatch.profileDetailResponseModel?.data
                            ?.subscriptionPlanCount ??
                            ""} ${"Key_Plans".localized}",
                        style: TextStyles.txtSemiBold16(context).copyWith(
                          color: Constant.clrWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 15.h,
            right: 15.w,
            child: InkWell(
              onTap: () {
                Route route = SlideRightPageRoute(
                  builder: (context) => EditSubscriptionAmountScreen(
                    profileData: profileWatch.profileDetailResponseModel?.data,
                  ),
                  settings: const RouteSettings(),
                );
                Navigator.of(context).push(route);
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Constant.clrWhite.withValues(alpha:0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Constant.clrWhite,
                  size: 18.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Social Links Section
  Widget _buildSocialLinksSection(ProfileScreenController profileWatch) {
    bool hasNoSocialLinks = ((profileWatch.profileDetailResponseModel?.data
        ?.facebookUrl
        .toString()
        .isEmpty) ==
        true &&
        (profileWatch.profileDetailResponseModel?.data?.twitterUrl
            .toString()
            .isEmpty) ==
            true &&
        (profileWatch.profileDetailResponseModel?.data?.instagramUrl
            .toString()
            .isEmpty) ==
            true &&
        (profileWatch.profileDetailResponseModel?.data?.websiteUrl
            .toString()
            .isEmpty) ==
            true)
        ? true
        : false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Constant.clrDarkByScaffoldTheme(context),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasNoSocialLinks) ...[
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 20.h, bottom: 15.h),
              child: Text(
                getLocalValue("Key_SocialLinks").toUpperCase(),
                style: TextStyles.txtMedium12(context).copyWith(
                  color: Constant.clrBlackNew.withValues(alpha:0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  if ((profileWatch.profileDetailResponseModel?.data
                      ?.facebookUrl
                      .toString()
                      .isEmpty) ==
                      false)
                    _buildSocialLinkItem(
                      icon: Constant.icFacebook,
                      label: "Key_FacebookLink",
                      url: profileWatch.profileDetailResponseModel?.data
                          ?.facebookUrl ??
                          "",
                    ),
                  if ((profileWatch.profileDetailResponseModel?.data?.twitterUrl
                      .toString()
                      .isEmpty) ==
                      false) ...[
                    SizedBox(height: 15.h),
                    _buildSocialLinkItem(
                      icon: Constant.icTwitterPrimary,
                      label: "Key_TwitterLink",
                      url: profileWatch.profileDetailResponseModel?.data
                          ?.twitterUrl ??
                          "",
                    ),
                  ],
                  if ((profileWatch.profileDetailResponseModel?.data
                      ?.instagramUrl
                      .toString()
                      .isEmpty) ==
                      false) ...[
                    SizedBox(height: 15.h),
                    _buildSocialLinkItem(
                      icon: Constant.icInstagram,
                      label: "Key_InstagramLink",
                      url: profileWatch.profileDetailResponseModel?.data
                          ?.instagramUrl ??
                          "",
                    ),
                  ],
                  if ((profileWatch.profileDetailResponseModel?.data?.websiteUrl
                      .toString()
                      .isEmpty) ==
                      false) ...[
                    SizedBox(height: 15.h),
                    _buildSocialLinkItem(
                      icon: Constant.icWeb,
                      label: "Key_WebsiteLink",
                      url: profileWatch.profileDetailResponseModel?.data
                          ?.websiteUrl ??
                          "",
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 15.h),
          ],

          // Add/Update Button
          Center(
            child: TextButton(
              onPressed: () {
                Route route = SlideRightPageRoute(
                  builder: (context) => AddSocialLinksScreen(
                      profileData:
                      profileWatch.profileDetailResponseModel?.data,
                      isUpdateSocialLinks: !hasNoSocialLinks),
                  settings: const RouteSettings(),
                );
                Navigator.of(context).push(route);
              },
              child: Text(
                getLocalValue(hasNoSocialLinks
                    ? "Key_AddSocialLinks"
                    : "Key_UpdateSolcailLinks"),
                style: TextStyles.txtMedium14(context).copyWith(
                  color: Constant.clrPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSocialLinkItem({
    required String icon,
    required String label,
    required String url,
  }) {
    return InkWell(
      onTap: () {
        launchSocialUrl(Uri.parse(url));
      },
      child: Row(
        children: [
          CommonImageAsset(
            strIcon: icon,
            height: 24.h,
            width: 24.h,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getLocalValue(label),
                  style: TextStyles.txtRegular12(context).copyWith(
                    color: Constant.clrBlackNew,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  url,
                  style: TextStyles.txtMedium14(context).copyWith(
                    color: Constant.clrPrimary,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            color: Constant.clrBlackNew.withValues(alpha:0.3),
            size: 18.h,
          ),
        ],
      ),
    );
  }

  //API Logout Call
  Future<void> apiLogout() async {
    final loginWatch = ref.watch(signInProvider);
    final dashboardWatch = ref.watch(dashboardProvider);
    final profileWatch = ref.watch(profileProvider);
    final drawerWatch = ref.watch(drawerProvider);
    if (isInternetConnectionOn) {
      await loginWatch.logoutApi(context);

      loginWatch.updateWidget();

      if (loginWatch.commonResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString() ||
          loginWatch.commonResponseModel?.status ==
              ApiEndPoints.apiStatus_401.toString()) {
        await logoutAction(context);
        dashboardWatch.updateProfile(false);
        dashboardWatch.bottomTabInit();
        dashboardWatch.updateWidget();
        drawerWatch.updateDrawerPosition(0);
        await drawerWatch.updateDrawerPosition(0);

        profileWatch.profileDetailResponseModel = null;
        await loginWatch.updateWidget();
        Route route = SlideRightPageRoute(
            builder: (context) => const DrawerMenu(),
            settings: const RouteSettings());
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
        getStartedDialog(context, canPop: false);
        dashboardWatch.updateWidget();
        ZoomDrawer.of(context)!.toggle();
      }
    }
  }
  /// Sign Out Dialog
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constant.clrDarkByScaffoldTheme(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          title: Text(
            getLocalValue("Key_SignOut"),
            style: TextStyles.txtSemiG18(context).copyWith(
              color: Constant.clrWhiteBlackByTheme(context),
            ),
          ),
          content: Text(
            getLocalValue("Key_SignOutMess"),
            style: TextStyles.txtRegG14(context).copyWith(
              color: Constant.clrWhiteBlackByTheme(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: ()  {
                Navigator.of(context).pop();
              },
              child: Text(
                getLocalValue("Key_Cancel"),
                style: TextStyles.txtRegG14(context).copyWith(
                  color: Constant.clrBlackNew.withValues(alpha:0.6),
                ),
              ),
            ),
            TextButton(
              onPressed:() async { // <-- Make the function async
                  Navigator.of(context).pop(); // Close the dialog first
                  await apiLogout(); // <-- Call the apiLogout function here
                },

              child: Text(
                getLocalValue("Key_SignOut"),
                style: TextStyles.txtMedG14(context).copyWith(
                  color: Constant.clrPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Profile API Call
  Future<void> profileAPI(ProfileScreenController profileWatch) async {
    if (isInternetConnectionOn) {
      if (getUserStatus() != guest) {
        await profileWatch.profileAPI(context);
      }
    }
  }

  /// Url Launcher
  Future<void> launchSocialUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> notificationCountAPICall(
      NotificationController notificationWatch) async {
    if (getUserStatus() != guest) {
      if (isInternetConnectionOn) {
        await notificationWatch.notificationCountAPI(context);
      }
    }
  }
}