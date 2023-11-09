import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class SellValidationPage extends StatefulWidget {
  var params;
  SellValidationPage({super.key,required this.params});

  @override
  State<SellValidationPage> createState() => _SellValidationPageState();
}

class _SellValidationPageState extends State<SellValidationPage> {

  late BuySellProvider buySellProvider;
  bool acceptTerms = false;


  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    super.initState();
  }


  var selectedAccountId = "";
  placeSellOrder(context)async{
    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    selectedAccountId = sharedPre.getString('accountId') ?? "";
    var data = widget.params;
    setState(() {
      data['action'] = "place_sell_order";
    });

    // print(jsonEncode(data));
    await buySellProvider.sellOrder(widget.params, selectedAccountId, context);
  }

  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    return Scaffold(
      bottomNavigationBar: buySellProvider.sellOderLoading
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
            placeSellOrder(context);
          }else{
            Helper.dialogCall.showToast(context, "Review All Details.");
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(15,0,15,15),
          alignment: Alignment.center,
          height: 45,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: acceptTerms
              ?
          MyStyle.buttonDecoration
              :
          MyStyle.invalidDecoration,

          child: Text(
            "Place Sell Order",
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

      appBar: AppBar(
        centerTitle: true,
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
          "Place Order",
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Note: ${buySellProvider.getSellValidation['info']}".split("\n").first,
              style: MyStyle.tx18RWhite.copyWith(
                fontSize: 14,
                color: MyColor.dotBoarderColor
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Text(
                    "Note: ${buySellProvider.getSellValidation['info']}".split("\n")[2],
                    style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                    )
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      "Note: ${buySellProvider.getSellValidation['info']}".split("\n")[3].split(" ").last,
                      style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                      )
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
                "${buySellProvider.getSellValidation['info']}".split("\n")[4],
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 16
                )
            ),
            const SizedBox(height: 8),
            Text(
                "${buySellProvider.getSellValidation['info']}".split("\n")[5],
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 16
                )
            ),

            const SizedBox(height: 8),
            Text(
                "${buySellProvider.getSellValidation['info']}".split("\n")[6],
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 16
                )
            ),

            const SizedBox(height: 8),
            Text(
                "${buySellProvider.getSellValidation['info']}".split("\n")[7],
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 16
                )
            ),

            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                setState(() {
                  acceptTerms = !acceptTerms;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: acceptTerms ? const Center(child: Icon(Icons.check,size: 18,color: Colors.white,)) : const SizedBox(),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                        "${buySellProvider.getSellValidation['info'].split("\n")[8]}",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16,
                            color: acceptTerms ? MyColor.whiteColor : MyColor.dotBoarderColor
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
