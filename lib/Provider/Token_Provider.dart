import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import '../LocalDb/Local_Token_provider.dart';
import '../Models/AccountTokenModel.dart';
import '../Models/NetworkModel.dart';

class TokenProvider with ChangeNotifier {

  bool isLoading = true;
  bool isSuccess = false;

  var netWorkData;
  bool networkLoad = false;
  getNetworks(url) async {
    isLoading = true;
    networkLoad = false;
    notifyListeners();

      await ApiHandler.get(url).then((responseData) async {

        var value = json.decode(responseData.body);

        // print("get network");x

        // await DbNetwork.dbNetwork.deleteAllNetwork();


        if(responseData.statusCode == 200 && value["status"] == true){
          // isSuccess = true;
          netWorkData = value;

          await DbNetwork.dbNetwork.getNetwork();
          (netWorkData["data"] as List).map((token) async {
            var index = DbNetwork.dbNetwork.networkList.indexWhere((element) => "${element.id}" == "${token["id"]}");
            if(index != -1 ){
              await DbNetwork.dbNetwork.updateNetwork(NetworkList.fromJson(token));
            }else {
              await DbNetwork.dbNetwork.createNetwork(NetworkList.fromJson(token));
            }
          }).toList();


          networkLoad = true;
          isLoading = false;
          notifyListeners();
        }
        else {
          // isSuccess = false;
          isLoading = false;
          networkLoad = false;

          notifyListeners();

          print("=========== Get Network Api Error ==========");

        }

      });

  }



  bool isAddTokenDone = false;
  var allToken;
  getAccountToken(data, url,id,shortType) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.getCapWithParams(url,data).then((responseData) async {

        var value = json.decode(responseData.body);
        // print("get Token api :- $value");

        if(responseData.statusCode == 200){
          allToken = value;
          await DBTokenProvider.dbTokenProvider.getAccountToken(id);
          List marketId = ["1","2","74","328","825","1027","1839","1958"];
          List tokenID = ["8","29","28","0","-1","1","2","10"];


          for(int i = 0; i<marketId.length; i++){

            Map<String,dynamic> marketInfo = allToken['data'][marketId[i]];


            print("price --->  ${marketInfo['name']}");
            await DbNetwork.dbNetwork.getNetworkBySymbol("${marketInfo['symbol']}");

            if(DbNetwork.dbNetwork.networkListBySymbol.isNotEmpty) {

              await DbAccountAddress.dbAccountAddress.getPublicKey(id, DbNetwork.dbNetwork.networkListBySymbol.first.id);

              AccountTokenList accountTokenList = AccountTokenList(
                id: int.parse(marketId[i]),
                token_id: int.parse(tokenID[i]),
                accAddress: DbAccountAddress.dbAccountAddress.selectAccountPublicAddress,
                networkId: DbNetwork.dbNetwork.networkListBySymbol.isNotEmpty ? DbNetwork.dbNetwork.networkListBySymbol.first.id:0,
                marketId:int.parse(marketId[i]),
                name: marketInfo['name'],
                type: "",
                address: "",
                symbol: marketInfo['symbol'],
                decimals: 0,
                logo: "https://s2.coinmarketcap.com/static/img/coins/64x64/$marketId.png",
                balance: "0",
                networkName: DbNetwork.dbNetwork.networkListBySymbol.first.name,
                price: marketInfo['quote']['USD']['price'],
                percentChange24H: marketInfo['quote']['USD']['percent_change_24h'],
                accountId: id,
                explorer_url: DbNetwork.dbNetwork.networkListBySymbol.first.name,
              );

              // print("${accountTokenList.toJson()}");

              var tokenListIndex = DBTokenProvider.dbTokenProvider.tokenList.indexWhere((element) {
                return "${element.id}"== "${marketId[i]}";
              });

              if(tokenListIndex != -1){
                await DBTokenProvider.dbTokenProvider.updateToken(accountTokenList, marketId[i],id);
              }else{
                await DBTokenProvider.dbTokenProvider.createToken(accountTokenList);
              }

            }

          }

          // print(tokenNote);

          isSuccess = true;
          isLoading = false;
          notifyListeners();

        }
        else {
          isSuccess = false;
          isLoading = false;
          notifyListeners();

          print("=========== Get Account Token Api Error ==========");

        }

      });

  }


  var deleteData;
  deleteToken(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        // print(value);
        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isSuccess = true;
          deleteData = value;
          isLoading = false;
          notifyListeners();
        }
        else
        {
          isLoading = false;
          isSuccess = false;
          notifyListeners();

          print("=========== Delete Token Api Error ==========");

        }

      });

  }


  var tokenData;
  getCustomToken(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print(value);
      if(responseData.statusCode == 200 && value["status"] == true)
      {
        isSuccess = true;
        tokenData = value;
        notifyListeners();
      }
      else
      {
        tokenData = null;
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        print("=========== Get Custom Token Api Error ==========");

      }

    });

  }


  bool isTokenLoading = false;
  bool isTokenAdded = false;
  var tokenDetail;
  addCustomToken(data,url,id) async {
    isTokenLoading = true;
    isTokenAdded = false;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print("add token response ===> $value");
      if(responseData.statusCode == 200 && value["status"] == true)
      {
        tokenDetail = value;

        /* (tokenDetail["data"] as List).map((token){
          DBTokenProvider.dbTokenProvider.createToken(AccountTokenList.fromJson(token,id,0));
        }).toList(); */

        isTokenAdded = true;
        isTokenLoading = false;
        notifyListeners();
      }
      else
      {
        isTokenAdded = false;
        isTokenLoading = false;
        notifyListeners();

        print("=========== Add Custom Token Api Error ==========");

      }

    });
  }


  bool isEstimate = false;
  var estimateData = null;
  getEstimate(data,url) async{

    isLoading = true;
    isEstimate = false;
    notifyListeners();

    //print(data);
    await ApiHandler.testPost(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print(" ====> $value");

      if(responseData.statusCode == 200 && value["status"] == true) {
        isLoading = false;
        isEstimate = true;
        estimateData = value;
        notifyListeners();
      } else {
        estimateData = null;
        isEstimate = false;
        isLoading = false;

        print("=========== Get Estimate Api Error ==========");

      }

    });

  }


  var pairDetails;
  getPairPrice(url,params) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.getParams(url,params).then((responseData){

      var value = json.decode(responseData.body);
      //print(value);

      if(responseData.statusCode == 200 && value["status"] == true) {
        pairDetails = value;

        isSuccess = true;
        isLoading = false;
        notifyListeners();
      }
      else {
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        print("=========== Get Pair Price Api Error ==========");

      }

    });
  }


  var tokenBalance;
  bool isBalance = false;
  getTokenBalance(data,url) async {
    isLoading = true;
    notifyListeners();

    // print(data);

      await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        // print(value);

        if(responseData.statusCode == 200 && value["status"] == true) {
          tokenBalance = value;

          isBalance = true;
          isLoading = false;
          notifyListeners();
        }
        else {
          tokenBalance = null;

          isLoading = false;
          isBalance = false;
          notifyListeners();

          print("=========== get Token Balance Api Error ==========");

        }

      });

  }

}