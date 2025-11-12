// Enhanced Stock Model for US Market with Tab Filtering Support
class StockModel {
  final String ticker;
  final String companyName;
  final String price;
  final String iconAsset;
  final bool isFavorite;
  final String changePercent;
  final bool isPositiveChange;
  final String buyStatus; // "Strong Buy", "Buy", "Hold", "Sell"
  final String complianceStatus; // "Sharia Compliant", "Non-Sharia Compliant"
  final bool isBlurred;
  final String dateTime;

  StockModel({
    required this.ticker,
    required this.companyName,
    required this.price,
    required this.iconAsset,
    this.isFavorite = false,
    this.changePercent = "0.0",
    this.isPositiveChange = true,
    this.buyStatus = "Hold",
    this.complianceStatus = "Sharia Compliant",
    this.isBlurred = false,
    this.dateTime = "",
  });

  // Enhanced mock data for stock list with all fields
  static List<StockModel> getMockStockList() {
    return [
      StockModel(
        ticker: "XPEV",
        companyName: "Xpeng Inc.",
        price: "\$644.0",
        iconAsset: "IC_STOCK_XPEV",
        isFavorite: false,
        changePercent: "+3.1%",
        isPositiveChange: true,
        buyStatus: "Strong Buy",
        complianceStatus: "Sharia Compliant",
        isBlurred: false,
        dateTime: "01/11/2022 14:35",
      ),
      StockModel(
        ticker: "AAPL",
        companyName: "Apple Inc.",
        price: "\$854.0",
        iconAsset: "IC_STOCK_AAPL",
        isFavorite: true,
        changePercent: "+2.5%",
        isPositiveChange: true,
        buyStatus: "Sell",
        complianceStatus: "Non-Sharia Compliant",
        isBlurred: true,
        dateTime: "01/11/2022 14:35",
      ),
      StockModel(
        ticker: "TSLA",
        companyName: "Tesla Inc.",
        price: "\$1,245.0",
        iconAsset: "IC_STOCK_TSLA",
        isFavorite: false,
        changePercent: "-0.8%",
        isPositiveChange: false,
        buyStatus: "Strong Buy",
        complianceStatus: "Sharia Compliant",
        isBlurred: false,
        dateTime: "01/11/2022 15:20",
      ),
      StockModel(
        ticker: "NIO",
        companyName: "NIO Inc.",
        price: "\$342.0",
        iconAsset: "IC_STOCK_NIO",
        isFavorite: false,
        changePercent: "+1.2%",
        isPositiveChange: true,
        buyStatus: "Buy",
        complianceStatus: "Sharia Compliant",
        isBlurred: false,
        dateTime: "01/11/2022 16:10",
      ),
      StockModel(
        ticker: "AMZN",
        companyName: "Amazon Inc.",
        price: "\$3,125.0",
        iconAsset: "IC_STOCK_AMZN",
        isFavorite: false,
        changePercent: "+1.8%",
        isPositiveChange: true,
        buyStatus: "Hold",
        complianceStatus: "Non-Sharia Compliant",
        isBlurred: false,
        dateTime: "01/11/2022 13:45",
      ),
      StockModel(
        ticker: "DIS",
        companyName: "The Walt Disney Company",
        price: "\$325.0",
        iconAsset: "IC_STOCK_DIS",
        isFavorite: false,
        changePercent: "-1.2%",
        isPositiveChange: false,
        buyStatus: "Buy",
        complianceStatus: "Sharia Compliant",
        isBlurred: false,
        dateTime: "01/11/2022 12:30",
      ),
      StockModel(
        ticker: "PLTR",
        companyName: "Palantir Technologies Inc.",
        price: "\$425.0",
        iconAsset: "IC_STOCK_PLTR",
        isFavorite: false,
        changePercent: "+0.5%",
        isPositiveChange: true,
        buyStatus: "Sell",
        complianceStatus: "Non-Sharia Compliant",
        isBlurred: true,
        dateTime: "01/11/2022 11:15",
      ),
      StockModel(
        ticker: "APDD",
        companyName: "Air Products and Chemicals",
        price: "\$2,845.0",
        iconAsset: "IC_STOCK_APDD",
        isFavorite: false,
        changePercent: "+4.2%",
        isPositiveChange: true,
        buyStatus: "Strong Buy",
        complianceStatus: "Sharia Compliant",
        isBlurred: false,
        dateTime: "01/11/2022 10:00",
      ),
      StockModel(
        ticker: "GOOGL",
        companyName: "Alphabet Inc.",
        price: "\$138.90",
        iconAsset: "IC_STOCK_GOOGL",
        isFavorite: false,
        changePercent: "+2.1%",
        isPositiveChange: true,
        buyStatus: "Buy",
        complianceStatus: "Sharia Compliant",
        isBlurred: false,
        dateTime: "01/11/2022 09:30",
      ),
      StockModel(
        ticker: "MSFT",
        companyName: "Microsoft Corporation",
        price: "\$378.50",
        iconAsset: "IC_STOCK_MSFT",
        isFavorite: true,
        changePercent: "+1.5%",
        isPositiveChange: true,
        buyStatus: "Strong Buy",
        complianceStatus: "Sharia Compliant",
        isBlurred: false,
        dateTime: "01/11/2022 08:45",
      ),
    ];
  }

  // Copy with method for state updates - NOW WITH ALL FIELDS
  StockModel copyWith({
    String? ticker,
    String? companyName,
    String? price,
    String? iconAsset,
    bool? isFavorite,
    String? changePercent,
    bool? isPositiveChange,
    String? buyStatus,
    String? complianceStatus,
    bool? isBlurred,
    String? dateTime,
  }) {
    return StockModel(
      ticker: ticker ?? this.ticker,
      companyName: companyName ?? this.companyName,
      price: price ?? this.price,
      iconAsset: iconAsset ?? this.iconAsset,
      isFavorite: isFavorite ?? this.isFavorite,
      changePercent: changePercent ?? this.changePercent,
      isPositiveChange: isPositiveChange ?? this.isPositiveChange,
      buyStatus: buyStatus ?? this.buyStatus,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      isBlurred: isBlurred ?? this.isBlurred,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}