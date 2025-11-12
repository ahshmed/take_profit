// To parse this JSON data, do
//
//     final allSignalListResponseModel = allSignalListResponseModelFromJson(jsonString);

import 'dart:convert';
import 'package:take_profit/framework/repository/signal/model/signal_list_response_model.dart' as Sig;


AllSignalListResponseModel allSignalListResponseModelFromJson(String str) => AllSignalListResponseModel.fromJson(json.decode(str));

String allSignalListResponseModelToJson(AllSignalListResponseModel data) => json.encode(data.toJson());

class AllSignalListResponseModel {
  String? success;
  String? status;
  String? message;
  Data? data;

  AllSignalListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  factory AllSignalListResponseModel.fromJson(Map<String, dynamic> json) => AllSignalListResponseModel(
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
  dynamic pageNumber;
  String? totalPage;
  int? perPage;
  List<Sig.SignalList>? signalList;

  Data({
    this.pageNumber,
    this.totalPage,
    this.perPage,
    this.signalList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"],
    totalPage: json["total_page"],
    perPage: json["per_page"],
    signalList: json["signal_list"] == null ? [] : List<Sig.SignalList>.from(json["signal_list"]!.map((x) => Sig.SignalList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber,
    "total_page": totalPage,
    "per_page": perPage,
    "signal_list": signalList == null ? [] : List<dynamic>.from(signalList!.map((x) => x.toJson())),
  };
}


class Target {
  String? targetId;
  String? targetType;
  String? price;
  String? toPrice;

  Target({
    this.targetId,
    this.targetType,
    this.price,
    this.toPrice,
  });

  factory Target.fromJson(Map<String, dynamic> json) => Target(
    targetId: json["target_id"],
    targetType: json["target_type"],
    price: json["price"],
    toPrice: json["to_price"],
  );

  Map<String, dynamic> toJson() => {
    "target_id": targetId,
    "target_type": targetType,
    "price": price,
    "to_price": toPrice,
  };
}
