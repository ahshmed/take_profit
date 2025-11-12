// To parse this JSON data, do
//
//     final countryResponseModel = countryResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

CountryResponseModel countryResponseModelFromJson(String str) => CountryResponseModel.fromJson(json.decode(str));

String countryResponseModelToJson(CountryResponseModel data) => json.encode(data.toJson());

class CountryResponseModel {
  CountryResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  List<CountryData>? data;

  factory CountryResponseModel.fromJson(Map<String, dynamic> json) => CountryResponseModel(
    success: json["success"] == null ? null : json["success"],
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<CountryData>.from(json["data"].map((x) => CountryData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "status": status == null ? null : status,
    "message": message == null ? null : message,
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CountryData {
  CountryData({
    this.id,
    this.name,
    this.code,
    this.flag,
  });

  String? id;
  String? name;
  String? code;
  String? flag;

  factory CountryData.fromJson(Map<String, dynamic> json) => CountryData(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    code: json["code"] == null ? null : json["code"],
    flag: json["flag"] == null ? null : json["flag"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "code": code == null ? null : code,
    "flag": flag == null ? null : flag,
  };
}
