// To parse this JSON data, do
//
//     final revenueChartResponseModel = revenueChartResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

RevenueChartResponseModel revenueChartResponseModelFromJson(String str) => RevenueChartResponseModel.fromJson(json.decode(str));

String revenueChartResponseModelToJson(RevenueChartResponseModel data) => json.encode(data.toJson());

class RevenueChartResponseModel {
  RevenueChartResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory RevenueChartResponseModel.fromJson(Map<String, dynamic> json) => RevenueChartResponseModel(
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
    this.totalSubs,
    this.totalPayment,
    this.yAxisMaxValue,
    this.graphData,
  });

  String? totalSubs;
  String? totalPayment;
  String? yAxisMaxValue;
  List<GraphDatum>? graphData;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalSubs: json["total_subs"] == null ? null : json["total_subs"],
    totalPayment: json["total_payment"] == null ? null : json["total_payment"],
    yAxisMaxValue: json["y_axis_max_value"] == null ? null : json["y_axis_max_value"],
    graphData: json["graph_data"] == null ? null : List<GraphDatum>.from(json["graph_data"].map((x) => GraphDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total_subs": totalSubs == null ? null : totalSubs,
    "total_payment": totalPayment == null ? null : totalPayment,
    "y_axis_max_value": yAxisMaxValue == null ? null : yAxisMaxValue,
    "graph_data": graphData == null ? null : List<dynamic>.from(graphData!.map((x) => x.toJson())),
  };
}

class GraphDatum {
  GraphDatum({
    this.xAxis,
    this.yAxis,
  });

  String? xAxis;
  String? yAxis;

  factory GraphDatum.fromJson(Map<String, dynamic> json) => GraphDatum(
    xAxis: json["x_axis"] == null ? null : json["x_axis"],
    yAxis: json["y_axis"] == null ? null : json["y_axis"],
  );

  Map<String, dynamic> toJson() => {
    "x_axis": xAxis == null ? null : xAxis,
    "y_axis": yAxis == null ? null : yAxis,
  };
}
