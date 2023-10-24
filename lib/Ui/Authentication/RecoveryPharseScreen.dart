import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pin;
import '../Dashboard/DashboardScreen.dart';

class RecoveryPharseScreen extends StatefulWidget {
  const RecoveryPharseScreen({super.key});

  @override
  State<RecoveryPharseScreen> createState() => _RecoveryPharseScreenState();
}

class _RecoveryPharseScreenState extends State<RecoveryPharseScreen> {

  TextEditingController phraseController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

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
          "Import Wallet",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SizedBox(
            height: height,
            width: width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  Text(
                    "Enter the 12 recovery phrase your wew given when you created your account",
                    style:MyStyle.tx22RWhite.copyWith(
                        fontSize: 18,
                        color: MyColor.grey01Color
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 25, 18, 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: MyColor.darkGrey01Color,
                        border: Border.all(
                            color: MyColor.boarderColor,
                            width: 0.8
                        )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 15),
                        TextFormField(
                          textAlign: TextAlign.center,
                          controller: phraseController,
                          cursorColor: MyColor.greenColor,
                          style: MyStyle.tx18RWhite,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Recovery Phrase",
                            hintStyle:MyStyle.tx22RWhite.copyWith(
                                fontSize: 18,
                                color: MyColor.whiteColor.withOpacity(0.7)
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                        InkWell(
                          onTap: () async {
                            ClipboardData? data = await Clipboard.getData('text/plain');
                            String? value = data?.text.toString();

                            List list = value!.trim().split(" ");
                            if(list.length == 12 || list.length == 24){

                              setState(() {
                                phraseController.text = value;
                                //seedList = value.split(" ");
                              });

                            }
                            else{

                              Fluttertoast.showToast(
                                  msg: "Invalid_Seed_Phrase !!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );

                            }
                          },
                          child:  Text(
                            "Paste",
                            style:MyStyle.tx22RWhite.copyWith(
                                fontSize: 18
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  Text(
                    "Enter App PassCode",
                    style:MyStyle.tx22RWhite.copyWith(
                        fontSize: 18,
                        color: MyColor.grey01Color
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: pin.PinCodeTextField(
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 6,
                        obscureText: true,

                        obscuringWidget:  Container(
                          decoration: const BoxDecoration(
                              color: MyColor.greenColor,
                              shape: BoxShape.circle
                          ),
                        ),
                        pinTheme:pin.PinTheme(
                            shape: pin.PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(100),
                            fieldHeight: 20,
                            fieldWidth: 20,
                            inactiveColor: MyColor.boarderColor,
                            inactiveBorderWidth: 2,
                            inactiveFillColor: MyColor.transparentColor
                        ),
                        cursorColor: MyColor.greenColor,
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        controller: pinCodeController,
                        keyboardType: TextInputType.number,

                        onCompleted: (v) {
                          debugPrint("Completed");
                        },
                        onChanged: (value) {
                          debugPrint(value);

                        },

                      ),
                    ),
                  ),

                  SizedBox(
                    height: 230,
                    child: CustomKeyBoard(
                      maxLength: 6,
                      pinTheme: PinTheme(
                          keysColor: MyColor.mainWhiteColor
                      ),
                      onChanged: (p0) {
                        setState(() {
                          pinCodeController.text = p0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ), (route) => false
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 45,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: MyStyle.buttonDecoration,
                      child: const Text(
                        "Import wallet",
                        style: MyStyle.tx18BWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30)
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}
