import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:take_profit/utils/theme_const.dart';

import 'const.dart';

class ImagePickerManagerNew  {
  ImagePickerManagerNew._privateConstructor();

  static final ImagePickerManagerNew instance =
  ImagePickerManagerNew._privateConstructor();

  ///Image options
  final List<String> _imageOptions = ["camera", "gallery"];

  ///Open Picker
  Future<File?> openPicker(BuildContext context,
      {double? ratioX, double? ratioY, bool cropNeed = true}) async {
    String type = await _showBottomSheet(context);

    File? croppedFile;
    if (type.isNotEmpty) {
      XFile? fileProfile;

      if (_imageOptions.elementAt(0) == type) {
        fileProfile = (await ImagePicker()
            .pickImage(source: ImageSource.camera, imageQuality: 30));
      } else {
        fileProfile = (await ImagePicker()
            .pickImage(source: ImageSource.gallery, imageQuality: 30));
      }
      showLog("fileProfile: $fileProfile");
      if (cropNeed) {
        if (fileProfile != null && fileProfile.path != "") {
          CroppedFile? cropImage = (await ImageCropper().cropImage(
            sourcePath: fileProfile.path,
            aspectRatio: CropAspectRatio(
                ratioX: ratioX ?? 1,
                ratioY: ratioY ?? 1
            ),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Constant.clrPrimary,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'Crop Image',
                aspectRatioLockEnabled: false,
              ),
            ],
          ));

          if (cropImage != null && cropImage.path != "") {
            croppedFile = File(cropImage.path);
          }
        }
      } else {
        croppedFile = File(fileProfile?.path ?? '');
      }
    }
    return croppedFile;
  }

  /// Alternative method with specific aspect ratio presets
  Future<File?> openPickerWithPreset(BuildContext context,
      {CropAspectRatioPreset aspectRatioPreset = CropAspectRatioPreset.original,
        bool cropNeed = true}) async {
    String type = await _showBottomSheet(context);

    File? croppedFile;
    if (type.isNotEmpty) {
      XFile? fileProfile;

      if (_imageOptions.elementAt(0) == type) {
        fileProfile = (await ImagePicker()
            .pickImage(source: ImageSource.camera, imageQuality: 30));
      } else {
        fileProfile = (await ImagePicker()
            .pickImage(source: ImageSource.gallery, imageQuality: 30));
      }

      if (cropNeed && fileProfile != null && fileProfile.path != "") {
        CroppedFile? cropImage = (await ImageCropper().cropImage(
          sourcePath: fileProfile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Constant.clrPrimary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: aspectRatioPreset,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioLockEnabled: false,
            ),
          ],
        ));

        if (cropImage != null) {
          croppedFile = File(cropImage.path);
        }
      } else {
        croppedFile = File(fileProfile?.path ?? '');
      }
    }
    return croppedFile;
  }

  ///Image option bottom sheet
  _showBottomSheet(BuildContext context) async {
    String str = "";
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          height: 250.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Constant.clrScaffoldBGByTheme(context),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.only(top: 32.h, bottom: 32.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        str = _imageOptions.elementAt(1);
                      },
                      child: Text(
                        "Key_PhotoGallery".tr(),
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Constant.clrBlue,
                            fontWeight: Constant.fwMedium),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(height: 0.5, color: (Constant.clrGreyShadow)),
                    SizedBox(height: 20.h),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        str = _imageOptions.elementAt(0);
                      },
                      child: Text("Key_Camera".tr(),
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: Constant.clrBlue,
                              fontWeight: Constant.fwMedium)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19.h),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Constant.clrDarkByScaffoldTheme(context),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.only(
                      left: 70.w, right: 70.w, top: 23.h, bottom: 23.h),
                  child: Center(
                    child: Text(
                      "Key_Cancel".tr(),
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: (Constant.clrBlue),
                          fontWeight: Constant.fwBold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return str;
  }
}

/* Class usage
File? file = await ImagePickerManager.instance.openPicker(context);

// For specific aspect ratio preset:
File? file = await ImagePickerManager.instance.openPickerWithPreset(
  context,
  aspectRatioPreset: CropAspectRatioPreset.square
);
*/