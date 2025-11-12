// To parse this JSON data, do
//
//     final homeRecommenderDetailsResponseModel = homeRecommenderDetailsResponseModelFromJson(jsonString);

import 'dart:convert';

HomeRecommenderDetailsResponseModel homeRecommenderDetailsResponseModelFromJson(String str) => HomeRecommenderDetailsResponseModel.fromJson(json.decode(str));

String homeRecommenderDetailsResponseModelToJson(HomeRecommenderDetailsResponseModel data) => json.encode(data.toJson());

class HomeRecommenderDetailsResponseModel {
  String? success;
  String? status;
  String? message;
  Data? data;

  HomeRecommenderDetailsResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  factory HomeRecommenderDetailsResponseModel.fromJson(Map<String, dynamic> json) => HomeRecommenderDetailsResponseModel(
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

  Data({
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    recommenderId: json["recommender_id"],
    name: json["name"],
    profileImage: json["profile_image"],
    isPremiumUser: json["is_premium_user"],
    trendingLabel: json["trending_label"],
    bio: json["bio"],
    facebookUrl: json["facebook_url"],
    twitterUrl: json["twitter_url"],
    instagramUrl: json["instagram_url"],
    websiteUrl: json["website_url"],
    isSubscribed: json["is_subscribed"],
    subscriptionEndDate: json["subscription_end_date"],
    enableRequestAnalysis: json["enable_request_analysis"],
    requestAnalysisAmount: json["request_analysis_amount"],
    isSameUser: json["is_same_user"],
  );

  Map<String, dynamic> toJson() => {
    "recommender_id": recommenderId,
    "name": name,
    "profile_image": profileImage,
    "is_premium_user": isPremiumUser,
    "trending_label": trendingLabel,
    "bio": bio,
    "facebook_url": facebookUrl,
    "twitter_url": twitterUrl,
    "instagram_url": instagramUrl,
    "website_url": websiteUrl,
    "is_subscribed": isSubscribed,
    "subscription_end_date": subscriptionEndDate,
    "enable_request_analysis": enableRequestAnalysis,
    "request_analysis_amount": requestAnalysisAmount,
    "is_same_user": isSameUser,
  };
}
