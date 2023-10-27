import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
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
          "WalletConnect",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15,20,15,10),
        child: Column(
          children: [
            Text(
              "Connect your wallet with WalletConnect to make transactions",
              style:MyStyle.tx18RWhite.copyWith(
                  fontSize: 18,
                  color: MyColor.grey01Color
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: MyColor.greenColor
                    )
                ),
                child: Text(
                  "NEW CONNECTION",
                  textAlign: TextAlign.center,
                  style: MyStyle.tx28RGreen.copyWith(
                      fontSize: 18
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
