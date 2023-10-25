import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:local_auth_ios/types/auth_messages_ios.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../LocalDb/Local_Account_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController passwordController = TextEditingController();

  bool showPassword = true;

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;



  final LocalAuthentication auth = LocalAuthentication();
  late String deviceId;
  bool fingerOn = false;
  String isLogin = "";

  var errorText = "";
  bool isLoading = false;

  getDeviceId() async {

    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      deviceId = sharedPreferences.getString('deviceId')!;
      isLogin = sharedPreferences.getString('isLogin') ?? "";
      fingerOn = sharedPreferences.getBool('fingerOn') ?? false;
    });
    //_authenticate();

    if(isLogin == "true"){

      if(fingerOn == true){
        _authenticate();
      }
      else{
        setState(() {
          isLoading = false;
        });
      }
    }
    else{

      setState(() {
        isLoading = false;
      });

    }

  }

  bool _authorizedAvailable = false;
  Future<void> _authenticate() async {
    bool authenticated = false;

    List<BiometricType> availableBiometrics =
    await auth.getAvailableBiometrics();

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face) ||  availableBiometrics.contains( BiometricType.strong) ) {

        _authorizedAvailable = true;
        // Face ID.
      } else if (availableBiometrics.contains(BiometricType.fingerprint) ||  availableBiometrics.contains( BiometricType.strong)) {
        // Touch ID.
        _authorizedAvailable = true;
      }
    }
    else if(Platform.isAndroid){
      if(availableBiometrics.contains(BiometricType.fingerprint) ||  availableBiometrics.contains( BiometricType.strong) ||  availableBiometrics.contains( BiometricType.weak)){
        _authorizedAvailable = true;
      }
    }

    if(_authorizedAvailable == true){

      try {
        IOSAuthMessages iosStrings = const IOSAuthMessages(
            cancelButton: "cancel",
            goToSettingsButton:"settings",
            goToSettingsDescription:  "Please_set_up_your_Touch_ID",
            lockOut: "Please_Re_enable_your_Touch_ID"
        );


        authenticated = await auth.authenticate(
          localizedReason: "Please_authenticate_to_Login_your_Account",
          authMessages: [iosStrings],
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
            useErrorDialogs: true,

          ),
        );
      } on PlatformException catch (_) {
        setState(() {
          isLoading = false;
        });
      }

      if(authenticated == true){

        setState(() {
          isLoading = false;
        });

        autologin();
      }
      else{

        setState(() {
          isLoading = false;
        });

      }

    }
    else{

      setState(() {
        isLoading = false;
      });

    }

  }

  autologin() async {

    setState((){
      errorText = "";
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    String? password = sharedPreferences.getString('password');

    var data = {
      "device_id":deviceId,
      "password":"$password",
    };

    await accountProvider.loginAccount(data,'/deviceLogin');
    if(accountProvider.isSuccess == true){

      getAccount();

    }
    else{
      setState((){
        errorText = "Incorrect_Password";
        isLoading = false;
      });

    }
  }

  getAccount() async {

    //print("Account");

    await DBAccountProvider.dbAccountProvider.getAllAccount();

    getToken();

  }

  var currency = "";
  getToken() async {

    // await DBTokenProvider.dbTokenProvider.deleteAllToken();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currency = sharedPreferences.getString("currency") ?? "USD";

    for (int i = 0; i < DBAccountProvider.dbAccountProvider.newAccountList.length; i++) {

      await DbAccountAddress.dbAccountAddress.getAccountAddress(DBAccountProvider.dbAccountProvider.newAccountList[i].id);

      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
      }

      data["convert"] = currency;

      await tokenProvider.getAccountToken(data, '/getAccountTokens', DBAccountProvider.dbAccountProvider.newAccountList[i].id,"");

    }

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen()
      )
    );

    setState((){
      isLoading = false;
    });

  }

  loginAccount() async {

    setState(() {
      errorText = "";
      isLoading = true;
    });

    var data = {
      "device_id": deviceId,
      "password": passwordController.text,
    };

    await accountProvider.loginAccount(data,'/deviceLogin');
    if(accountProvider.isSuccess == true){

      getAccount();

    }
    else{

      setState(() {
        isLoading = false;
      });
      errorText =  "Incorrect Password!!";

    }

  }


  deleteAlert() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:  MyColor.backgroundColor,
        title: Text(
           "Are_you_sure",
          style: MyStyle.tx18RWhite.copyWith(
            fontSize: 16
          )
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber,size: 17,color: MyColor.yellowColor,),
            Flexible(
              child: Text(
                  "Do_you_want_to_Delete_Your_All_Accounts",
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 14
                  )
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "No",
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 14
                )            ),
          ),
          TextButton(
            onPressed: () {

              Navigator.pop(context);
              deleteAllAccountApi();

            },
            /*Navigator.of(context).pop(true)*/
            child: Text(
              "Yes",
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 14
                )            ),
          ),
        ],
      ),
    );
  }

  deleteAllAccountApi() async {

    var data = {
      "device_id":"$deviceId"
    };

    await accountProvider.forgotPassword(data,'/forgotPassword');

    if(accountProvider.isPassword == true){
      DBAccountProvider.dbAccountProvider.deleteAllAccount();
      await DbAccountAddress.dbAccountAddress.deleteAllAccountAddress();
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('isLogin', 'false');
      sharedPreferences.clear();

      createDeviceId();
    }
  }

  createDeviceId() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? deviceId = "";
    sharedPreferences = await SharedPreferences.getInstance();

    final deviceInfoPlugin = DeviceInfoPlugin();


    if(Platform.isAndroid){
      final  deviceInfo = await deviceInfoPlugin.androidInfo;
      deviceId = deviceInfo.id;
    }else{

      final deviceInfo = await deviceInfoPlugin.iosInfo;
      deviceId = deviceInfo.identifierForVendor!;
    }

    setState(() {
      sharedPreferences.setString('deviceId', deviceId!);
    });

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const WelcomeScreen()
    )
    );

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 15
              ),
              child: Column(
                children: [

                  // app image
                  RichText(
                      text: const TextSpan(
                          children: [
                            TextSpan(
                                text: "Jost",
                                style:MyStyle.tx28BYellow
                            ),
                            TextSpan(
                                text: "Pay",
                                style:MyStyle.tx28RGreen
                            ),
                          ]
                      )
                  ),
                  const SizedBox(height: 15),

                  // title
                  Text(
                      "Please Enter your password \nto proceed!",
                    textAlign: TextAlign.center,
                    style:MyStyle.tx18RWhite.copyWith(
                        fontSize: 14,
                        color: MyColor.grey01Color
                    ),
                  ),
                  const SizedBox(height: 15),

                  //password field
                  TextFormField(
                    controller: passwordController,
                    obscureText: showPassword,
                    validator: (value) {
                      if(value!.isEmpty){
                        return "Please enter login password";
                      }else{
                        return null;
                      }
                    },
                    cursorColor: MyColor.greenColor,
                    style: MyStyle.tx18RWhite,
                    decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Passwords",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15
                        ),
                        suffixIcon: showPassword
                            ?
                        IconButton(
                            onPressed: (){
                              setState(() {
                                showPassword = false;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility,
                              color: MyColor.mainWhiteColor,
                            )
                        )
                            :
                        IconButton(
                            onPressed: (){
                              setState(() {
                                showPassword = true;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility_off,
                              color: MyColor.mainWhiteColor,
                            )
                        )
                    ),
                  ),
                  const SizedBox(height: 30),

                  // login button
                  isLoading == true
                      ?
                  const Center(
                      child: CircularProgressIndicator(
                        color: MyColor.greenColor,
                      )
                  )
                      :
                  InkWell(
                    onTap: () async {
                      if(passwordController.text.isNotEmpty){
                        FocusScope.of(context).unfocus();
                        loginAccount();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 45,
                      margin: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: MyStyle.buttonDecoration,
                      child: Text(
                          "Login",
                          style: MyStyle.tx18BWhite.copyWith(
                              color: MyColor.mainWhiteColor
                          )
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // reset button
                  InkWell(
                    onTap: (){
                      deleteAlert();
                    },
                    child: const Text(
                      "Reset wallet",
                      style: MyStyle.tx18RWhite
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}