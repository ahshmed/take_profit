// To parse this JSON data, do
//
//     final currencyListResponseModel = currencyListResponseModelFromJson(jsonString);

import 'dart:convert';

CurrencyListResponseModel currencyListResponseModelFromJson(String str) => CurrencyListResponseModel.fromJson(json.decode(str));

String currencyListResponseModelToJson(CurrencyListResponseModel data) => json.encode(data.toJson());

class CurrencyListResponseModel {
  CurrencyListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory CurrencyListResponseModel.fromJson(Map<String, dynamic> json) => CurrencyListResponseModel(
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
    this.pageNumber,
    this.totalPage,
    this.perPage,
    this.currencyList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<CurrencyList>? currencyList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"],
    totalPage: json["total_page"],
    perPage: json["per_page"],
    currencyList: json["currency_list"] == null ? [] : List<CurrencyList>.from(json["currency_list"]!.map((x) => CurrencyList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber,
    "total_page": totalPage,
    "per_page": perPage,
    "currency_list": currencyList == null ? [] : List<dynamic>.from(currencyList!.map((x) => x.toJson())),
  };
}

class CurrencyList {
  CurrencyList({
    this.id,
    this.name,
    this.apiCurrencyId,
    this.currencyCode,
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

  factory CurrencyList.fromJson(Map<String, dynamic> json) => CurrencyList(
    id: json["id"],
    name: json["name"],
    apiCurrencyId: json["api_currency_id"],
    currencyCode: json["currency_code"],
    symbol: json["symbol"],
    logo: json["logo"],
    price: json["price"],
    isFavourite: json["is_favourite"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "api_currency_id": apiCurrencyId,
    "currency_code": currencyCode,
    "symbol": symbol,
    "logo": logo,
    "price": price,
    "is_favourite": isFavourite,
  };
}
