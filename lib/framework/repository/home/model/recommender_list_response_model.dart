// To parse this JSON data, do
//
//     final recommenderListResponseModel = recommenderListResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

RecommenderListResponseModel recommenderListResponseModelFromJson(String str) => RecommenderListResponseModel.fromJson(json.decode(str));

String recommenderListResponseModelToJson(RecommenderListResponseModel data) => json.encode(data.toJson());

class RecommenderListResponseModel {
  RecommenderListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory RecommenderListResponseModel.fromJson(Map<String, dynamic> json) => RecommenderListResponseModel(
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
    this.trendingList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<TrendingList>? trendingList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"] == null ? null : json["page_number"],
    totalPage: json["total_page"] == null ? null : json["total_page"],
    perPage: json["per_page"] == null ? null : json["per_page"],
    trendingList: json["trending_list"] == null ? null : List<TrendingList>.from(json["trending_list"].map((x) => TrendingList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber == null ? null : pageNumber,
    "total_page": totalPage == null ? null : totalPage,
    "per_page": perPage == null ? null : perPage,
    "trending_list": trendingList == null ? null : List<dynamic>.from(trendingList!.map((x) => x.toJson())),
  };
}

class TrendingList {
  TrendingList({
    this.recommenderId,
    this.name,
    this.profileImage,
    this.cryptoImages,
    this.isPremiumUser
  });

  String? recommenderId;
  String? name;
  String? profileImage;
  List<dynamic>? cryptoImages;
  String? isPremiumUser;

  factory TrendingList.fromJson(Map<String, dynamic> json) => TrendingList(
    recommenderId: json["recommender_id"] == null ? null : json["recommender_id"],
    name: json["name"] == null ? null : json["name"],
    profileImage: json["profile_image"] == null ? null : json["profile_image"],
    isPremiumUser: json["is_premium_user"] == null ? null : json["is_premium_user"],
    cryptoImages: json["crypto_images"] == null ? null : List<dynamic>.from(json["crypto_images"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "recommender_id": recommenderId == null ? null : recommenderId,
    "name": name == null ? null : name,
    "profile_image": profileImage == null ? null : profileImage,
    "is_premium_user": isPremiumUser == null ? null : isPremiumUser,
    "crypto_images": cryptoImages == null ? null : List<dynamic>.from(cryptoImages!.map((x) => x)),
  };
}
