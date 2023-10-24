import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

import 'QrScannerPage.dart';

class SendCoinScreen extends StatefulWidget {
  const SendCoinScreen({super.key});

  @override
  State<SendCoinScreen> createState() => _SendCoinScreenState();
}

class _SendCoinScreenState extends State<SendCoinScreen> {

  TextEditingController toController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:  InkWell(
        onTap: () {},
        child: Container(
          alignment: Alignment.center,
          height: 45,
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: MyStyle.buttonDecoration.copyWith(
              color: toController.text.isNotEmpty ? MyColor.greenColor : MyColor.greenColor.withOpacity(0.6)
          ),
          child:  Text(
            "Next",
            style: MyStyle.tx18BWhite.copyWith(
                color: toController.text.isNotEmpty ? MyColor.mainWhiteColor : MyColor.mainWhiteColor.withOpacity(0.6)
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
          "Sent BTC",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
        child: Column(
          children: [

            // Account Name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: MyColor.darkGreyColor
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "To",
                      style: MyStyle.tx18BWhite,
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: toController,
                    cursorColor: MyColor.greenColor,
                    style: MyStyle.tx18RWhite,
                    decoration: MyStyle.textInputDecoration.copyWith(
                      hintText: "Recipient Address",
                      isDense: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                      suffixIcon: SizedBox(
                        width: 90,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.copy,
                                  color: MyColor.greenColor,
                                )
                            ),
                            InkWell(
                              onTap: () async {
                                final value = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const QrScannerPage()
                                    )
                                );
                              },
                              child: Image.asset(
                                "assets/images/dashboard/scan.png",
                                height: 25,
                                width: 25,
                                color: MyColor.greenColor,
                              ),
                            ),
                          ],
                        ),
                      )
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
