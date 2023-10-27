import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Provider/Transection_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'QrScannerPage.dart';

// ignore: must_be_immutable
class SendCoinScreen extends StatefulWidget {

  String sendTokenAddress = "",
      sendTokenNetworkId = "",
      sendTokenName = "",
      sendTokenSymbol = "",
      selectTokenMarketId = "",
      sendTokenImage = "",
      sendTokenBalance = "",
      sendTokenId = "",
      sendTokenUsd = "";
  int sendTokenDecimals;


  SendCoinScreen({
    super.key,
    required this.sendTokenAddress,
    required this.sendTokenNetworkId,
    required this.sendTokenName,
    required this.sendTokenSymbol,
    required this.selectTokenMarketId,
    required this.sendTokenImage,
    required this.sendTokenBalance,
    required this.sendTokenId,
    required this.sendTokenUsd,
    required this.sendTokenDecimals,
  });

  @override
  State<SendCoinScreen> createState() => _SendCoinScreenState();
}

class _SendCoinScreenState extends State<SendCoinScreen> {

  TextEditingController toController = TextEditingController();


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
      // selectedAccountPrivateAddress = sharedPreferences.getString('accountPrivateAddress') ?? "";

    });

    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);


    await DbNetwork.dbNetwork.getNetwork();


    if(widget.sendTokenId != ""){
      sendTokenAddress = widget.sendTokenAddress;
      sendTokenNetworkId = widget.sendTokenNetworkId;
      sendTokenName = widget.sendTokenName;
      sendTokenSymbol = widget.sendTokenSymbol;
      selectTokenMarketId = widget.selectTokenMarketId;
      sendTokenImage  = widget.sendTokenImage;
      sendTokenBalance  = widget.sendTokenBalance;
      sendTokenId  = widget.sendTokenId;
      sendTokenUsd  = widget.sendTokenUsd;


      await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, sendTokenNetworkId);

      setState(() {
        selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
        selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
      });


    }else{

      List<AccountTokenList> listData = DBTokenProvider.dbTokenProvider.tokenList.where((element) => element.marketId == 1839).toList();

      sendTokenAddress = listData[0].address;
      sendTokenNetworkId = "${listData[0].networkId}";
      sendTokenName =  listData[0].name;
      sendTokenSymbol =  listData[0].symbol;
      selectTokenMarketId = "${listData[0].marketId}";
      sendTokenImage  = listData[0].logo;
      sendTokenBalance  = listData[0].balance;
      sendTokenId  = "${listData[0].token_id}";
      sendTokenUsd = "${listData[0].price}";
      sendTokenUsd = "${listData[0].price}";
      sendTokenDecimals = listData[0].decimals;

      await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,sendTokenNetworkId);

      setState(() {
        selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
        selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
      });

    }

    networkList = DbNetwork.dbNetwork.networkList.where((element) => "${element.id}" == sendTokenNetworkId).toList();

    setState(() {
      networkSymbol = networkList[0].symbol;
      isTxfees = networkList[0].isTxfees;
      fromAddressController = TextEditingController(text: selectedAccountAddress);
    });

  }

  late TransectionProvider transectionProvider;
  late TokenProvider tokenProvider;
  bool isLoading = false;


  @override
  void initState() {
    transectionProvider = Provider.of<TransectionProvider>(context, listen: false);
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
        sendNonce = body['nonce'];
        sendTransactionFee = "${body['transactionFee']}";

        double networkUsd = 0.0,tokenUsd = 0.0;



        tokenUsd = double.parse(sendTokenQuantity.text) * double.parse(widget.sendTokenUsd);
        networkUsd = double.parse(sendTransactionFee) * double.parse(widget.sendTokenUsd);


        totalSendValue = double.parse(sendTokenQuantity.text) + double.parse(sendTransactionFee);
        totalUsd = tokenUsd + networkUsd;

      });

      // ignore: use_build_context_synchronously
      confirmBottomSheet(context);
    }
    else{

      var data = DbNetwork.dbNetwork.networkList.where((element) => "${element.id}" == sendTokenNetworkId).toList();

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Insufficient ${data[0].symbol} balance please deposit some ${data[0].symbol}");
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
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
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
                                  imageUrl: "https://s2.coinmarketcap.com/static/img/coins/64x64/${widget.selectTokenMarketId}.png",
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
                                        '${sendTokenQuantity.text}   $sendTokenSymbol',
                                        style: MyStyle.tx18BWhite.copyWith(
                                            fontSize: 14
                                        ),
                                      ),
                                    ),

                                    Text(
                                      double.parse("${double.parse(sendTokenQuantity.text)*double.parse(sendTokenUsd)}").toStringAsFixed(2),
                                        style: MyStyle.tx18RWhite.copyWith(
                                            fontSize: 14
                                        )
                                    ),

                                    Text(
                                      "USD",
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

                                  Expanded(
                                    child: Text(
                                      "Network Fee",
                                      style:MyStyle.tx18BWhite.copyWith(
                                          fontSize: 14
                                      )
                                    ),
                                  ),

                                  Text(
                                    "${ApiHandler.calculateLength3(sendTransactionFee)}  $networkSymbol",
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 14
                                      )
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
                                      widget.sendTokenNetworkId == "9" ? double.parse("${double.parse(sendTokenQuantity.text)}").toStringAsFixed(4) : '${totalSendValue.toStringAsFixed(4)} ${networkSymbol}',
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 14
                                      )
                                  ),

                                ],
                              ),

                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                    widget.sendTokenNetworkId == "9" ? double.parse("${double.parse(sendTokenQuantity.text)*double.parse(widget.sendTokenUsd)}").toStringAsFixed(4) : '(${totalUsd.toStringAsFixed(2)} USD)',
                                    style: MyStyle.tx18RWhite.copyWith(
                                        fontSize: 14
                                    )
                                ),
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
                      const Center(
                        child: CircularProgressIndicator(color: MyColor.greenColor),
                      )
                          :
                      checkBox == false
                          ?
                      Center(
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
                      )
                          :
                      InkWell(
                        onTap: (){
                          setState((){});
                          confirmSend();
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
      "value": sendTokenQuantity.text,
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
        isLoading = false;

        sendGasPrice = "";
        sendGas = "";
        sendNonce = "";
        sendTransactionFee = "";

        // fromAddressController.clear();
        toController.clear();
        sendTokenQuantity.clear();

        // sendTokenAddress = "";
        // sendTokenNetworkId = "";
        // sendTokenName = "";
        // sendTokenSymbol = "";
        // selectTokenMarketId = "";
        // sendTokenImage = "";
        // sendTokenBalance = "";
        // sendTokenId = "";
        // sendTokenUsd = "";

      });

    }
    else {
      if (sendTokenNetworkId == "9" && transectionProvider.sendTokenData["status"] == false) {
        // ignore: use_build_context_synchronously
        Helper.dialogCall.showToast(context,"Insufficient fees balance");

      } else {

        // ignore: use_build_context_synchronously
        Helper.dialogCall.showToast(context, "Send token error");
      }

      setState(() {
        isLoading = false;
      });
    }
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

    return Scaffold(

      bottomNavigationBar:isLoading == true
          ?
      const SizedBox(
          height:52,
          child: Center(
              child: CircularProgressIndicator(
                color: MyColor.greenColor,
              )
          )
      )
          :
      isTxfees == 0
          ?
      InkWell(
        onTap: () {
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
            confirmBottomSheet(context);
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: 45,
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: MyStyle.buttonDecoration.copyWith(
              color: sendTokenId == ""
                  || sendTokenQuantity.text.isEmpty
                  || double.parse(sendTokenQuantity.text) == 0.0
                  || toController.text.isEmpty
                  || double.parse(sendTokenQuantity.text) == 0
                  || double.parse(sendTokenQuantity.text) < 0.00
                  || double.parse(sendTokenBalance) <  double.parse(sendTokenQuantity.text)
                  ?
              MyColor.boarderColor
                  :
              MyColor.greenColor
          ),
          child:  Text(
            "Next",
            style: MyStyle.tx18BWhite.copyWith(
                color: sendTokenId == ""
                    || sendTokenQuantity.text.isEmpty
                    || double.parse(sendTokenQuantity.text) == 0.0
                    || toController.text.isEmpty
                    || double.parse(sendTokenQuantity.text) == 0
                    || double.parse(sendTokenQuantity.text) < 0.00
                    || double.parse(sendTokenBalance) <  double.parse(sendTokenQuantity.text)
                    ?
                MyColor.mainWhiteColor.withOpacity(0.6)
                    :
                MyColor.mainWhiteColor
            ),
          ),
        ),
      )
          :
      InkWell(
        onTap: () {
          if(sendTokenId == ""
              || sendTokenQuantity.text.isEmpty
              || double.parse(sendTokenQuantity.text) == 0.0
              || double.parse(sendTokenQuantity.text) == 0
              || double.parse(sendTokenQuantity.text) < 0.00
              || double.parse(sendTokenBalance) <  double.parse(sendTokenQuantity.text)
                  || toController.text.isEmpty
          ){

            print("object");
          }else{
            FocusScope.of(context).unfocus();
            getNetworkFees();
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: 45,
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: MyStyle.buttonDecoration.copyWith(
              color: sendTokenId == ""
                  || sendTokenQuantity.text.isEmpty
                  || double.parse(sendTokenQuantity.text) == 0.0
                  || toController.text.isEmpty
                  || double.parse(sendTokenQuantity.text) == 0
                  || double.parse(sendTokenQuantity.text) < 0.00
                  || double.parse(sendTokenBalance) <  double.parse(sendTokenQuantity.text)
                  ?
              MyColor.boarderColor
                  :
               MyColor.greenColor
          ),
          child:  Text(
            "Next",
            style: MyStyle.tx18BWhite.copyWith(
                color: sendTokenId == ""
                    || sendTokenQuantity.text.isEmpty
                    || double.parse(sendTokenQuantity.text) == 0.0
                    || toController.text.isEmpty
                    || double.parse(sendTokenQuantity.text) == 0
                    || double.parse(sendTokenQuantity.text) < 0.00
                    || double.parse(sendTokenBalance) <  double.parse(sendTokenQuantity.text)
                    ?
                MyColor.mainWhiteColor.withOpacity(0.6)
                    :
                MyColor.mainWhiteColor
            ),
          ),
        ),
      ),

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
          "Sent ${widget.sendTokenSymbol}",
        ),
      ),

      body: SingleChildScrollView(
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
              controller: toController,
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              decoration: MyStyle.textInputDecoration2.copyWith(
                suffixIcon: SizedBox(
                  width: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {
                            FlutterClipboard.paste().then((value){
                                toController.text = value;
                            });
                          },
                          child: Center(
                            child: Text(
                              "Past",
                              textAlign: TextAlign.center,
                              style: MyStyle.tx18BWhite.copyWith(
                                  fontSize: 14,
                                  color: MyColor.greenColor
                              ),
                            ),
                          ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () async {
                          final value = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const QrScannerPage()
                              )
                          );

                          setState(() {
                            toController.text = value;
                          });
                        },
                        child: Image.asset(
                          "assets/images/dashboard/scan.png",
                          height: 25,
                          width: 25,
                          color: MyColor.greenColor,
                        ),
                      ),
                      const SizedBox(width: 8),

                    ],
                  ),
                )
              ),
            ),
            const SizedBox(height: 15),

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

            // Amount
            TextFormField(
              keyboardType: TextInputType.number,
              controller: sendTokenQuantity,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
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

                      double tokenBalance = (double.parse(sendTokenBalance) * 96) / 100;

                      //print(tokenBalance.toStringAsFixed(3));
                      setState(() {
                        sendTokenQuantity = TextEditingController(
                            text: tokenBalance.toStringAsFixed(3)
                        );
                      });
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


            //Available Balance
            Text(
              "Available: ${ApiHandler.calculateLength("${double.parse(sendTokenBalance) }")} $sendTokenSymbol",
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
