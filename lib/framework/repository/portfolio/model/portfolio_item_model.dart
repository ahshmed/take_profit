class PortfolioItemModel {
  final String ticker;
  final String companyName;
  final String currentPrice;
  final double buyPrice;
  final String buyStatus;
  final String complianceStatus;
  final String dateTime;

  PortfolioItemModel({
    required this.ticker,
    required this.companyName,
    required this.currentPrice,
    required this.buyPrice,
    required this.buyStatus,
    required this.complianceStatus,
    required this.dateTime,
  });

  // CopyWith method
  PortfolioItemModel copyWith({
    String? ticker,
    String? companyName,
    String? currentPrice,
    double? buyPrice,
    String? buyStatus,
    String? complianceStatus,
    String? dateTime,
  }) {
    return PortfolioItemModel(
      ticker: ticker ?? this.ticker,
      companyName: companyName ?? this.companyName,
      currentPrice: currentPrice ?? this.currentPrice,
      buyPrice: buyPrice ?? this.buyPrice,
      buyStatus: buyStatus ?? this.buyStatus,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'companyName': companyName,
      'currentPrice': currentPrice,
      'buyPrice': buyPrice,
      'buyStatus': buyStatus,
      'complianceStatus': complianceStatus,
      'dateTime': dateTime,
    };
  }

  // From JSON
  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      ticker: json['ticker'] ?? '',
      companyName: json['companyName'] ?? '',
      currentPrice: json['currentPrice'] ?? '\$0.0',
      buyPrice: (json['buyPrice'] ?? 0).toDouble(),
      buyStatus: json['buyStatus'] ?? 'Hold',
      complianceStatus: json['complianceStatus'] ?? 'Sharia Compliant',
      dateTime: json['dateTime'] ?? '',
    );
  }
}
