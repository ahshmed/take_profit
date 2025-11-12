import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/recommender/my_recommendation_controller.dart';
import '../../framework/data_provider/recommender/new_social_controller.dart';
import '../../framework/data_provider/recommender/recommender_provider.dart';
import '../../framework/repository/social/model/social_list_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/image_picker_manager_new.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/description_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../auth/helper/common_title.dart';


class NewSocialScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final SignalList? socialData;

  const NewSocialScreen({Key? key, required this.isEdit, this.socialData})
      : super(key: key);

  @override
  ConsumerState<NewSocialScreen> createState() => _NewSocialScreenState();
}

class _NewSocialScreenState extends ConsumerState<NewSocialScreen>
     {
  TextEditingController descriptionCTREn = TextEditingController();
  FocusNode descriptionFocusEn = FocusNode();

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final newSocialWatch = ref.watch(newSocialProvider);
      newSocialWatch.clearProvider();
      if (widget.isEdit) {
        newSocialWatch.isValidate = true;
        // newSocialWatch.isImageSelected = true;
        // newSocialWatch.apiImg = true;
        descriptionCTREn.text = widget.socialData?.descriptionEn ?? "";
        newSocialWatch.checkEnDescriptionValidation(
            context, descriptionCTREn.text);

        /// Download image File
        newSocialWatch.convertStringToFile(widget.socialData?.image ?? "");
      }
      descriptionFocusEn.addListener(() {
        newSocialWatch.checkEnDescriptionValidation(
            context, descriptionCTREn.text);
      });
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final newSocialWatch = ref.watch(newSocialProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: widget.isEdit
                ? getLocalValue("Key_EditNewSocial")
                : getLocalValue("Key_AddNewSocial"),
            appBar: AppBar(),
          ),
          body: NoInternetBuilder(
            child: bodyWidget(newSocialWatch),
          ),
          bottomNavigationBar: bottomButton(newSocialWatch),
        ),
        DialogProgressBar(isLoading: newSocialWatch.isLoading)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(NewSocialController newSocialWatch) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hideKeyboard(context);
      },
      child: Consumer(builder: (context, ref, child) {
        final drawerWatch = ref.watch(drawerProvider);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              CommonTitle(
                icon: "",
                title: "${"Key_AddImages".localized}*",
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                children: [
                  Expanded(child: imageViewWidget(newSocialWatch)),
                ],
              ),
              SizedBox(
                height: 30.h,
              ),
              CommonTitle(
                icon: "",
                title: "${"Key_AddDescriptionEn".localized}*",
              ),
              SizedBox(
                height: 15.h,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: DescriptionTextField(
                      context: context,
                      textAlign: TextAlign.right,
                      myController: descriptionCTREn,
                      myFocus: descriptionFocusEn,
                      bgColor: Constant.clrDarkByScaffoldTheme(context),
                      textInputType: TextInputType.multiline,
                      onChanged: (str) {
                        newSocialWatch.checkEnDescriptionValidation(context, str);
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(maxAboutUsLength500),
                      ],
                      hintText: getLocalValue("Key_EnterHere"),
                      textInputAction: TextInputAction.newline,
                      errorMessage: newSocialWatch.strDescriptionErrorEn,
                      borderRadius: 15.r,
                      marginNeed: false,
                      paddingNeed: false,
                      contentPadding: EdgeInsets.only(
                          left: -20.w,
                          right: 10.w,
                          top: 20),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      "${newSocialWatch.descriptionCountEn}/4000",
                      style: TextStyles.txtMedium12(context).copyWith(color: Constant.clrGreyNew),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget bottomButton(NewSocialController newSocialWatch) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: getIsIOSPlatform() ? 20.h : 40.h,
          left: 20.w,
          right: 20.w,
          top: 20.h),
      child: (newSocialWatch.isLoading)
          ? DialogProgressBar(isLoading: true, forPagination: true)
          : CommonButton(
              isEnable: newSocialWatch.isValidate,
              label: widget.isEdit
                  ? getLocalValue("Key_Save")
                  : getLocalValue("Key_CreateSocial"),
              onTap: () {
                if (widget.isEdit) {
                  editSocialAPI(newSocialWatch);
                } else {
                  addNewSocialAPI(newSocialWatch);
                }
              },
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              textSize: 16.sp,
            ),
    );
  }

  Widget imageViewWidget(NewSocialController newSocialWatch) {
    return Container(
      height: 105.h,
      width: 105.h,
      padding: EdgeInsets.only(
          left: getAppLanguage() == 'en'
              ? 10.w
              : MediaQuery.of(context).size.width * 0.66,
          right: getAppLanguage() == 'en'
              ? MediaQuery.of(context).size.width * 0.66
              : 10.w,
          top: 5.h,
          bottom: 5.h),
      child: SizedBox(
        height: 95.h,
        width: 95.h,
        child: (newSocialWatch.imgFile != null)
            ? imageWidget(newSocialWatch)
            : uploadImageWidget(newSocialWatch),
      ),
    );
  }

  Widget uploadImageWidget(NewSocialController newSocialWatch) {
    return InkWell(
      onTap: () async {
        hideKeyboard(context);
        File? file = await ImagePickerManagerNew.instance
            .openPicker(context, cropNeed: false);
        if (file != null) {
          newSocialWatch.addImage(file);
        }
      },
      child: Container(
        width: 90.w,
        height: 90.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.h),
          border: Border.all(
            color: Constant.clrGrey,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Constant.icAddImage,
              width: 60.w,
              height: 60.w,
            ),
            Text(
              "Key_AddImage".localized,
              softWrap: true,
              style: TextStyles.txtMedium10(context).copyWith(color: Constant.clrBlackNew),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageWidget(NewSocialController newSocialWatch) {
    return Stack(
      children: [
        Container(
          height: 100.h,
          width: 100.h,
          margin: EdgeInsets.all(8.sp),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              5.r,
            ),
            child: (newSocialWatch.imgFile != null)
                ? Image.file(
                    newSocialWatch.imgFile!,
                    width: 90.h,
                    height: 90.h,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(),
          ),
        ),
        Positioned(
          top: -15,
          right: -15,
          child: IconButton(
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.w),
                color: (Constant.clrGrey),
              ),
              height: 18.w,
              width: 18.w,
              child: Icon(
                Icons.close_rounded,
                color: Constant.clrDarkBlue,
                size: 12.sp,
              ),
            ),
            onPressed: () async {
              showConfirmationDialog2(
                context,
                getLocalValue("Key_DeleteImageMSG"),
                (isPositive) async {
                  if (isPositive) {
                    newSocialWatch.removeImage();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// add new social API Call
  Future<void> addNewSocialAPI(NewSocialController newSocialWatch) async {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);

    await newSocialWatch.addNewSocialAPI(context);
    if (newSocialWatch.commonResponseModelAdd?.status ==
        ApiEndPoints.apiStatus_200.toString()) {
      showMessageDialog(
          context,
          newSocialWatch.commonResponseModelAdd?.message ?? "",
          () async {
              final newSocialWatch = ref.watch(newSocialProvider);
              newSocialWatch.socialListResponseModel = null;
              newSocialWatch.socialList?.clear();
              newSocialWatch.isHasMorePage = false;
              myRecommendationWatch.updateSocialSubTabIndex(0);
              socialListApi(myRecommendationWatch);
              Navigator.pop(context);
          });
    }
  }

  /// Edit social API Call
  Future<void> editSocialAPI(NewSocialController newSocialWatch) async {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    if (widget.socialData?.descriptionEn != descriptionCTREn.text ||
        newSocialWatch.imgFile != null) {
      await newSocialWatch.editSocialAPI(
          context, widget.socialData?.socialId ?? "");
    } else {
      Navigator.pop(context);
    }

    if (newSocialWatch.commonResponseModelEdit?.status ==
        ApiEndPoints.apiStatus_200.toString()) {
      showMessageDialog(
        context,
        newSocialWatch.commonResponseModelEdit?.message ?? "",
        () {
          if (mounted)
          {
              final newSocialWatch = ref.watch(newSocialProvider);
              newSocialWatch.socialListResponseModel = null;
              newSocialWatch.socialList?.clear();
              newSocialWatch.isHasMorePage = false;
              socialListApi(myRecommendationWatch);
              Navigator.pop(context);
            }
        },
      );
    }
  }

  /// social list api calling tab-wise
  Future<void> socialListApi(
      MyRecommendationScreenController myRecommendationWatch) async {
    final newSocialWatch = ref.watch(newSocialProvider);
    newSocialWatch.clearProvider();
    if (myRecommendationWatch.socialSubTabSelectIndex == 0) {
      String todaysDate =
          getCustomFormatDateFromDateTime(DateTime.now(), "dd-MM-yyyy");
      await newSocialWatch.socialListApi(
          context, todaysDate, getUserEntityId());
    } else if (myRecommendationWatch.socialSubTabSelectIndex == 1) {
      String yesterdayDate = getCustomFormatDateFromDateTime(
          DateTime.now().subtract(const Duration(days: 1)), "dd-MM-yyyy");
      await newSocialWatch.socialListApi(
          context, yesterdayDate, getUserEntityId());
    } else if (myRecommendationWatch.socialSubTabSelectIndex == 2) {
      String calenderDate = getCustomFormatDateFromDateTime(
          myRecommendationWatch.selectDate2, "dd-MM-yyyy");
      if (myRecommendationWatch.selectDate2 == DateTime.now()) {
        myRecommendationWatch.updateSocialSubTabIndex(0);
      }
      await newSocialWatch.socialListApi(
          context, calenderDate, getUserEntityId());
    }
  }
}
