import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../utils/extension/string_extension.dart';
import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/model/country_list_response_model.dart';
import '../../repository/profile/contract/profile_repository.dart';
import '../../repository/profile/model/profile_details_response_model.dart';
import '../../repository/profile/repository/profile_repository_builder.dart';


class EditProfileScreenController extends ChangeNotifier {
  String strNameEn = "";
  String strNameErrorEn = "";
  String strUserBioEn = "";
  String strUserBioErrorEn = "";
  String strNameAr = "";
  String strNameErrorAr = "";
  String strUserBioAr = "";
  String strUserBioErrorAr = "";
  // Track original values to detect changes
  String? originalNameEn, originalUserBioEn, originalEmail, originalMobile;
  String strImage = "";
  File? imageFile;
  bool isValidate = false;
  String strMobileNumber = "";
  String strMobileNumberError = "";
  String strEmail = "";
  String strEmailError = "";
  CountryData? countryData;
  List<CountryData> arrCountry = [];

  
  ///Check mobile validation
  void checkMobileNumberValidation(BuildContext context, String value) {
    strMobileNumber = value;
    strMobileNumberError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strMobileNumberError = getLocalValue("Key_PleaseEnterMobileNumber");
    } else if (!isPhoneNumberValid(value)) {
      strMobileNumberError = getLocalValue("Key_MobileNumberIsInvalid");
    }

