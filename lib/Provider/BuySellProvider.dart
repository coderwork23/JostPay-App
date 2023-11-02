import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
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
        // print(responseData);

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
  LoginModel? loginModel;
  getLogIn(params,context)async{
    isLoginLoader = true;
    notifyListeners();

    try {
      ApiHandler.getInstantApi(params).then((responseData) async {

        var value = json.decode(responseData.body);

        // print("getLogIn->  ${value[0].}");
        // json[0]["1"].keys.forEach((key){ print(key); });

        if (responseData.statusCode == 200 && value['error'] == null) {

          List<RatesInfo> ratesInfoList = [];

          // print("${}");
          value['rates_info'].keys.forEach((key){
            ratesInfoList.add(
                RatesInfo.fromJson(value['rates_info'][key],key));
          });


          loginModel = LoginModel.fromJson(value,ratesInfoList);

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
  getExRate(params,context)async  {
    isExRateLoader = true;
    notifyListeners();

    try {
      ApiHandler.getInstantApi(params).then((responseData) async {

        var value = json.decode(responseData.body);
        // print("getLogIn->  $value");

        if (responseData.statusCode == 200) {
          var buy =value['exchange_rate'].toString().split("Buy");

          for(int i = 0; i<buy.length; i++){
            if(buy[i].split("Sell").length > 1) {
              var buyValue = buy[i].split("Sell")[0];
              var sellValue = buy[i].split("Sell")[1];
              var buyMainValue = buyValue.split(".").last.split(" ")[1].trim();
              var sellMainValue = sellValue.split(".").last.split(" ")[1].trim();

              print("buyValue 1 -----> $buyMainValue");
              print("sellValue 1 ----> $sellMainValue");
            }else{
              var buyValue1 = buy[i].split("Sell")[0];
              List buyMainValue1 = buyValue1.split(".").last.split(" ").toList();
              // print("buyValue 0 ---> ${buyMainValue1}");

              if (buyMainValue1.length >= 2) {
                var currencyValue = buyMainValue1[1].trim();

                print("buyValue 0 ---> $currencyValue");
              } else {
                print("Invalid format for buyValue1");
              }

            }

          }
          //
          isExRateLoader = false;
          notifyListeners();
        } else {

          // Helper.dialogCall.showToast(context, "${value['error']}");
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