import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/AddAssetsScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/ReceiveToken/ReceiveToken.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenList.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';

import 'CoinDetailScreen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  showAddAsserts(BuildContext context){
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height/2,
            maxHeight: MediaQuery.of(context).size.height*0.8
          ),
            child: const AddAssetsScreen()
        );
      },
    );
  }

  showSendTokenList(BuildContext context){
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20,22,20,10),
            constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height/2,
            maxHeight: MediaQuery.of(context).size.height*0.8
          ),
            child: const SendTokenList()
        );
      },
    );
  }

  showReceiveTokenList(BuildContext context){
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20,22,20,10),
            constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height/2,
            maxHeight: MediaQuery.of(context).size.height*0.8
          ),
            child: const ReceiveToken()
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashProvider = Provider.of<DashboardProvider>(context);
    return Scaffold(
      backgroundColor: MyColor.darkGreyColor,
      appBar: AppBar(
        backgroundColor: MyColor.darkGreyColor,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: RichText(
              text: const TextSpan(
                  children: [
                    TextSpan(
                        text: "Jost",
                        style:MyStyle.tx28BYellow
                    ),
                    TextSpan(
                        text: "Pay",
                        style:MyStyle.tx28RGreen
                    ),
                  ]
              )
          ),
        ),
        actions:  [
          IconButton(
            onPressed: () {
              showAddAsserts(context);
            },
            icon: const Icon(
              Icons.add,
              color: MyColor.mainWhiteColor,

            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),

          Text(
            "Current Balance - Main Wallet",
            style: MyStyle.tx18RWhite.copyWith(
              fontSize: 14,
              color: MyColor.grey01Color
            ),
          ),
          const SizedBox(height: 15),

          Text(
            "0.0 USD",
            style: MyStyle.tx22RWhite.copyWith(
              fontSize: 35,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // send
              InkWell(
                onTap: () {
                  showSendTokenList(context);
                },
                child: Column(
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
              ),
              const SizedBox(width: 16),

              // receive
              InkWell(
                onTap: () {
                  showReceiveTokenList(context);
                },
                child: Column(
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
              ),
              const SizedBox(width: 16),

              // withdraw
              InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(2);
                },
                child: Column(
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
              ),
              const SizedBox(width: 16),

              // Exchange
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

          Expanded(
             child: Container(
               padding: const EdgeInsets.only(top:12),
               decoration: const BoxDecoration(
                 color: MyColor.backgroundColor,
                 borderRadius: BorderRadius.only(
                   topLeft: Radius.circular(25),
                   topRight: Radius.circular(25),
                 ),
               ),
               child: ClipRRect(
                 borderRadius: const BorderRadius.only(
                   topLeft: Radius.circular(40),
                   topRight: Radius.circular(40),
                 ),
                 child : ListView.builder(
                   itemCount: 10,
                   padding: const EdgeInsets.fromLTRB(12,10,12,70),
                   itemBuilder: (context, index) {
                     return InkWell(
                       onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => const CoinDetailScreen(),
                           )
                         );
                       },
                       child: Container(
                         margin: const EdgeInsets.only(bottom: 10),
                         padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(15),
                           color: MyColor.darkGreyColor
                         ),
                         child: Row(
                           children: [
                             Image.asset(
                               "assets/images/bitcoin.png",
                               height: 50,
                               width: 50,
                               fit: BoxFit.contain,
                             ),
                             const SizedBox(width: 12),

                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const Text(
                                     "Bitcoin",
                                     style: MyStyle.tx18RWhite,
                                   ),
                                   const SizedBox(height: 5),
                                   RichText(
                                       text: TextSpan(
                                           children: [
                                             TextSpan(
                                               text: "\$2345432 ",
                                               style: MyStyle.tx18RWhite.copyWith(
                                                   fontSize: 14,
                                                   color: MyColor.grey01Color
                                               ),
                                             ),
                                             TextSpan(
                                                 text: "(-2.2%)",
                                                 style:MyStyle.tx28RGreen.copyWith(
                                                   fontSize: 12
                                                 )
                                             ),
                                           ]
                                       )
                                   ),
                                 ],
                               )
                             ),
                             const SizedBox(width: 10),

                             Column(
                               crossAxisAlignment: CrossAxisAlignment.end,
                               children: [
                                 Text(
                                   "0.0 BTC",
                                   style: MyStyle.tx22RWhite.copyWith(
                                     fontSize: 20,
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
                       ),
                     );
                   },
                 ),
               ),
             )
          )
        ],
      ),
    );
  }
}
