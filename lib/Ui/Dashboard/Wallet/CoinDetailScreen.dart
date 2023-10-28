import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Provider/Transection_Provider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ExchangeCoin/ExchangeScreen.dart';
import 'ReceiveToken/ReceiveScreen.dart';
import 'SendToken/SendCoinScreen.dart';


// ignore: must_be_immutable
class CoinDetailScreen extends StatefulWidget {

  String selectedAccountAddress,tokenId,tokenNetworkId,tokenAddress,tokenName,token_transection_Id,
      tokenSymbol,tokenBalance,tokenImage,tokenType,tokenMarketId,tokenDecimal,explorerUrl;
  double tokenUsdPrice,tokenUpDown,tokenFullPrice;

  CoinDetailScreen({
    super.key,
    required this.selectedAccountAddress,
    required this.tokenId,
    required this.token_transection_Id,
    required this.tokenNetworkId,
    required this.tokenAddress,
    required this.tokenName,
    required this.tokenImage,
    required this.tokenDecimal,
    required this.tokenType,
    required this.tokenSymbol,
    required this.tokenBalance,
    required this.tokenUsdPrice,
    required this.tokenUpDown,
    required this.tokenFullPrice,
    required this.tokenMarketId,
    required this.explorerUrl,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {

  showReceiveScreen(BuildContext context){
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
            child: ReceiveScreen(
              networkId: int.parse(widget.tokenNetworkId),
              tokenName: widget.tokenName,
              tokenSymbol: widget.tokenSymbol,
            )
        );
      },
    );
  }


  late TransectionProvider transectionProvider;

  String tokenId = "",tokenName = "",tokenNatewokrkId = "",
      tokenSymbol = "",tokenImage = "",tokenUsd = "",
      tokenBalance = "",tokenMarketId = "",sendTokenType = "";

  late TokenProvider tokenProvider;
  List<NetworkList> networkList = [];

  @override
  void initState() {
    super.initState();
    transectionProvider = Provider.of<TransectionProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    transectionProvider.transectionList.clear();

    tokenId = widget.tokenId;
    tokenNatewokrkId = widget.tokenNetworkId;
    tokenName = widget.tokenName;
    tokenSymbol = widget.tokenSymbol;
    tokenImage = widget.tokenImage;
    tokenBalance = widget.tokenBalance;
    sendTokenType = widget.tokenType;
    tokenUsd = "${widget.tokenUsdPrice}";

    getNetWork();

  }


  getNetWork() async {
    await DbNetwork.dbNetwork.getNetwork();
    networkList = DbNetwork.dbNetwork.networkList.where((element) {
      return "${element.id}" == widget.tokenNetworkId;
    }).toList();

    setState(() {});
    getTransection();
    getCustomTokenBalance();
  }

  getTransection() async {

    var data = {
      "network_id": widget.tokenNetworkId,
      "token_id":widget.token_transection_Id,
      "tokenDecimal": widget.tokenDecimal,
      "tokenAddress":widget.tokenAddress,
      "address":widget.selectedAccountAddress,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "network_name":networkList.first.name,
      "explorer_url":networkList.first.explorerUrl,
      "symbol":networkList.first.symbol
    };
    // print(json.encode(data));
    await transectionProvider.getTransection(data,'/getTransactions');
    //print(transectionProvider.transectionList.length);
    setState(() {
      _showRefresh = false;
    });
  }

  getCustomTokenBalance() async {

    var data = {
      "tokenAddress":widget.tokenAddress,
      "address":widget.selectedAccountAddress,
      "network_id":tokenNatewokrkId,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "network_name":networkList.first.name,
    };


    await tokenProvider.getTokenBalance(data,'/getTokenBalance');
    var body = tokenProvider.tokenBalance;
    if(body != null){

      var getPrice = await DBTokenProvider.dbTokenProvider.getTokenUsdPrice(tokenId);
      setState((){

        tokenBalance = "${body['data']['balance']}";
        tokenUsd = "${double.parse(tokenBalance) * getPrice[0]['price']}";
      });
    }

  }

  bool _showRefresh = false;
  Future<void> _getData() async {
    setState(() {
      _showRefresh = true;
    });

    transectionProvider.transectionList.clear();
    getTransection();
    getCustomTokenBalance();

  }


