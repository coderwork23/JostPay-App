import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/Provider/ExchangeProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Values/utils.dart';
import 'ExChangeTokenList.dart';
import 'ExchangeAddressScreen.dart';
import 'ExchangeHistory.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {

  TextEditingController sendCoinController = TextEditingController();
  late ExchangeProvider exchangeProvider;
  var selectedAccountId = "",sendError ="";
  bool showSendError = false;


  // get token list
  getExToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await exchangeProvider.getTokenList("/v1/currencies");
  }

  // get receive token animate amount
  estimateExchangeAmount()async{
    String sendSymbol = exchangeProvider.sendCoin.symbol.toLowerCase();
    String receiveSymbol = exchangeProvider.receiveCoin.symbol.toLowerCase();
    var data = {
      "api_key":Utils.apiKey
    };
    await exchangeProvider.estimateExchangeAmount("v1/exchange-amount/fixed-rate/${sendCoinController.text.trim()}/${sendSymbol}_$receiveSymbol",data);
  }

  // swap UpDown methods
  swapUpDown(){
    var tempSend = exchangeProvider.sendCoin;
    var tempReceive = exchangeProvider.receiveCoin;

    exchangeProvider.changeReceiveToken(tempSend, context, selectedAccountId);
    exchangeProvider.changeSendToken(tempReceive, context, selectedAccountId);

    estimateExchangeAmount();
  }

  @override
  void initState() {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: false);
    exchangeProvider.getCoinController.clear();
    super.initState();
    Future.delayed(Duration.zero,(){
      getExToken();
    });
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: true);

    return Scaffold(
      bottomNavigationBar: exchangeProvider.isLoading || exchangeProvider.exRateLoading || exchangeProvider.estimateLoading
          ?
      Visibility(
        visible: exchangeProvider.exRateLoading,
        child: SizedBox(
          height: 55,
          child: Helper.dialogCall.showLoader(),
        ),
      )
            :
      InkWell(
        onTap: () {
          if(showSendError || exchangeProvider.getCoinController.text.isEmpty || sendCoinController.text.isEmpty){
            Helper.dialogCall.showToast(context, "Please provide all details");
          }else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExchangeAddressScreen(
                        sendAmount: sendCoinController.text.trim(),
                      ),
                )
            );
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: 45,
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: showSendError || exchangeProvider.getCoinController.text.isEmpty ? MyStyle.invalidDecoration : MyStyle.buttonDecoration,
          child:  Text(
            "Continue",
            style: MyStyle.tx18BWhite.copyWith(
                color: showSendError || exchangeProvider.getCoinController.text.isEmpty ? MyColor.dotBoarderColor : MyColor.mainWhiteColor,
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
        title: const Text(
          "Exchange",
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExchangeHistory(),
                  )
                );
              },
              icon: const Icon(
                Icons.history,
                color: MyColor.mainWhiteColor,
              )
          )
        ],
      ),

      body:exchangeProvider.isLoading || exchangeProvider.exRateLoading
          ?
      Helper.dialogCall.showLoader()
          :
      SingleChildScrollView(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // send coin details
            Container(
              height: 80,
              width: width,
              decoration: BoxDecoration(
                color:MyColor.blackColor,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [

                  // text filed and title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Text(
                            "You send ${exchangeProvider.sendCoin.name.split(" ").first} ${exchangeProvider.sendCoin.type}",
                            style:MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: MyColor.grey01Color
                            ),
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if(double.parse(value) < exchangeProvider.minAmount){
                              setState(() {
                                showSendError = true;
                                sendError = "Amount must be more then ${exchangeProvider.minAmount}";
                              });
                            }else if(exchangeProvider.maxAmount!=-1 && double.parse(value) > exchangeProvider.maxAmount){
                              setState(() {
                                showSendError = true;
                                sendError = "Amount must be less then ${exchangeProvider.maxAmount}";
                              });
                            }else{
                              setState(() {
                                showSendError = false;
                                sendError = "";
                              });
                              estimateExchangeAmount();

                            }
                          },
                          controller: sendCoinController,
                          cursorColor: MyColor.greenColor,
                          style: MyStyle.tx18RWhite,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                            ],
                          decoration: InputDecoration(
                              hintText: "0.0",
                              border: InputBorder.none,
                              hintStyle:MyStyle.tx22RWhite.copyWith(
                                  fontSize: 18,
                                  color: MyColor.whiteColor.withOpacity(0.7)
                              ),
                              errorStyle: const TextStyle(fontSize: 0,height: 0),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                          )
                        )
                      ],
                    ),
                  ),


                  const SizedBox(width: 8),
                  const VerticalDivider(
                    thickness: 1.5,
                    color: MyColor.backgroundColor,
                  ),
                  const SizedBox(width: 8),

                  // coin images and name
                  SizedBox(
                    width: width * 0.3,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExChangeTokenList(
                              pageType: "send"
                            ),
                          )
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Row(
                          children: [
                            exchangeProvider.sendCoin.symbol == "usdtbsc" || exchangeProvider.sendCoin.symbol == "usdttrc20"
                                ?
                            Image.asset(
                              exchangeProvider.sendCoin.symbol == "usdtbsc"
                                  ?
                              "assets/images/bsc_usdt.png"
                                  :
                              exchangeProvider.sendCoin.symbol == "usdttrc20"
                                  ?
                              "assets/images/trx_usdt.png"
                                  :
                              "assets/images/bitcoin.png",
                              height: 25,
                              width: 25,
                            )
                                :
                            CachedNetworkImage(
                              height: 25,
                              width: 25,
                              fit: BoxFit.fill,
                              imageUrl: exchangeProvider.sendCoin.logo,
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: MyColor.greenColor
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  height: 25,
                                  width: 25,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: MyColor.whiteColor,
                                  ),
                                  child: Image.asset(
                                    "assets/images/bitcoin.png",
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                exchangeProvider.sendCoin.name,
                                style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: showSendError,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  sendError,
                  style: MyStyle.tx18BWhite.copyWith(
                      color: MyColor.redColor,
                      fontSize: 12
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // middle send coin value and price
            Row(
              children: [
                // Text(
                //   "1BTC ~ ",
                //   style: MyStyle.tx18RWhite.copyWith(
                //     color: MyColor.textGreyColor,
                //     fontSize: 14
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 4),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(4),
                //     color:MyColor.darkGreenColor
                //   ),
                //   child: Text(
                //     "18.5266582 ETH",
                //     style: MyStyle.tx18RWhite.copyWith(
                //         fontSize: 14,
                //         color: MyColor.greenColor
                //     ),
                //   ),
                // ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    swapUpDown();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    color:MyColor.blackColor,
                    child: Image.asset(
                      "assets/images/dashboard/up_down_arrow.png",
                      height: 20,
                      width: 20,
                      color: MyColor.mainWhiteColor,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // get coin details
            Container(
              height: 80,
              width: width,
              decoration: BoxDecoration(
                  color:MyColor.blackColor,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [

                  // text filed and title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Text(
                            "You get ${exchangeProvider.receiveCoin.name.split(" ").first} ${exchangeProvider.receiveCoin.type}",
                            style:MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: MyColor.grey01Color
                            ),
                          ),
                        ),
                        TextFormField(
                            keyboardType: TextInputType.number,
                            controller: exchangeProvider.getCoinController,
                            readOnly: true,
                            cursorColor: MyColor.greenColor,
                            style: MyStyle.tx18RWhite,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: "0.0",
                              border: InputBorder.none,
                              hintStyle:MyStyle.tx22RWhite.copyWith(
                                  fontSize: 18,
                                  color: MyColor.whiteColor.withOpacity(0.7)
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                            )
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  const VerticalDivider(
                    thickness: 1.5,
                    color: MyColor.backgroundColor,
                  ),
                  const SizedBox(width: 8),

                  // coin images and name
                  SizedBox(
                    width: width * 0.3,
                    child: InkWell(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExChangeTokenList(
                                pageType: "receive"
                            ),
                          )
                        );

                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Row(
                          children: [
                            exchangeProvider.receiveCoin.symbol == "usdtbsc" || exchangeProvider.receiveCoin.symbol == "usdttrc20"
                                ?
                            Image.asset(
                              exchangeProvider.receiveCoin.symbol == "usdtbsc"
                                  ?
                              "assets/images/bsc_usdt.png"
                                  :
                              exchangeProvider.receiveCoin.symbol == "usdttrc20"
                                  ?
                              "assets/images/trx_usdt.png"
                                  :
                              "assets/images/bitcoin.png",
                              height: 25,
                              width: 25,
                            )
                                :
                            CachedNetworkImage(
                              height: 25,
                              width: 25,
                              fit: BoxFit.fill,
                              imageUrl: exchangeProvider.receiveCoin.logo,
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: MyColor.greenColor
                                  ),
                              );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                    height: 25,
                                    width: 25,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: MyColor.whiteColor,
                                    ),
                                    child: Image.asset(
                                      "assets/images/bitcoin.png",
                                    ),
                                  );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                exchangeProvider.receiveCoin.name,
                                style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

          ],
        ),
      ),

    );
  }

}
