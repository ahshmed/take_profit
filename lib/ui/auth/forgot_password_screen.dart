import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/auth/auth_provider.dart';
import '../../framework/data_provider/auth/forgot_password_screen_controller.dart';
import '../../framework/repository/common/model/country_list_response_model.dart';
import '../../framework/repository/profile/model/profile_details_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/apis/global_apis.dart';
import '../../utils/const.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_text.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import 'helper/common_title.dart';
import 'otp_screen.dart';


class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;
  final ProfileData? profileData;
  const ForgotPasswordScreen(
      {Key? key, this.isFromProfile = false, this.profileData})
      : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    {
  ///Text Editing Controller
  TextEditingController mobileNumberCTR = TextEditingController();

  ///Focus Node
  FocusNode mobileNumberFocus = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final forgotPasswordWatch = ref.watch(forgotPasswordScreenProvider);
      forgotPasswordWatch.clearProvider();
      countryListApi(forgotPasswordWatch);

      mobileNumberFocus.addListener(() {
        forgotPasswordWatch.checkMobileNumberValidation(
            context, mobileNumberCTR.text);
      });

      // if(widget.profileData != null)
      //   {
      //     mobileNumberCTR.text = widget.profileData?.mobileNumber.toString() ?? "";
      //     forgotPasswordWatch.checkMobileNumberValidation(context, mobileNumberCTR.text);
      //
      //     showLog("country id+ ${widget.profileData?.country?.id.toString()}");
      //
      //     // showLog("code list id + ${forgotPasswordWatch.codeList.first }");
      //
      //     // CountryData? countryData = forgotPasswordWatch.codeList.where((element) => (element.code?.trim().toLowerCase() == widget.profileData?.country?.code?.trim().toLowerCase())).first;
      //     // forgotPasswordWatch.countryData = countryData;
      //   }
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final forgotPasswordWatch = ref.watch(forgotPasswordScreenProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue(!widget.isFromProfile
                ? "Key_ForgotPassword"
                : "Key_ChangeMobile"),
            appBar: AppBar(
              backgroundColor: Constant.clrWhiteNew,
            ),
            isTitleCenter: true,
            isLeading: true,
          ),
          body: bodyWidget(forgotPasswordWatch),
        ),
        DialogProgressBar(isLoading: forgotPasswordWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(ForgotPasswordScreenController forgotPasswordWatch) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 19.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Text(
                  getLocalValue(!widget.isFromProfile
                      ? "Key_ForgotPasswordContent"
                      : "Key_ChangeMobileContent"),
                  style: TextStyles.txtRegular12(context).copyWith(
                    color: Constant.clrWhiteBlackNewByTheme(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 53.h,
              ),
              CommonTitle(
                  icon: Constant.icMobile, title: "${"Key_MobileNumber".localized}*"),
              SizedBox(
                height: 15.h,
              ),
              CustomTextField(
                context: context,
                myController: mobileNumberCTR,
                myFocus: mobileNumberFocus,
                bgColor: Constant.clrDarkByScaffoldTheme(context),
                // keep a fixed width dropdown as prefix but use symmetric padding
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
                      value: forgotPasswordWatch.countryData,
                      dropdownColor: Constant.clrCardBGByTheme(context),
                      items: forgotPasswordWatch.codeList.map(
                        (value) {
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
                        },
                      ).toList(),
                      isExpanded: true,
                      underline: Divider(
                        color: Constant.clrPrimary,
                      ),
                      onTap: () {},
                      enableFeedback: false,
                      borderRadius: BorderRadius.circular(10.r),
                      onChanged: (newValue) {
                        forgotPasswordWatch.updateSelectedCode(newValue!);
                      },
                    ),
                  ),
                ),
                textInputType: TextInputType.number,
                onChanged: (str) {
                  forgotPasswordWatch.checkMobileNumberValidation(context, str);
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxMobileLength),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                hintText: getLocalValue("Key_MobileNumber"),
                textInputAction: TextInputAction.next,
                errorMessage: forgotPasswordWatch.strMobileNumberError,
                marginNeed: false,
                paddingNeed: false,
              ),
              SizedBox(
                height: 65.h,
              ),
              CommonButton(
                height: 49.h,
                label: getLocalValue("Key_SendOTP"),
                onTap: () {
                  !widget.isFromProfile
                      ? _forgotPasswordApi(forgotPasswordWatch)
                      : updateMobileNumber(forgotPasswordWatch);

                  /// here change mobile number api
                },
                bgColor: Constant.clrPrimary,
                labelColor: Constant.clrWhite,
                isEnable: forgotPasswordWatch.isValidate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// forgot password API
  Future _forgotPasswordApi(
      ForgotPasswordScreenController forgotPasswordWatch) async {
    if (isInternetConnectionOn) {
      await forgotPasswordWatch.forgotPasswordApi(context);
      if (forgotPasswordWatch.forgotPasswordResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        showLog("success");

        /// Message Change according to from screen Response model
        showMessageDialog(context,
            forgotPasswordWatch.forgotPasswordResponseModel?.message ?? "", () {
          Route route = SlideRightPageRoute(
              builder: (context) => OTPScreen(
                    mobileNumber: forgotPasswordWatch.strMobileNumber,
                    countryData: forgotPasswordWatch.countryData,
                    fromScreen: FromScreen.FromForgotPassword,
                    userID: forgotPasswordWatch
                            .forgotPasswordResponseModel?.data?.id ??
                        "",
                  ),
              settings: const RouteSettings());
          Navigator.of(context).push(route);
        });
      }
    }
  }

  Future<void> updateMobileNumber(
      ForgotPasswordScreenController forgotPasswordWatch) async {
    if (isInternetConnectionOn) {
      if (mobileNumberCTR.text != widget.profileData?.mobileNumber.toString()) {
        await forgotPasswordWatch.updateMobileApi(context);
        if (forgotPasswordWatch.updateMobileResponseModel?.status ==
            ApiEndPoints.apiStatus_200.toString()) {
          showMessageDialog(context,
              forgotPasswordWatch.updateMobileResponseModel?.message ?? "", () {
            Route route = SlideRightPageRoute(
                builder: (context) => OTPScreen(
                      mobileNumber: forgotPasswordWatch.strMobileNumber,
                      fromScreen: FromScreen.FromProfile,
                      countryData: forgotPasswordWatch.countryData,
                      userID: forgotPasswordWatch
                              .updateMobileResponseModel?.data?.id ??
                          "",
                    ),
                settings: const RouteSettings());
            Navigator.of(context).push(route);
          });
        }
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  ///Country List Api
  Future countryListApi(
      ForgotPasswordScreenController forgotPasswordWatch) async {
    forgotPasswordWatch.updateIsLoading(true);
    await GlobalApis.instance.getCountryListApi(context, (model, error) {
      forgotPasswordWatch.updateIsLoading(false);
      if (model != null) {
        forgotPasswordWatch.fillCountryList(model.data);
      }
    });
  }
}
