// To parse this JSON data, do
//
//     final currencyDetailResponseModel = currencyDetailResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

CurrencyDetailResponseModel currencyDetailResponseModelFromJson(String str) => CurrencyDetailResponseModel.fromJson(json.decode(str));

String currencyDetailResponseModelToJson(CurrencyDetailResponseModel data) => json.encode(data.toJson());

class CurrencyDetailResponseModel {
  CurrencyDetailResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  CurrencyData? data;

  factory CurrencyDetailResponseModel.fromJson(Map<String, dynamic> json) => CurrencyDetailResponseModel(
    success: json["success"] == null ? null : json["success"],
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : CurrencyData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "status": status == null ? null : status,
    "message": message == null ? null : message,
    "data": data == null ? null : data!.toJson(),
  };
}

class CurrencyData {
  CurrencyData({
    this.id,
    this.apiCurrencyId,
    this.currencyCode,
    this.name,
    this.symbol,
    this.logo,
    this.price,
    this.isFavourite,
  });

  String? id;
  String? name;
  String? apiCurrencyId;
  String? currencyCode;
  String? symbol;
  String? logo;
  String? price;
  String? isFavourite;

  factory CurrencyData.fromJson(Map<String, dynamic> json) => CurrencyData(
    id: json["id"] == null ? null : json["id"],
    apiCurrencyId: json["api_currency_id"] == null ? null : json["api_currency_id"],
    currencyCode: json["currency_code"] == null ? null : json["currency_code"],
    name: json["name"] == null ? null : json["name"],
    symbol: json["symbol"] == null ? null : json["symbol"],
    logo: json["logo"] == null ? null : json["logo"],
    price: json["price"] == null ? null : json["price"],
    isFavourite: json["is_favourite"] == null ? null : json["is_favourite"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "api_currency_id": apiCurrencyId == null ? null : apiCurrencyId,
    "currency_code": currencyCode == null ? null : currencyCode,
    "name": name == null ? null : name,
    "symbol": symbol == null ? null : symbol,
    "logo": logo == null ? null : logo,
    "price": price == null ? null : price,
    "is_favourite": isFavourite == null ? null : isFavourite,
  };
}