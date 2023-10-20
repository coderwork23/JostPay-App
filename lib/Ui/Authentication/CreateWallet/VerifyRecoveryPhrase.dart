import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class VerifyRecoveryPhrase extends StatefulWidget {
  const VerifyRecoveryPhrase({super.key});

  @override
  State<VerifyRecoveryPhrase> createState() => _VerifyRecoveryPhraseState();
}

class _VerifyRecoveryPhraseState extends State<VerifyRecoveryPhrase> {
  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return  Scaffold(
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