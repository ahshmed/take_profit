// To parse this JSON data, do
//
//     final recommenderDetailResponseModel = recommenderDetailResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

RecommenderDetailResponseModel recommenderDetailResponseModelFromJson(String str) => RecommenderDetailResponseModel.fromJson(json.decode(str));

String recommenderDetailResponseModelToJson(RecommenderDetailResponseModel data) => json.encode(data.toJson());

class RecommenderDetailResponseModel {
  RecommenderDetailResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  RecommenderDetailData? data;

  factory RecommenderDetailResponseModel.fromJson(Map<String, dynamic> json) => RecommenderDetailResponseModel(
    success: json["success"] == null ? null : json["success"],
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : RecommenderDetailData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "status": status == null ? null : status,
    "message": message == null ? null : message,
    "data": data == null ? null : data!.toJson(),
  };
}

class RecommenderDetailData {
  RecommenderDetailData({
    this.recommenderId,
    this.name,
    this.profileImage,
    this.isPremiumUser,
    this.trendingLabel,
    this.bio,
    this.facebookUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.websiteUrl,
    this.isSubscribed,
    this.subscriptionEndDate,
    this.enableRequestAnalysis,
    this.requestAnalysisAmount,
    this.isSameUser,
  });

  String? recommenderId;
  String? name;
  String? profileImage;
  String? isPremiumUser;
  String? trendingLabel;
  String? bio;
  String? facebookUrl;
  String? twitterUrl;
  String? instagramUrl;
  String? websiteUrl;
  String? isSubscribed;
  String? subscriptionEndDate;
  String? enableRequestAnalysis;
  String? requestAnalysisAmount;
  String? isSameUser;

  factory RecommenderDetailData.fromJson(Map<String, dynamic> json) => RecommenderDetailData(
    recommenderId: json["recommender_id"] == null ? null : json["recommender_id"],
    name: json["name"] == null ? null : json["name"],
    profileImage: json["profile_image"] == null ? null : json["profile_image"],
    isPremiumUser: json["is_premium_user"] == null ? null : json["is_premium_user"],
    trendingLabel: json["trending_label"] == null ? null : json["trending_label"],
    bio: json["bio"] == null ? null : json["bio"],
    facebookUrl: json["facebook_url"] == null ? null : json["facebook_url"],
    twitterUrl: json["twitter_url"] == null ? null : json["twitter_url"],
    instagramUrl: json["instagram_url"] == null ? null : json["instagram_url"],
    websiteUrl: json["website_url"] == null ? null : json["website_url"],
    isSubscribed: json["is_subscribed"] == null ? null : json["is_subscribed"],
    subscriptionEndDate: json["subscription_end_date"] == null ? null : json["subscription_end_date"],
    enableRequestAnalysis: json["enable_request_analysis"] == null ? null : json["enable_request_analysis"],
    requestAnalysisAmount: json["request_analysis_amount"] == null ? null : json["request_analysis_amount"],
    isSameUser: json["is_same_user"] == null ? null : json["is_same_user"],

  );

  Map<String, dynamic> toJson() => {
    "recommender_id": recommenderId == null ? null : recommenderId,
    "name": name == null ? null : name,
    "profile_image": profileImage == null ? null : profileImage,
    "is_premium_user": isPremiumUser == null ? null : isPremiumUser,
    "trending_label": trendingLabel == null ? null : trendingLabel,
    "bio": bio == null ? null : bio,
    "facebook_url": facebookUrl == null ? null : facebookUrl,
    "twitter_url": twitterUrl == null ? null : twitterUrl,
    "instagram_url": instagramUrl == null ? null : instagramUrl,
    "website_url": websiteUrl == null ? null : websiteUrl,
    "is_subscribed": isSubscribed == null ? null : isSubscribed,
    "subscription_end_date": subscriptionEndDate == null ? null : subscriptionEndDate,
    "enable_request_analysis": enableRequestAnalysis == null ? null : enableRequestAnalysis,
    "request_analysis_amount": requestAnalysisAmount == null ? null : requestAnalysisAmount,
    "is_same_user": isSameUser == null ? null : isSameUser,

  };
}