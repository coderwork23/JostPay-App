import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Buy/BuyScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/SettingScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Support/SupportScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WalletScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  List body = [
    const WalletScreen(),
    const BuyScreen(),
    const SellScreen(),
    const SupportScreen(),
    const SettingScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final dashProvider = Provider.of<DashboardProvider>(context,listen: true);
    return  Scaffold(
      extendBody: true,
      bottomNavigationBar: Container(
        height: 60,
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color:  MyColor.backgroundColor,
          border: Border.all(
            color: MyColor.boarderColor
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
        ),
        child: Row(
          children: [

            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(0);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/wallet.png",
                      height: 20,
                      width: 20,
                      fit: BoxFit.contain,
                      color: dashProvider.currentIndex == 0 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Wallet",
                      style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 13,
                        color: dashProvider.currentIndex == 0 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(1);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/card.png",
                      height: 26,
                      width: 26,
                      fit: BoxFit.contain,
                      color: dashProvider.currentIndex == 1 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Buy",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 13,
                        color: dashProvider.currentIndex == 1 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(2);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/card.png",
                      height: 26,
                      width: 26,
                      fit: BoxFit.contain,
                          color: dashProvider.currentIndex == 2 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Sell",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 13,
                          color: dashProvider.currentIndex == 2 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(3);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/support.png",
                      height: 22,
                      width: 22 ,
                      fit: BoxFit.contain,
                          color: dashProvider.currentIndex == 3 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Support",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 13,
                          color: dashProvider.currentIndex == 3 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(4);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/setting.png",
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                          color: dashProvider.currentIndex == 4 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Setting",
                      style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 13,
                          color: dashProvider.currentIndex == 4 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: body[dashProvider.currentIndex],
    );
  }
}


