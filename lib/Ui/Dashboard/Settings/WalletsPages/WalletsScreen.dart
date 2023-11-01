import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

import 'WalletInfoPage.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {

  getAllAccount()async{
    await DBAccountProvider.dbAccountProvider.getAllAccount();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAllAccount();
  }

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
        title: const Text(
          "Wallets",
          // style:MyStyle.tx22RWhite.copyWith(fontSize: 22),
          // textAlign: TextAlign.center,
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeScreen(
                      isNew: true,
                    ),
                  )
              );
            },
            child: Image.asset(
              "assets/images/dashboard/add.png",
              height: 25,
              width: 25,
              fit: BoxFit.contain,
              color: MyColor.mainWhiteColor,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: ListView.builder(
        itemCount: DBAccountProvider.dbAccountProvider.newAccountList.length,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15,20,15,10),
        itemBuilder: (context, index) {

          var list = DBAccountProvider.dbAccountProvider.newAccountList[index];

          return InkWell(
            onTap: () {

              var seedPhase = DBAccountProvider.dbAccountProvider.newAccountList[index].mnemonic;
              List seedPhaseList = [];
              if(seedPhase != ""){
                seedPhaseList = seedPhase.trim().split(" ");
              }

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletInfoScreen(
                      accountId: DBAccountProvider.dbAccountProvider.newAccountList[index].id,
                      seedPhare: seedPhaseList,
                      name: DBAccountProvider.dbAccountProvider.newAccountList[index].name,
                    ),
                  )
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                          list.name,
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
