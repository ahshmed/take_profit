// To parse this JSON data, do
//
//     final commonResponseModel = commonResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

CommonResponseModel commonResponseModelFromJson(String str) => CommonResponseModel.fromJson(json.decode(str));

String commonResponseModelToJson(CommonResponseModel data) => json.encode(data.toJson());

class CommonResponseModel {
  CommonResponseModel({
    this.success,
    this.status,
    this.message,
  });

  String? success;
  String? status;
  String? message;

  factory CommonResponseModel.fromJson(Map<String, dynamic> json) => CommonResponseModel(
    success: json["success"] == null ? null : json["success"],
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "status": status == null ? null : status,
    "message": message == null ? null : message,
  };
}
