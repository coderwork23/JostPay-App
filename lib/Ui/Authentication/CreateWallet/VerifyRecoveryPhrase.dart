import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class VerifyRecoveryPhrase extends StatefulWidget {
  const VerifyRecoveryPhrase({super.key});

  @override
  State<VerifyRecoveryPhrase> createState() => _VerifyRecoveryPhraseState();
}

class _VerifyRecoveryPhraseState extends State<VerifyRecoveryPhrase> {

  confirmBottomSheet(BuildContext context){
    showModalBottomSheet(
      isScrollControlled: false,
      backgroundColor: MyColor.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal:20,vertical:22),
          child: Column(
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
              // check icon
              Image.asset(
                "assets/images/check.png",
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 25),

              //title congratulations text
              Text(
                "Congratulations",
                style:MyStyle.tx22RWhite.copyWith(
                  color: MyColor.mainWhiteColor,
                  fontSize: 25
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              //subtitle text
              Text(
                "You've successfully protected your wallet. Remember to "
                    "keep your recovery phrase safe, its your responsibility!",
                textAlign: TextAlign.center,
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 17,
                    color: MyColor.grey01Color
                ),
              ),
              const SizedBox(height: 28),

              //setting recovery text
              Text(
                "You can find your recovery phrase in",
                textAlign: TextAlign.center,
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 17,
                    color: MyColor.whiteColor
                ),
              ),
              const SizedBox(height: 4),

              // setting info
              Text(
                "Settings > Wallets",
                textAlign: TextAlign.center,
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 17,
                    color: MyColor.greenColor
                ),
              ),
              const SizedBox(height: 30),

              // done button
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ), (route) => false
                  );
                },
                child : Container(
                  alignment: Alignment.center,
                  height: 45,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: MyStyle.buttonDecoration,
                  child:  const Text(
                      "Done",
                      style: MyStyle.tx18BWhite
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return  Scaffold(
      // continue button
      bottomNavigationBar: InkWell(
        onTap: () {
          confirmBottomSheet(context);
        },
        child: Container(
          alignment: Alignment.center,
          height: 45,
          margin: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: MyStyle.buttonDecoration,
          child:  const Text(
              "Continue",
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
          "Verify Recovery Phrase",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 15),

              // select 3 phrase container
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 20),
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: MyColor.darkGreyColor,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Tap each world in the order it was presented to you.",
                      style: MyStyle.tx18RWhite,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        Expanded(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: DottedDecoration(
                                shape: Shape.box,
                                borderRadius: BorderRadius.circular(10),
                                color: MyColor.dotBoarderColor
                            ),
                            child: Text(
                              "9",
                              textAlign: TextAlign.center,
                              style: MyStyle.tx18RWhite.copyWith(
                                  color: MyColor.dotBoarderColor
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: DottedDecoration(
                                shape: Shape.box,
                                borderRadius: BorderRadius.circular(10),
                                color: MyColor.dotBoarderColor
                            ),
                            child: Text(
                              "1",
                              textAlign: TextAlign.center,
                              style: MyStyle.tx18RWhite.copyWith(
                                  color: MyColor.dotBoarderColor
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: DottedDecoration(
                                shape: Shape.box,
                                borderRadius: BorderRadius.circular(10),
                                color: MyColor.dotBoarderColor
                            ),
                            child: Text(
                              "5",
                              textAlign: TextAlign.center,
                              style: MyStyle.tx18RWhite.copyWith(
                                  color: MyColor.dotBoarderColor
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                      ],
                    )
                  ],
                )
              ),
              const SizedBox(height: 15),

              //  Grid View Phrase
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
                        color: MyColor.darkGrey01Color
                    ),
                    child: Text(
                      "${index+1} Check",
                      textAlign: TextAlign.center,
                      style: MyStyle.tx18RWhite,
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}


// axis acquire beach trip donkey away feel hood differ rug large noble