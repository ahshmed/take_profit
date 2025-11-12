// To parse this JSON data, do
//
//     final cryptoCurrencyResponseModel = cryptoCurrencyResponseModelFromJson(jsonString);

import 'dart:convert';

CryptoCurrencyResponseModel cryptoCurrencyResponseModelFromJson(String str) =>
    CryptoCurrencyResponseModel.fromJson(json.decode(str));

String cryptoCurrencyResponseModelToJson(CryptoCurrencyResponseModel data) =>
    json.encode(data.toJson());

class CryptoCurrencyResponseModel {
  List<CryptoCurrencyData>? data;

  CryptoCurrencyResponseModel({
    this.data,
  });

  factory CryptoCurrencyResponseModel.fromJson(Map<String, dynamic> json) =>
      CryptoCurrencyResponseModel(
        data: json["data"] == null
            ? []
            : List<CryptoCurrencyData>.from(
                json["data"]!.map((x) => CryptoCurrencyData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CryptoCurrencyData {
  int? id;
  String? symbol;
  String? name;
  String? priceUsd;
  String? logo;
  bool updatedByBinance;

  CryptoCurrencyData({
    this.id,
    this.symbol,
    this.name,
    this.priceUsd,
    this.logo,
    this.updatedByBinance = false,
  });

  factory CryptoCurrencyData.fromJson(Map<String, dynamic> json) =>
      CryptoCurrencyData(
        id: json["id"],
        symbol: json["symbol"],
        name: json["name"],
        priceUsd: json["priceUsd"].toString(),
        logo: json["logo"],
        updatedByBinance: json["updatedByBinance"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "priceUsd": priceUsd,
        "logo": logo,
        "updatedByBinance": updatedByBinance,
      };
}

class BinanceCryptoCurrencyData {
  String? symbol;
  String? priceUsd;

  BinanceCryptoCurrencyData({
    this.symbol,
    this.priceUsd,
  });

  factory BinanceCryptoCurrencyData.fromJson(Map<String, dynamic> json) =>
      BinanceCryptoCurrencyData(
        symbol: json['s'],
        priceUsd: double.parse(json["c"]).toString(),
      );

  Map<String, dynamic> toJson() => {
    "s": symbol,
    "c": priceUsd,
  };
}