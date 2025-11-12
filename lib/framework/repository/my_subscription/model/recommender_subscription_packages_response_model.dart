// To parse this JSON data, do
//
//     final getRecommenderSubscriptionPackagesResponseModel = getRecommenderSubscriptionPackagesResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

GetRecommenderSubscriptionPackagesResponseModel getRecommenderSubscriptionPackagesResponseModelFromJson(String str) => GetRecommenderSubscriptionPackagesResponseModel.fromJson(json.decode(str));

String getRecommenderSubscriptionPackagesResponseModelToJson(GetRecommenderSubscriptionPackagesResponseModel data) => json.encode(data.toJson());

class GetRecommenderSubscriptionPackagesResponseModel {
  GetRecommenderSubscriptionPackagesResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory GetRecommenderSubscriptionPackagesResponseModel.fromJson(Map<String, dynamic> json) => GetRecommenderSubscriptionPackagesResponseModel(
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
    this.pageNumber,
    this.totalPage,
    this.perPage,
    this.subscriptionPackageList,
    this.forAppleReview,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<SubscriptionPackageList>? subscriptionPackageList;
  String? forAppleReview;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"] == null ? null : json["page_number"],
    totalPage: json["total_page"] == null ? null : json["total_page"],
    perPage: json["per_page"] == null ? null : json["per_page"],
    subscriptionPackageList: json["subscription_package_list"] == null ? null : List<SubscriptionPackageList>.from(json["subscription_package_list"].map((x) => SubscriptionPackageList.fromJson(x))),
    forAppleReview: json["for_apple_review"] == null ? null : json["for_apple_review"],
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber == null ? null : pageNumber,
    "total_page": totalPage == null ? null : totalPage,
    "per_page": perPage == null ? null : perPage,
    "subscription_package_list": subscriptionPackageList == null ? null : List<dynamic>.from(subscriptionPackageList!.map((x) => x.toJson())),
    "for_apple_review": forAppleReview == null ? null : forAppleReview,
  };
}

class SubscriptionPackageList {
  SubscriptionPackageList({
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

  factory SubscriptionPackageList.fromJson(Map<String, dynamic> json) => SubscriptionPackageList(
    profilePackageId: json["profile_package_id"] == null ? null : json["profile_package_id"],
    price: json["price"] == null ? null : json["price"],
    subscriptionPackageId: json["subscription_package_id"] == null ? null : json["subscription_package_id"],
    packageName: json["package_name"] == null ? null : json["package_name"],
    packageDuration: json["package_duration"] == null ? null : json["package_duration"],
    interval: json["interval"] == null ? null : json["interval"],
    currency: json["currency"] == null ? null : json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "profile_package_id": profilePackageId == null ? null : profilePackageId,
    "price": price == null ? null : price,
    "subscription_package_id": subscriptionPackageId == null ? null : subscriptionPackageId,
    "package_name": packageName == null ? null : packageName,
    "package_duration": packageDuration == null ? null : packageDuration,
    "interval": interval == null ? null : interval,
    "currency": currency == null ? null : currency,
  };
}
