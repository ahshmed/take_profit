// To parse this JSON data, do
//
//     final favouriteResponseModel = favouriteResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

FavouriteResponseModel favouriteResponseModelFromJson(String str) => FavouriteResponseModel.fromJson(json.decode(str));

String favouriteResponseModelToJson(FavouriteResponseModel data) => json.encode(data.toJson());

class FavouriteResponseModel {
  FavouriteResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory FavouriteResponseModel.fromJson(Map<String, dynamic> json) => FavouriteResponseModel(
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
    this.favouriteList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<FavouriteData>? favouriteList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"] == null ? null : json["page_number"],
    totalPage: json["total_page"] == null ? null : json["total_page"],
    perPage: json["per_page"] == null ? null : json["per_page"],
    favouriteList: json["favourite_list"] == null ? null : List<FavouriteData>.from(json["favourite_list"].map((x) => FavouriteData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber == null ? null : pageNumber,
    "total_page": totalPage == null ? null : totalPage,
    "per_page": perPage == null ? null : perPage,
    "favourite_list": favouriteList == null ? null : List<dynamic>.from(favouriteList!.map((x) => x.toJson())),
  };
}

class FavouriteData {
  FavouriteData({
    this.favouriteId,
    this.currencyId,
    this.apiCurrencyId,
    this.currencyCode,
    this.name,
    this.symbol,
    this.logo,
    this.price,
  });

  String? favouriteId;
  String? currencyId;
  String? apiCurrencyId;
  String? currencyCode;
  String? name;
  String? symbol;
  String? logo;
  String? price;

  factory FavouriteData.fromJson(Map<String, dynamic> json) => FavouriteData(
    favouriteId: json["favourite_id"] == null ? null : json["favourite_id"],
    currencyId: json["currency_id"] == null ? null : json["currency_id"],
    apiCurrencyId: json["api_currency_id"] == null ? null : json["api_currency_id"],
    currencyCode: json["currency_code"] == null ? null : json["currency_code"],
    name: json["name"] == null ? null : json["name"],
    symbol: json["symbol"] == null ? null : json["symbol"],
    logo: json["logo"] == null ? null : json["logo"],
    price: json["price"] == null ? null : json["price"],
  );

  Map<String, dynamic> toJson() => {
    "favourite_id": favouriteId == null ? null : favouriteId,
    "currency_id": currencyId == null ? null : currencyId,
    "api_currency_id": apiCurrencyId == null ? null : apiCurrencyId,
    "currency_code": currencyCode == null ? null : currencyCode,
    "name": name == null ? null : name,
    "symbol": symbol == null ? null : symbol,
    "logo": logo == null ? null : logo,
    "price": price == null ? null : price,
  };
}
