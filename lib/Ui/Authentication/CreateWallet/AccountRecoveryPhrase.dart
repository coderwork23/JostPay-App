import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

import 'VerifyRecoveryPhrase.dart';


class AccountRecoveryPhrase extends StatefulWidget {
  const AccountRecoveryPhrase({super.key});

  @override
  State<AccountRecoveryPhrase> createState() => _AccountRecoveryPhraseState();
}

class _AccountRecoveryPhraseState extends State<AccountRecoveryPhrase> {


  bool showPhrase = false;
  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VerifyRecoveryPhrase(),
              )
          );
        },
        child: Container(
          alignment: Alignment.center,
          height: 45,
          margin: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: MyStyle.buttonDecoration,
          child:  const Text(
            "Get Started",
            style: MyStyle.tx18BWhite
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
          "Account Recovery Phrase",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 15),

                // subTitle
                Text(
                  "Select each word in the order it was presented to you",
                  textAlign: TextAlign.center,
                  style:MyStyle.tx22RWhite.copyWith(
                      fontSize: 18,
                      color: MyColor.grey01Color
                  ),
                ),
                const SizedBox(height: 22),

                //  Grid View Phrase
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: MyColor.darkGreyColor,
                  ),
                  child: Stack(
                    children: [
                      AlignedGridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColor.backgroundColor
                            ),
                            child: Text(
                              "${index+1} Check",
                              textAlign: TextAlign.center,
                              style: MyStyle.tx18RWhite,
                            ),
                          );
                        },
                      ),
                      Visibility(
                        visible: !showPhrase,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              showPhrase = !showPhrase;
                            });
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                child: Container(
                                  width: width,
                                  height: 260,
                                  padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: MyColor.mainWhiteColor.withOpacity(0.001)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.visibility_off,
                                        color: MyColor.mainWhiteColor,
                                        size: 35,
                                      ),
                                      const SizedBox(height: 20),

                                      Text(
                                        'Tap to reveal you seed \nphrase',
                                        textAlign: TextAlign.center,
                                        style: MyStyle.tx28BYellow.copyWith(
                                            color: MyColor.mainWhiteColor,
                                            fontSize: 21
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Text(
                                        'Make sure no one is watching your screen',
                                        textAlign: TextAlign.center,
                                        style: MyStyle.tx22RWhite.copyWith(
                                            fontSize: 15
                                        ),
                                      ),

                                      const SizedBox(height: 25),

                                    ],
                                  ),
                                ),
                              )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // copy button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: MyColor.darkGreyColor,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.copy,
                        color: MyColor.mainWhiteColor,
                      ),
                      SizedBox(width: 15),
                      Text(
                        "Copy",
                        style: MyStyle.tx18RWhite,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // do not shared
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                  decoration: BoxDecoration(
                    color: MyColor.orange01Color,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "DO NOT ",
                                    style:MyStyle.tx28BYellow.copyWith(
                                      fontSize: 18,
                                      color: MyColor.whiteColor
                                    )
                                ),
                                const TextSpan(
                                    text: "share your recovery.",
                                    style:MyStyle.tx18RWhite
                                ),
                              ]
                          )
                      ),
                      const SizedBox(height: 6),

                      Text(
                        "If someone has your recovery phrase,"
                            "they will have full control of  your wallet.",
                        style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 17.5
                        ),
                      )
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
