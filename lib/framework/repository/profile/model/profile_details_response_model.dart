// To parse this JSON data, do
//
//     final profileDetailResponseModel = profileDetailResponseModelFromJson(jsonString);

import 'dart:convert';

ProfileDetailResponseModel profileDetailResponseModelFromJson(String str) => ProfileDetailResponseModel.fromJson(json.decode(str));

String profileDetailResponseModelToJson(ProfileDetailResponseModel data) => json.encode(data.toJson());

class ProfileDetailResponseModel {
  ProfileDetailResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  ProfileData? data;

  factory ProfileDetailResponseModel.fromJson(Map<String, dynamic> json) => ProfileDetailResponseModel(
    success: json["success"],
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : ProfileData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProfileData {
  ProfileData({
    this.id,
    this.name,
    this.nameEn,
    this.nameAr,
    this.email,
    this.mobileNumber,
    this.profileImage,
    this.country,
    this.isSocialLogin,
    this.userType,
    this.bio,
    this.bioEn,
    this.bioAr,
    this.subscriptionAmount,
    this.facebookUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.websiteUrl,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.ibanCode,
    this.subscriptionPlanCount,
    this.subscriptionPlans,
    this.isPremiumUser,
    this.userTypeLabel,
  });

  String? id;
  String? name;
  String? nameEn;
  String? nameAr;
  String? email;
  String? mobileNumber;
  String? profileImage;
  Country? country;
  String? isSocialLogin;
  String? userType;
  String? bio;
  String? bioEn;
  String? bioAr;
  String? subscriptionAmount;
  String? facebookUrl;
  String? twitterUrl;
  String? instagramUrl;
  String? websiteUrl;
  String? bankName;
  String? accountName;
  String? accountNumber;
  String? ibanCode;
  String? subscriptionPlanCount;
  List<SubscriptionPlan>? subscriptionPlans;
  String? isPremiumUser;
  String? userTypeLabel;

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json["id"],
    name: json["name"],
    nameEn: json["name:en"],
    nameAr: json["name:ar"],
    email: json["email"],
    mobileNumber: json["mobile_number"],
    profileImage: json["profile_image"],
    country: json["country"] == null ? null : Country.fromJson(json["country"]),
    isSocialLogin: json["is_social_login"],
    userType: json["user_type"],
    bio: json["bio"],
    bioEn: json["bio:en"],
    bioAr: json["bio:ar"],
    subscriptionAmount: json["subscription_amount"],
    facebookUrl: json["facebook_url"],
    twitterUrl: json["twitter_url"],
    instagramUrl: json["instagram_url"],
    websiteUrl: json["website_url"],
    bankName: json["bank_name"],
    accountName: json["account_name"],
    accountNumber: json["account_number"],
    ibanCode: json["iban_code"],
    subscriptionPlanCount: json["subscription_plan_count"],
    subscriptionPlans: json["subscription_plans"] == null ? [] : List<SubscriptionPlan>.from(json["subscription_plans"]!.map((x) => SubscriptionPlan.fromJson(x))),
    isPremiumUser: json["is_premium_user"],
    userTypeLabel: json["user_type_label"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "name:en": nameEn,
    "name:ar": nameAr,
    "email": email,
    "mobile_number": mobileNumber,
    "profile_image": profileImage,
    "country": country?.toJson(),
    "is_social_login": isSocialLogin,
    "user_type": userType,
    "bio": bio,
    "bio:en": bioEn,
    "bio:ar": bioAr,
    "subscription_amount": subscriptionAmount,
    "facebook_url": facebookUrl,
    "twitter_url": twitterUrl,
    "instagram_url": instagramUrl,
    "website_url": websiteUrl,
    "bank_name": bankName,
    "account_name": accountName,
    "account_number": accountNumber,
    "iban_code": ibanCode,
    "subscription_plan_count": subscriptionPlanCount,
    "subscription_plans": subscriptionPlans == null ? [] : List<dynamic>.from(subscriptionPlans!.map((x) => x.toJson())),
    "is_premium_user": isPremiumUser,
    "user_type_label": userTypeLabel,
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
    id: json["id"],
    name: json["name"],
    code: json["code"],
    flag: json["flag"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "flag": flag,
  };
}

class SubscriptionPlan {
  SubscriptionPlan({
    this.profilePackageId,
    this.price,
    this.subscriptionPackageId,
    this.packageName,
    this.packageDuration,
    this.interval,
    this.currency,
  });

  String? profilePackageId;
  String? price;
  String? subscriptionPackageId;
  String? packageName;
  String? packageDuration;
  String? interval;
  String? currency;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => SubscriptionPlan(
    profilePackageId: json["profile_package_id"],
    price: json["price"],
    subscriptionPackageId: json["subscription_package_id"],
    packageName: json["package_name"],
    packageDuration: json["package_duration"],
    interval: json["interval"],
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "profile_package_id": profilePackageId,
    "price": price,
    "subscription_package_id": subscriptionPackageId,
    "package_name": packageName,
    "package_duration": packageDuration,
    "interval": interval,
    "currency": currency,
  };
}
