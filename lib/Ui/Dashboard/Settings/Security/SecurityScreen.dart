import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
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
  bool passwordType = false;

  String savePassword = "",savePasscode = "";
  bool pinNotSave = false;

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController reNewPassController = TextEditingController();

  TextEditingController setPassCodeController = TextEditingController();
  TextEditingController setRePassCodeController = TextEditingController();

  TextEditingController oldPassCodeController = TextEditingController();
  TextEditingController newPassCodeController = TextEditingController();
  TextEditingController reNewPassCodeController = TextEditingController();

  getData()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      fingerPrint = sharedPreferences.getBool('fingerOn') ?? false;
      passwordType = sharedPreferences.getBool('passwordType') ?? false;
      savePassword = sharedPreferences.getString('password') ?? "";
      savePasscode = sharedPreferences.getString('passcode') ?? "";
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
                          fontSize: 14,
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
                    Text(
                      "Use App PassCode",
                      style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            !passwordType ? "Password is Enable" : "Passcode is Enable",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 14
                            ),
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
                          value: passwordType,
                          showOnOff: false,
                          onToggle: (val) async {
                            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();


                            var savePince2 = sharedPreferences.getString("passcode")??"";
                            if(savePince2 == ""){
                              setState(() {
                                pinNotSave = true;
                              });
                              // ignore: use_build_context_synchronously
                              Helper.dialogCall.showToast(context, "Please set your passcode.");
                            }else{
                              setState(() {
                                passwordType = val;
                                sharedPreferences.setBool('passwordType',passwordType);
                              });
                            }

                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "The App PassCode helps you keep your wallet secured and safe.",
                      style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 13,
                          color: MyColor.grey01Color
                      ),
                    ),
                    const SizedBox(height: 15),

                    pinNotSave
                        ?
                    Column(
                        children: [
                          // new passcode
                          TextFormField(
                              controller: setPassCodeController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6)
                              ],
                              keyboardType: TextInputType.number,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 16
                              ),
                              decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText:"Enter new passcode",
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
                              controller: setRePassCodeController,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                              decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText: "Confirm new passcode"
                              )
                          ),
                        ]
                    )
                        :
                    Column(
                      children: [
                        //old passcode
                        Visibility(
                          visible: savePasscode.isNotEmpty || savePassword.isNotEmpty,
                          child: TextFormField(
                              inputFormatters: passwordType ?  [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6)
                              ] : [],
                              keyboardType:passwordType ? TextInputType.number : TextInputType.text,
                              controller: passwordType ? oldPassCodeController : oldPassController,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite,
                              decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText: !passwordType ? "Enter old password" : "Enter old passcode"
                              )
                           ),
                         ),
                        const SizedBox(height: 15),

                        // new passcode
                        TextFormField(
                            inputFormatters: passwordType ?  [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6)
                            ] : [],
                            keyboardType:passwordType ? TextInputType.number : TextInputType.text,
                            cursorColor: MyColor.greenColor,
                            style: MyStyle.tx18RWhite,
                            decoration: MyStyle.textInputDecoration.copyWith(
                                hintText: !passwordType ? "Enter new password"  : "Enter new passcode"
                            )
                         ),
                        const SizedBox(height: 15),

                        //Confirm new passcode
                        TextFormField(
                            keyboardType:passwordType ? TextInputType.number : TextInputType.text,
                            inputFormatters: passwordType ?  [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6)
                            ] : [],
                            controller: passwordType ? reNewPassCodeController : reNewPassController,
                            cursorColor: MyColor.greenColor,
                            style: MyStyle.tx18RWhite,
                            decoration: MyStyle.textInputDecoration.copyWith(
                                hintText: !passwordType ? "Confirm new password" :  "Confirm new passcode"
                            )
                         ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Center(
                      child: InkWell(
                        onTap: () {
                          if(pinNotSave){

                          }else{

                          }
                        },
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
                            pinNotSave ? "Set ": "Reset",
                            textAlign: TextAlign.center,
                            style: MyStyle.tx28RGreen.copyWith(
                              fontSize: 18
                            ),
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
