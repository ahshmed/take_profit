// To parse this JSON data, do
//
//     final socialListResponseModel = socialListResponseModelFromJson(jsonString);

import 'dart:convert';

SocialListResponseModel socialListResponseModelFromJson(String str) => SocialListResponseModel.fromJson(json.decode(str));

String socialListResponseModelToJson(SocialListResponseModel data) => json.encode(data.toJson());

class SocialListResponseModel {
  SocialListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory SocialListResponseModel.fromJson(Map<String, dynamic> json) => SocialListResponseModel(
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
    this.pageNumber,
    this.totalPage,
    this.perPage,
    this.signalList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<SignalList>? signalList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"],
    totalPage: json["total_page"],
    perPage: json["per_page"],
    signalList: json["signal_list"] == null ? [] : List<SignalList>.from(json["signal_list"]!.map((x) => SignalList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber,
    "total_page": totalPage,
    "per_page": perPage,
    "signal_list": signalList == null ? [] : List<dynamic>.from(signalList!.map((x) => x.toJson())),
  };
}

class SignalList {
  SignalList({
    this.socialId,
    this.description,
    this.descriptionEn,
    this.descriptionAr,
    this.createdAt,
    this.date,
    this.time,
    this.image,
  });

  String? socialId;
  String? description;
  String? descriptionEn;
  String? descriptionAr;
  String? createdAt;
  String? date;
  String? time;
  String? image;

  factory SignalList.fromJson(Map<String, dynamic> json) => SignalList(
    socialId: json["social_id"],
    description: json["description"],
    descriptionEn: json["description:en"],
    descriptionAr: json["description:ar"],
    createdAt: json["created_at"],
    date: json["date"],
    time: json["time"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "social_id": socialId,
    "description": description,
    "description:en": descriptionEn,
    "description:ar": descriptionAr,
    "created_at": createdAt,
    "date": date,
    "time": time,
    "image": image,
  };
}
