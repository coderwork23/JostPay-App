import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Sell_History_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Sell_History_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Sell_History_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Models/BuySellHistoryModel.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Buy/BuyHistory.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellHistory.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellStatusPage.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellValidationPage.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/SellHistoryModel.dart';

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


  bool sellValidOrder = true,isValidSuccess = false;
  dynamic getSellValidation;
  List<dynamic> sellRateList = [];
  List<String> sellBankList = [];

  validateSellOrder(params,accountId,context)async{
    sellValidOrder = true;
    isValidSuccess = false;
    getSellValidation = null;
    notifyListeners();

    ApiHandler.getInstantApi(params).then((responseData) async {
      var value = json.decode(responseData.body);
      // print("object $value");

      if (responseData.statusCode == 200 && value["info"]!= null) {

        sellValidOrder = false;
        isValidSuccess = true;
        getSellValidation = value;

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellValidationPage(params:params),)
        );
        notifyListeners();

      }else{
        sellBankList.clear();
        sellRateList.clear();

        // if(value['error'] == null) {
          if (value['rates_info'] != null) {
            await DBTokenProvider.dbTokenProvider.getAccountToken(accountId);
            value['rates_info'].keys.forEach((key) {
              int findToken = DBTokenProvider.dbTokenProvider.tokenList
                  .indexWhere((element) {
                if (key == "USDTTRC20") {
                  return element.type.toLowerCase() == "TRC20".toLowerCase();
                }
                if (key == "USDTBEP20") {
                  return element.type.toLowerCase() == "BEP20".toLowerCase();
                }
                if (key == "BNBBEP20") {
                  return element.symbol.toLowerCase() == "BNB".toLowerCase();
                } else {
                  return element.symbol.toLowerCase() ==
                      key.toString().toLowerCase();
                }
              });

              List<AccountTokenList> tokenList = DBTokenProvider.dbTokenProvider
                  .tokenList;

              if (findToken != -1) {
                var amount = double.parse(tokenList[findToken].balance) *
                    tokenList[findToken].price;
                var data = {
                  "amount": ApiHandler.calculateLength(
                      "${amount == 0 ? "0.0" : amount}"),
                  "name": value['rates_info'][key]['name'],
                  "symbol": key,
                  "type": tokenList[findToken].type,
                  "logo": tokenList[findToken].logo,
                  "sellPrice": value['rates_info'][key]['sell_price'],
                  "minSellAmount": value['rates_info'][key]['min_sell_amount'],
                };

                sellRateList.add(data);
              }
            });
          }

          if (value['sell_banks'] != null) {
            List<String> list = List<String>.from(
                value['sell_banks'].map((x) => x));
            sellBankList.addAll(list);
          }
        // }else{
        //   Helper.dialogCall.showToast(context, value['error']);
        // }
        sellValidOrder = false;
        notifyListeners();
      }
    });
  }


  bool sellOderLoading = false;
  sellOrder(params,accountId,context){
    sellOderLoading = true;
    notifyListeners();
    ApiHandler.getInstantApi(params).then((responseData) async {
      var value = json.decode(responseData.body);

      // print("value $value");
      if (responseData.statusCode == 200) {
        print("object id ---> $accountId");
        await DbSellHistory.dbSellHistory.getSellHistory(accountId);

        var trxIndex = DbSellHistory.dbSellHistory.sellHistoryList.indexWhere((element) => element.invoice == "${value['invoice']}");

        if(trxIndex == -1) {
          await DbSellHistory.dbSellHistory.createSellHistory(
              SellHistoryModel.fromJson(value, accountId)
          );
        }else{
          await DbSellHistory.dbSellHistory.updateSellHistory(
              SellHistoryModel.fromJson(value, accountId),
              value["invoice"],
              accountId
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SellStatusPage(invoiceNo: value["invoice"]),
          )
        );
        Helper.dialogCall.showToast(context, "Your order placed successfully.");
        sellOderLoading = false;

        notifyListeners();

      }else{

        Helper.dialogCall.showToast(context, "something is wrong please try again.");
        sellOderLoading = false;
        notifyListeners();
      }
    });

  }


  bool checkOrderLoading = false;
  checkOrderStatus(params,accountId,context){
    checkOrderLoading = true;
    notifyListeners();
    ApiHandler.getInstantApi(params).then((responseData) async {
      var value = json.decode(responseData.body);

      print("checkOrderStatus $value");
      if (responseData.statusCode == 200) {
        await DbSellHistory.dbSellHistory.getSellHistory(accountId);
        await DbSellHistory.dbSellHistory.updateStatus(
            value["order_status"],
            value["invoice"],
            accountId
        );

        checkOrderLoading = false;

        notifyListeners();

      }else{
        print("--------> check order status api error <--------");
        checkOrderLoading = false;
        notifyListeners();
      }
    });

  }
}