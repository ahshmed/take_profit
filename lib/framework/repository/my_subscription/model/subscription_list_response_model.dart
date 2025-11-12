// To parse this JSON data, do
//
//     final subscriptionListResponseModel = subscriptionListResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

SubscriptionListResponseModel subscriptionListResponseModelFromJson(String str) => SubscriptionListResponseModel.fromJson(json.decode(str));

String subscriptionListResponseModelToJson(SubscriptionListResponseModel data) => json.encode(data.toJson());

class SubscriptionListResponseModel {
  SubscriptionListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory SubscriptionListResponseModel.fromJson(Map<String, dynamic> json) => SubscriptionListResponseModel(
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
    this.subscriptionList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<SubscriptionList>? subscriptionList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"] == null ? null : json["page_number"],
    totalPage: json["total_page"] == null ? null : json["total_page"],
    perPage: json["per_page"] == null ? null : json["per_page"],
    subscriptionList: json["subscription_list"] == null ? null : List<SubscriptionList>.from(json["subscription_list"].map((x) => SubscriptionList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber == null ? null : pageNumber,
    "total_page": totalPage == null ? null : totalPage,
    "per_page": perPage == null ? null : perPage,
    "subscription_list": subscriptionList == null ? null : List<dynamic>.from(subscriptionList!.map((x) => x.toJson())),
  };
}

class SubscriptionList {
  SubscriptionList({
    this.recommenderId,
    this.expireOn,
    this.userName,
    this.userImage,
    this.packageName,
    this.packageDuration,
    this.interval,
    this.currency,
    this.amount,
    this.currencyLogo,
    this.isPremiumUser
  });

  String? recommenderId;
  String? expireOn;
  String? userName;
  String? userImage;
  String? packageName;
  String? packageDuration;
  String? interval;
  String? currency;
  String? amount;
  List<String>? currencyLogo;
  String? isPremiumUser;

  factory SubscriptionList.fromJson(Map<String, dynamic> json) => SubscriptionList(
    recommenderId: json["recommender_id"] == null ? null : json["recommender_id"],
    expireOn: json["expire_on"] == null ? null : json["expire_on"],
    userName: json["user_name"] == null ? null : json["user_name"],
    userImage: json["user_image"] == null ? null : json["user_image"],
    packageName: json["package_name"] == null ? null : json["package_name"],
    packageDuration: json["package_duration"] == null ? null : json["package_duration"],
    interval: json["interval"] == null ? null : json["interval"],
    currency: json["currency"] == null ? null : json["currency"],
    amount: json["amount"] == null ? null : json["amount"],
    isPremiumUser: json["is_premium_user"] == null ? null : json["is_premium_user"],
    currencyLogo: json["currency_logo"] == null ? null : List<String>.from(json["currency_logo"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "recommender_id": recommenderId == null ? null : recommenderId,
    "expire_on": expireOn == null ? null : expireOn,
    "user_name": userName == null ? null : userName,
    "user_image": userImage == null ? null : userImage,
    "package_name": packageName == null ? null : packageName,
    "package_duration": packageDuration == null ? null : packageDuration,
    "interval": interval == null ? null : interval,
    "currency": currency == null ? null : currency,
    "amount": amount == null ? null : amount,
    "is_premium_user": isPremiumUser == null ? null : isPremiumUser,
    "currency_logo": currencyLogo == null ? null : List<dynamic>.from(currencyLogo!.map((x) => x)),
  };
}
