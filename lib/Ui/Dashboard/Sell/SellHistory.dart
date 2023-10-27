import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class SellHistory extends StatefulWidget {
  const SellHistory({super.key});

  @override
  State<SellHistory> createState() => _SellHistoryState();
}

class _SellHistoryState extends State<SellHistory> {
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
            "History",
          ),
        ),
        body: Center(
          child: Text(
            "No Transaction Yet.",
            style: MyStyle.tx18RWhite.copyWith(
                color: MyColor.grey01Color
            ),
          ),
        )
    );
  }
}
