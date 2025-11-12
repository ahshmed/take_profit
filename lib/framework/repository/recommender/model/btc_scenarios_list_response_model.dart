// To parse this JSON data, do
//
//     final btcScenariosListResponseModel = btcScenariosListResponseModelFromJson(jsonString);

import 'dart:convert';

BtcScenariosListResponseModel btcScenariosListResponseModelFromJson(String str) => BtcScenariosListResponseModel.fromJson(json.decode(str));

String btcScenariosListResponseModelToJson(BtcScenariosListResponseModel data) => json.encode(data.toJson());

class BtcScenariosListResponseModel {
  BtcScenariosListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory BtcScenariosListResponseModel.fromJson(Map<String, dynamic> json) => BtcScenariosListResponseModel(
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
    this.signalList,
  });

  String? pageNumber;
  String? totalPage;
  String? perPage;
  List<SignalList>? signalList;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pageNumber: json["page_number"],
    totalPage: json["total_page"],
    perPage: json["per_page"],
    signalList: json["signal_list"] == null ? [] : List<SignalList>.from(json["signal_list"]!.map((x) => SignalList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "page_number": pageNumber,
    "total_page": totalPage,
    "per_page": perPage,
    "signal_list": signalList == null ? [] : List<dynamic>.from(signalList!.map((x) => x.toJson())),
  };
}

class SignalList {
  SignalList({
    this.scenarioId,
    this.description,
    this.descriptionEn,
    this.descriptionAr,
    this.createdAt,
    this.date,
    this.time,
    this.images,
  });

  String? scenarioId;
  String? description;
  String? descriptionEn;
  String? descriptionAr;
  String? createdAt;
  String? date;
  String? time;
  List<BTCImage>? images;

  factory SignalList.fromJson(Map<String, dynamic> json) => SignalList(
    scenarioId: json["scenario_id"],
    description: json["description"],
    descriptionEn: json["description:en"],
    descriptionAr: json["description:ar"],
    createdAt: json["created_at"],
    date: json["date"],
    time: json["time"],
    images: json["images"] == null ? [] : List<BTCImage>.from(json["images"]!.map((x) => BTCImage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "scenario_id": scenarioId,
    "description": description,
    "description:en": descriptionEn,
    "description:ar": descriptionAr,
    "created_at": createdAt,
    "date": date,
    "time": time,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
  };
}

class BTCImage {
  BTCImage({
    this.imageId,
    this.image,
  });

  String? imageId;
  String? image;

  factory BTCImage.fromJson(Map<String, dynamic> json) => BTCImage(
    imageId: json["image_id"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "image_id": imageId,
    "image": image,
  };
}
