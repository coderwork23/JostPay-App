import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/AddAssetsScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/ReceiveToken/ReceiveTokenList.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenList.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WithdrawToken/WithDrawTokenList.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CoinDetailScreen.dart';
import 'ExchangeCoin/ExchangeScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;

  showAddAsserts(BuildContext context,selectedAccountId){
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height/2,
            maxHeight: MediaQuery.of(context).size.height*0.8
          ),
            child: AddAssetsScreen(selectedAccountId:selectedAccountId)
        );
      },
    ).whenComplete(() async {
      getToken();
      // await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);
      setState(() {});
    });
  }

  showSendTokenList(BuildContext context){
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20,22,20,10),
            constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height/2,
            maxHeight: MediaQuery.of(context).size.height*0.8
          ),
            child: const SendTokenList()
        );
      },
    );
  }

  showReceiveTokenList(BuildContext context){
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20,22,20,10),
            constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height/2,
            maxHeight: MediaQuery.of(context).size.height*0.8
          ),
            child: const ReceiveTokenList()
        );
      },
    );
  }

  showWithdrawTokenList(BuildContext context){
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20,22,20,10),
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height/2,
                maxHeight: MediaQuery.of(context).size.height*0.8
            ),
            child: const WithDrawTokenList()
        );
      },
    );
  }

  late String deviceId;
  String selectedAccountId = "",
      selectedAccountName = "",
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "";

  bool isCalculating = false;
  bool isLoaded = false;

  @override
  void initState() {
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    super.initState();
    selectedAccount();
  }


  double showTotalValue = 0.0;
  var trxPrivateKey ="";

  // get selected account
  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      isLoaded = false;
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
      selectedAccountAddress = sharedPreferences.getString('accountAddress') ?? "";
      selectedAccountPrivateAddress = sharedPreferences.getString('accountPrivateAddress') ?? "";
      showTotalValue = sharedPreferences.getDouble('myBalance') ?? 0.00;
    });

    // print("object selectedAccountId ${selectedAccountId}");

    if(selectedAccountId == "") {
      setState(() {
        selectedAccountId = DBAccountProvider.dbAccountProvider.newAccountList[0].id;
        selectedAccountName = DBAccountProvider.dbAccountProvider.newAccountList[0].name;

        sharedPreferences.setString('accountId', selectedAccountId);
        sharedPreferences.setString('accountName', selectedAccountName);

      });
    }

    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);
    await DbNetwork.dbNetwork.getNetwork();

    for(int i=0; i< DbAccountAddress.dbAccountAddress.allAccountAddress.length; i ++){

      if(DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicKeyName == "address"){

        if(mounted) {
          setState(() {
            selectedAccountAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicAddress;
            selectedAccountPrivateAddress =
                DbAccountAddress.dbAccountAddress.allAccountAddress[i].privateAddress;
            sharedPreferences.setString('accountAddress', selectedAccountAddress);
            sharedPreferences.setString('accountPrivateAddress', selectedAccountPrivateAddress);
          });
        }
      }
    }

    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,9);

    if(mounted) {
      setState(() {
        trxPrivateKey = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
      });

      getToken();
    }
  }


  bool _showRefresh = false,isNeeded = false;

  //cry lawn discover subway captain rib claw spice sure frequent struggle yellow
  // getToken for coin market cap
  getToken() async {
    if (isNeeded == true) {

      await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);

      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
      }

      // print(jsonEncode(data));

      await tokenProvider.getAccountToken(data, '/getAccountTokens', selectedAccountId);



      if(mounted) {
        setState(() {
          isNeeded = false;
        });
      }
    }
    else {
      await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);
      setState(() {});
    }

    getSocketData();

    if(mounted) {
      setState(() {
        _showRefresh = false;
        isLoaded = true;
      });
    }
  }


  IO.Socket? socket;

  // socket for get updated balance
  getSocketData() async {
    // print("Connecting socket");
    socket = IO.io('http://${Utils.url}/', <String, dynamic>{
      "secure": true,
      "path":"/api/socket.io",
      "rejectUnauthorized": false,
      "transports":["websocket", "polling"],
      "upgrade": false,
    });

    socket!.connect();

    socket!.onConnect((_) {

      socket!.on("getTokenBalance", (response) async {
        // print(json.encode(response));
        if(mounted) {
          if (response["status"] == true) {
            if ("${response["data"]["balance"]}" != "0") {
              if (response["data"]["balance"] != "null") {
                await DBTokenProvider.dbTokenProvider.updateTokenBalance(
                  '${response["data"]["balance"]}',
                  '${response["data"]["id"]}',
                );
              }
            }
          }

          // print("Socket ac id $selectedAccountId");

          await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);
          if(mounted) {
            setState(() {});
          }
          getAccountTotal();
        }

      });
    });



    for (int i = 0; i < DBTokenProvider.dbTokenProvider.tokenList.length; i++) {
      List <NetworkList> networkList =  DbNetwork.dbNetwork.networkList.where((element) => element.id == DBTokenProvider.dbTokenProvider.tokenList[i].networkId).toList();
      var data = {
        "id": "${DBTokenProvider.dbTokenProvider.tokenList[i].id}",
        "network_id": "${DBTokenProvider.dbTokenProvider.tokenList[i].networkId}",
        "tokenAddress": DBTokenProvider.dbTokenProvider.tokenList[i].address,
        "address": DBTokenProvider.dbTokenProvider.tokenList[i].accAddress,
        "trxPrivateKey": trxPrivateKey,
        "isCustomeRPC":false,
        "network_url":networkList.isEmpty ? "" : networkList.first.url,
      };

      // print("socket emit ==>  $data");
      socket!.emit("getTokenBalance", jsonEncode(data));
    }

  }


  bool updatingValue = false;
  double updatingTotalValue = 0.00;

  // Calculate all amount
  getAccountTotal() async {

    if(mounted) {
      setState(() {
        showTotalValue = 0.0;
      });
    }

    double valueUsd = 0.0;

    for(int i =0; i<DBTokenProvider.dbTokenProvider.tokenList.length; i++){

      // print("${DBTokenProvider.dbTokenProvider.tokenList[i].name} balance:- ${DBTokenProvider.dbTokenProvider.tokenList[i].balance} price:- ${DBTokenProvider.dbTokenProvider.tokenList[i].price}");



      if (DBTokenProvider.dbTokenProvider.tokenList[i].balance == "" ||
          DBTokenProvider.dbTokenProvider.tokenList[i].balance == "0" ||
          DBTokenProvider.dbTokenProvider.tokenList[i].balance == null ||
          DBTokenProvider.dbTokenProvider.tokenList[i].price == 0.0
      ) {
        valueUsd += 0;
      }
      else {
        valueUsd += double.parse(DBTokenProvider.dbTokenProvider.tokenList[i].balance) * DBTokenProvider.dbTokenProvider.tokenList[i].price;
      }

    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(mounted) {
      setState(() {
        showTotalValue = valueUsd;
        sharedPreferences.setDouble("myBalance", showTotalValue);
        updatingValue = false;
      });
    }
    // print("show Total Value === > $showTotalValue");
  }


  Future<void> _getData() async {
    setState(() {
      updatingValue = false;
    });

    socket!.close();
    socket!.destroy();
    socket!.dispose();

    if(DBTokenProvider.dbTokenProvider.tokenList.isNotEmpty){
      setState(() {
        updatingValue = true;
        updatingTotalValue = showTotalValue;
      });
    }

    setState(() {
      _showRefresh = true;
      isNeeded = true;
      getToken();
    });
  }

  doNothing(){}

  @override
  Widget build(BuildContext context) {

    final dashProvider = Provider.of<DashboardProvider>(context);

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: MyColor.darkGreyColor,
      appBar: AppBar(
        backgroundColor: MyColor.darkGreyColor,
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        title: Padding(
          padding: const EdgeInsets.only(top: 4.0,bottom: 4),
          child:  Image.asset(
            "assets/images/splash_screen.png",
            height: 35,
            fit: BoxFit.contain,
          ),
        ),
        actions:  [
          IconButton(
            onPressed: () async {
              showAddAsserts(context,selectedAccountId);
            },
            icon: Image.asset(
              "assets/images/dashboard/add.png",
              height: 23,
              width: 23,
              color: MyColor.mainWhiteColor,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),

          // Current Balance and wallet name
          Text(
            "Current Balance - $selectedAccountName",
            style: MyStyle.tx18RWhite.copyWith(
              fontSize: 14,
              color: MyColor.grey01Color
            ),
          ),
          const SizedBox(height: 15),

          // total amount
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "~${ApiHandler.calculateLength("$showTotalValue")} ",
                  style: MyStyle.tx22RWhite.copyWith(
                    fontSize: 32,
                  ),
                ),
                TextSpan(
                  text: "USD",
                  style: MyStyle.tx22RWhite.copyWith(
                    fontSize: 22,
                  ),
                ),
              ]
            ),
          ),
          const SizedBox(height: 18),

          // send receive withdraw and exchange
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // send
              InkWell(
                onTap: () {
                  showSendTokenList(context);
                },
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      padding: const EdgeInsets.all(13),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: MyColor.backgroundColor,
                        shape: BoxShape.circle
                      ),
                      child: Image.asset(
                        "assets/images/dashboard/send.png",
                        height: 18,
                        width: 18,
                        color: MyColor.greenColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Send",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 12,
                          color: MyColor.whiteColor
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // receive
              InkWell(
                onTap: () {
                  showReceiveTokenList(context);
                },
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      padding: const EdgeInsets.all(13),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: MyColor.backgroundColor,
                          shape: BoxShape.circle
                      ),
                      child: Image.asset(
                        "assets/images/dashboard/receive.png",
                        height: 18,
                        width: 18,
                        color: MyColor.greenColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Receive",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 12,
                          color: MyColor.whiteColor
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // withdraw
              InkWell(
                onTap: () {
                  showWithdrawTokenList(context);
                },
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      padding: const EdgeInsets.all(13),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: MyColor.backgroundColor,
                          shape: BoxShape.circle
                      ),
                      child: Image.asset(
                        "assets/images/dashboard/card.png",
                        height: 18,
                        width: 18,
                        color: MyColor.greenColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Withdraw",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 12,
                          color: MyColor.whiteColor
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Exchange
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  const ExchangeScreen(tokenList: null),
                    )
                  );
                },
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      padding: const EdgeInsets.all(13),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: MyColor.backgroundColor,
                          shape: BoxShape.circle
                      ),
                      child: Image.asset(
                        "assets/images/dashboard/exchange.png",
                        height: 18,
                        width: 18,
                        color: MyColor.greenColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Exchange",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 12,
                          color: MyColor.whiteColor
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // coin list
          Expanded(
             child: Container(
               padding: const EdgeInsets.only(top:12),
               decoration: const BoxDecoration(
                 color: MyColor.backgroundColor,
                 borderRadius: BorderRadius.only(
                   topLeft: Radius.circular(25),
                   topRight: Radius.circular(25),
                 ),
               ),
               child: ClipRRect(
                 borderRadius: const BorderRadius.only(
                   topLeft: Radius.circular(40),
                   topRight: Radius.circular(40),
                 ),
                 child : DeclarativeRefreshIndicator(
                   color: MyColor.greenColor,
                   backgroundColor: MyColor.mainWhiteColor,
                   onRefresh: isCalculating == true ? doNothing : _getData,
                   refreshing: _showRefresh,
                   child: ListView.builder(
                     itemCount: DBTokenProvider.dbTokenProvider.tokenList.length,
                     padding: const EdgeInsets.fromLTRB(12,10,12,70),
                     itemBuilder: (context, index) {

                       var list = DBTokenProvider.dbTokenProvider.tokenList[index];

                       // print(list.toJson());
                       double? tokenUsdPrice;

                       if(list.price == 0.0){
                         tokenUsdPrice =  0.0;
                       }
                       else if (list.price > 0.0){
                         tokenUsdPrice = double.parse(list.balance) * list.price;
                       }

                       return InkWell(
                         onTap: () async {

                           double selectTokenUSD;

                           if(list.price == null){
                             selectTokenUSD = 0.0;
                           }
                           else{
                             selectTokenUSD = double.parse(list.balance) * list.price;
                           }


                           await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,list.networkId);
                           selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;


                             // ignore: use_build_context_synchronously
                           var value = await Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => CoinDetailScreen(
                                   selectedAccountAddress: selectedAccountAddress,
                                   tokenDecimal: "${list.decimals}",
                                   accAddress: list.accAddress,
                                   tokenId: "${list.token_id}",
                                   tokenNetworkId: "${list.networkId}",
                                   tokenAddress: list.address,
                                   tokenName: list.name,
                                   tokenSymbol: list.symbol,
                                   tokenBalance: list.balance,
                                   tokenMarketId: "${list.marketId}",
                                   tokenType: list.type,
                                   tokenImage: list.logo,
                                   tokenUsdPrice: selectTokenUSD,
                                   tokenFullPrice: list.price,
                                   tokenUpDown: list.percentChange24H,
                                   token_transection_Id: "${list.token_id}",
                                   explorerUrl: list.explorer_url,
                               ),
                             )
                           );

                           if(value == null ){
                             socket!.destroy();
                             socket!.dispose();
                             getSocketData();
                           }

                         },
                         child: Container(
                           margin: const EdgeInsets.only(bottom: 10),
                           padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(15),
                             color: MyColor.darkGreyColor
                           ),
                           child: Row(
                             children: [

                               // coin token
                               ClipRRect(
                                 borderRadius: BorderRadius.circular(100),
                                 child: CachedNetworkImage(
                                   height: 45,
                                   width: 45,
                                   fit: BoxFit.fill,
                                   imageUrl:  list.logo,
                                   placeholder: (context, url) => const Center(
                                     child: CircularProgressIndicator(color: MyColor.greenColor),
                                   ),
                                   errorWidget: (context, url, error) =>
                                       Container(
                                             height: 45,
                                             width: 45,
                                             padding: const EdgeInsets.all(10),
                                             decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(14),
                                               color: MyColor.whiteColor,
                                             ),
                                             child: Image.asset(
                                               "assets/images/bitcoin.png",
                                             ),
                                           ),
                                 ),
                               ),

                               const SizedBox(width: 12),

                               // coin name and price and 24h
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       list.name,
                                       style: MyStyle.tx18RWhite.copyWith(
                                         fontSize: 16
                                       ),
                                     ),
                                     const SizedBox(height: 3),
                                     RichText(
                                         text: TextSpan(
                                             children: [
                                               TextSpan(
                                                 text: list.type.isNotEmpty ? "${list.type}\t" : "",
                                                 style: MyStyle.tx18RWhite.copyWith(
                                                     fontSize: 14,
                                                     color: MyColor.grey01Color
                                                 ),
                                               ),TextSpan(
                                                 text: "\$${ApiHandler.calculateLength("${list.price}")} ",
                                                 style: MyStyle.tx18RWhite.copyWith(
                                                     fontSize: 14,
                                                     color: MyColor.grey01Color
                                                 ),
                                               ),
                                               TextSpan(
                                                   text: "(${list.percentChange24H.toStringAsFixed(2)}%)" ,
                                                   style:MyStyle.tx28RGreen.copyWith(
                                                     fontSize: 12,
                                                     color: list.percentChange24H < 0
                                                         ?
                                                     MyColor.redColor
                                                         :
                                                     MyColor.greenColor
                                                   )
                                               ),
                                             ]
                                         )
                                     ),
                                   ],
                                 )
                               ),
                               const SizedBox(width: 10),

                               // balance and coin price
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.end,
                                 children: [
                                   Text(
                                     isCalculating == true
                                         ?
                                     "--"
                                         :
                                     list.balance == "0"
                                         ?
                                     "${double.parse(list.balance).toStringAsFixed(2)} ${list.symbol}"
                                         :
                                     "${ApiHandler.calculateLength3(list.balance)} ${list.symbol}",

                                     style: MyStyle.tx22RWhite.copyWith(
                                       fontSize: 15,
                                       color: MyColor.mainWhiteColor
                                     ),
                                   ),
                                   const SizedBox(height: 3),
                                   Text(
                                     "\$ ${tokenUsdPrice!.toStringAsFixed(2)}",
                                     style: MyStyle.tx18RWhite.copyWith(
                                         fontSize: 14,
                                         color: MyColor.grey01Color
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                       );
                     },
                   ),
                 ),
               ),
             )
          )
        ],
      ),
    );
  }

}
