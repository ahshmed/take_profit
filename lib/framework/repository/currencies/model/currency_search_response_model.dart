// To parse this JSON data, do
//
//     final currencySearchResponseModel = currencySearchResponseModelFromJson(jsonString);

import 'dart:convert';

CurrencySearchResponseModel currencySearchResponseModelFromJson(String str) => CurrencySearchResponseModel.fromJson(json.decode(str));

String currencySearchResponseModelToJson(CurrencySearchResponseModel data) => json.encode(data.toJson());

class CurrencySearchResponseModel {
  CurrencySearchResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory CurrencySearchResponseModel.fromJson(Map<String, dynamic> json) => CurrencySearchResponseModel(
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
    this.searchCurrencyList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<SearchCurrencyList>? searchCurrencyList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"],
    totalPage: json["total_page"],
    perPage: json["per_page"],
    searchCurrencyList: json["currency_list"] == null ? [] : List<SearchCurrencyList>.from(json["currency_list"]!.map((x) => SearchCurrencyList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber,
    "total_page": totalPage,
    "per_page": perPage,
    "currency_list": searchCurrencyList == null ? [] : List<dynamic>.from(searchCurrencyList!.map((x) => x.toJson())),
  };
}

class SearchCurrencyList {
  SearchCurrencyList({
    this.id,
    this.name,
    this.apiCurrencyId,
    this.currencyCode,
    this.symbol,
    this.logo,
    this.price,
    this.isFavourite,
    this.recommenders,
  });

  String? id;
  String? name;
  String? apiCurrencyId;
  String? currencyCode;
  String? symbol;
  String? logo;
  String? price;
  String? isFavourite;
  List<Recommender>? recommenders;

  factory SearchCurrencyList.fromJson(Map<String, dynamic> json) => SearchCurrencyList(
    id: json["id"],
    name: json["name"],
    apiCurrencyId: json["api_currency_id"],
    currencyCode: json["currency_code"],
    symbol: json["symbol"],
    logo: json["logo"],
    price: json["price"],
    isFavourite: json["is_favourite"],
    recommenders: json["recommenders"] == null ? [] : List<Recommender>.from(json["recommenders"]!.map((x) => Recommender.fromJson(x))),
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
    "recommenders": recommenders == null ? [] : List<dynamic>.from(recommenders!.map((x) => x.toJson())),
  };
}

class Recommender {
  Recommender({
    this.recommenderId,
    this.name,
    this.profileImage,
  });

  String? recommenderId;
  String? name;
  String? profileImage;

  factory Recommender.fromJson(Map<String, dynamic> json) => Recommender(
    recommenderId: json["recommender_id"],
    name: json["name"],
    profileImage: json["profile_image"],
  );

  Map<String, dynamic> toJson() => {
    "recommender_id": recommenderId,
    "name": name,
    "profile_image": profileImage,
  };
}