  @override
  Widget build(BuildContext context) {
    final dashProvider = Provider.of<DashboardProvider>(context);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return  Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.darkGreyColor,
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // coin details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: MyColor.darkGreyColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 5),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.tokenName,
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 18,
                            color: MyColor.grey01Color
                        ),
                      ),
                    ),
                    Text(
                      "\$${widget.tokenFullPrice.toStringAsFixed(2)} ",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 14,
                      ),
                    ),
                    Text(
                      "(${widget.tokenUpDown.toStringAsFixed(2)})",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 14,
                          color:widget.tokenUpDown < 0 ? MyColor.redColor :  MyColor.greenColor
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: MyColor.darkGrey01Color,
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    height: 45,
                    width: 45,
                    fit: BoxFit.fill,
                    imageUrl: "https://s2.coinmarketcap.com/static/img/coins/64x64/${widget.tokenMarketId}.png",
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
                const SizedBox(height: 18),

                Text(
                  "${ApiHandler.calculateLength(tokenUsd)} USD",
                  style: MyStyle.tx22RWhite.copyWith(
                    fontSize: 28,
                  ),
                ),

                Text(
                  tokenBalance == "0" ? "0 $tokenSymbol" : "${double.parse(ApiHandler.calculateLength(tokenBalance))} $tokenSymbol",
                  style: MyStyle.tx22RWhite.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // send
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SendCoinScreen(
                                sendTokenAddress: widget.tokenAddress,
                                sendTokenNetworkId: widget.tokenNetworkId,
                                sendTokenName: widget.tokenName,
                                sendTokenSymbol: widget.tokenSymbol,
                                selectTokenMarketId: widget.tokenMarketId,
                                sendTokenImage : widget.tokenImage,
                                sendTokenBalance : widget.tokenBalance,
                                sendTokenId : widget.tokenId,
                                sendTokenUsd : "${widget.tokenFullPrice}",
                                sendTokenDecimals:int.parse(widget.tokenDecimal)
                            ),
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
                              "assets/images/dashboard/send.png",
                              height: 18,
                              width: 18,
                              color: MyColor.greenColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Send",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 14,
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
                        showReceiveScreen(context);
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
                          const SizedBox(height: 5),
                          Text(
                            "Receive",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 14,
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
                        Navigator.pop(context);
                        dashProvider.changeBottomIndex(2);
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
                          const SizedBox(height: 5),
                          Text(
                            "Withdraw",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 14,
                                color: MyColor.whiteColor
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    //Exchange
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExchangeScreen(),
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
                          const SizedBox(height: 5),
                          Text(
                            "Exchange",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 14,
                                color: MyColor.whiteColor
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          const SizedBox(height: 30),

          //Activity
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Activity",
                style: MyStyle.tx28BYellow.copyWith(
                  color: MyColor.whiteColor,
                  fontSize: 18
                ),
              ),
            ),
          ),

          // Transactions list
          Expanded(
            child: DeclarativeRefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              color: MyColor.greenColor,
              backgroundColor: MyColor.mainWhiteColor,
              onRefresh: _getData,
              refreshing: _showRefresh,
              child: transectionProvider.isLoading == true && !_showRefresh
                    ?
                const Center(
                  child: CircularProgressIndicator(
                    color: MyColor.greenColor,
                  ),
                )
                    :
                transectionProvider.transectionList.isEmpty
                    ?
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: height * 0.45,
                    width: width,
                    child: Center(
                      child: Text(
                        "No Transaction Yet.",
                        textAlign: TextAlign.center,
                        style: MyStyle.tx18RWhite.copyWith(
                            color: MyColor.grey01Color
                        ),
                      ),
                    ),
                  ),
                )
                    :
                Padding(
                  padding: const EdgeInsets.only(top:12),
                  child: ListView.builder(
                    itemCount: transectionProvider.transectionList.length,
                    padding: const EdgeInsets.fromLTRB(12,10,12,10),
                    itemBuilder: (context, index) {

                      var transectionDetails = transectionProvider.transectionList[index];

                      DateTime time =
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(transectionDetails.timeStamp) * 1000);

                      String formattedDate = DateFormat('MMM dd, yyyy').format(time);
                      String formattedTime = DateFormat('hh:mm aa').format(time);


                      return InkWell(
                        onTap: () {
                          launchUrl(
                            Uri.parse(transectionProvider.transectionList[index].explorerUrl)
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: MyColor.darkGreyColor
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Transactions type icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: MyColor.darkGrey01Color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      transectionProvider.transectionList[index].from.toLowerCase() == widget.selectedAccountAddress.toLowerCase()
                                          ?
                                      "assets/images/dashboard/send.png"
                                          :
                                      "assets/images/dashboard/receive.png",
                                      height: 17,
                                      width: 17,
                                      fit: BoxFit.contain,
                                      color: MyColor.greenColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // coin name text
                                  Expanded(
                                      child: Text(
                                        widget.tokenName,
                                        style: MyStyle.tx18RWhite,
                                      )
                                  ),
                                  const SizedBox(width: 10),

                                  // receive text
                                  Text(
                                    "${ApiHandler.calculateLength("${transectionProvider.transectionList[index].value}")} ${widget.tokenSymbol}",
                                    style: MyStyle.tx22RWhite.copyWith(
                                        fontSize: 16,
                                        color:  transectionProvider.transectionList[index].from.toLowerCase() == widget.selectedAccountAddress.toLowerCase()
                                            ?
                                        MyColor.redColor
                                            :
                                        MyColor.greenColor
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Date: ",
                                                  style:MyStyle.tx18RWhite.copyWith(
                                                      fontSize: 14,
                                                      color: MyColor.grey01Color
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: formattedDate,
                                                  style:MyStyle.tx18RWhite.copyWith(
                                                      fontSize: 14,
                                                      color: MyColor.grey01Color
                                                  ),
                                                )
                                              ]
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Time: ",
                                                  style:MyStyle.tx18RWhite.copyWith(
                                                      fontSize: 14,
                                                      color: MyColor.grey01Color
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: formattedTime,
                                                  style:MyStyle.tx18RWhite.copyWith(
                                                      fontSize: 14,
                                                      color: MyColor.grey01Color
                                                  ),
                                                )
                                              ]
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "\$ ${ApiHandler.calculateLength("${(widget.tokenFullPrice * transectionProvider.transectionList[index].value)}")} ",

                                        style: MyStyle.tx18RWhite.copyWith(
                                            fontSize: 15,
                                            color: MyColor.grey01Color
                                        ),
                                      ),
                                      RichText(
                                        textAlign: TextAlign.end,
                                        text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Status: ",
                                                style:MyStyle.tx18RWhite.copyWith(
                                                    fontSize: 14,
                                                    color: MyColor.grey01Color
                                                ),
                                              ),
                                              TextSpan(
                                                text: transectionProvider.transectionList[index].status,
                                                style:MyStyle.tx18RWhite.copyWith(
                                                    fontSize: 14,
                                                    color:transectionProvider.transectionList[index].status == "Success" ? MyColor.greenColor: MyColor.redColor

                                                ),
                                              )
                                            ]
                                        ),
                                      ),
                                    ],
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
          ),

        ],
      ),
    );
  }
}
