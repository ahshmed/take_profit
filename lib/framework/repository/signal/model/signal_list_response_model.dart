// To parse this JSON data, do
//
//     final signalListResponseModel = signalListResponseModelFromJson(jsonString);

import 'dart:convert';

SignalListResponseModel signalListResponseModelFromJson(String str) => SignalListResponseModel.fromJson(json.decode(str));

String signalListResponseModelToJson(SignalListResponseModel data) => json.encode(data.toJson());

class SignalListResponseModel {
  SignalListResponseModel({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  String? success;
  String? status;
  String? message;
  Data? data;

  factory SignalListResponseModel.fromJson(Map<String, dynamic> json) => SignalListResponseModel(
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
    this.signalId,
    this.currencyId,
    this.apiCurrencyId,
    this.currencyCode,
    this.currencyName,
    this.currencySymbol,
    this.currencyLogo,
    this.walletPercentage,
    this.riskFactor,
    this.riskFactorLabel,
    this.profitStatus,
    this.profitLabel,
    this.livePrice,
    this.entryPrice,
    this.stopLoss,
    this.chartImage,
    this.description,
    this.descriptionEn,
    this.descriptionAr,
    this.status,
    this.targets,
    this.livePriceFromBinance = false,
    this.enableNotification = 1,
  });

  String? signalId;
  String? currencyId;
  String? apiCurrencyId;
  String? currencyCode;
  String? currencyName;
  String? currencySymbol;
  String? currencyLogo;
  String? walletPercentage;
  String? riskFactor;
  String? riskFactorLabel;
  String? profitStatus;
  String? profitLabel;
  String? livePrice;
  String? entryPrice;
  String? stopLoss;
  String? chartImage;
  String? description;
  String? descriptionEn;
  String? descriptionAr;
  String? status;
  List<Target>? targets;
  bool livePriceFromBinance;
  int enableNotification;

  factory SignalList.fromJson(Map<String, dynamic> json) => SignalList(
    signalId: json["signal_id"],
    currencyId: json["currency_id"],
    apiCurrencyId: json["api_currency_id"],
    currencyCode: json["currency_code"],
    currencyName: json["currency_name"],
    currencySymbol: json["currency_symbol"],
    currencyLogo: json["currency_logo"],
    walletPercentage: json["wallet_percentage"],
    riskFactor: json["risk_factor"],
    riskFactorLabel: json["risk_factor_label"],
    profitStatus: json["profit_status"],
    profitLabel: json["profit_label"],
    livePrice: json["live_price"],
    entryPrice: json["entry_price"],
    stopLoss: json["stop_loss"],
    chartImage: json["chart_image"],
    description: json["description"],
    descriptionEn: json["description:en"],
    descriptionAr: json["description:ar"],
    status: json["status"],
    targets: json["targets"] == null ? [] : List<Target>.from(json["targets"]!.map((x) => Target.fromJson(x))),
    livePriceFromBinance: json["livePriceFromBinance"] ?? false,
    enableNotification: json["enable_notification"] ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "signal_id": signalId,
    "currency_id": currencyId,
    "api_currency_id": apiCurrencyId,
    "currencyCode": currencyCode,
    "currency_name": currencyName,
    "currency_symbol": currencySymbol,
    "currency_logo": currencyLogo,
    "wallet_percentage": walletPercentage,
    "risk_factor": riskFactor,
    "risk_factor_label": riskFactorLabel,
    "profit_status": profitStatus,
    "profit_label": profitLabel,
    "live_price": livePrice,
    "entry_price": entryPrice,
    "stop_loss": stopLoss,
    "chart_image": chartImage,
    "description": description,
    "description:en": descriptionEn,
    "description:ar": descriptionAr,
    "status": status,
    "targets": targets == null ? [] : List<dynamic>.from(targets!.map((x) => x.toJson())),
    "livePriceFromBinance": livePriceFromBinance,
    "enable_notification": enableNotification,
  };
}

class Target {
  Target({
    this.targetId,
    this.targetType,
    this.price,
    this.toPrice,
    this.rawPrice,
  });

  String? targetId;
  String? targetType;
  String? price;
  String? toPrice;
  String? rawPrice;

  factory Target.fromJson(Map<String, dynamic> json) => Target(
    targetId: json["target_id"],
    targetType: json["target_type"],
    price: json["price"],
    toPrice: json["to_price"],
    rawPrice: json["raw_price"],
  );

  Map<String, dynamic> toJson() => {
    "target_id": targetId,
    "target_type": targetType,
    "price": price,
    "to_price": toPrice,
    "raw_price": rawPrice,
  };
}
