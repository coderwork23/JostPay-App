import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

import 'ExchangeAddressScreen.dart';
import 'ExchangeHistory.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {

  TextEditingController sendCoinController = TextEditingController();
  TextEditingController getCoinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExchangeAddressScreen(),
              )
          );
        },
        child: Container(
          alignment: Alignment.center,
          height: 45,
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: MyStyle.buttonDecoration.copyWith(
              color: MyColor.greenColor,
          ),
          child:  Text(
            "Enter Address",
            style: MyStyle.tx18BWhite.copyWith(
                color:  MyColor.mainWhiteColor,
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
        title: Text(
          "Exchange",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExchangeHistory(),
                  )
                );
              },
              icon: const Icon(
                Icons.history,
                color: MyColor.mainWhiteColor,
              )
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // send coin details
            Container(
              height: 80,
              width: width,
              decoration: BoxDecoration(
                color:MyColor.blackColor,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [

                  // text filed and title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Text(
                            "You send Bitcoin",
                            style:MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: MyColor.grey01Color
                            ),
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: sendCoinController,
                          cursorColor: MyColor.greenColor,
                          style: MyStyle.tx18RWhite,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                            ],
                          decoration: InputDecoration(
                              hintText: "0.0",
                              border: InputBorder.none,
                              hintStyle:MyStyle.tx22RWhite.copyWith(
                                  fontSize: 18,
                                  color: MyColor.whiteColor.withOpacity(0.7)
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                          )
                        )
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  const VerticalDivider(
                    thickness: 1.5,
                    color: MyColor.backgroundColor,
                  ),
                  const SizedBox(width: 8),

                  // coin images and name
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/bitcoin.png",
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Bitcoin",
                          style: MyStyle.tx18RWhite,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),

            // middle send coin value and price
            Row(
              children: [
                Text(
                  "1BTC ~ ",
                  style: MyStyle.tx18RWhite.copyWith(
                    color: MyColor.textGreyColor,
                    fontSize: 14
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:MyColor.darkGreenColor
                  ),
                  child: Text(
                    "18.5266582 ETH",
                    style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 14,
                        color: MyColor.greenColor
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                  color:MyColor.blackColor,
                  child: Image.asset(
                    "assets/images/dashboard/up_down_arrow.png",
                    height: 20,
                    width: 20,
                    color: MyColor.mainWhiteColor,
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),


            // get coin details
            Container(
              height: 80,
              width: width,
              decoration: BoxDecoration(
                  color:MyColor.blackColor,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [

                  // text filed and title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Text(
                            "You get Bitcoin",
                            style:MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: MyColor.grey01Color
                            ),
                          ),
                        ),
                        TextFormField(
                            keyboardType: TextInputType.number,
                            controller: getCoinController,
                            readOnly: true,
                            cursorColor: MyColor.greenColor,
                            style: MyStyle.tx18RWhite,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: "0.0",
                              border: InputBorder.none,
                              hintStyle:MyStyle.tx22RWhite.copyWith(
                                  fontSize: 18,
                                  color: MyColor.whiteColor.withOpacity(0.7)
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                            )
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  const VerticalDivider(
                    thickness: 1.5,
                    color: MyColor.backgroundColor,
                  ),
                  const SizedBox(width: 8),

                  // coin images and name
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/bitcoin.png",
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Bitcoin",
                          style: MyStyle.tx18RWhite,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
