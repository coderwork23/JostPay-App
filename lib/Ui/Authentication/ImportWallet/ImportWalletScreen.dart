import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pin;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../LocalDb/Local_Account_address.dart';
import '../../../Provider/Token_Provider.dart';
import '../../Dashboard/DashboardScreen.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {

  TextEditingController phraseController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }


  Future<void> secureScreenOff() async {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);

    super.initState();

    secureScreen();
  }

  @override
  void dispose(){
    super.dispose();
    secureScreenOff();
  }

  bool isLoading = false;

  String deviceId = "";

  importAccount() async {
    setState(() {
      isLoading = true;
    });

    await DbNetwork.dbNetwork.getNetwork();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    //print(deviceId);

    var data = {
      "name": "MainWallet",
      "device_id": deviceId,
      "type": "mnemonic",
      "password": pinCodeController.text,
      "mnemonic":  phraseController.text.trim(),
    };

    // print("initCreateWallet");
    // print(jsonEncode(data));

    await accountProvider.addAccount(data, '/initCreateWallet');
    if (accountProvider.isSuccess == true) {
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('isLogin', 'true');
      sharedPreferences.setInt('account', 1);
      sharedPreferences.setString('password', pinCodeController.text);
      //print(sharedPreferences.getString('isLogin'));

      // print("accountProvider.accountData === > ${accountProvider.accountData.length}");
      for(int i=0; i<accountProvider.accountData.length; i++){


        for(int j=0; j<DbNetwork.dbNetwork.networkList.length; j++){

          await DbAccountAddress.dbAccountAddress.createAccountAddress(
              accountProvider.accountData[i]["id"],
              accountProvider.accountData[i][DbNetwork.dbNetwork.networkList[j].publicKeyName],
              accountProvider.accountData[i][DbNetwork.dbNetwork.networkList[j].privateKeyName],
              DbNetwork.dbNetwork.networkList[j].publicKeyName,
              DbNetwork.dbNetwork.networkList[j].privateKeyName,
              DbNetwork.dbNetwork.networkList[j].id,
              DbNetwork.dbNetwork.networkList[j].name
          );

        }

        // print("create account db call");
        await DBAccountProvider.dbAccountProvider.createAccount(
            "${accountProvider.accountData[i]["id"]}",
            accountProvider.accountData[i]["device_id"],
            accountProvider.accountData[i]["name"],
            accountProvider.accountData[i]["mnemonic"]
        );

      }

      getAccount();

    } else {

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
          msg: "Invalid Seed Phrase",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0
      );

    }
  }

  getAccount() async {
    await DBAccountProvider.dbAccountProvider.getAllAccount();
    getToken();
  }


  // var currency;
  getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // currency = sharedPreferences.getString("currency") ?? "USD";
    //print("token =======> ");

    await DBTokenProvider.dbTokenProvider.deleteAllToken();

    for (int i = 0; i < DBAccountProvider.dbAccountProvider.newAccountList.length; i++) {

      await DbAccountAddress.dbAccountAddress.getAccountAddress(DBAccountProvider.dbAccountProvider.newAccountList[i].id);
      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        //print("public address");
        //print(DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName);
        //print(DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress);
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;

      }
      // data["convert"] = currency;
      //print(json.encode(data));
      await tokenProvider.getAccountToken(data, '/getAccountTokens', DBAccountProvider.dbAccountProvider.newAccountList[i].id,"");

    }

    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen()
      ),(route) => false,
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

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
      body: Padding(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                InkWell(
                  onTap: () {
                    importAccount();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 45,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: phraseController.text.isNotEmpty || pinCodeController.text.isNotEmpty
                        ?
                    MyStyle.buttonDecoration
                        :
                    MyStyle.invalidDecoration,

                    child: Text(
                      "Import wallet",
                      style:  MyStyle.tx18BWhite.copyWith(
                        color: phraseController.text.isNotEmpty || pinCodeController.text.isNotEmpty
                            ?
                        MyColor.mainWhiteColor
                            :
                        MyColor.mainWhiteColor.withOpacity(0.5)
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30)
              ],
            ),
          ),
        ),
      ),
    );

  }
}
