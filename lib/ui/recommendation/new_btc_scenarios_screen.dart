import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import 'package:take_profit/utils/theme_const.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../framework/data_provider/drawer/drawer_provider.dart';
import '../../framework/data_provider/recommender/my_recommendation_controller.dart';
import '../../framework/data_provider/recommender/new_btc_scenarios_controller.dart';
import '../../framework/data_provider/recommender/recommender_provider.dart';
import '../../framework/repository/recommender/model/btc_scenarios_list_response_model.dart';
import '../../utils/apis/api_end_points.dart';
import '../../utils/const.dart';
import '../../utils/no_internet_builder.dart';
import '../../utils/widgets/common_button.dart';
import '../../utils/widgets/commonappbar.dart';
import '../../utils/widgets/description_textfield.dart';
import '../../utils/widgets/dialog_progressbar.dart';
import '../auth/helper/common_title.dart';

class NewBTCScenariosScreen extends ConsumerStatefulWidget {
  final String? scenarioId;
  final bool? isEdit;
  final SignalList? model;
  final List<File>? imageList;
  final List<BTCImage>? stringImageList;

  const NewBTCScenariosScreen(
      {Key? key,
      this.isEdit,
      this.scenarioId,
      this.imageList,
      this.model,
      this.stringImageList})
      : super(key: key);

  @override
  ConsumerState<NewBTCScenariosScreen> createState() =>
      _NewBTCScenariosScreenState();
}

