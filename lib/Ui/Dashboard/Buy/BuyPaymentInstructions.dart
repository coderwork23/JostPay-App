import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Buy/BuySuccessful.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ignore: must_be_immutable
class BuyPaymentInstructions extends StatefulWidget {
  var buyResponse;

  BuyPaymentInstructions({
    super.key,
    required this.buyResponse
  });

  @override
  State<BuyPaymentInstructions> createState() => _BuyPaymentInstructionsState();
}

class _BuyPaymentInstructionsState extends State<BuyPaymentInstructions> {

  late BuySellProvider buySellProvider;

  notifyOrder(invoice)async{

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    var email = sharedPre.getString("email");

    var params = {
      "action":"notify_payment_made",
      "email":email,
      "invoice":invoice,
      "auth":"p1~\$*)Ze(@"
    };

    // ignore: use_build_context_synchronously
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
                BuySuccessful(
                  invoice: invoice,
                ),
          )
      );

    }
  }

  @override
  void initState() {
    super.initState();
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);

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
          "Payment Instructions",
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
              decoration: BoxDecoration(
                  color:MyColor.darkGrey01Color,
                borderRadius: BorderRadius.circular(10)
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.buyResponse.toString().substring(1,widget.buyResponse.toString().length-1).split("\n").length,
                itemBuilder: (context, index) {
                  var length = widget.buyResponse.toString().substring(1,widget.buyResponse.toString().length-1).split("\n").length;
                  var list = widget.buyResponse.toString().substring(1,widget.buyResponse.toString().length-1).split("\n")[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: index == 0,
                          child:  Text(
                              index != 0 ? "" : list.split(',').last,
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 15,
                                color: MyColor.whiteColor
                            ),
                          ),
                        ),
                        Visibility(
                          visible: index != 0 && index != length -1,
                          child: Text(
                              list,
                            style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 15,
                              color: MyColor.whiteColor
                            ),
                          ),
                        ),
                        Visibility(
                          visible: index == length -1 ,
                          child: Text(
                              list.split(",").first,
                            style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 15,
                                color: MyColor.whiteColor
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            buySellProvider.notifyLoading
                ?
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Helper.dialogCall.showLoader(),
            )
                :
            InkWell(
              onTap: () {
                var value = widget.buyResponse.toString().substring(1,widget.buyResponse.toString().length-1).split("Invoice no :").last.trim();
                var invoice = value.split(" ").first.split("\n").first.trim();
                notifyOrder(invoice);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(15,0,15,15),
                alignment: Alignment.center,
                height: 45,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: MyStyle.buttonDecoration,
                child: Text(
                  "I have paid",
                  style: MyStyle.tx18BWhite.copyWith(
                      color: MyColor.mainWhiteColor
                  ),
                ),
              ),
            ),

            Text(
              "Tap this button once you make payment",
              style: MyStyle.tx18RWhite.copyWith(
                  fontSize: 15,
                  color: MyColor.whiteColor
              ),
            )
          ],
        ),
      )
    );
  }
}
