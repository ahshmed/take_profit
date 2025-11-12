// To parse this JSON data, do
//
//     final graphMonthDataModel = graphMonthDataModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

List<GraphDataModel> graphDataModelFromJson(String str) => List<GraphDataModel>.from(json.decode(str).map((x) => GraphDataModel.fromJson(x)));

String graphDataModelToJson(List<GraphDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GraphDataModel {
  GraphDataModel({
    this.title,
    this.value,
  });

  String? title;
  double? value;

  factory GraphDataModel.fromJson(Map<String, dynamic> json) => GraphDataModel(
    title: json["title"] == null ? null : json["title"],
    value: json["value"] == null ? null : json["value"],
  );

  Map<String, dynamic> toJson() => {
    "title": title == null ? null : title,
    "value": value == null ? null : value,
  };
}
