import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // dos icon
        Container(
          width: 45,
          height: 5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyColor.lightGreyColor
          ),
        ),
        const SizedBox(height: 25),

        // Select assets text
        Text(
          "Receive ETH",
          style: MyStyle.tx28RGreen.copyWith(
              color: MyColor.mainWhiteColor,
              fontFamily: "NimbusSanLBol",
              fontSize: 22
          ),
        ),
        const SizedBox(height: 25),

        // warning message
        Text(
          "Send only Ethereum (ETH) to this address. "
              "Sending any other coins may result in permanent loss.",
          textAlign: TextAlign.center,
          style:MyStyle.tx18RWhite.copyWith(
              fontSize: 18,
              color: MyColor.grey01Color
          ),
        ),

        const SizedBox(height: 25),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                decoration: BoxDecoration(
                  color: MyColor.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  Row(
                  children: [
                    Expanded(
                      child: Text(
                        "0x1BOBE8653CA24c8Cf54D056f116f696249a640",
                        textAlign: TextAlign.center,
                        style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.copy,
                      color: MyColor.greenColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              decoration: const BoxDecoration(
                color: MyColor.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.share_outlined,
                color: MyColor.greenColor,
              ),
            ),
          ],
        )

      ],
    );
  }
}
