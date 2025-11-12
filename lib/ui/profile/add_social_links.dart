import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../framework/data_provider/profile/add_social_link_screen_controller.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/profile/profile_screen_controller.dart';
import '../../framework/repository/profile/model/profile_details_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_image_asset.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';


class AddSocialLinksScreen extends ConsumerStatefulWidget {
  final ProfileData? profileData;
  final bool? isUpdateSocialLinks;

  // final bool isFromEdit;
  const AddSocialLinksScreen(
      {Key? key,
      /* required this.isFromEdit*/ required this.profileData,
      this.isUpdateSocialLinks})
      : super(key: key);

  @override
  ConsumerState<AddSocialLinksScreen> createState() =>
      _AddSocialLinksScreenState();
}

class _AddSocialLinksScreenState extends ConsumerState<AddSocialLinksScreen>
    {
  ///Text Editing Controller
  TextEditingController facebookLinkCTR = TextEditingController();
  TextEditingController twitterLinkCTR = TextEditingController();
  TextEditingController instagramLinkCTR = TextEditingController();
  TextEditingController webLinkCTR = TextEditingController();

  ///Focus Node
  FocusNode facebookLinkFocus = FocusNode();
  FocusNode twitterLinkFocus = FocusNode();
  FocusNode instagramLinkFocus = FocusNode();
  FocusNode webLinkFocus = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final addSocialLinkWatch = ref.watch(addSocialLinkProvider);
      addSocialLinkWatch.clearProvider();

      if (widget.profileData?.facebookUrl != "") {
        facebookLinkCTR.text = widget.profileData?.facebookUrl ?? "";
        addSocialLinkWatch.checkFacebookLinkValidation(
            context, facebookLinkCTR.text);
      }
      if (widget.profileData?.twitterUrl != "") {
        twitterLinkCTR.text = widget.profileData?.twitterUrl ?? "";
        addSocialLinkWatch.checkTwitterLinkValidation(
            context, twitterLinkCTR.text);
      }
      if (widget.profileData?.instagramUrl != "") {
        instagramLinkCTR.text = widget.profileData?.instagramUrl ?? "";
        addSocialLinkWatch.checkInstagramLinkValidation(
            context, instagramLinkCTR.text);
      }
      if (widget.profileData?.websiteUrl != "") {
        webLinkCTR.text = widget.profileData?.websiteUrl ?? "";
        addSocialLinkWatch.checkWebLinkValidation(context, webLinkCTR.text);
      }

      facebookLinkFocus.addListener(() {
        addSocialLinkWatch.checkFacebookLinkValidation(
            context, facebookLinkCTR.text);
      });

      twitterLinkFocus.addListener(() {
        addSocialLinkWatch.checkTwitterLinkValidation(
            context, twitterLinkCTR.text);
      });

      instagramLinkFocus.addListener(() {
        addSocialLinkWatch.checkInstagramLinkValidation(
            context, instagramLinkCTR.text);
      });

      webLinkFocus.addListener(() {
        addSocialLinkWatch.checkWebLinkValidation(context, webLinkCTR.text);
      });
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final addSocialLinkWatch = ref.watch(addSocialLinkProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Constant.clrScaffoldBGByTheme(context),
      appBar: CommonAppBar(
        title: getLocalValue(widget.isUpdateSocialLinks == true
            ? "Key_UpdateSolcailLinks"
            : "Key_AddSocialLinks"),
        isTitleCenter: true,
        appBar: AppBar(
            backgroundColor: Constant.clrScaffoldBGByTheme(context), toolbarHeight: 64.h),
        isDrawer: false,
      ),
      body: NoInternetBuilder(
        child: bodyWidget(addSocialLinkWatch),
      ),
    );
  }

  ///Body Widget
  Widget bodyWidget(AddSocialLinkScreenController addSocialLinkWatch) {
    final profileWatch = ref.watch(profileProvider);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              ///Add Facebook Link
              facebookLinkWidget(addSocialLinkWatch),
              SizedBox(
                height: 23.h,
              ),
              twitterLinkWidget(addSocialLinkWatch),
              SizedBox(
                height: 23.h,
              ),
              instagramLinkWidget(addSocialLinkWatch),
              SizedBox(
                height: 23.h,
              ),
              webLinkWidget(addSocialLinkWatch),
              SizedBox(
                height: 60.h,
              ),
              CommonButton(
                label: getLocalValue("Key_Done"),
                onTap: () {
                  if (widget.profileData?.facebookUrl != facebookLinkCTR.text ||
                      widget.profileData?.twitterUrl != twitterLinkCTR.text ||
                      widget.profileData?.instagramUrl !=
                          instagramLinkCTR.text ||
                      widget.profileData?.websiteUrl != webLinkCTR.text) {
                    updateProfileDetailsAPI(addSocialLinkWatch, profileWatch);
                  } else {
                    Navigator.pop(context);
                  }
                },
                bgColor: Constant.clrPrimary,
                labelColor: Constant.clrWhite,
                isEnable: addSocialLinkWatch.isValidate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Facebook Add Link Widget
  Widget facebookLinkWidget(AddSocialLinkScreenController addSocialLinkWatch) {
    return Column(
      children: [
        Row(
          children: [
            CommonImageAsset(
              strIcon: Constant.icFacebook,
              height: 24.h,
              width: 24.h,
              boxFit: BoxFit.cover,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Text(
                getLocalValue("Key_FacebookLink"),
                style: TextStyles.txtMedium12
                    (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
              ),
            ),
            InkWell(
              onTap: () {
                facebookLinkCTR.text = "";
                addSocialLinkWatch.clearFacebook();
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getLocalValue("Key_Clear"),
                  style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrDarkPurple),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextField(
          context: context,
          myController: facebookLinkCTR,
          myFocus: facebookLinkFocus,
          contentPadding: EdgeInsets.only(
              left: getAppLanguage() == 'ar' ? -20.w : 20.w,
              right: getAppLanguage() == 'ar' ? 20.w : -20.w),
          bgColor: Constant.clrDarkByScaffoldTheme(context),
          marginNeed: false,
          paddingNeed: false,
          onChanged: (str) {
            addSocialLinkWatch.checkFacebookLinkValidation(context, str);
          },
          hintText: getLocalValue("Key_PleaseEnterFacebookLinkAddress"),
          errorMessage: addSocialLinkWatch.strFacebookLinkError,
        ),
      ],
    );
  }

  ///Twitter Add Link Widget
  Widget twitterLinkWidget(AddSocialLinkScreenController addSocialLinkWatch) {
    return Column(
      children: [
        Row(
          children: [
            CommonImageAsset(
              strIcon: Constant.icTwitterPrimary,
              height: 24.h,
              width: 24.h,
              boxFit: BoxFit.cover,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Text(
                getLocalValue("Key_TwitterLink"),
                style: TextStyles.txtMedium12
                    (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
              ),
            ),
            InkWell(
              onTap: () {
                twitterLinkCTR.text = "";
                addSocialLinkWatch.clearTwitter();
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getLocalValue("Key_Clear"),
                  style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrDarkPurple),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextField(
          context: context,
          myController: twitterLinkCTR,
          myFocus: twitterLinkFocus,
          bgColor: Constant.clrDarkByScaffoldTheme(context),
          contentPadding: EdgeInsets.only(
              left: getAppLanguage() == 'ar' ? -20.w : 20.w,
              right: getAppLanguage() == 'ar' ? 20.w : -20.w),
          marginNeed: false,
          paddingNeed: false,
          onChanged: (str) {
            addSocialLinkWatch.checkTwitterLinkValidation(context, str);
          },
          hintText: getLocalValue("Key_PleaseEnterTwitterLinkAddress"),
          errorMessage: addSocialLinkWatch.strTwitterLinkError,
        ),
      ],
    );
  }

  ///Instagram Add Link Widget
  Widget instagramLinkWidget(AddSocialLinkScreenController addSocialLinkWatch) {
    return Column(
      children: [
        Row(
          children: [
            CommonImageAsset(
              strIcon: Constant.icInstagram,
              height: 24.h,
              width: 24.h,
              boxFit: BoxFit.cover,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Text(
                getLocalValue("Key_InstagramLink"),
                style: TextStyles.txtMedium12
                    (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
              ),
            ),
            InkWell(
              onTap: () {
                instagramLinkCTR.text = "";
                addSocialLinkWatch.clearInstagram();
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getLocalValue("Key_Clear"),
                  style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrDarkPurple),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextField(
          context: context,
          myController: instagramLinkCTR,
          myFocus: instagramLinkFocus,
          bgColor: Constant.clrDarkByScaffoldTheme(context),
          contentPadding: EdgeInsets.only(
              left: getAppLanguage() == 'ar' ? -20.w : 20.w,
              right: getAppLanguage() == 'ar' ? 20.w : -20.w),
          marginNeed: false,
          paddingNeed: false,
          onChanged: (str) {
            addSocialLinkWatch.checkInstagramLinkValidation(context, str);
          },
          hintText: getLocalValue("Key_PleaseEnterInstagramLinkAddress"),
          errorMessage: addSocialLinkWatch.strInstagramLinkError,
        ),
      ],
    );
  }

  ///Web Add Link Widget
  Widget webLinkWidget(AddSocialLinkScreenController addSocialLinkWatch) {
    return Column(
      children: [
        Row(
          children: [
            CommonImageAsset(
              strIcon: Constant.icWeb,
              height: 24.h,
              width: 24.h,
              boxFit: BoxFit.cover,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Text(
                getLocalValue("Key_WebsiteLink"),
                style: TextStyles.txtMedium12
                    (context).copyWith(color: Constant.clrWhiteBlackByTheme(context)),
              ),
            ),
            InkWell(
              onTap: () {
                webLinkCTR.text = "";
                addSocialLinkWatch.clearWeb();
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getLocalValue("Key_Clear"),
                  style: TextStyles.txtRegular12(context).copyWith(color: Constant.clrDarkPurple),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextField(
          context: context,
          myController: webLinkCTR,
          myFocus: webLinkFocus,
          bgColor: Constant.clrDarkByScaffoldTheme(context),
          contentPadding: EdgeInsets.only(
              left: getAppLanguage() == 'ar' ? -20.w : 20.w,
              right: getAppLanguage() == 'ar' ? 20.w : -20.w),
          marginNeed: false,
          paddingNeed: false,
          onChanged: (str) {
            addSocialLinkWatch.checkWebLinkValidation(context, str);
          },
          hintText: getLocalValue("Key_PleaseEnterWebLinkAddress"),
          errorMessage: addSocialLinkWatch.strWebLinkError,
        ),
      ],
    );
  }

  /// Update Profile
  Future<void> updateProfileDetailsAPI(
      AddSocialLinkScreenController socialLinkWatch,
      ProfileScreenController profileWatch) async {
    if (isInternetConnectionOn) {
      await socialLinkWatch.updateProfileAPI(context);
      if (socialLinkWatch.profileDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        Navigator.of(context).pop();
        profileWatch.profileAPI(context);
      }
    }
  }
}
