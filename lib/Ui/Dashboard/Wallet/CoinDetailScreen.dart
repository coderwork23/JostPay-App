import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';


class CoinDetailScreen extends StatefulWidget {
  const CoinDetailScreen({super.key});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.darkGreyColor,
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // coin details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: MyColor.darkGreyColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 5),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Tron",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 18,
                            color: MyColor.grey01Color
                        ),
                      ),
                    ),
                    Text(
                      "\$0.0906",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 14,
                      ),
                    ),
                    Text(
                      "(-2.23)",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 14,
                          color: MyColor.redColor
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: MyColor.darkGrey01Color,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    "assets/images/bnb.png",
                    height: 50,
                    width: 50,
                    color: MyColor.yellowColor,
                    fit: BoxFit.contain,
                  ),
                ),

                Text(
                  "0.0 USD",
                  style: MyStyle.tx22RWhite.copyWith(
                    fontSize: 28,
                  ),
                ),

                Text(
                  "\$ 21.2",
                  style: MyStyle.tx22RWhite.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(13),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: MyColor.backgroundColor,
                              shape: BoxShape.circle
                          ),
                          child: Image.asset(
                            "assets/images/dashboard/send.png",
                            height: 18,
                            width: 18,
                            color: MyColor.greenColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Send",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14,
                              color: MyColor.whiteColor
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(13),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: MyColor.backgroundColor,
                              shape: BoxShape.circle
                          ),
                          child: Image.asset(
                            "assets/images/dashboard/receive.png",
                            height: 18,
                            width: 18,
                            color: MyColor.greenColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Receive",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14,
                              color: MyColor.whiteColor
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(13),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: MyColor.backgroundColor,
                              shape: BoxShape.circle
                          ),
                          child: Image.asset(
                            "assets/images/dashboard/card.png",
                            height: 18,
                            width: 18,
                            color: MyColor.greenColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Withdraw",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14,
                              color: MyColor.whiteColor
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(13),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: MyColor.backgroundColor,
                              shape: BoxShape.circle
                          ),
                          child: Image.asset(
                            "assets/images/dashboard/exchange.png",
                            height: 18,
                            width: 18,
                            color: MyColor.greenColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Exchange",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14,
                              color: MyColor.whiteColor
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          const SizedBox(height: 30),

          //Activity
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Activity",
                style: MyStyle.tx28BYellow.copyWith(
                  color: MyColor.whiteColor,
                  fontSize: 18
                ),
              ),
            ),
          ),

          // Transactions list
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top:12),
                child: ListView.builder(
                  itemCount: 10,
                  padding: const EdgeInsets.fromLTRB(12,10,12,10),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: MyColor.darkGreyColor
                      ),
                      child: Row(
                        children: [
                          // Transactions type icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: MyColor.darkGrey01Color,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              "assets/images/dashboard/send.png",
                              height: 20,
                              width: 20,
                              fit: BoxFit.contain,
                              color: MyColor.greenColor,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // coin name text
                          const Expanded(
                            child: Text(
                              "Binance",
                              style: MyStyle.tx18RWhite,
                            )
                          ),
                          const SizedBox(width: 10),

                          // receive text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "0.0 BNB",
                                style: MyStyle.tx22RWhite.copyWith(
                                    fontSize: 18,
                                    color: MyColor.mainWhiteColor
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "\$ 12",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 15,
                                    color: MyColor.grey01Color
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
          )
        ],
      ),
    );
  }
}
