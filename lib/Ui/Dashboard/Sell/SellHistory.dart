import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
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
                      padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 15),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColor.darkGrey01Color,
                          border: Border.all(
                            color: MyColor.boarderColor,
                          )
                      ),
                      child: Column(
                        children: [


                          Row(
                            children: [
                              Text(
                                "status:",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),

                              const SizedBox(width: 5),
                              Text(
                                list.orderStatus,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                              const Spacer(),

                            ],
                          ),


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
