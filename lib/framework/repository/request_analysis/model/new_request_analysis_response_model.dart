// To parse this JSON data, do
//
//     final newRequestAnalysisResponseModel = newRequestAnalysisResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

NewRequestAnalysisResponseModel newRequestAnalysisResponseModelFromJson(String str) => NewRequestAnalysisResponseModel.fromJson(json.decode(str));

String newRequestAnalysisResponseModelToJson(NewRequestAnalysisResponseModel data) => json.encode(data.toJson());

class NewRequestAnalysisResponseModel {
  NewRequestAnalysisResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory NewRequestAnalysisResponseModel.fromJson(Map<String, dynamic> json) => NewRequestAnalysisResponseModel(
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
    this.orderId,
    this.amount,
  });

  String? orderId;
  String? amount;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    orderId: json["order_id"] == null ? null : json["order_id"],
    amount: json["amount"] == null ? null : json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId == null ? null : orderId,
    "amount": amount == null ? null : amount,
  };
}
