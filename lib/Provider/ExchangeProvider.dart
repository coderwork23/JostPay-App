import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Ex_Transaction_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Models/ExTransactionModel.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeProvider with ChangeNotifier{
  

  // List<ExchangeTokenModel> exTokenList = [];
  List<AccountTokenList> exTokenList = [];

  late AccountTokenList sendCoin;
  late AccountTokenList receiveCoin;

  bool isLoading = true;

  getTokenList(String url)async{
    isLoading = true;
    exTokenList.clear();
    notifyListeners();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);

    sendCoin = AccountTokenList.fromJson(
        await DBTokenProvider.dbTokenProvider.getTokenById(selectedAccountId,"1"),
        selectedAccountId
    );

    receiveCoin = AccountTokenList.fromJson(
        await DBTokenProvider.dbTokenProvider.getTokenById(selectedAccountId,"1027"),
        selectedAccountId
    );
    isLoading = false;

    await getExchangeMinMax(
        "v1/exchange-range/fixed-rate/${sendCoin.symbol.toLowerCase()}_${receiveCoin.symbol.toLowerCase()}",
        {"api_key":Utils.apiKey}
    );
    notifyListeners();

    // await ApiHandler.getExchange(url).then((responseData) async {
    //   var value = json.decode(responseData.body);
    //   // print("Get Exchange Token ----> $value");
    //
    //   if(responseData.statusCode == 200) {
    //
    //     List<ExchangeTokenModel> list = [];
    //     (value as List).map((token) {
    //       list.add(ExchangeTokenModel.fromJson(token));
    //     }).toList();
    //
    //     exTokenList = list;
    //     sendCoin = exTokenList[0];
    //     receiveCoin = exTokenList[1];
    //
    //     await getExchangeMinMax(
    //       "v1/exchange-range/${sendCoin.ticker}_${receiveCoin.ticker}",
    //       {"api_key":Utils.apiKey}
    //     );
    //     isLoading = false;
    //     notifyListeners();
    //
    //   }else{
    //     isLoading = false;
    //     notifyListeners();
    //   }
    // });

  }

  double minAmount = 0,maxAmount = 0;
  bool exRateLoading= true;
  getExchangeMinMax(String url,params)async{
    exRateLoading = true;
    notifyListeners();

    await ApiHandler.getExchangeParams(url, params).then((responseData){
      var value = json.decode(responseData.body);
      // print("object ---> $value");

      if(responseData.statusCode == 200) {

        minAmount = value['minAmount'] ?? -1;
        maxAmount = value['maxAmount'] ?? -1;

        exRateLoading = false;
        notifyListeners();
      }else{
        exRateLoading = false;
        notifyListeners();

      }
    });
  }

  changeSendToken(AccountTokenList newToken, context, id) async {
    if (sendCoin.id != newToken.id) {
      // Create a copy of newToken
      AccountTokenList copiedToken = AccountTokenList.fromJson(newToken.toJson(),id);
      sendCoin = copiedToken;

      if (newToken.type == "TRX20") {
        sendCoin.symbol = "usdttrc20";
      } else if (newToken.type == "BEP20") {
        sendCoin.symbol = "usdtbsc";
      }

      notifyListeners();
    } else {
      Helper.dialogCall.showToast(context, "You can't select the same coin");
    }
  }

  changeReceiveToken(AccountTokenList newToken,context,id) async {


    if(receiveCoin.id != newToken.id ) {
      AccountTokenList copiedToken = AccountTokenList.fromJson(newToken.toJson(),id);
      receiveCoin = copiedToken;

      if (newToken.type == "TRX20") {
        receiveCoin.symbol = "usdttrc20";
      } else if (newToken.type == "BEP20") {
        receiveCoin.symbol = "usdtbsc";
      }
      notifyListeners();

    }else{
      Helper.dialogCall.showToast(context, "You can't select same coin");
    }
  }


  bool estimateLoading = false;
  double estimatedAmount =0;
  TextEditingController getCoinController = TextEditingController();
  estimateExchangeAmount(String url,params)async{
    estimateLoading = true;
    notifyListeners();

    print("object--->  $url");
    print("object--->  $params");

    await ApiHandler.getExchangeParams(url, params).then((responseData){
      var value = json.decode(responseData.body);

      print("estimate object --->  $value");

      if(responseData.statusCode == 200) {

        estimatedAmount = value['estimatedAmount']??0;
        getCoinController.text = estimatedAmount.toStringAsFixed(6);
        notifyListeners();
        estimateLoading = false;

      }else{
        estimateLoading = false;
        notifyListeners();
        print(" =====> exchange estimate Exchange Amount api error <====");
      }
    });
  }


  String payinAddress ="",payoutAddress ="",fromCurrency ="",toCurrency ="",validUntil ="",trxId ="";
  double amount = 0;

  bool createExLoading = false,createExSuccess = false;
  createExchange(url,body)async{

    createExSuccess = false;
    createExLoading = true;
    notifyListeners();

    await ApiHandler.postExchange(url,body).then((responseData) async {

      var value = json.decode(responseData.body);
      // print("object url ---> $url");
      if(responseData.statusCode == 200) {
        payinAddress = value["payinAddress"];
        payoutAddress = value["payoutAddress"];
        fromCurrency = value["fromCurrency"];
        toCurrency = value["toCurrency"];
        validUntil = value["validUntil"];
        trxId = value["id"];
        amount = value["amount"];
        print("object ---> $value");
        createExLoading = false;
        createExSuccess = true;
        print("createExSuccess $createExSuccess");
        notifyListeners();
      }
      else{
        createExLoading = false;
        createExSuccess = false;
        notifyListeners();
      }
    });
  
  }


  bool getTrxStatus = false,statusLoading = false;
  transactionStatus(url,accountId) async {
    statusLoading = true;
    getTrxStatus = false;
    notifyListeners();

    await ApiHandler.getExchange(url).then((responseData) async {
      var value = json.decode(responseData.body);
      // print("object url ---> $url");
      print("transactionStatus ---> $value");

      if(responseData.statusCode == 200) {

        await DbExTransaction.dbExTransaction.getExTransaction(accountId);

        var trxIndex = DbExTransaction.dbExTransaction.exTransactionList.indexWhere((element) => "${element.id}" == "${value['id']}");

        if(trxIndex == -1) {
          await DbExTransaction.dbExTransaction.createExTransaction(
              ExTransactionModel.fromJson(value, accountId)
          );
        }else{
          await DbExTransaction.dbExTransaction.updateExTransaction(
              ExTransactionModel.fromJson(value, accountId),
              value["id"],
              accountId
          );
        }


        statusLoading = false;
        getTrxStatus = true;
        notifyListeners();

      }else{
        statusLoading = false;
        getTrxStatus = false;
        notifyListeners();
        print("-----> transactionStatus api error <------");
      }
    });
  }


  bool isAddressVerify = false,verifyAddressLoading =false;
  addressVerification(String url,params,context) async {
    verifyAddressLoading = true;
    notifyListeners();

    await ApiHandler.getExchangeParams(url, params).then((responseData){
      var value = json.decode(responseData.body);
      print("object url ---> $params");
      print("object ---> $value");

      if(responseData.statusCode == 200) {
        isAddressVerify = value["result"];
        verifyAddressLoading = false;
        notifyListeners();
      }else{
        if(value["result"] != null) {
          isAddressVerify = value["result"];
          Helper.dialogCall.showToast(context, "${value['message']}");
        }else{
          Helper.dialogCall.showToast(context, "Address is not valid");
        }
        verifyAddressLoading = false;
        notifyListeners();

      }
    });
  }

}