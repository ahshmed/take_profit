// To parse this JSON data, do
//
//     final notificationListResponseModel = notificationListResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

NotificationListResponseModel notificationListResponseModelFromJson(String str) => NotificationListResponseModel.fromJson(json.decode(str));

String notificationListResponseModelToJson(NotificationListResponseModel data) => json.encode(data.toJson());

class NotificationListResponseModel {
  NotificationListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  NotificationData? data;

  factory NotificationListResponseModel.fromJson(Map<String, dynamic> json) => NotificationListResponseModel(
    success: json["success"] == null ? null : json["success"],
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : NotificationData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "status": status == null ? null : status,
    "message": message == null ? null : message,
    "data": data == null ? null : data!.toJson(),
  };
}

class NotificationData {
  NotificationData({
    this.pageNumber,
    this.totalPage,
    this.perPage,
    this.notificationList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<NotificationList>? notificationList;

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    pageNumber: json["page_number"] == null ? null : json["page_number"],
    totalPage: json["total_page"] == null ? null : json["total_page"],
    perPage: json["per_page"] == null ? null : json["per_page"],
    notificationList: json["notification_list"] == null ? null : List<NotificationList>.from(json["notification_list"].map((x) => NotificationList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber == null ? null : pageNumber,
    "total_page": totalPage == null ? null : totalPage,
    "per_page": perPage == null ? null : perPage,
    "notification_list": notificationList == null ? null : List<dynamic>.from(notificationList!.map((x) => x.toJson())),
  };
}

class NotificationList {
  NotificationList({
    this.id,
    this.profileImage,
    this.title,
    this.content,
    this.slug,
    this.dataId,
    this.recommenderId,
    this.createdAt,
    this.isRead,
    this.date,
  });

  String? id;
  String? profileImage;
  String? title;
  String? content;
  String? slug;
  String? dataId;
  String? recommenderId;
  DateTime? createdAt;
  String? isRead;
  String? date;

  factory NotificationList.fromJson(Map<String, dynamic> json) => NotificationList(
    id: json["id"] == null ? null : json["id"],
    profileImage: json["profile_image"] == null ? null : json["profile_image"],
    title: json["title"] == null ? null : json["title"],
    content: json["content"] == null ? null : json["content"],
    slug: json["slug"] == null ? null : json["slug"],
    dataId: json["data_id"] == null ? null : json["data_id"],
    recommenderId: json["recommender_id"] == null ? null : json["recommender_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    isRead: json["is_read"] == null ? null : json["is_read"],
    date: json["date"] == null ? null : json["date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "profile_image": profileImage == null ? null : profileImage,
    "title": title == null ? null : title,
    "content": content == null ? null : content,
    "slug": slug == null ? null : slug,
    "data_id": dataId == null ? null : dataId,
    "recommender_id": recommenderId == null ? null : recommenderId,
    "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
    "is_read": isRead == null ? null : isRead,
    "date": date == null ? null : date,
  };
}