class _NewBTCScenariosScreenState extends ConsumerState<NewBTCScenariosScreen>
     {
  TextEditingController descriptionCTREN = TextEditingController();
  FocusNode descriptionFocusEn = FocusNode();

  // TextEditingController descriptionCTRAr = TextEditingController();
  // FocusNode descriptionFocusAr = FocusNode();

  File? file;

  ///init state
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      showLog("isEdit value : ${widget.isEdit}");
      final newBTCSWatch = ref.watch(newBTCScenariosProvider);
      newBTCSWatch.clearProvider();
      descriptionFocusEn.addListener(() {
        newBTCSWatch.checkEnDescriptionValidation(
            context, descriptionCTREN.text);
      });

      // descriptionFocusAr.addListener(() {
      //   newBTCSWatch.checkArDescriptionValidation(
      //       context, descriptionCTRAr.text);
      // });
      if (widget.isEdit == true) {
        newBTCSWatch.convertStringToFile(widget.stringImageList);
        newBTCSWatch.updateLoadingValue(true);
      }

      if (widget.model != null) {
        descriptionCTREN.text = widget.model?.descriptionEn ?? "";
        newBTCSWatch.checkEnDescriptionValidation(
            context, descriptionCTREN.text);
        // descriptionCTRAr.text = widget.model?.descriptionAr ?? "";
        // newBTCSWatch.checkArDescriptionValidation(
        //     context, descriptionCTRAr.text);
      }
    });
  }

  ///main build
  @override
  Widget build(BuildContext context) {
    final newBTCSWatch = ref.watch(newBTCScenariosProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Constant.clrScaffoldBGByTheme(context),
          appBar: CommonAppBar(
            title: widget.isEdit == true
                ? getLocalValue("Key_EditNewBTCScenarios")
                : getLocalValue("Key_AddNewBTCScenarios"),
            appBar: AppBar(),
          ),
          body: NoInternetBuilder(child: bodyWidget(newBTCSWatch)),
          bottomNavigationBar: bottomButton(newBTCSWatch),
        ),
        DialogProgressBar(
            isLoading: newBTCSWatch.isLoading || newBTCSWatch.isLoadingForImage)
      ],
    );
  }

  ///body Widget
  Widget bodyWidget(NewBTCScenariosController newBTCSWatch) {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
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
              listViewOfImage(newBTCSWatch, myRecommendationWatch),
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
                      myController: descriptionCTREN,
                      myFocus: descriptionFocusEn,
                      bgColor: Constant.clrDarkByScaffoldTheme(context),
                      textInputType: TextInputType.multiline,
                      onChanged: (str) {
                        newBTCSWatch.checkEnDescriptionValidation(context, str);
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4000),
                      ],
                      hintText: getLocalValue("Key_EnterHere"),
                      textInputAction: TextInputAction.newline,
                      errorMessage: newBTCSWatch.strDescriptionErrorEn,
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
                height: 15.h,
              ),
              // CommonTitle(
              //   icon: "",
              //   title: "Key_AddDescriptionAr".localized + "*",
              // ),
              // SizedBox(
              //   height: 15.h,
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 10.w),
              //   child: CustomTextField(
              //     height: 92.h,
              //     context: context,
              //     myController: descriptionCTRAr,
              //     myFocus: descriptionFocusAr,
              //     bgColor: clrDarkByScaffoldTheme(),
              //     textInputType: TextInputType.multiline,
              //     onChanged: (str) {
              //       newBTCSWatch.checkArDescriptionValidation(context, str);
              //     },
              //     inputFormatters: [
              //       LengthLimitingTextInputFormatter(maxAboutUsLength),
              //     ],
              //     hintText: getLocalValue("Key_EnterHere"),
              //     textInputAction: TextInputAction.done,
              //     errorMessage: newBTCSWatch.strDescriptionErrorAr,
              //     borderRadius: 15.r,
              //     marginNeed: false,
              //     paddingNeed: false,
              //     contentPadding: EdgeInsets.only(
              //         right: drawerWatch.isEngEnable == true ? -20.w : 10.w,
              //         left: drawerWatch.isEngEnable == true ? 10.w : -20.w,
              //         top: 20),
              //     maxLine: 7,
              //   ),
              // ),
            ],
          ),
        );
      }),
    );
  }

  Widget bottomButton(NewBTCScenariosController newBTCSWatch) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: getIsIOSPlatform() ? 20.h : 40.h,
          left: 20.w,
          right: 20.w,
          top: 20.h),
      child: (newBTCSWatch.isLoading)
          ? DialogProgressBar(isLoading: true, forPagination: true)
          : CommonButton(
              isEnable: newBTCSWatch.isValidate,
              label: widget.isEdit == true
                  ? getLocalValue("Key_Save")
                  : getLocalValue("Key_Add"),
              onTap: () async {
                widget.isEdit == true
                    ? editBTCScenario(newBTCSWatch, widget.scenarioId)
                    : newBTCScenario(newBTCSWatch);
              },
              bgColor: Constant.clrPrimary,
              labelColor: Constant.clrWhite,
              textSize: 16.sp,
            ),
    );
  }

  Widget listViewOfImage(NewBTCScenariosController newBTCSWatch,
      MyRecommendationScreenController myRecommendationWatch) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 30.0,
      mainAxisSpacing: 1.0,
      shrinkWrap: true,
      children: List.generate(
        newBTCSWatch.getImageList().length + 1,
        (index) {
          if (index == newBTCSWatch.getImageList().length) {
            return uploadImageWidget(newBTCSWatch);
          } else {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 0.w, right: 10.w, top: 10.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      5.r,
                    ),
                    child: Image.file(
                      newBTCSWatch.imgFile[index],
                      width: 86.h,
                      height: 86.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  top: 0.h,
                  right: 0.w,
                  child: InkWell(
                    child: Image.asset(
                      Constant.icCancel,
                      width: 25.h,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    onTap: () async {
                      showConfirmationDialog2(
                        context,
                        getLocalValue("Key_DeleteImageMSG"),
                        (isPositive) async {
                          if (isPositive) {
                            newBTCSWatch.removeImage(index);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget uploadImageWidget(NewBTCScenariosController newBTCSWatch) {
    return InkWell(
      onTap: () async {
        hideKeyboard(context);

        if (newBTCSWatch.imgFile.length > 4) {
          showMessageDialog(
              context, getLocalValue("Key_ImageUploadLimitMSG"), () => null);
        } else {
          loadImageFromPhone(newBTCSWatch, newBTCSWatch.imgFile.length);
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.w, bottom: 10.h, top: 10, left: 10.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.h),
            border: Border.all(color: (Constant.clrGrey))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Constant.icAddImage),
            Text(
              "Key_AddImage".localized,
              style: TextStyles.txtMedium10(context).copyWith(color: Constant.clrBlackNew),
            )
          ],
        ),
      ),
    );
  }

  /*
  * -- multi image picker
  * */
  loadImageFromPhone(
      NewBTCScenariosController newBTCSWatch, int listLength) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 5 - listLength,
        themeColor: Constant.clrPrimary,
        requestType: RequestType.image,
      ),
    );

    if (result != null && result.isNotEmpty == true) {
      for (final AssetEntity entity in result) {
        final File? file = await entity.file;
        newBTCSWatch.addImage(file!);
      }
    }
  }

  /// New BTC Scenario API
  Future newBTCScenario(NewBTCScenariosController newBTCScenarioWatch) async {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    await newBTCScenarioWatch.newBTCScenariosApi(context);
    if (newBTCScenarioWatch.newBTCScenarioResponseModel?.status ==
        ApiEndPoints.apiStatus_200.toString()) {
      myRecommendationWatch.btcScenariosListResponseModel = null;
      myRecommendationWatch.signalList?.length = 0;
      await getBTCScenariosList(myRecommendationWatch, getUserEntityId());
    }
  }

  /// Edit BTC Scenario API
  Future editBTCScenario(NewBTCScenariosController editBTCScenarioWatch,
      String? scenarioID) async {
    final myRecommendationWatch = ref.watch(myRecommendationProvider);
    await editBTCScenarioWatch.editBTCScenariosApi(context, scenarioID);
    if (editBTCScenarioWatch.editBTCScenarioResponseModel?.status ==
        ApiEndPoints.apiStatus_200.toString()) {
      myRecommendationWatch.btcScenariosListResponseModel = null;
      myRecommendationWatch.signalList?.length = 0;
      myRecommendationWatch.btcImageList?.length = 0;
      myRecommendationWatch.imageString?.length = 0;
      await getBTCScenariosList(myRecommendationWatch, getUserEntityId());
    }
  }

  /// Get BTC Scenarios List
  Future getBTCScenariosList(
      MyRecommendationScreenController myRecommenderWatch,
      String? recommenderID,
      {bool removeOld = false}) async {
    if (removeOld) {
      myRecommenderWatch.isHasMorePage = false;
    }
    await myRecommenderWatch.getBTCScenariosListApi(context, recommenderID);
  }
}
