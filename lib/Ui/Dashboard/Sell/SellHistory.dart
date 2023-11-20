import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Sell_History_address.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SellStatusPage.dart';

class SellHistory extends StatefulWidget {
  const SellHistory({super.key});

  @override
  State<SellHistory> createState() => _SellHistoryState();
}

class _SellHistoryState extends State<SellHistory> {
  late BuySellProvider buySellProvider;

  String selectedAccountId ="";
  bool isLoading = false;

  getAllSellHistory() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DbSellHistory.dbSellHistory.getSellHistory(selectedAccountId);

    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    buySellProvider.sellHistoryList.clear();
    Future.delayed(Duration.zero,(){
      getAllSellHistory();
    });
  }

  @override
  Widget build(BuildContext context) {

    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    return Scaffold(
      appBar: AppBar(
        leading:  InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: MyColor.mainWhiteColor,
            size: 20,
          ),
        ),
        title: const Text(
          "Sell History",
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [


            Expanded(
              child: isLoading
                  ?
              Helper.dialogCall.showLoader()
                  :
              DbSellHistory.dbSellHistory.sellHistoryList.isEmpty
                  ?
              Center(
                child: Text(
                  "No Transaction Yet.",
                  style: MyStyle.tx18RWhite.copyWith(
                      color: MyColor.grey01Color
                  ),
                ),
              )
                  :
              ListView.builder(
                shrinkWrap: true,
                itemCount: DbSellHistory.dbSellHistory.sellHistoryList.length,
                itemBuilder: (context, index) {
                  var list = DbSellHistory.dbSellHistory.sellHistoryList[index];
                  dynamic sendNetwork;
                  var dbSymbol = list.payinAmount.split(" ").last;
                  if(dbSymbol.toLowerCase() == "usdtbsc"){
                    sendNetwork = {
                      "logo":"http://139.59.88.239/api/img/token/bsc_usdt.png",
                      "name":"Tether USD",
                      "symbol":"USDT"
                    };
                  }
                  else if(dbSymbol.toLowerCase() == "usdttrc20"){
                    sendNetwork = {
                      "logo":"http://139.59.88.239/api/img/token/trx_usdt.png",
                      "name":"Tether USD",
                      "symbol":"USDT"
                    };
                  }
                  else{
                    final temp = DbNetwork.dbNetwork.networkList.where((element) {
                      return element.symbol.toLowerCase() == dbSymbol.trim().toLowerCase();
                    }).toList().first;

                    sendNetwork = {
                      "logo":temp.logo,
                      "name":temp.name,
                      "symbol":temp.symbol

                    };
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellStatusPage(invoiceNo: list.invoice),
                          )
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                      decoration: BoxDecoration(
                          color: MyColor.darkGrey01Color,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              CachedNetworkImage(
                                height: 25,
                                width: 25,
                                fit: BoxFit.fill,
                                imageUrl: sendNetwork["logo"],
                                placeholder: (context, url) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                        color: MyColor.greenColor
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) {
                                  return Container(
                                    height: 25,
                                    width: 25,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: MyColor.whiteColor,
                                    ),
                                    child: Image.asset(
                                      "assets/images/bitcoin.png",
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  sendNetwork["name"],
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                              ),
                              Text(
                                DbSellHistory.dbSellHistory.getTrxStatusData == null ? "" :
                                "~${DbSellHistory.dbSellHistory.getTrxStatusData!.payinAmount}",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [

                              Expanded(
                                child: Text(
                                  "We Pay: ",
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                              ),
                              Text(
                                "${list.amountPayableNgn} NGN",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [

                              Expanded(
                                child: Text(
                                  "Trxn Status: ",
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                              ),
                              Text(
                                list!.orderStatus,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 10),

                          // invoice id
                          InkWell(
                            onTap: () {
                              FlutterClipboard.copy(list.invoice).then((value) {
                                Helper.dialogCall.showToast(context, "Invoice No Copied");
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Invoice No: ",
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    list.invoice,
                                    textAlign: TextAlign.end,
                                    style: MyStyle.tx18RWhite.copyWith(
                                        fontSize: 16
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.copy,
                                  size: 20,
                                  color: MyColor.whiteColor,
                                ),

                              ],
                            ),
                          ),
                          const SizedBox(height: 10),


                          //  validity time
                          Row(
                            children: [

                              Text(
                                "Date: ",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat("dd MMM yyyy hh:mm a").format(DateTime.fromMillisecondsSinceEpoch(list.time * 1000)),
                                  textAlign: TextAlign.end,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 5),

                        ],
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}
