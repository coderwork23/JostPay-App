import 'dart:io';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:local_auth_ios/types/auth_messages_ios.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pin;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWithPassCode extends StatefulWidget {
  const LoginWithPassCode({super.key});

  @override
  State<LoginWithPassCode> createState() => _LoginWithPassCodeState();
}

class _LoginWithPassCodeState extends State<LoginWithPassCode> {

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
            goToSettingsDescription:"Please set up your Touch ID",
            lockOut: "Please Re-enable your Touch ID"
        );


        authenticated = await auth.authenticate(
          localizedReason: "Please authenticate to Login your Account",
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
    Helper.dialogCall.showAlertDialog(context);
    setState((){
      errorText = "";
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    String? password = sharedPreferences.getString('passcode');

    // print(password);
    var data = {
      "device_id":deviceId,
      "password":"$password",
    };

    await accountProvider.loginAccount(data,'/deviceLogin');
    if(accountProvider.isSuccess == true){

      getAccount();

    }
    else{
      Helper.dialogCall.showToast(context, "Incorrect Password !!");
      Navigator.pop(context);
      setState((){
        errorText = "Incorrect Password";
        isLoading = false;
      });

    }
  }

  getAccount() async {

    //print("Account");

    await DBAccountProvider.dbAccountProvider.getAllAccount();

    getToken();

  }

  getToken() async {
    DBTokenProvider.dbTokenProvider.deleteAccountToken(DBAccountProvider.dbAccountProvider.newAccountList[0].id);

    for (int i = 0; i < DBAccountProvider.dbAccountProvider.newAccountList.length; i++) {
      var data ={
        "id":"1,2,74,328,825,1027,1839,1958"
      };
      await tokenProvider.getAccountToken(data, '/v1/cryptocurrency/quotes/latest', DBAccountProvider.dbAccountProvider.newAccountList[i].id);
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
    Helper.dialogCall.showAlertDialog(context);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    // print("object --> $deviceId");
    setState(() {
      errorText = "";
      isLoading = true;
    });

    var data = {
      "device_id": deviceId,
      "password": passwordController.text,
    };

    try {
      await accountProvider.loginAccount(data, '/deviceLogin');
      if (accountProvider.isSuccess == true) {
        getAccount();
      }
      else {
        setState(() {
          isLoading = false;
        });
        errorText = "Incorrect Password!!";
        Helper.dialogCall.showToast(context, "Incorrect Password!!");
        Navigator.pop(context);
      }
    }catch(e){
      errorText = "Incorrect Password!!";
      Helper.dialogCall.showToast(context, "Incorrect Password!!");
      Navigator.pop(context);

      setState(() {
        isLoading = false;
      });
    }
  }


  deleteAlert() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:  MyColor.backgroundColor,
        title: Text(
            "Are you sure",
            style: MyStyle.tx18BWhite.copyWith(
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
                  "Do you want to delete your all accounts",
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
      "device_id":deviceId
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
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WelcomeScreen(isNew: false)
    )
    );

  }

  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);

    super.initState();

    Future.delayed(Duration.zero,(){
      getDeviceId();
    });
  }

  @override
  Widget build(BuildContext context) {

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 15),
              Image.asset(
                "assets/images/splash_screen.png",
                height: 60,
                width: width * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 5),

              // title
              Text(
                "Please Enter your passcode \nto proceed!",
                textAlign: TextAlign.center,
                style:MyStyle.tx18RWhite.copyWith(
                    fontSize: 14,
                    color: MyColor.grey01Color
                ),
              ),
              SizedBox(height: height*0.09),


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
                    controller: passwordController,
                    keyboardType: TextInputType.number,

                    onCompleted: (v) {

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
                    passwordController.text = p0;
                  });
                },
                onCompleted: (p0) {
                  loginAccount();
                },
                specialKey: Visibility(
                  visible: fingerOn,
                  child: Image.asset(
                    "assets/images/fingerprint.png",
                    height: 45,
                    width: 60,
                    fit: BoxFit.contain,
                    color: MyColor.whiteColor,
                  ),
                ),
                specialKeyOnTap: () {
                  if(fingerOn) {
                    _authenticate();
                  }
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