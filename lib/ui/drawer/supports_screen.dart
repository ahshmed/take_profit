import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/drawer/supports_screen_controller.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/profile/profile_screen_controller.dart';
import '../../framework/repository/common/model/country_list_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/apis/global_apis.dart';
import '../../utils/const.dart';
import '../../utils/darkmode/dark_provider.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_text.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../auth/helper/common_title.dart';


class SupportsScreen extends ConsumerStatefulWidget {
  const SupportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SupportsScreen> createState() => _SupportsScreenState();
}

class _SupportsScreenState extends ConsumerState<SupportsScreen>  {
  ///Text Editing Controller
  TextEditingController mobileNumberCTR = TextEditingController();
  TextEditingController emailCTR = TextEditingController();
  TextEditingController nameCTR = TextEditingController();
  TextEditingController messageCTR = TextEditingController();

  ///Focus Node
  FocusNode mobileNumberFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode messageFocus = FocusNode();
  FocusNode nameFocus = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      apiCallFromInit();
    });
  }

  /// Api Call From Init Method
  apiCallFromInit() async {
    final supportsScreenWatch = ref.watch(supportsScreenProvider);
    supportsScreenWatch.clearProvider();

    await countryListApi(supportsScreenWatch);

    final profileWatch = ref.watch(profileProvider);
    if (supportsScreenWatch.arrCountry.isNotEmpty &&
        profileWatch.profileDetailResponseModel?.data != null) {
      CountryData _countryData = supportsScreenWatch.arrCountry
          .where((element) => ((element.id ?? "") ==
              (profileWatch.profileDetailResponseModel?.data?.country?.id ??
                  "1")))
          .first;
      supportsScreenWatch.updateSelectedCode(_countryData);
    }
    if (profileWatch.profileDetailResponseModel?.data != null) {
      nameCTR.text = profileWatch.profileDetailResponseModel?.data?.name ?? "";
      supportsScreenWatch.checkNameValidation(context, nameCTR.text);
      mobileNumberCTR.text =
          profileWatch.profileDetailResponseModel?.data?.mobileNumber ?? "";
      emailCTR.text =
          profileWatch.profileDetailResponseModel?.data?.email ?? "";

      if (emailCTR.text.isNotEmpty) {
        supportsScreenWatch.checkEmailValidation(context, emailCTR.text);
      }
      if (mobileNumberCTR.text.isNotEmpty) {
        supportsScreenWatch.checkMobileNumberValidation(
            context, mobileNumberCTR.text);
      }
    }
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final profileWatch = ref.watch(profileProvider);
    final supportsScreenWatch = ref.watch(supportsScreenProvider);
    // ignore: unused_local_variable
    final darkModeWatch = ref.watch(darkProvider);
    final drawerWatch = ref.watch(drawerProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            appBar: AppBar(
              backgroundColor: Constant.clrWhiteNew,
            ),
            title: getLocalValue("Key_Support"),
            isDrawer: true,
          ),
          body: NoInternetBuilder(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                hideKeyboard(context);
              },
              child: bodyWidget(supportsScreenWatch),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
                left: 20.w,
                top: 10.h,
                right: 20.w,
                bottom: getIsIOSPlatform()
                    ? 20.h
                    : (MediaQuery.of(context).padding.bottom + 8).h),
            child: CommonButton(
              labelColor: Constant.clrWhiteNew,
              bgColor: Constant.clrPrimary,
              label: getLocalValue("Key_Submit"),
              borderRadius: 30.r,
              isEnable: supportsScreenWatch.isValidate,
              onTap: () async {
                supportApi(supportsScreenWatch, profileWatch);
              },
            ),
          ),
        ),
        DialogProgressBar(
            isLoading: supportsScreenWatch.isLoading || profileWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(SupportsScreenController supportsScreenWatch) {
    return Consumer(builder: (context, ref, child) {
      final drawerWatch = ref.watch(drawerProvider);
      return Padding(
        padding: EdgeInsets.all(20.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTitle(icon: Constant.icProfile, title: "${"Key_Name".localized}*"),
              SizedBox(
                height: 15.h,
              ),
              CustomTextField(
                context: context,
                myController: nameCTR,
                myFocus: nameFocus,
                bgColor: Constant.clrDarkByScaffoldTheme(context),
                textInputType: TextInputType.text,
                onChanged: (str) {
                  supportsScreenWatch.checkNameValidation(context, str);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9\s]*')),
                  LengthLimitingTextInputFormatter(maxNameLength)
                ],
                hintText: getLocalValue("Key_EnterName"),
                textInputAction: TextInputAction.next,
                errorMessage: supportsScreenWatch.strNameError,
                marginNeed: false,
                paddingNeed: false,
              ),
              SizedBox(
                height: 23.h,
              ),
              CommonTitle(
                  icon: Constant.icMobile, title: "Key_MobileNumber".localized + "*"),
              SizedBox(
                height: 15.h,
              ),
              CustomTextField(
                context: context,
                myController: mobileNumberCTR,
                myFocus: mobileNumberFocus,
                bgColor: Constant.clrDarkByScaffoldTheme(context),
                prefix: Container(
                  width: 115.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CountryData>(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 25,
                        color: Constant.clrWhiteBlackByTheme(context),
                      ),
                      hint: Align(
                        alignment: Alignment.centerLeft,
                        child: CommonText(
                          title: getLocalValue("Key_Code"),
                          fontSize: 14.sp,
                          clrFont: Constant.clrHintText,
                        ),
                      ),
                      value: supportsScreenWatch.countryData,
                      dropdownColor: Constant.clrCardBGByTheme(context),
                      items: supportsScreenWatch.arrCountry.map((value) {
                        return DropdownMenuItem<CountryData>(
                          value: value,
                          child: Row(
                            children: [
                              CacheImage(
                                imageURL: value.flag ?? "",
                                height: 20.h,
                                width: 20.h,
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                value.code ?? "",
                                style: TextStyles.txtMedium14(context).copyWith(
                                  color: Constant.clrWhiteBlackByTheme(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: Divider(
                        color: Constant.clrPrimary,
                      ),
                      onTap: () {},
                      enableFeedback: false,
                      borderRadius: BorderRadius.circular(10.r),
                      onChanged: (newValue) {
                        supportsScreenWatch.updateSelectedCode(newValue!);
                      },
                    ),
                  ),
                ),
                textInputType: TextInputType.number,
                onChanged: (str) {
                  supportsScreenWatch.checkMobileNumberValidation(context, str);
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxMobileLength),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                hintText: getLocalValue("Key_MobileNumber"),
                textInputAction: TextInputAction.next,
                errorMessage: supportsScreenWatch.strMobileNumberError,
                marginNeed: false,
                paddingNeed: false,
              ),
              SizedBox(
                height: 23.h,
              ),
              CommonTitle(
                  icon: Constant.icEmail, title: "${"Key_EmailAddress".localized}*"),
              SizedBox(
                height: 15.h,
              ),
              CustomTextField(
                context: context,
                myController: emailCTR,
                myFocus: emailFocus,
                textStyle: TextStyles.txtMedium14
                    (context).copyWith(color: Constant.clrPrimaryClr3A0360(context)),
                bgColor: Constant.clrDarkByScaffoldTheme(context),
                textInputType: TextInputType.emailAddress,
                isEmail: true,
                onChanged: (str) {
                  supportsScreenWatch.checkEmailValidation(context, str);
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxEmailLength),
                ],
                hintText: getLocalValue("Key_Email"),
                textInputAction: TextInputAction.next,
                errorMessage: supportsScreenWatch.strEmailError,
                marginNeed: false,
                paddingNeed: false,
              ),
              SizedBox(
                height: 23.h,
              ),
              CommonTitle(icon: "", title: "Key_AddMessage".localized + "*"),
              SizedBox(
                height: 15.h,
              ),
              CustomTextField(
                height: 92.h,
                context: context,
                myController: messageCTR,
                myFocus: messageFocus,
                contentPadding: EdgeInsets.only(
                    right: drawerWatch.isEngEnable == true ? -20.w : 10.w,
                    left: drawerWatch.isEngEnable == true ? 10.w : -20.w,
                    top: 20),
                bgColor: Constant.clrDarkByScaffoldTheme(context),
                textInputType: TextInputType.multiline,
                onChanged: (str) {
                  supportsScreenWatch.checkMessageValidation(context, str);
                },
                hintText: getLocalValue("Key_EnterHere"),
                textInputAction: TextInputAction.newline,
                errorMessage: supportsScreenWatch.strMessageError,
                marginNeed: false,
                paddingNeed: false,
                maxLine: 7,
                borderRadius: 15.r,
              ),
            ],
          ),
        ),
      );
    });
  }

  ///Country List Api
  Future countryListApi(SupportsScreenController supportsScreenWatch) async {
    supportsScreenWatch.updateIsLoading(true);
    await GlobalApis.instance.getCountryListApi(
      context,
      (model, error) {
        supportsScreenWatch.updateIsLoading(false);
        if (model != null) {
          supportsScreenWatch.fillCountryList(model.data);
        }
      },
    );
  }

  ///Support Api
  Future supportApi(SupportsScreenController supportsScreenWatch,
      ProfileScreenController profileWatch) async {
    if (isInternetConnectionOn) {
      await supportsScreenWatch.supportApi(
          context, profileWatch.profileDetailResponseModel?.data?.id ?? "");

      if (supportsScreenWatch.supportResponseModel?.status ==
          ApiEndPoints.apiStatus_200) {
        showMessageDialog(
          context,
          supportsScreenWatch.supportResponseModel?.message ?? "",
          () {
            supportsScreenWatch.clearProvider();
            nameCTR.text = "";
            mobileNumberCTR.text = "";
            emailCTR.text = "";
            messageCTR.text = "";
            apiCallFromInit();
          },
        );
      }
    }
  }
}
