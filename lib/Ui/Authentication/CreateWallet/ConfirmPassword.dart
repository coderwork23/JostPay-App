import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pin;

import 'SecureScreen.dart';

class ConfirmPassword extends StatefulWidget {
  const ConfirmPassword({super.key});

  @override
  State<ConfirmPassword> createState() => _ConfirmPasswordState();
}

class _ConfirmPasswordState extends State<ConfirmPassword> {

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                "Re-enter your password",
                style:MyStyle.tx22RWhite,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              Text(
                "Lock your wallet on this device",
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
                      Future.delayed(const Duration(milliseconds: 500),(){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecureScreen(),
                            )
                        );
                      });
                    },
                    onChanged: (value) {
                      debugPrint(value);

                    },

                  ),
                ),
              ),

              const Spacer(),
              CustomKeyBoard(
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


              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}
