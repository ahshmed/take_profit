// To parse this JSON data, do
//
//     final getUrlForCryptoCurrencyPriceResponseModel = getUrlForCryptoCurrencyPriceResponseModelFromJson(jsonString);

import 'dart:convert';

GetUrlForCryptoCurrencyPriceResponseModel getUrlForCryptoCurrencyPriceResponseModelFromJson(String str) => GetUrlForCryptoCurrencyPriceResponseModel.fromJson(json.decode(str));

String getUrlForCryptoCurrencyPriceResponseModelToJson(GetUrlForCryptoCurrencyPriceResponseModel data) => json.encode(data.toJson());

class GetUrlForCryptoCurrencyPriceResponseModel {
  GetUrlForCryptoCurrencyPriceResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory GetUrlForCryptoCurrencyPriceResponseModel.fromJson(Map<String, dynamic> json) => GetUrlForCryptoCurrencyPriceResponseModel(
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
    this.cryptoCurrencyApiUrl,
  });

  String? cryptoCurrencyApiUrl;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    cryptoCurrencyApiUrl: json["crypto_currency_api_url"],
  );

  Map<String, dynamic> toJson() => {
    "crypto_currency_api_url": cryptoCurrencyApiUrl,
  };
}
