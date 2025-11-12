// To parse this JSON data, do
//
//     final cmsResponseModel = cmsResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

CmsResponseModel cmsResponseModelFromJson(String str) => CmsResponseModel.fromJson(json.decode(str));

String cmsResponseModelToJson(CmsResponseModel data) => json.encode(data.toJson());

class CmsResponseModel {
  CmsResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  CmsData? data;

  factory CmsResponseModel.fromJson(Map<String, dynamic> json) => CmsResponseModel(
    success: json["success"] == null ? null : json["success"],
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : CmsData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "status": status == null ? null : status,
    "message": message == null ? null : message,
    "data": data == null ? null : data!.toJson(),
  };
}

class CmsData {
  CmsData({
    this.pageName,
    this.content,
  });

  String? pageName;
  String? content;

  factory CmsData.fromJson(Map<String, dynamic> json) => CmsData(
    pageName: json["page_name"] == null ? null : json["page_name"],
    content: json["content"] == null ? null : json["content"],
  );

  Map<String, dynamic> toJson() => {
    "page_name": pageName == null ? null : pageName,
    "content": content == null ? null : content,
  };
}
