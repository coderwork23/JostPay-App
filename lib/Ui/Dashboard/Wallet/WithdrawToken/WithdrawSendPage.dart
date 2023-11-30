import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Provider/Transection_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WithdrawToken/WithdrawSuccessful.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';


// ignore: must_be_immutable
class WithdrawSendPage extends StatefulWidget {

  String sendTokenAddress = "",
      sendTokenNetworkId = "",
      sendTokenName = "",
      sendTokenSymbol = "",
      selectTokenMarketId = "",
      tokenUpDown = "",
      sendTokenImage = "",
      selectTokenUSD = "",
      sendTokenBalance = "",
      sendTokenId = "",
      explorerUrl = "",
      sellInvoice = "",
      sendTokenUsd = "";
  int sendTokenDecimals;
  var params,sellResponce;

  WithdrawSendPage({
    super.key,
    required this.sendTokenAddress,
    required this.sellInvoice,
    required this.sendTokenNetworkId,
    required this.sendTokenName,
    required this.sendTokenSymbol,
    required this.selectTokenMarketId,
    required this.tokenUpDown,
    required this.sendTokenImage,
    required this.sendTokenBalance,
    required this.selectTokenUSD,
    required this.params,
    required this.sellResponce,
    required this.sendTokenId,
    required this.explorerUrl,
    required this.sendTokenUsd,
    required this.sendTokenDecimals,
  });

  @override
  State<WithdrawSendPage> createState() => _WithdrawSendPageState();
}

class _WithdrawSendPageState extends State<WithdrawSendPage> {
  TextEditingController toController = TextEditingController();
  late BuySellProvider buySellProvider;


  GlobalKey<FormState> formKey = GlobalKey();
  List<NetworkList> networkList = [];
  bool isLoaded = false,checkBox = false;

  late String deviceId;
  String selectedAccountId = "",
      selectedAccountName = "",
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "";


  String sendTokenAddress = "",
      sendTokenNetworkId = "",
      sendTokenName = "",
      sendTokenSymbol = "",
      selectTokenMarketId = "",
      sendTokenImage = "",
      tokenUpDown = "",
      selectTokenUSD = "",
      explorerUrl = "",
      sendTokenBalance = "0",
      sendTokenId = "",
      sendTokenUsd = "0",
      tokenType = ""; int sendTokenDecimals = 0;

  String networkSymbol = "";
  int? isTxfees;

