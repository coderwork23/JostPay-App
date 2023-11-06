import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Security/SecurityScreen.dart';
import 'WalletConnect/WalletConnectScreen.dart';
import 'WalletsPages/WalletsListingScreen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  String selectedAccountName = "";

  getWalletName()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });
  }


  @override
  void initState() {
    super.initState();
    getWalletName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Text(
            "Settings",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //Wallets
            InkWell(
              onTap: () async{
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletsListingScreen(),
                  )
                );
               getWalletName();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
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
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                        color: MyColor.mainWhiteColor,
                      ),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        "Wallets",
                        style:MyStyle.tx18RWhite.copyWith(
                            fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Text(
                      selectedAccountName,
                      style:MyStyle.tx18RWhite.copyWith(
                        fontSize: 18,
                        color: MyColor.grey01Color
                      ),
                    ),
                    const SizedBox(width: 10),

                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: MyColor.mainWhiteColor,
                      size: 18,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            //Security
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityScreen(),
                  )
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
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
                        "assets/images/dashboard/lock.png",
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                        color: MyColor.mainWhiteColor,
                      ),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        "Security",
                        style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: MyColor.mainWhiteColor,
                      size: 18,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            //Wallet connect
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WalletConnectScreen(),
                    )
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: MyColor.darkGreyColor
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/wallet_connect.png",
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        "Wallet connect",
                        style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),



                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: MyColor.mainWhiteColor,
                      size: 18,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            //About
            Text(
              "About",
              style:MyStyle.tx18RWhite.copyWith(
                  fontSize: 18,
                  color: MyColor.grey01Color
              ),
            ),
            const SizedBox(height: 10),

            //Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
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
                      "assets/images/dashboard/version.png",
                      height: 30,
                      width: 30,
                      fit: BoxFit.contain,
                      color: MyColor.mainWhiteColor,
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Text(
                      "Version",
                      style:MyStyle.tx18RWhite.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Text(
                    "0.0.2",
                    style:MyStyle.tx18RWhite.copyWith(
                        fontSize: 18,
                        color: MyColor.grey01Color
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
