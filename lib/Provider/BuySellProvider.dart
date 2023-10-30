import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuySellProvider with ChangeNotifier{

  String loginButtonText = "Get Otp";
  var accessToken = "";

  List coinList = [
    'PMUSD','BTC','ETH','PPUSD','WEBMONEY','PAYEER',
    'LTC,','SKYPE', 'XMR','XRP','DOGE','BNBBEP20',
    'TRX','USDTTRC20','USDTBEP20','USDCBEP20','USDCPOLYGON'
  ];

  bool getOtpBool = false;
  bool showOtpText = false;

  getLoginOTPApi(params,context)async{
    getOtpBool = true;
    showOtpText = false;
    notifyListeners();

    try {
      ApiHandler.getInstantApi(params).then((responseData) {
        print(responseData);

        var value = json.decode(responseData.body);
        print("value getLoginOTPApi ==> $value");
        if (responseData.statusCode == 200 && value['error'] == null) {

          Helper.dialogCall.showToast(context, "${value['info']}");

          getOtpBool = false;
          showOtpText = true;

          loginButtonText = "Login";
          notifyListeners();
        } else {

          Helper.dialogCall.showToast(context, "${value['error']}");

          getOtpBool = false;
          notifyListeners();

        }
      });
    }catch(e){

      print("$e");
      print("============  get Login OTP Api error  ============");

      getOtpBool = false;
      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      notifyListeners();

    }
  }

  bool isLoginLoader = false;
  getLogIn(params,context)async{
    isLoginLoader = true;
    notifyListeners();

    try {
      ApiHandler.getInstantApi(params).then((responseData) async {

        var value = json.decode(responseData.body);
        // print("getLogIn->  $value");

        if (responseData.statusCode == 200 && value['error'] == null) {
          // print("check value here");
          SharedPreferences sharedPre = await SharedPreferences.getInstance();
          sharedPre.setString("accessToken","${value['access_token']}");
          accessToken = value['access_token'];

          isLoginLoader = false;
          showOtpText = false;
          loginButtonText = "Get Otp";

          notifyListeners();
        } else {

          Helper.dialogCall.showToast(context, "${value['error']}");
          isLoginLoader = false;

          notifyListeners();

        }
      });
    }catch(e){

      print("$e");
      print("============  get Login Api error  ============");

      isLoginLoader = false;
      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      notifyListeners();

    }
  }


  bool isExRateLoader = false;
  getExRate(params,context)async{
    isExRateLoader = true;
    notifyListeners();

    try {
      ApiHandler.getInstantApi(params).then((responseData) async {

        var value = json.decode(responseData.body);
        // print("getLogIn->  $value");

        if (responseData.statusCode == 200 && value['error'] == null) {
          // print("check value here");

          isExRateLoader = false;
          notifyListeners();
        } else {

          Helper.dialogCall.showToast(context, "${value['error']}");
          isExRateLoader = false;
          notifyListeners();

        }
      });
    }catch(e){

      print("$e");
      print("============  get Login Api error  ============");

      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      isExRateLoader = false;
      notifyListeners();

    }
  }


}