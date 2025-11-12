import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/profile/add_email_screen_controller.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/repository/profile/model/profile_details_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/sliderightroute.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../auth/helper/common_title.dart';
import '../auth/otp_screen.dart';



class AddEmailScreen extends ConsumerStatefulWidget {
  final ProfileData? profileData;
  final bool? isEmailUpdate;

  const AddEmailScreen({Key? key, this.profileData, this.isEmailUpdate})
      : super(key: key);

  @override
  ConsumerState<AddEmailScreen> createState() => _AddEmailScreenState();
}

class _AddEmailScreenState extends ConsumerState<AddEmailScreen> {
  ///Text Editing Controller
  TextEditingController emailCTR = TextEditingController();

  ///Focus Node
  FocusNode emailFocus = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final addEmailWatch = ref.watch(addEmailProvider);
      addEmailWatch.clearProvider();
      emailFocus.addListener(() {
        addEmailWatch.checkEmailValidation(context, emailCTR.text);
      });

      // if(widget.profileData != null)
      //   {
      //     emailCTR.text = widget.profileData?.email.toString() ?? "";
      //     addEmailWatch.checkEmailValidation(context, emailCTR.text);
      //   }
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final addEmailWatch = ref.watch(addEmailProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: getLocalValue(widget.isEmailUpdate == true
                ? "Key_UpdateEmail"
                : "Key_AddEmail"),
            appBar: AppBar(
              backgroundColor: Constant.clrWhiteNew,
            ),
            isTitleCenter: true,
            isLeading: true,
          ),
          body: NoInternetBuilder(
            child: bodyWidget(addEmailWatch),
          ),
        ),
        DialogProgressBar(isLoading: addEmailWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(AddEmailScreenController addEmailWatch) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView(
          children: [
            SizedBox(
              height: 19.h,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                getLocalValue("Key_PleaseEnterEmailAddress"),
                style: TextStyles.txtRegular12(context),
              ),
            ),
            SizedBox(
              height: 76.h,
            ),
            CommonTitle(
                icon: Constant.icEmail, title: "Key_EmailAddress".localized + "*"),
            SizedBox(
              height: 11.h,
            ),
            CustomTextField(
              context: context,
              myController: emailCTR,
              myFocus: emailFocus,
              bgColor: Constant.clrDarkByScaffoldTheme(context),
              isEmail: true,  // Add email validation
              prefix: Image.asset(
                Constant.icEmail,
                width: 24.w,
                height: 24.h,
              ),
              onChanged: (str) {
                addEmailWatch.checkEmailValidation(context, str);
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(maxEmailLength),
              ],
              hintText: getLocalValue("Key_Email"),
              textInputAction: TextInputAction.done,
              errorMessage: addEmailWatch.strEmailError,
              marginNeed: false,
              paddingNeed: false,
            ),
            SizedBox(
              height: 65.h,
            ),
            CommonButton(
              label: getLocalValue("Key_Verify"),
              onTap: () {
                ///here update email api call
                _updateEmailApi(addEmailWatch);
              },
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              isEnable: addEmailWatch.isValidate,
            )
          ],
        ),
      ),
    );
  }

  ///update email API
  Future _updateEmailApi(AddEmailScreenController addEmailWatch) async {
    if (isInternetConnectionOn) {
      if (emailCTR.text != widget.profileData?.email.toString()) {
        await addEmailWatch.updateEmailApi(context);
        if (addEmailWatch.updateEmailResponseModel?.status ==
            ApiEndPoints.apiStatus_200.toString()) {
          showLog("success");

          showMessageDialog(
              context, addEmailWatch.updateEmailResponseModel?.message ?? "",
              () {
            Route route = SlideRightPageRoute(
                builder: (context) => OTPScreen(
                      mobileNumber: "",
                      countryData: null,
                      fromScreen: FromScreen.FromProfile,
                      email: addEmailWatch.strEmail,
                      userID:
                          addEmailWatch.updateEmailResponseModel?.data?.id ??
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
}
