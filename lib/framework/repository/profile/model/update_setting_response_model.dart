// To parse this JSON data, do
//
//     final updateSettingResponseModel = updateSettingResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

UpdateSettingResponseModel updateSettingResponseModelFromJson(String str) => UpdateSettingResponseModel.fromJson(json.decode(str));

String updateSettingResponseModelToJson(UpdateSettingResponseModel data) => json.encode(data.toJson());

class UpdateSettingResponseModel {
  UpdateSettingResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory UpdateSettingResponseModel.fromJson(Map<String, dynamic> json) => UpdateSettingResponseModel(
    success: json["success"] == null ? null : json["success"],
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "status": status == null ? null : status,
    "message": message == null ? null : message,
    "data": data == null ? null : data!.toJson(),
  };
}

class Data {
  Data({
    this.id,
    this.name,
    this.email,
    this.mobileNumber,
    this.profileImage,
    this.country,
    this.mobileVerified,
    this.profileVerified,
    this.isPremiumUser,
    this.enableNotification,
    this.enableSms,
    this.enableEmail,
    this.isSocialLogin,
    this.userType,
    this.langauge,
    this.enableRequestAnalysis,
    this.requestAnalysisAmount,
  });

  String? id;
  String? name;
  String? email;
  String? mobileNumber;
  String? profileImage;
  Country? country;
  String? mobileVerified;
  String? profileVerified;
  String? isPremiumUser;
  String? enableNotification;
  String? enableSms;
  String? enableEmail;
  String? isSocialLogin;
  String? userType;
  String? langauge;
  String? enableRequestAnalysis;
  String? requestAnalysisAmount;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    email: json["email"] == null ? null : json["email"],
    mobileNumber: json["mobile_number"] == null ? null : json["mobile_number"],
    profileImage: json["profile_image"] == null ? null : json["profile_image"],
    country: json["country"] == null ? null : Country.fromJson(json["country"]),
    mobileVerified: json["mobile_verified"] == null ? null : json["mobile_verified"],
    profileVerified: json["profile_verified"] == null ? null : json["profile_verified"],
    isPremiumUser: json["is_premium_user"] == null ? null : json["is_premium_user"],
    enableNotification: json["enable_notification"] == null ? null : json["enable_notification"],
    enableSms: json["enable_sms"] == null ? null : json["enable_sms"],
    enableEmail: json["enable_email"] == null ? null : json["enable_email"],
    isSocialLogin: json["is_social_login"] == null ? null : json["is_social_login"],
    userType: json["user_type"] == null ? null : json["user_type"],
    langauge: json["langauge"] == null ? null : json["langauge"],
    enableRequestAnalysis: json["enable_request_analysis"] == null ? null : json["enable_request_analysis"],
    requestAnalysisAmount: json["request_analysis_amount"] == null ? null : json["request_analysis_amount"],

  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "email": email == null ? null : email,
    "mobile_number": mobileNumber == null ? null : mobileNumber,
    "profile_image": profileImage == null ? null : profileImage,
    "country": country == null ? null : country!.toJson(),
    "mobile_verified": mobileVerified == null ? null : mobileVerified,
    "profile_verified": profileVerified == null ? null : profileVerified,
    "is_premium_user": isPremiumUser == null ? null : isPremiumUser,
    "enable_notification": enableNotification == null ? null : enableNotification,
    "enable_sms": enableSms == null ? null : enableSms,
    "enable_email": enableEmail == null ? null : enableEmail,
    "is_social_login": isSocialLogin == null ? null : isSocialLogin,
    "user_type": userType == null ? null : userType,
    "langauge": langauge == null ? null : langauge,
    "enable_request_analysis": enableRequestAnalysis == null ? null : enableRequestAnalysis,
    "request_analysis_amount": requestAnalysisAmount == null ? null : requestAnalysisAmount,

  };
}

class Country {
  Country({
    this.id,
    this.name,
    this.code,
    this.flag,
  });

  String? id;
  String? name;
  String? code;
  String? flag;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    code: json["code"] == null ? null : json["code"],
    flag: json["flag"] == null ? null : json["flag"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "code": code == null ? null : code,
    "flag": flag == null ? null : flag,
  };
}
