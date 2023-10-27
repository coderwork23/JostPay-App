import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

import 'WalletInfoPage.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  @override
  Widget build(BuildContext context) {
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
        title: Text(
          "Wallets",
          // style:MyStyle.tx22RWhite.copyWith(fontSize: 22),
          // textAlign: TextAlign.center,
        ),
        actions: [
          Image.asset(
            "assets/images/dashboard/add.png",
            height: 25,
            width: 25,
            fit: BoxFit.contain,
            color: MyColor.mainWhiteColor,
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: ListView.builder(
        itemCount: 1,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15,20,15,10),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletInfoScreen(),
                  )
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: MyColor.darkGreyColor
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding:const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyColor.greenColor,
                    ),
                    child: Image.asset(
                      "assets/images/dashboard/wallet.png",
                      fit: BoxFit.contain,
                      color: MyColor.mainWhiteColor,
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Main Wallet",
                          style:MyStyle.tx18RWhite.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Multi-chain Wallet",
                          style:MyStyle.tx18RWhite.copyWith(
                              fontSize: 12,
                              color: MyColor.grey01Color
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),


                  const SizedBox(width: 10),

                  const Icon(
                    Icons.info_outline,
                    color: MyColor.mainWhiteColor,
                    size: 22,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
