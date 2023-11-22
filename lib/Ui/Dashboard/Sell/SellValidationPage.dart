import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Wallet/WithdrawToken/WithdrawSuccessful.dart';

// ignore: must_be_immutable
class SellValidationPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var params,coinName,pageName,sendData;
  SellValidationPage({
    super.key,
    required this.params,
    required this.coinName,
    required this.pageName,
    this.sendData,
  });

  @override
  State<SellValidationPage> createState() => _SellValidationPageState();
}

class _SellValidationPageState extends State<SellValidationPage> {

    late BuySellProvider buySellProvider;
  bool acceptTerms = false;


  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    buySellProvider.sellOderLoading = false;
    super.initState();
  }


  var selectedAccountId = "";
  placeSellOrder()async{
    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    selectedAccountId = sharedPre.getString('accountId') ?? "";
    var data = widget.params;

    setState(() {
      data['action'] = "place_sell_order";
    });

    var sendData = widget.sendData;
    // ignore: use_build_context_synchronously
    // print("object ${widget.sendData}");
    await buySellProvider.sellOrder(
        widget.params,
        selectedAccountId,
        context,
        widget.pageName == "" ? "" : "send",
        widget.sendData == null ? {} : sendData,
        widget.coinName
    );

    if(buySellProvider.sellSuccess){
      if(widget.sendData == null) {
        notifyOrder();
      }
    }
  }


  notifyOrder()async{

    var params = {
      "action":"notify_payment_made",
      "email":widget.params['email'],
      "invoice":buySellProvider.sellResponce['invoice'],
      "auth":"p1~\$*)Ze(@"
    };

    await buySellProvider.notifyOrder(
        params,
        context,
        "sell"
    );

    if(buySellProvider.placeNotifyOrder) {

      // ignore: use_build_context_synchronously
      Navigator.pop(context,"refresh");
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WithdrawSuccessful(
                  invoice: buySellProvider.sellResponce['invoice'],
                  tokenName: widget.coinName,
                ),
          )
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(15,0,15,15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
               setState(() {
                 acceptTerms = !acceptTerms;
               });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                        color: acceptTerms ? MyColor.greenColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            width: 1.5,
                            color: acceptTerms ?  MyColor.greenColor : MyColor.whiteColor.withOpacity(0.4)
                        )
                    ),
                    child: acceptTerms
                        ?
                    const Center(
                        child: Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        )
                    )
                        :
                    const SizedBox(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:"Accept ",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text:"Terms & Condition",
                            style: MyStyle.tx18BWhite.copyWith(
                                fontSize: 16,
                                color: MyColor.greenColor
                            ),
                          ),
                        ]
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),

            buySellProvider.sellOderLoading
                ?
            const SizedBox(
                height:52,
                child: Center(
                    child: CircularProgressIndicator(
                      color: MyColor.greenColor,
                    )
                )
            )
                :
            InkWell(
              onTap: () {
                if(acceptTerms) {
                  placeSellOrder();
                }else{
                  Helper.dialogCall.showToast(context, "Accept terms and condition.");
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: 45,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: acceptTerms
                    ?
                MyStyle.buttonDecoration
                    :
                MyStyle.invalidDecoration,

                child: Text(
                  "Proceed",
                  style:  MyStyle.tx18BWhite.copyWith(
                      color: acceptTerms
                          ?
                      MyColor.mainWhiteColor
                          :
                      MyColor.mainWhiteColor.withOpacity(0.4)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          "Sell Order Preview",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: buySellProvider.getSellValidation['info'].split("\n").length,
                itemBuilder: (context, index) {
                  var list = buySellProvider.getSellValidation['info'].split("\n")[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                     index < buySellProvider.getSellValidation['info'].split("\n").length-1
                          ?
                      list
                          :
                      "You Get : ${list.toString().split(":").last.trim()}",
                      style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 15
                      ),
                    ),
                  );
                },
              ),

              Text(
                "Coin : ${widget.coinName}",
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 15
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "Transaction type : Sell",
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 15
                ),
              ),
              const SizedBox(height: 15),

              Text(
                "Note: Please confirm your sell order and make sure all details"
                    " provided are correct before you proceed",
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 13,
                    color: MyColor.grey01Color
                ),
              ),

            ],
          ),

        ),
      ),
    );
  }
}
