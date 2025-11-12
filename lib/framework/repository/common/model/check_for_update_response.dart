import 'dart:convert';

CheckForUpdateResponseModel checkForUpdateResponseModelFromJson(String str) => CheckForUpdateResponseModel.fromJson(json.decode(str));

String checkForUpdateResponseModelToJson(CheckForUpdateResponseModel data) => json.encode(data.toJson());


class CheckForUpdateResponseModel {
  CheckForUpdateResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory CheckForUpdateResponseModel.fromJson(Map<String, dynamic> json) => CheckForUpdateResponseModel(
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
    this.required = 2,
    this.latest,
    this.showClosedSignal = 0,
    this.showSocialPosts = 0,
    this.guideUrl,
    this.whatsapp,
  });

  int required;
  String? latest;
  int showClosedSignal;
  int showSocialPosts;
  String? guideUrl;
  String? whatsapp;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    required: json["required"],
    latest: json["latest"],
    showClosedSignal: json["show_closed_signal"] ?? 0,
    showSocialPosts: json["show_social_posts"] ?? 0,
    guideUrl: json["guide_url"],
    whatsapp: json["whatsapp"],
  );

  Map<String, dynamic> toJson() => {
    "required": required,
    "latest": latest,
    "show_closed_signal": showClosedSignal,
    "show_social_posts": showSocialPosts,
    "guide_url": guideUrl,
    "whatsapp": whatsapp,
  };
}
