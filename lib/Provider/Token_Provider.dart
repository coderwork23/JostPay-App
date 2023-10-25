import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
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

    await ApiHandler.post(data, url).then((responseData) async {

        var value = json.decode(responseData.body);
        // print("get Token api :- $value");
        if(responseData.statusCode == 200 && value["status"] == true){

          allToken = value;

          // await DBTokenProvider.dbTokenProvider.deleteAccountToken(id);


            await DBTokenProvider.dbTokenProvider.getAccountToken(id, "");

            (allToken["data"] as List).map((token) async {
              var index = DBTokenProvider.dbTokenProvider.tokenList.indexWhere((element) {
                return "${element.id}"== "${token["id"]}";
              });
              // print(index);
              if(index != -1){
                int isCustom = DBTokenProvider.dbTokenProvider.tokenList[index].isCustom;
                await DBTokenProvider.dbTokenProvider.updateToken(AccountTokenList.fromJson(token,id,isCustom), token["id"],id,shortType);
              }else{
                await DBTokenProvider.dbTokenProvider.createToken(AccountTokenList.fromJson(token,id,0));
              }
            }).toList();

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

  bool rcpLoaded = false;
  getRCPUrl(data,url,context) async {
    await ApiHandler.postRcp(data,url).then((responseData){

      try {
        // var value = json.decode(responseData.body);
        // print(value);

        if (responseData == true) {
          rcpLoaded = true;
          isLoading = false;
          notifyListeners();
        }
        else {
          isLoading = false;
          rcpLoaded = false;
          notifyListeners();
          Navigator.pop(context);
          print("=========== get getRCPUrl Api Error ==========");
        }
      }catch(e){
        isLoading = false;
        rcpLoaded = false;
        Navigator.pop(context);
        notifyListeners();

        print("=========== get getRCPUrl Api Error ==========");
      }
    });
  }

}