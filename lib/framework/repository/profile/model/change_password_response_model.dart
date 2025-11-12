// To parse this JSON data, do
//
//     final changePasswordResponseModel = changePasswordResponseModelFromJson(jsonString);

import 'dart:convert';

ChangePasswordResponseModel changePasswordResponseModelFromJson(String str) => ChangePasswordResponseModel.fromJson(json.decode(str));

String changePasswordResponseModelToJson(ChangePasswordResponseModel data) => json.encode(data.toJson());

class ChangePasswordResponseModel {
  ChangePasswordResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) => ChangePasswordResponseModel(
    success: json["success"],
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  Data({
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
    this.subscriptionPlanCount,
    this.subscriptionPlans,
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
  String? subscriptionPlanCount;
  List<SubscriptionPlan>? subscriptionPlans;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
    subscriptionPlanCount: json["subscription_plan_count"],
    subscriptionPlans: json["subscription_plans"] == null ? [] : List<SubscriptionPlan>.from(json["subscription_plans"]!.map((x) => SubscriptionPlan.fromJson(x))),
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
    "subscription_plan_count": subscriptionPlanCount,
    "subscription_plans": subscriptionPlans == null ? [] : List<dynamic>.from(subscriptionPlans!.map((x) => x.toJson())),
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
