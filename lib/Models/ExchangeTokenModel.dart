import 'dart:convert';

List<ExchangeTokenModel> exchangeTokenModelFromJson(String str) => List<ExchangeTokenModel>.from(json.decode(str).map((x) => ExchangeTokenModel.fromJson(x)));

String exchangeTokenModelToJson(List<ExchangeTokenModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExchangeTokenModel {
  String ticker;
  String name;
  String image;
  bool hasExternalId;
  bool isFiat;
  bool featured;
  bool isStable;
  bool supportsFixedRate;

  ExchangeTokenModel({
    required this.ticker,
    required this.name,
    required this.image,
    required this.hasExternalId,
    required this.isFiat,
    required this.featured,
    required this.isStable,
    required this.supportsFixedRate,
  });

  factory ExchangeTokenModel.fromJson(Map<String, dynamic> json) => ExchangeTokenModel(
    ticker: json["ticker"],
    name: json["name"],
    image: json["image"],
    hasExternalId: json["hasExternalId"],
    isFiat: json["isFiat"],
    featured: json["featured"],
    isStable: json["isStable"],
    supportsFixedRate: json["supportsFixedRate"],
  );

  Map<String, dynamic> toJson() => {
    "ticker": ticker,
    "name": name,
    "image": image,
    "hasExternalId": hasExternalId,
    "isFiat": isFiat,
    "featured": featured,
    "isStable": isStable,
    "supportsFixedRate": supportsFixedRate,
  };
}
