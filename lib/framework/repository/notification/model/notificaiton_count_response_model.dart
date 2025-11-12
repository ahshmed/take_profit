// To parse this JSON data, do
//
//     final notificationCountResponseModel = notificationCountResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

NotificationCountResponseModel notificationCountResponseModelFromJson(String str) => NotificationCountResponseModel.fromJson(json.decode(str));

String notificationCountResponseModelToJson(NotificationCountResponseModel data) => json.encode(data.toJson());

class NotificationCountResponseModel {
  NotificationCountResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory NotificationCountResponseModel.fromJson(Map<String, dynamic> json) => NotificationCountResponseModel(
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
    this.count,
  });

  String? count;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    count: json["count"] == null ? null : json["count"],
  );

  Map<String, dynamic> toJson() => {
    "count": count == null ? null : count,
  };
}
