// To parse this JSON data, do
//
//     final requestAnalysisDetailsResponseModel = requestAnalysisDetailsResponseModelFromJson(jsonString);

import 'dart:convert';

RequestAnalysisDetailsResponseModel requestAnalysisDetailsResponseModelFromJson(String str) => RequestAnalysisDetailsResponseModel.fromJson(json.decode(str));

String requestAnalysisDetailsResponseModelToJson(RequestAnalysisDetailsResponseModel data) => json.encode(data.toJson());

class RequestAnalysisDetailsResponseModel {
  RequestAnalysisDetailsResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  RequestAnalysisApiData? data;

  factory RequestAnalysisDetailsResponseModel.fromJson(Map<String, dynamic> json) => RequestAnalysisDetailsResponseModel(
    success: json["success"],
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : RequestAnalysisApiData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class RequestAnalysisApiData {
  RequestAnalysisApiData({
    this.requestId,
    this.requestBy,
    this.amount,
    this.image,
    this.requestDescription,
    this.analysisDescription,
    this.status,
    this.statusDisplay,
    this.createdAt,
  });

  String? requestId;
  String? requestBy;
  String? amount;
  String? image;
  String? requestDescription;
  String? analysisDescription;
  String? status;
  String? statusDisplay;
  String? createdAt;

  factory RequestAnalysisApiData.fromJson(Map<String, dynamic> json) => RequestAnalysisApiData(
    requestId: json["request_id"],
    requestBy: json["request_by"],
    amount: json["amount"],
    image: json["image"],
    requestDescription: json["request_description"],
    analysisDescription: json["analysis_description"],
    status: json["status"],
    statusDisplay: json["status_display"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "request_id": requestId,
    "request_by": requestBy,
    "amount": amount,
    "image": image,
    "request_description": requestDescription,
    "analysis_description": analysisDescription,
    "status": status,
    "status_display": statusDisplay,
    "created_at": createdAt,
  };
}
