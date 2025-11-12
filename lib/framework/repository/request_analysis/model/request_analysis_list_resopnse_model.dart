// To parse this JSON data, do
//
//     final requestAnalysisListResponseModel = requestAnalysisListResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

RequestAnalysisListResponseModel requestAnalysisListResponseModelFromJson(String str) => RequestAnalysisListResponseModel.fromJson(json.decode(str));

String requestAnalysisListResponseModelToJson(RequestAnalysisListResponseModel data) => json.encode(data.toJson());

class RequestAnalysisListResponseModel {
  RequestAnalysisListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory RequestAnalysisListResponseModel.fromJson(Map<String, dynamic> json) => RequestAnalysisListResponseModel(
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
    this.requestAnalysisList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<RequestAnalysisList>? requestAnalysisList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"] == null ? null : json["page_number"],
    totalPage: json["total_page"] == null ? null : json["total_page"],
    perPage: json["per_page"] == null ? null : json["per_page"],
    requestAnalysisList: json["request_analysis_list"] == null ? null : List<RequestAnalysisList>.from(json["request_analysis_list"].map((x) => RequestAnalysisList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber == null ? null : pageNumber,
    "total_page": totalPage == null ? null : totalPage,
    "per_page": perPage == null ? null : perPage,
    "request_analysis_list": requestAnalysisList == null ? null : List<dynamic>.from(requestAnalysisList!.map((x) => x.toJson())),
  };
}

class RequestAnalysisList {
  RequestAnalysisList({
    this.requestId,
    this.requestBy,
    this.amount,
    this.image,
    this.requestDescription,
    this.analysisDescription,
    this.status,
    this.statusDisplay,
    this.createdAt,
    this.isRequester,
    this.userType,
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
  String? isRequester;
  String? userType;

  factory RequestAnalysisList.fromJson(Map<String, dynamic> json) => RequestAnalysisList(
    requestId: json["request_id"] == null ? null : json["request_id"],
    requestBy: json["request_by"] == null ? null : json["request_by"],
    amount: json["amount"] == null ? null : json["amount"],
    image: json["image"] == null ? null : json["image"],
    requestDescription: json["request_description"] == null ? null : json["request_description"],
    analysisDescription: json["analysis_description"] == null ? null : json["analysis_description"],
    status: json["status"] == null ? null : json["status"],
    statusDisplay: json["status_display"] == null ? null : json["status_display"],
    createdAt: json["created_at"] == null ? null : json["created_at"],
    isRequester: json["is_requester"] == null ? null : json["is_requester"],
    userType: json["user_type"] == null ? null : json["user_type"],
  );

  Map<String, dynamic> toJson() => {
    "request_id": requestId == null ? null : requestId,
    "request_by": requestBy == null ? null : requestBy,
    "amount": amount == null ? null : amount,
    "image": image == null ? null : image,
    "request_description": requestDescription == null ? null : requestDescription,
    "analysis_description": analysisDescription == null ? null : analysisDescription,
    "status": status == null ? null : status,
    "status_display": statusDisplay == null ? null : statusDisplay,
    "created_at": createdAt == null ? null : createdAt,
    "is_requester": isRequester == null ? null : isRequester,
    "user_type": userType == null ? null : userType,
  };
}
