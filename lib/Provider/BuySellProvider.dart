import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/Models/BuySellHistoryModel.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Buy/BuyHistory.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuySellProvider with ChangeNotifier{

  String loginButtonText = "Get Otp";
  var accessToken = "";

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
        // print("value getLoginOTPApi ==> $value");
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

      // print("$e");
      print("============  get Login OTP Api error  ============");

      getOtpBool = false;
      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      notifyListeners();

    }
  }

  bool isLoginLoader = false;
  LoginModel? loginModel;
  getLogIn(params,context,email)async{
    isLoginLoader = true;
    notifyListeners();

    try {
      ApiHandler.getInstantApi(params).then((responseData) async {

        var value = json.decode(responseData.body);

        if (responseData.statusCode == 200 && value['error'] == null) {

          List<RatesInfo> ratesInfoList = [];

          var list = ["PMUSD","PPUSD","WEBMONEY","PAYEER","SKYPE","XMR","USDCBEP20","XRP","USDTPOLYGON","USDCPOLYGON"];
          // print("${}");
          value['rates_info'].keys.forEach((key){
            if(list.indexWhere((element) => element == key) == -1){
              // print("object key $key");
              ratesInfoList.add(
                  RatesInfo.fromJson(value['rates_info'][key],key));
            }
          });


          loginModel = LoginModel.fromJson(value,ratesInfoList);
          // print(loginModel!.ratesInfo.map((e) => print(e.name)));

          // print("check value here");
          SharedPreferences sharedPre = await SharedPreferences.getInstance();
          sharedPre.setString("email","$email");
          accessToken = value['access_token'];

          await getExRate({"action":"exchange_rate"},context);

          for(int i =0; i<loginModel!.ratesInfo.length; i++){
            var exListIndex = exchangeList.indexWhere((element) => element["name"] == loginModel!.ratesInfo[i].name);
            if(exListIndex != -1){
              loginModel!.ratesInfo[i].buyPrice = exchangeList[i]['buy'];
              loginModel!.ratesInfo[i].sellPrice = exchangeList[i]['sell'];
            }
          }

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

      // print("$e");
      print("============  get Login Api error  ============");

      isLoginLoader = false;
      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      notifyListeners();

    }
  }


  bool isExRateLoader = false;
  List exchangeList = [];

  getExRate(params,context)async  {
    isExRateLoader = true;
    notifyListeners();

    try {

      ApiHandler.getInstantApi(params).then((responseData) async {
        var value = json.decode(responseData.body);

        if (responseData.statusCode == 200) {
          var buy =value['exchange_rate'].toString().split("Buy");

          for(int i = 0; i<buy.length; i++){
            if(buy[i].split("Sell").length >= 2) {

              var buyValue = buy[i].split("Sell")[0];
              var sellValue = buy[i].split("Sell")[1];
              // print("buy ====>${}");

              var buyMainValue = buyValue.split(".").last.split(" ")[1].trim();
              var sellMainValue = sellValue.split(".").last.split(" ")[1].trim();

              var dataValue = {
                "buy" : int.parse(buyMainValue),
                "sell" : int.parse(sellMainValue),
                "name": buyValue.split(".").first.split(" ").last.trim(),
              };

              exchangeList.add(dataValue);

            }
            else{
              var buyValue1 = buy[i].split("Sell")[0];
              List buyMainValue1 = buyValue1.split(".").last.split(" ").toList();

              if (buyMainValue1.length >= 2) {
                var currencyValue = buyMainValue1[1].trim();
                var dataValue ={
                  "buy" : int.parse(currencyValue),
                  "sell" : 0,
                  "name": currencyValue.split(".").first.split(" ").last.trim(),
                };
                exchangeList.add(dataValue);
              }

            }
          }

          isExRateLoader = false;
          notifyListeners();

        } else {

          isExRateLoader = false;
          notifyListeners();

        }
      });
    }catch(e){

      print("============  get Login Api error  ============");

      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      isExRateLoader = false;
      notifyListeners();

    }
  }

  dynamic getValidData;
  bool isValidBuyLoading = true;
  String receiveValue = "";
  validateBuyOrder(params)async{
    isValidBuyLoading = true;
    getValidData = null;
    receiveValue = "";
    notifyListeners();

    ApiHandler.getInstantApi(params).then((responseData){
      var value = json.decode(responseData.body);

      // print("${value['info'].toString()}");
      if (responseData.statusCode == 200) {
        isValidBuyLoading = false;
        getValidData = value;
        if(getValidData['info'].toString().contains("RAW AMOUNT :")){
          var data = getValidData['info'].toString().split("RAW AMOUNT :").last.trim().split(" ");
          receiveValue = "${double.parse(data[0]).toStringAsFixed(3)} ${data[1].trim().split("\n").first}" ;
        }

        notifyListeners();
      }else{
        isValidBuyLoading = false;
        notifyListeners();
      }
    });
  }

  bool orderLoading = false;
  placeBuyOrder(params,context)async{
    orderLoading = true;
    notifyListeners();

    ApiHandler.getInstantApi(params).then((responseData){
      // var value = json.decode(responseData.body);
      if (responseData.statusCode == 200) {
        orderLoading = false;

        Helper.dialogCall.showToast(context, "Your order placed successfully.");

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BuyHistory(),
            )
        );

        notifyListeners();

      }else{
        Helper.dialogCall.showToast(context, "something is wrong please try again.");

        orderLoading = false;
        notifyListeners();
      }
    });
  }

  bool buyHistoryLoading = false;
  List<BuySellHistoryModel> buyHistoryList = [];
  buyHistory(params)async{
    buyHistoryLoading = true;
    notifyListeners();
    List<BuySellHistoryModel> list = [];


    ApiHandler.getInstantApi(params).then((responseData){
      var value = json.decode(responseData.body);
      if (responseData.statusCode == 200) {
        buyHistoryLoading = false;


        var items = value["transactions"];
        List client = items as List;

        list = client.map<BuySellHistoryModel>((json) {
          
          return BuySellHistoryModel.fromJson(json);
        }).toList();

        buyHistoryList.addAll(list.where((element) => element.details.transactionType == "Buy").toList());
        notifyListeners();

      }else{
        buyHistoryLoading = false;
        notifyListeners();
      }
    });
  }


  bool sellHistoryLoading = false;
  List<BuySellHistoryModel> sellHistoryList = [];
  sellHistory(params)async{
    sellHistoryLoading = true;
    notifyListeners();
    List<BuySellHistoryModel> list = [];


    ApiHandler.getInstantApi(params).then((responseData){
      var value = json.decode(responseData.body);
      if (responseData.statusCode == 200) {


        var items = value["transactions"];
        List client = items as List;

        list = client.map<BuySellHistoryModel>((json) {

          return BuySellHistoryModel.fromJson(json);
        }).toList();

        sellHistoryList.addAll(list.where((element) => element.details.transactionType == "Sell").toList());
        sellHistoryLoading = false;

        notifyListeners();

      }else{
        sellHistoryLoading = false;
        notifyListeners();
      }
    });
  }


  bool sellValidOrder = false,isValidSuccess = false;
  dynamic getSellValidation;

  validateSellOrder(params)async{
    sellValidOrder = true;
    isValidSuccess = false;
    getSellValidation = null;
    receiveValue = "";
    notifyListeners();

    ApiHandler.getInstantApi(params).then((responseData){
      var value = json.decode(responseData.body);

      if (responseData.statusCode == 200 && value["info"]!= null) {
        sellValidOrder = false;
        isValidSuccess = true;
        getSellValidation = value;

        notifyListeners();
      }else{

        sellValidOrder = false;
        notifyListeners();
      }
    });
  }
}