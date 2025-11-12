// To parse this JSON data, do
//
//     final getSubscriptionPackageList = getSubscriptionPackageListFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

GetSubscriptionPackageList getSubscriptionPackageListFromJson(String str) => GetSubscriptionPackageList.fromJson(json.decode(str));

String getSubscriptionPackageListToJson(GetSubscriptionPackageList data) => json.encode(data.toJson());

class GetSubscriptionPackageList {
    GetSubscriptionPackageList({
        this.success,
        this.status,
        this.message,
        this.data,
    });

    String? success;
    String? status;
    String? message;
    Data? data;

    factory GetSubscriptionPackageList.fromJson(Map<String, dynamic> json) => GetSubscriptionPackageList(
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
        this.packageList,
    });

    String? pageNumber;
    String? totalPage;
    String? perPage;
    List<PackageList>? packageList;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        pageNumber: json["page_number"] == null ? null : json["page_number"],
        totalPage: json["total_page"] == null ? null : json["total_page"],
        perPage: json["per_page"] == null ? null : json["per_page"],
        packageList: json["package_list"] == null ? null : List<PackageList>.from(json["package_list"].map((x) => PackageList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "page_number": pageNumber == null ? null : pageNumber,
        "total_page": totalPage == null ? null : totalPage,
        "per_page": perPage == null ? null : perPage,
        "package_list": packageList == null ? null : List<dynamic>.from(packageList!.map((x) => x.toJson())),
    };
}

class PackageList {
    PackageList({
        this.subscriptionPackageId,
        this.packageName,
        this.packageDuration,
        this.interval
    });

    String? subscriptionPackageId;
    String? packageName;
    String? packageDuration;
    String? interval;

    factory PackageList.fromJson(Map<String, dynamic> json) => PackageList(
        subscriptionPackageId: json["subscription_package_id"] == null ? null : json["subscription_package_id"],
        packageName: json["package_name"] == null ? null : json["package_name"],
        packageDuration: json["package_duration"] == null ? null : json["package_duration"],
        interval: json["interval"] == null ? null : json["interval"],
    );

    Map<String, dynamic> toJson() => {
        "subscription_package_id": subscriptionPackageId == null ? null : subscriptionPackageId,
        "package_name": packageName == null ? null : packageName,
        "package_duration": packageDuration == null ? null : packageDuration,
        "interval": interval == null ? null : interval
    };
}
