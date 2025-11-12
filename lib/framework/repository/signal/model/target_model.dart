// To parse this JSON data, do
//
//     final parseTargetModel = parseTargetModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

ParseTargetModel parseTargetModelFromJson(String str) => ParseTargetModel.fromJson(json.decode(str));

String parseTargetModelToJson(ParseTargetModel data) => json.encode(data.toJson());

class ParseTargetModel {
  ParseTargetModel({
    this.targets,
  });

  List<TargetData>? targets;

  factory ParseTargetModel.fromJson(Map<String, dynamic> json) => ParseTargetModel(
    targets: json["targets"] == null ? null : List<TargetData>.from(json["targets"].map((x) => TargetData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "targets": targets == null ? null : List<dynamic>.from(targets!.map((x) => x.toJson())),
  };
}

class TargetData {
  TargetData({
    this.targetType,
    this.price,
    this.toPrice,
  });

  String? targetType;
  String? price;
  String? toPrice;

  factory TargetData.fromJson(Map<String, dynamic> json) => TargetData(
    targetType: json["target_type"] == null ? null : json["target_type"],
    price: json["price"] == null ? null : json["price"],
    toPrice: json["to_price"] == null ? null : json["to_price"],
  );

  Map<String, dynamic> toJson() => {
    "target_type": targetType == null ? null : targetType,
    "price": price == null ? null : price,
    "to_price": toPrice == null ? null : toPrice,
  };
}