    checkValidation();
    notifyListeners();
  }

  ///Check Email validation - treat email as optional unless changed, only validate when non-empty
  void checkEmailValidation(BuildContext context, String value) {
    strEmail = value;
    strEmailError = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isNotEmpty && !value.isEmailValid()) {
      strEmailError = getLocalValue("Key_EmailIsInvalid");
    }

    checkValidation();
    notifyListeners();
  }
  ///Check validation - enable when ANY changed field is valid (name/bio/email/phone/image)
  void checkValidation() {
    // Detect changes vs. originals
    final hasNameChange   = strNameEn.trim()       != (originalNameEn ?? '').trim();
    final hasBioChange    = strUserBioEn.trim()    != (originalUserBioEn ?? '').trim();
    final hasEmailChange  = strEmail.trim()        != (originalEmail ?? '').trim();
    final hasMobileChange = strMobileNumber.trim() != (originalMobile ?? '').trim();
    final hasImageChange  = imageFile != null || (strImage.isNotEmpty);

    // Field-specific validity
    final nameOk  = strNameEn.trim().isNotEmpty && strNameErrorEn == '';
    // Bio is optional; if changed, treat as ok unless you set an error elsewhere
    final bioOk   = strUserBioErrorEn == '';
    // Email optional unless changed; if non-empty, must be valid (error already computed in checkEmailValidation)
    final emailOk = strEmailError == '' || strEmail.trim().isEmpty;
    // Phone optional unless changed; if non-empty, must be valid and have a selected country
    final phoneOk = (strMobileNumberError == '' && (countryData != null)) || strMobileNumber.trim().isEmpty;

    isValidate = (hasNameChange   && nameOk)
              || (hasBioChange    && bioOk)
              || (hasEmailChange  && emailOk)
              || (hasMobileChange && phoneOk)
              ||  hasImageChange;
  }
  void fillCountryList(List<CountryData>? list) {
    arrCountry = list ?? [];
    if (arrCountry.isNotEmpty) {
      try {
        // Set Kuwait as the default country if available
        countryData = arrCountry.firstWhere(
              (country) => country.name?.toLowerCase() == "kuwait",
        );
      } catch (e) {
        // If Kuwait is not found, default to the first country in the list
        countryData = arrCountry.first;
      }
    }
    notifyListeners();
  }

  ///Check En Name Validation
  void checkEnNameValidation(BuildContext context, String value) {
    strNameEn = value;
    strNameErrorEn = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strNameErrorEn = getLocalValue("Key_PleaseEnterName");
    }
    checkValidation();
    notifyListeners();
  }

  ///Check En User Bio Validation
  void checkUserEnBioValidation(BuildContext context, String value) {
    strUserBioEn = value;
    strUserBioErrorEn = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      // strUserBioErrorEn = getLocalValue("Key_PleaseEnterBio");
    }
    checkValidation();
    notifyListeners();
  }

  ///Check Ar Name Validation
  void checkArNameValidation(BuildContext context, String value) {
    strNameAr = value;
    strNameErrorAr = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      strNameErrorAr = getLocalValue("Key_PleaseEnterName");
    }
    checkValidation();
    notifyListeners();
  }

  ///Check Ar User Bio Validation
  void checkUserArBioValidation(BuildContext context, String value) {
    strUserBioAr = value;
    strUserBioErrorAr = "";

    String removeWhiteSpace = value.replaceAll(" ", "");
    if (removeWhiteSpace.isEmpty) {
      // strUserBioErrorAr = getLocalValue("Key_PleaseEnterBio");
    }
    checkValidation();
    notifyListeners();
  }

  ///Update Picked Image
  Future<void> updatePickedImage(String photoFile, File file) async {
    strImage = photoFile;
    imageFile = file;
    checkValidation();
    notifyListeners();
  }

  /// Seed original values so we can detect changes and enable Save accordingly
  void seedInitialValues({
    required String nameEn,
    required String bioEn,
    required String email,
    required String mobile,
    CountryData? country,
  }) {
    originalNameEn = nameEn;
    originalUserBioEn = bioEn;
    originalEmail = email;
    originalMobile = mobile;

    strNameEn = nameEn;
    strUserBioEn = bioEn;
    strEmail = email;
    strMobileNumber = mobile;

    // Mirror Arabic values if not collected separately to avoid blocking validations elsewhere
    if (strNameAr.isEmpty) strNameAr = nameEn;
    if (strUserBioAr.isEmpty) strUserBioAr = bioEn;

    countryData = country ?? countryData;
    checkValidation();
    notifyListeners();
  }

  void clearProvider() {
    strNameEn = "";
    strNameErrorEn = "";
    strUserBioEn = "";
    strUserBioErrorEn = "";
    strMobileNumber = "";
    strMobileNumberError = "";
    strEmail = "";
    strEmailError = "";
    strNameAr = "";
    strNameErrorAr = "";
    strUserBioAr = "";
    strUserBioErrorAr = "";
    strImage = "";
    isValidate = false;
    imageFile = null;
    originalNameEn = originalUserBioEn = originalEmail = originalMobile = null;
    notifyListeners();
  }

  /// ---------------------------- Api Integration ---------------------------------///

  bool isLoading = false;
  bool isError = false;

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  final ProfileRepository _profileRepository =
      ProfileRepositoryBuilder.repository();

  ProfileDetailResponseModel? profileDetailResponseModel;

  ///Profile Details Api
  Future<void> updateProfileAPI(BuildContext context) async {
    updateIsLoading(true);
    updateIsError(false);

    FormData formData;
    FormData formDataForPhoto;
    MultipartFile? photo;

    if (imageFile != null) {
      String fileName =
          "${generateFileName()}.${(imageFile?.path ?? "").split(".").last}";
      File? compressedImage = await compressImageFile(imageFile!);
      MultipartFile multipartFilePhoto = await MultipartFile.fromFile(
          compressedImage.path,
          filename: fileName);
      photo = multipartFilePhoto;
    }

    formData = FormData.fromMap({
      "name:en": strNameEn,
      "name:ar": strNameEn,
      "bio:en": strUserBioEn,
      "bio:ar": strUserBioEn,
    });

    formDataForPhoto = FormData.fromMap({
      "name:en": strNameEn,
      "name:ar": strNameEn,
      "bio:en": strUserBioEn,
      "bio:ar": strUserBioEn,
      "profile_image": photo,
    });

    ApiResult apiResult = await _profileRepository.updatePersonalDetailAPI(
        context, (imageFile != null) ? formDataForPhoto : formData);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      profileDetailResponseModel = data as ProfileDetailResponseModel;

      if (profileDetailResponseModel?.status ==
          ApiEndPoints.apiStatus_200.toString()) {
        photo = null;
      } else {
        updateIsError(true);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

}
