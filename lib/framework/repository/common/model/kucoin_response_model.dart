class KuCoinResponse {
  String? code;
  KuCoinResponseData? data;

  KuCoinResponse({
    this.code,
    this.data,
  });

  factory KuCoinResponse.fromJson(Map<String, dynamic> json) =>
      KuCoinResponse(
        code: json['code'],
        data: KuCoinResponseData.fromJson(json['data']),
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "data": data?.toJson(),
  };
}

class KuCoinResponseData {
  String? token;
  KuCoinInstanceServers? instanceServers;

  KuCoinResponseData({
    this.token,
    this.instanceServers,
  });

  factory KuCoinResponseData.fromJson(Map<String, dynamic> json) =>
      KuCoinResponseData(
        token: json['token'],
        instanceServers: KuCoinInstanceServers.fromJson(json['instanceServers'][0]),
      );

  Map<String, dynamic> toJson() => {
    "token": token,
    "instanceServers": instanceServers?.toJson(),
  };
}

class KuCoinInstanceServers {
  String? endpoint;

  KuCoinInstanceServers({
    this.endpoint,
  });

  factory KuCoinInstanceServers.fromJson(Map<String, dynamic> json) =>
      KuCoinInstanceServers(
        endpoint: json['endpoint'],
      );

  Map<String, dynamic> toJson() => {
    "endpoint": endpoint,
  };
}