import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyValidationPage extends StatefulWidget {
  String itemCode,amount,receivingAddress,bank;
  RatesInfo? selectedCoin;
  BuyValidationPage({
    super.key,
    required this.itemCode,
    required this.selectedCoin,
    required this.amount,
    required this.receivingAddress,
    required this.bank,
  });

  @override
  State<BuyValidationPage> createState() => _BuyValidationPageState();
}

class _BuyValidationPageState extends State<BuyValidationPage> {

  late BuySellProvider buySellProvider;

  validateBuy() async {

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    var email = sharedPre.getString("email");

    var params = {
      "action":"validate_buy_order",
      "email": email,
      "token":buySellProvider.loginModel!.accessToken,
      "item_code":widget.itemCode,
      "amount":widget.amount,
      "receiving_account":widget.receivingAddress,
      "bank":widget.bank,
      "auth":"p1~\$*)Ze(@",
    };

    await buySellProvider.validateBuyOrder(params);

  }

  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    super.initState();
    Future.delayed(Duration.zero,(){
      validateBuy();
    });
  }
  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
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
          "Validation Order",
        ),

      ),
      body: buySellProvider.isValidBuyLoading
          ?
      Helper.dialogCall.showLoader()
          :
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: MyColor.darkGrey01Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child: Text(
                          "Type: ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                          "Buy",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Currency/Service: ",
                          style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                          widget.selectedCoin!.name,
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Amount ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                        "${widget.amount} USD",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "You Pay ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "${(double.parse("${widget.selectedCoin!.buyPrice}") * double.parse(widget.amount) + 7.5 /100 * (5*double.parse(widget.amount)) + 50)} NGN",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),




                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: MyColor.darkGrey01Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "VAT",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "${7.5 /100 * (5*double.parse(widget.amount))} NGN",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                      ),

                      Expanded(
                        child: Text(
                          "(including 7.5% VAT)",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 12
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Stamp Duty: ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                        "50 NGN",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: MyColor.darkGrey01Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child: Text(
                          "Currency Account: ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                            "${widget.receivingAddress.substring(0,4)}...${widget.receivingAddress.substring(widget.receivingAddress.length-4,widget.receivingAddress.length)}",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Payment Method: ",
                          style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                          "Bank",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Bank Name: ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                        widget.bank,
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),

            // Text(
            //   "${buySellProvider.getValidData['info']}",
            //   style: MyStyle.tx18RWhite.copyWith(
            //       fontSize: 12
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
