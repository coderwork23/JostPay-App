import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {

  bool fingerPrint = false;

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController reNewPassController = TextEditingController();


  getData()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      fingerPrint = sharedPreferences.getBool('fingerOn') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
          "Security",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15,20,15,10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // touchId and FaceId toggle button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color:MyColor.darkGrey01Color
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Use Enhanced Security",
                            style: MyStyle.tx18RWhite,
                          ),
                        ),

                        FlutterSwitch(
                          width: 50.0,
                          height: 24.0,
                          toggleSize: 15.0,
                          valueFontSize: 0.0,
                          borderRadius: 30.0,
                          inactiveColor: MyColor.boarderColor,
                          activeColor: MyColor.greenColor,
                          value: fingerPrint,
                          showOnOff: false,
                          onToggle: (val) async {
                            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                            setState(() {
                              fingerPrint = val;
                              sharedPreferences.setBool('fingerOn',fingerPrint);
                            });

                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Use PassCode, TouchID or FaceID of your device to secure "
                          "the application at different key areas like launching"
                          " the app, sending tokens or changing wallets!",
                      style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 16,
                          color: MyColor.grey01Color
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // password container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color:MyColor.darkGrey01Color
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Use App PassCode",
                      style: MyStyle.tx18RWhite,
                    ),
                    const SizedBox(height: 15),

                    Text(
                      "The App PassCode helps you keep your wallet secured and safe.",
                      style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 16,
                          color: MyColor.grey01Color
                      ),
                    ),
                    const SizedBox(height: 15),

                    //old passcode
                    TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6)
                        ],
                        keyboardType: TextInputType.number,
                        controller: oldPassController,
                        cursorColor: MyColor.greenColor,
                        style: MyStyle.tx18RWhite,
                        decoration: MyStyle.textInputDecoration.copyWith(
                          hintText: "Enter old passcode"
                        )
                    ),
                    const SizedBox(height: 15),

                    // new passcode
                    TextFormField(
                        keyboardType: TextInputType.number,
                        controller: newPassController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6)
                        ],
                        cursorColor: MyColor.greenColor,
                        style: MyStyle.tx18RWhite,
                        decoration: MyStyle.textInputDecoration.copyWith(
                            hintText: "Enter new passcode"
                        )
                    ),
                    const SizedBox(height: 15),

                    //Confirm new passcode
                    TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6)
                        ],
                        controller: reNewPassController,
                        cursorColor: MyColor.greenColor,
                        style: MyStyle.tx18RWhite,
                        decoration: MyStyle.textInputDecoration.copyWith(
                            hintText: "Confirm new passcode"
                        )
                    ),
                    const SizedBox(height: 25),

                    Center(
                      child: Container(
                        height: 45,
                        width: 100,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: MyColor.greenColor
                          )
                        ),
                        child: Text(
                          "Reset",
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

            ],
          ),
        ),
      ),
    );
  }
}
