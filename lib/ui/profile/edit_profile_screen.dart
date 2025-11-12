import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/profile/edit_profile_screen_controller.dart';
import '../../framework/data_provider/profile/profile_provider.dart';
import '../../framework/data_provider/profile/profile_screen_controller.dart';
import '../../framework/repository/common/model/country_list_response_model.dart';
import '../../framework/repository/profile/model/profile_details_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/apis/global_apis.dart';
import '../../utils/const.dart';
import '../../utils/image_picker_manager_new.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/common_text.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../../utils/widgets/flag_phone_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileData? profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  ///TextEditing Controller
  TextEditingController nameEnCTR = TextEditingController();
  TextEditingController userBioEnCTR = TextEditingController();
  TextEditingController emailCTR = TextEditingController();
  TextEditingController mobileNumberCTR = TextEditingController();

  ///Focus Node
  FocusNode nameEnFocus = FocusNode();
  FocusNode userEnBioFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode mobileNumberFocus = FocusNode();

  File? file;

  // Country data for phone number
  CountryData? selectedCountryData;
  List<CountryData> arrCountry = [];

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final editProfileWatch = ref.watch(editProfileProvider);
      editProfileWatch.clearProvider();

      // Load country list
      countryListApi();

      // Initialize fields
      nameEnCTR.text = widget.profileData?.nameEn ?? "";
      userBioEnCTR.text = widget.profileData?.bioEn ?? "";
      emailCTR.text = widget.profileData?.email ?? "";
      mobileNumberCTR.text = widget.profileData?.mobileNumber ?? "";

      // Seed originals in controller for change detection BEFORE validations
      editProfileWatch.seedInitialValues(
        nameEn: nameEnCTR.text,
        bioEn: userBioEnCTR.text,
        email: emailCTR.text,
        mobile: mobileNumberCTR.text,
        country: selectedCountryData,
      );

      // Validations
      editProfileWatch.checkEnNameValidation(context, nameEnCTR.text);
      editProfileWatch.checkUserEnBioValidation(context, userBioEnCTR.text);
      editProfileWatch.checkEmailValidation(context, emailCTR.text);
      editProfileWatch.checkMobileNumberValidation(context, mobileNumberCTR.text);

      nameEnFocus.addListener(() {
        editProfileWatch.checkEnNameValidation(context, nameEnCTR.text);
      });

      userEnBioFocus.addListener(() {
        editProfileWatch.checkUserEnBioValidation(context, userBioEnCTR.text);
      });

      emailFocus.addListener(() {
        editProfileWatch.checkEmailValidation(context, emailCTR.text);
      });

      mobileNumberFocus.addListener(() {
        editProfileWatch.checkMobileNumberValidation(context, mobileNumberCTR.text);
      });
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final editProfileWatch = ref.watch(editProfileProvider);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            isTitleCenter: false,
            title: getLocalValue("Key_EditProfile"),
            leading: IconButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                icon: Transform.rotate(
                  angle: (getAppLanguage() == 'ar')? pi :0,
                  child: Icon(Icons.arrow_back_ios_new,size: 24,) ,
                )
            ),
            appBar: AppBar(),
          ),
          body: NoInternetBuilder(
            child: bodyWidget(editProfileWatch),
          ),
        ),
        DialogProgressBar(isLoading: editProfileWatch.isLoading),
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(EditProfileScreenController editProfileWatch) {
    final profileWatch = ref.watch(profileProvider);
    final drawerWatch = ref.watch(drawerProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30.h),

            // Profile Image with Edit Button
            _buildProfileImage(editProfileWatch),

            SizedBox(height: 40.h),

            // Form Fields
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name Field
                  _buildTextField(
                    controller: nameEnCTR,
                    focusNode: nameEnFocus,
                    hint: getLocalValue("Key_FullName"),
                    errorMessage: editProfileWatch.strNameErrorEn,
                    onChanged: (str) {
                      editProfileWatch.checkEnNameValidation(context, str);
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(maxNameLength)
                    ],
                  ),

                  SizedBox(height: 15.h),

                  // Phone Number Field with Country Code
                  _buildPhoneNumberField(editProfileWatch),

                  SizedBox(height: 15.h),

                  // Email Field
                  _buildTextField(
                    controller: emailCTR,
                    focusNode: emailFocus,
                    hint: getLocalValue("Key_Email"),
                    errorMessage: editProfileWatch.strEmailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (str) {
                      editProfileWatch.checkEmailValidation(context, str);
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100)
                    ],
                  ),

                  SizedBox(height: 15.h),

                  // Bio Field
                  _buildBioField(editProfileWatch, drawerWatch),

                  SizedBox(height: 30.h),

                  // User Type Display
                  //_buildUserTypeDisplay(),

                  SizedBox(height: 40.h),

                  // Save Button
                  CommonButton(
                    label: getLocalValue("Key_SaveAndUpdate"),
                    onTap: () {
                      updateProfileDetailsAPI(editProfileWatch, profileWatch);
                    },
                    bgColor: Constant.clrPrimary,
                    labelColor: Constant.clrWhite,
                    isEnable: editProfileWatch.isValidate,
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Profile Image Widget
  Widget _buildProfileImage(EditProfileScreenController editProfileWatch) {
    return Stack(
      children: [
        Container(
          height: 120.h,
          width: 120.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Constant.clrPrimaryLight.withValues(alpha:0.1),
            border: Border.all(
              color: Constant.clrPrimary.withValues(alpha:0.2),
              width: 2.w,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60.r),
            child: widget.profileData?.profileImage == ""
                ? Center(
              child: Text(
                _getInitials(widget.profileData?.name ?? ""),
                style: TextStyles.txtSemiBoldG20(context).copyWith(
                  color: Constant.clrPrimary,
                  fontSize: 40.sp,
                ),
              ),
            )
                : (editProfileWatch.strImage == '')
                ? CacheImage(
              imageURL: widget.profileData?.profileImage ?? "",
              height: 120.h,
              width: 120.h,
              contentMode: BoxFit.cover,
            )
                : Image.file(
              File(editProfileWatch.strImage),
              height: 120.h,
              width: 120.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () async {
              file = await ImagePickerManagerNew.instance.openPicker(context);
              if (file != null) {
                editProfileWatch.updatePickedImage(file?.path ?? "", file!);
              }
            },
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Constant.clrPrimary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Constant.clrScaffoldBGByTheme(context),
                  width: 2.w,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Constant.clrWhite,
                size: 20.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    String? errorMessage,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Constant.clrDarkByScaffoldTheme(context),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: Constant.isDarkMode(context)
              ? const Color(0xFF2B2B2B)
              : const Color(0xFFF2F2F2),
          width: 1.w,
        ),
      ),
      child: CustomTextField(
        context: context,
        myController: controller,
        myFocus: focusNode,
        bgColor: Colors.transparent,
        textInputType: keyboardType ?? TextInputType.text,
        onChanged: onChanged,
        inputFormatters: inputFormatters ?? [],
        hintText: hint,
        textInputAction: TextInputAction.next,
        errorMessage: errorMessage,
        marginNeed: false,
        paddingNeed: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        borderRadius: 15.r,
        borderColor: Colors.transparent,
      ),
    );
  }

  /// Phone Number Field with Country Code
  Widget _buildPhoneNumberField(EditProfileScreenController editProfileWatch) {
    return Container(
      decoration: BoxDecoration(
        color: Constant.clrDarkByScaffoldTheme(context),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: Constant.isDarkMode(context)
              ? const Color(0xFF2B2B2B)
              : const Color(0xFFF2F2F2),
          width: 1.w,
        ),
      ),
      child: CustomTextField(
        context: context,
        myController: mobileNumberCTR,
        myFocus: mobileNumberFocus,
        bgColor: Colors.transparent,
        prefix: Container(
          width: 115.w,
          padding: EdgeInsets.only(
            right: getAppLanguage() == 'ar' ? 20.w : 0,
            left: getAppLanguage() == 'ar' ? 0 : 20.w,
          ),
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
              value: selectedCountryData,
              dropdownColor: Constant.clrCardBGByTheme(context),
              items: arrCountry.map((value) {
                return DropdownMenuItem<CountryData>(
                  value: value,
                  child: Row(
                    children: [
                      FlagPhoneWidget(
                        flagUrl: value.flag,
                        size: 20.h,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        value.code ?? "",
                        style: TextStyles.txtRegG12(context).copyWith(
                          color: Constant.clrHint,
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
                setState(() {
                  selectedCountryData = newValue;
                });
                final editProfileWatch = ref.watch(editProfileProvider);
                editProfileWatch.countryData = newValue;
                editProfileWatch.checkMobileNumberValidation(context, mobileNumberCTR.text);
              },
            ),
          ),
        ),
        textInputType: TextInputType.number,
        onChanged: (str) {
          editProfileWatch.checkMobileNumberValidation(context, str);
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxMobileLength),
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        hintText: getLocalValue("Key_PhoneNumber"),
        textInputAction: TextInputAction.next,
        errorMessage: editProfileWatch.strMobileNumberError,
        marginNeed: false,
        paddingNeed: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        borderRadius: 15.r,
        borderColor: Colors.transparent,
      ),
    );
  }

  /// Bio Field Widget
  Widget _buildBioField(
      EditProfileScreenController editProfileWatch,
      dynamic drawerWatch,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Constant.clrDarkByScaffoldTheme(context),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: Constant.isDarkMode(context)
              ? const Color(0xFF2B2B2B)
              : const Color(0xFFF2F2F2),
          width: 1.w,
        ),
      ),
      child: CustomTextField(
        height: 120.h,
        context: context,
        myController: userBioEnCTR,
        myFocus: userEnBioFocus,
        bgColor: Colors.transparent,
        textInputType: TextInputType.multiline,
        onChanged: (str) {
          editProfileWatch.checkUserEnBioValidation(context, userBioEnCTR.text);
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxAboutUsLength),
        ],
        hintText: getLocalValue("Key_Bio"),
        textInputAction: TextInputAction.newline,
        errorMessage: editProfileWatch.strUserBioErrorEn,
        borderRadius: 15.r,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 2.h,
        ),
        marginNeed: false,
        paddingNeed: false,
        maxLine: 5,
        borderColor: Colors.transparent,
      ),
    );
  }

  // /// User Type Display Widget
  // Widget _buildUserTypeDisplay() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
  //     decoration: BoxDecoration(
  //       color: Constant.clrPrimaryLight.withValues(alpha:0.1),
  //       borderRadius: BorderRadius.circular(15.r),
  //       border: Border.all(
  //         color: Constant.clrPrimary.withValues(alpha:0.2),
  //         width: 1.w,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           Icons.verified_user,
  //           color: Constant.clrPrimary,
  //           size: 24.h,
  //         ),
  //         SizedBox(width: 12.w),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 getLocalValue("Key_RegisteredAsA"),
  //                 style: TextStyles.txtRegular12(context).copyWith(
  //                   color: Constant.clrBlackNew.withValues(alpha:0.7),
  //                 ),
  //               ),
  //               SizedBox(height: 4.h),
  //               Text(
  //                 getUserStatus() == trader
  //                     ? "Key_Trader".localized
  //                     : "Key_Recommender".localized,
  //                 style: TextStyles.txtMedium16(context).copyWith(
  //                   color: Constant.clrPrimary,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Get Initials for Profile Picture
  String _getInitials(String name) {
    if (name.isEmpty) return "TP";
    List<String> names = name.split(" ");
    if (names.length >= 2) {
      return "${names[0][0]}${names[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Country List Api
  Future countryListApi() async {
    final editProfileWatch = ref.watch(editProfileProvider);
    editProfileWatch.updateIsLoading(true);
    await GlobalApis.instance.getCountryListApi(context, (model, error) {
      editProfileWatch.updateIsLoading(false);
      if (model != null && model.data != null) {
        setState(() {
          arrCountry = model.data ?? [];
          // Set default country based on profile data
          if (widget.profileData?.country != null && arrCountry.isNotEmpty) {
            selectedCountryData = arrCountry.firstWhere(
                  (country) => country.code == widget.profileData?.country.toString(),
              orElse: () => arrCountry.first,
            );
          } else if (arrCountry.isNotEmpty) {
            selectedCountryData = arrCountry.first;
          }
        });
        // Sync selected country to controller for phone validation rules
        editProfileWatch.countryData = selectedCountryData;
        // Revalidate current mobile value with selected country
        editProfileWatch.checkMobileNumberValidation(context, mobileNumberCTR.text);
      }
    });
  }

  /// Update Profile
  Future<void> updateProfileDetailsAPI(
      EditProfileScreenController editProfileWatch,
      ProfileScreenController profileWatch,
      ) async {
    if (isInternetConnectionOn) {
      showLog("nameEnCTR ${nameEnCTR.text}");
      showLog("BioenCTR ${userBioEnCTR.text}");
      showLog("emailCTR ${emailCTR.text}");
      showLog("mobileCTR ${mobileNumberCTR.text}");

      await editProfileWatch.updateProfileAPI(context);

      if (editProfileWatch.profileDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        await profileWatch.profileAPI(context);
        Navigator.of(context).pop();
      }
    }
  }
}