  TextEditingController fromAddressController = TextEditingController();
  TextEditingController sendTokenQuantity = TextEditingController();


  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isLoaded = false;
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });

    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);
    await DbNetwork.dbNetwork.getNetwork();

    setState(() {
      sendTokenName = widget.sendTokenName;
      sendTokenAddress = widget.sendTokenAddress;
      sendTokenNetworkId = widget.sendTokenNetworkId;
      sendTokenSymbol = widget.sendTokenSymbol;
      selectTokenMarketId = widget.selectTokenMarketId;
      sendTokenImage  = widget.sendTokenImage;
      tokenUpDown  = widget.tokenUpDown;
      sendTokenBalance  = widget.sendTokenBalance;
      sendTokenId  = widget.sendTokenId;
      sendTokenUsd  = widget.sendTokenUsd;
      explorerUrl  = widget.explorerUrl;
      selectTokenUSD  = widget.selectTokenUSD;
      sendTokenDecimals = widget.sendTokenDecimals;
    });


    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, sendTokenNetworkId);

    setState(() {
      selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
    });




    networkList = DbNetwork.dbNetwork.networkList.where((element) => "${element.id}" == sendTokenNetworkId).toList();
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,networkList[0].id);

    setState(() {
      fromAddressController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      networkSymbol = networkList[0].symbol;
      isTxfees = networkList[0].isTxfees;
      toController = TextEditingController(text: widget.sellResponce['payin_address']);
      // print("payin_amount ${widget.sellResponce['payin_amount']}");
      sendTokenQuantity.text = widget.sellResponce['payin_amount'].toString().split(" ").first;
    });

    if(isTxfees == 0){

      if(sendTokenId == ""
          || sendTokenQuantity.text.isEmpty
          || double.parse(sendTokenQuantity.text) == 0.0
          || toController.text.isEmpty
          || double.parse(sendTokenQuantity.text) == 0
          || double.parse(sendTokenQuantity.text) < 0.00
          || double.parse(sendTokenBalance) <  double.parse(sendTokenQuantity.text)
      ){

      }else{
        FocusScope.of(context).unfocus();
        getNetworkFees();
      }

    }else{
      if(sendTokenId == ""
          || sendTokenQuantity.text.isEmpty
          || double.parse(sendTokenQuantity.text) == 0.0
          || double.parse(sendTokenQuantity.text) == 0
          || double.parse(sendTokenQuantity.text) < 0.00
          || double.parse(sendTokenBalance) <  double.parse(sendTokenQuantity.text)
          || toController.text.isEmpty
      ){

        // print("object");
      }else{
        FocusScope.of(context).unfocus();
        getNetworkFees();
      }

    }

  }

  late TransectionProvider transectionProvider;
  late TokenProvider tokenProvider;
  bool isLoading = false;


  @override
  void initState() {
    transectionProvider = Provider.of<TransectionProvider>(context, listen: false);
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    super.initState();
    selectedAccount();
  }





  String sendGasPrice = "";
  String sendGas = "";
  String? sendNonce = "";
  String sendTransactionFee = "0";
  double totalUsd = 0.0;
  double totalSendValue = 0.0;

  bool isGetQuote = false;

  getNetworkFees() async {

    setState((){
      isLoading = true;
    });

    var data = {

      "network_id": sendTokenNetworkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": toController.text,
      "token_id": sendTokenId,
      "value": sendTokenQuantity.text,
      "gasPrice": "",
      "gas":"",
      "nonce": 0,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "tokenAddress":sendTokenAddress,
      "decimals":sendTokenDecimals
    };

    // print(json.encode(data));

    await transectionProvider.getNetworkFees(data,'/getNetrowkFees',context);

    if( transectionProvider.isSuccess == true){

      var body = transectionProvider.networkData;

      setState(() {
        isGetQuote = true;
        isLoading = false;

        sendGasPrice = "${body['gasPrice']}";
        sendGas = "${body['gas']}";
        sendNonce = "${body['nonce']}";
        sendTransactionFee = "${body['transactionFee']}";

        double networkUsd = 0.0,tokenUsd = 0.0;



        tokenUsd = double.parse(sendTokenQuantity.text) * double.parse(widget.sendTokenUsd);
        networkUsd = double.parse(sendTransactionFee) * double.parse(widget.sendTokenUsd);

        var tokenPrice = DBTokenProvider.dbTokenProvider.tokenList.where((element) {
          return "${element.networkId}" == sendTokenNetworkId && element.type == "";
        }).first.price;

        if(sendTokenAddress != "") {
          totalSendValue = double.parse(sendTokenQuantity.text);
          totalUsd = tokenUsd + double.parse(sendTransactionFee) * tokenPrice;

        }else{
          totalSendValue = double.parse(sendTokenQuantity.text) + double.parse(sendTransactionFee);
          totalUsd = tokenUsd + networkUsd;
        }




      });

      // ignore: use_build_context_synchronously
      confirmBottomSheet(context);
    }
    else{

      var data = DbNetwork.dbNetwork.networkList.where((element) => "${element.id}" == sendTokenNetworkId).toList();

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Insufficient balance to cover fees, reduce withdraw amount");
      setState((){
        isLoading = false;
      });
    }

  }

  confirmBottomSheet(BuildContext context) {

    showModalBottomSheet(
        isScrollControlled:true,
        backgroundColor: MyColor.backgroundColor,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        builder: (context) {
          List<AccountTokenList> tokenBalance = DBTokenProvider.dbTokenProvider.tokenList.where((element) {
            return "${element.networkId}" == sendTokenNetworkId && element.type == "";
          }).toList();
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                // print("object $sendTransactionFee");
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.only(left: 20,right: 20,top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [


                      const SizedBox(height: 10),
                      // dos icon
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColor.lightGreyColor
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Padding(
                        padding: EdgeInsets.only(left: 5,bottom: 10),
                        child: Text(
                            "Asset",
                            style : MyStyle.tx18BWhite
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                            color: MyColor.darkGrey01Color,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [

                              const SizedBox(width: 10),


                              ClipRRect(
                                borderRadius: BorderRadius.circular(300),
                                child: CachedNetworkImage(
                                  width: 40,height: 40,
                                  fit: BoxFit.fill,
                                  imageUrl: sendTokenImage,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(color: MyColor.greenColor),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset("assets/images/bitcoin.png",
                                          width: 40,
                                          height: 40
                                      ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                    sendTokenName,
                                    style: MyStyle.tx18BWhite
                                ),
                              ),

                              const SizedBox(width: 12),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                            color: MyColor.darkGrey01Color,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                    "From address",
                                    style: MyStyle.tx18BWhite.copyWith(
                                        fontSize: 16
                                    )
                                ),
                              ),
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  fromAddressController.text,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 14
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                    "To address",
                                    style: MyStyle.tx18BWhite.copyWith(
                                        fontSize: 16
                                    )
                                ),
                              ),
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  toController.text,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 14
                                  ),
                                ),
                              ),


                              const SizedBox(height: 15),

                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                    "Token quantity",
                                    style: MyStyle.tx18BWhite.copyWith(
                                        fontSize: 14
                                    )
                                ),
                              ),

                              const SizedBox(height: 6),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: Text(
                                        '${ApiHandler.showFiveBalance(sendTokenQuantity.text)} $sendTokenSymbol',
                                        style: MyStyle.tx18BWhite.copyWith(
                                            fontSize: 14
                                        ),
                                      ),
                                    ),

                                    Text(
                                        double.parse("${double.parse(sendTokenQuantity.text)*double.parse(sendTokenUsd)}").toStringAsFixed(3),
                                        style: MyStyle.tx18RWhite.copyWith(
                                            fontSize: 14
                                        )
                                    ),

                                    Text(
                                        " USD",
                                        style: MyStyle.tx18RWhite.copyWith(
                                            fontSize: 14
                                        )
                                    ),

                                  ],
                                ),
                              ),


                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                            color: MyColor.darkGrey01Color,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Row(
                                children: [

                                  Text(
                                      "Network Fee",
                                      style:MyStyle.tx18BWhite.copyWith(
                                          fontSize: 14
                                      )
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                          "${ApiHandler.showFiveBalance(sendTransactionFee)} $networkSymbol (~\$ ${(double.parse(sendTransactionFee) * tokenBalance[0].price).toStringAsFixed(3)})",
                                          textAlign: TextAlign.end,
                                          style: MyStyle.tx18RWhite.copyWith(
                                              fontSize: 14
                                          )
                                      ),
                                    ),
                                  ),

                                ],
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [

                                  Expanded(
                                    child: Text(
                                        "Max total",
                                        style: MyStyle.tx18BWhite.copyWith(
                                            fontSize: 14
                                        )
                                    ),
                                  ),

                                  Text(
                                      '\$ ${totalUsd.toStringAsFixed(3)} USD',
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 14
                                      )
                                  ),
                                ],
                              ),


                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: MyColor.greenColor.withOpacity(0.5),
                            ),
                            child: Checkbox(
                              checkColor: MyColor.whiteColor,
                              activeColor: MyColor.greenColor,
                              value: checkBox,
                              onChanged: (value) {

                                setState(() {
                                  checkBox = value!;
                                });

                              },
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "I understand all the risk",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 14
                                ),
                              ),

                              Row(
                                children: [
                                  Text(
                                    "I agree to the",
                                    style: MyStyle.tx18RWhite.copyWith(
                                        fontSize: 14
                                    ),
                                  ),
                                  Text(
                                    "Terms and Conditions",
                                    style: MyStyle.tx18RWhite.copyWith(
                                        fontSize: 14
                                    ),
                                  )],
                              ),

                            ],
                          )

                        ],
                      ),

                      const SizedBox(height: 30),

                      isLoading == true
                          ?
                      Helper.dialogCall.showLoader()
                          :
                      checkBox == false || (sendTokenAddress == "" && totalSendValue > double.parse(sendTokenBalance))
                          || double.parse(tokenBalance[0].balance) < double.parse(sendTransactionFee)
                          ?
                      Center(
                        child: InkWell(
                          onTap: () {
                            if((sendTokenAddress == "" && totalSendValue > double.parse(sendTokenBalance))
                                || double.parse(tokenBalance[0].balance) < double.parse(sendTransactionFee)){
                              Helper.dialogCall.showToast(context, "Insufficient balance to cover fees, reduce withdraw amount");
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width-180,
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: MyColor.greenColor.withOpacity(0.23)
                            ),
                            child: const Center(
                              child: Text(
                                  "Confirm send",
                                  style: MyStyle.tx18RWhite
                              ),
                            ),
                          ),
                        ),
                      )
                          :
                      InkWell(
                        onTap: () async {
                          // print("check confirmSend ");
                          setState((){
                            isLoading = true;
                          });
                          await confirmSend();
                          setState((){});
                        },
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width-180,
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: MyColor.greenColor
                            ),
                            child: const Center(
                              child: Text(
                                  "Confirm send",
                                  style: MyStyle.tx18RWhite
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),


                    ],
                  ),
                );
              }
          );
        }).whenComplete(() {

      setState(() {
        checkBox = false;
      });

    });
  }

  confirmSend() async {

    setState((){
      isLoading = true;
    });


    var data = {
      "network_id": sendTokenNetworkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": toController.text,
      "token_id": sendTokenId,
      "value": sendTokenNetworkId != "9" ? sendTokenQuantity.text : double.parse(sendTokenQuantity.text).toStringAsFixed(3),
      "gasPrice": sendGasPrice,
      "gas": sendGas,
      "nonce": sendNonce,
      "networkFee": sendTransactionFee,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "tokenAddress":sendTokenAddress,
      "decimals":sendTokenDecimals
    };

    // print(jsonEncode(data));
    await transectionProvider.sendToken(data,'/sendAssets');
    if( transectionProvider.isSend == true){

      // ignore: use_build_context_synchronously
      Navigator.pop(context,"refresh");

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Send Token Successfully Done");


      setState((){

        sendGasPrice = "";
        sendGas = "";
        sendNonce = "";
        sendTransactionFee = "0";

        // fromAddressController.clear();
        toController.clear();
        sendTokenQuantity.text = "0";

        notifyOrder(context);

      });
    }

    //unfair pact message plastic lunch drama comfort faint start board black job
    else {
      if (sendTokenNetworkId == "9" && transectionProvider.sendTokenData["status"] == false) {
        // ignore: use_build_context_synchronously
        Helper.dialogCall.showToast(context, "Insufficient ${networkList[0].symbol} balance please deposit some ${networkList[0].symbol}");
        setState(() {
          isLoading = false;
        });
      } else {

        // ignore: use_build_context_synchronously
        Helper.dialogCall.showToast(context, "Send token error");
      }

      setState(() {
        isLoading = false;
      });
    }

  }

  notifyOrder(context)async{

    var params = {
      "action":"notify_payment_made",
      "email":widget.params['email'],
      "invoice":widget.sellInvoice.toString(),
      "auth":"p1~\$*)Ze(@"
    };

    await buySellProvider.notifyOrder(params, context,"");

    if(buySellProvider.placeNotifyOrder) {

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WithdrawSuccessful(
                  invoice: widget.sellInvoice,
                  tokenName: sendTokenName,
                ),
          )
      );

    }

    setState(() {
      isLoading = false;
    });
  }

  Web3Client? _web3client;
  getWeb3NetWorkFees()async{

    setState((){
      isLoading = true;
    });

    _web3client = Web3Client(
      networkList[0].url,
      http.Client(),
    );

    // print(rpcUrl);

    setState((){
      isLoading = true;
    });


    //print(EtherAmount.inWei(BigInt.from(1)));

    var estimateGas = await _web3client!.estimateGas(
        sender:EthereumAddress.fromHex(fromAddressController.text),
        to: EthereumAddress.fromHex(toController.text),
        value: EtherAmount.inWei(BigInt.from(double.parse(sendTokenBalance)))
    );
    var getGasPrice = await _web3client!.getGasPrice();

    //print("estimateGas === > ${"${estimateGas}"}");
    //print("getGasPrice === > ${"${getGasPrice.getInWei}"}");

    var value = BigInt.from(double.parse("$estimateGas") *  double.parse("${getGasPrice.getInWei}")) / BigInt.from(10).pow(18);
    //print(value);

    double tokenBalance = double.parse(double.parse(sendTokenBalance).toStringAsFixed(4)) - (value * 2);

    //print(tokenBalance);


    if(tokenBalance > 0){
      setState((){
        sendTokenQuantity = TextEditingController(text: "$tokenBalance");
        isLoading = false;
      });
    }else{
      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Insufficient ${networkList[0].symbol} balance please deposit some ${networkList[0].symbol}");
    }

    setState((){
      isLoading = false;
    });

  }


  @override
  Widget build(BuildContext context) {

    transectionProvider = Provider.of<TransectionProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    // print(networkList[0].isEVM);
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
          "Send ${widget.sendTokenSymbol}",
        ),
      ),

      body: isLoading == true
          ?
      Helper.dialogCall.showLoader()
          :
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),


            // to address
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Recipient Address",
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 16
                ),
              ),
            ),
            const SizedBox(height: 8),


            TextFormField(
              readOnly: true,
              controller: toController,
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              onChanged: (value) {
                setState(() {});
              },
              decoration: MyStyle.textInputDecoration2,
            ),
            const SizedBox(height: 15),

            //Amount text or Available Balance
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Amount",
                    style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(

                      sendTokenBalance == "0"
                          ?
                      "Available: 0.0 $sendTokenSymbol"
                          :
                      "Available: ${ApiHandler.showFiveBalance(sendTokenBalance)} $sendTokenSymbol",
                      style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 14,
                          color: MyColor.grey01Color
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),


            // Amount
            TextFormField(
              readOnly: true,
              keyboardType: TextInputType.number,
              controller: sendTokenQuantity,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
              onChanged: (value) {
                setState(() {});
              },
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              decoration: MyStyle.textInputDecoration2.copyWith(
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                  suffixIcon: InkWell(
                    onTap: () {
                      if(networkList[0].isEVM == 1){

                        if(toController.text != "") {
                          setState((){
                            FocusScope.of(context).unfocus();
                            // maxButtonCall = true;
                          });
                          // addressValidator();
                          getWeb3NetWorkFees();
                        }
                        else{
                          setState(() {
                            isLoading = false;
                          });
                        }

                      }
                      else {

                        // print(sendTokenAddress);
                        if(sendTokenAddress == "") {
                          double tokenBalance = (double.parse(sendTokenBalance) * 96) / 100;

                          //print(tokenBalance.toStringAsFixed(3));
                          setState(() {
                            sendTokenQuantity = TextEditingController(
                                text: tokenBalance.toStringAsFixed(6)
                            );
                          });
                        }else{
                          // print("object");
                          setState(() {
                            sendTokenQuantity.text = sendTokenBalance;
                          });
                        }
                      }
                    },
                    child: SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          "Max",
                          textAlign: TextAlign.center,
                          style: MyStyle.tx18BWhite.copyWith(
                              fontSize: 14,
                              color: MyColor.greenColor
                          ),
                        ),
                      ),
                    ),
                  )
              ),


            ),
            const SizedBox(height: 8),

            // usd amount
            Text(
              "= ${(double.parse(sendTokenQuantity.text.isNotEmpty ?sendTokenQuantity.text : "0") * double.parse(sendTokenUsd)).toStringAsFixed(2)} \$",
              style:MyStyle.tx18RWhite.copyWith(
                  fontSize: 14,
                  color: MyColor.grey01Color
              ),
            ),

            // const SizedBox(height: 30),
          ],
        ),
      ),

    );
  }

}
