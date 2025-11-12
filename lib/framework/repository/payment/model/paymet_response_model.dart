// To parse this JSON data, do
//
//     final paymentRequestAnalysisResponseModel = paymentResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

PaymentResponseModel paymentResponseModelFromJson(String str) => PaymentResponseModel.fromJson(json.decode(str));

String paymentResponseModelToJson(PaymentResponseModel data) => json.encode(data.toJson());

class PaymentResponseModel {
    PaymentResponseModel({
        this.success,
        this.status,
        this.message,
        this.data,
    });

    String? success;
    String? status;
    String? message;
    Data? data;

    factory PaymentResponseModel.fromJson(Map<String, dynamic> json) => PaymentResponseModel(
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
        this.paymentUrl,
        this.successUrl,
        this.errorUrl,
    });

    String? paymentUrl;
    String? successUrl;
    String? errorUrl;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        paymentUrl: json["payment_url"] == null ? null : json["payment_url"],
        successUrl: json["success_url"] == null ? null : json["success_url"],
        errorUrl: json["error_url"] == null ? null : json["error_url"],
    );

    Map<String, dynamic> toJson() => {
        "payment_url": paymentUrl == null ? null : paymentUrl,
        "success_url": successUrl == null ? null : successUrl,
        "error_url": errorUrl == null ? null : errorUrl,
    };
}
