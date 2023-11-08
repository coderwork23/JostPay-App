class SellHistoryModel {
  int amountPayableNgn;
  String invoice;
  String orderStatus;
  String invoiceNo;
  String invoiceUrl;
  int time;
  String type;
  String payinAmount;
  String payoutAmount;
  String payoutAddress;
  String accountId;
  String payinUrl;

  SellHistoryModel({
    required this.amountPayableNgn,
    required this.invoice,
    required this.orderStatus,
    required this.invoiceNo,
    required this.invoiceUrl,
    required this.time,
    required this.type,
    required this.payinAmount,
    required this.payoutAmount,
    required this.payoutAddress,
    required this.accountId,
    required this.payinUrl,
  });

  factory SellHistoryModel.fromJson(Map<String, dynamic> json,acId) => SellHistoryModel(
    amountPayableNgn: json["amount_payable_ngn"],
    invoice: json["invoice"],
    orderStatus: json["order_status"],
    invoiceNo: json["invoice_no"],
    invoiceUrl: json["invoice_url"],
    time: json["time"],
    type: json["type"],
    payinAmount: json["payin_amount"],
    payoutAmount: json["payout_amount"],
    payoutAddress: json["payout_address"],
    accountId: acId,
    payinUrl: json["payin_url"],
  );

  Map<String, dynamic> toJson() => {
    "amount_payable_ngn": amountPayableNgn,
    "invoice": invoice,
    "order_status": orderStatus,
    "invoice_no": invoiceNo,
    "invoice_url": invoiceUrl,
    "time": time,
    "type": type,
    "payin_amount": payinAmount,
    "payout_amount": payoutAmount,
    "payout_address": payoutAddress,
    "payin_url": payinUrl,
  };
}
