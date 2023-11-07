import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/InstantLoginScreen.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BuyValidationPage.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {

  TextEditingController priceController = TextEditingController();
  TextEditingController currencyAcController = TextEditingController();
  TextEditingController memoController = TextEditingController();
  bool isLoading = false;

  late BuySellProvider buySellProvider;
  RatesInfo? selectedCoin;
  String? selectedNetwork,networkFees,bankName;

  String errorMessage = "",selectedAccountId = "";

  var usdError = "";

  // getAccessToken()async{
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   // SharedPreferences sharedPre = await SharedPreferences.getInstance();
  //   // buySellProvider.accessToken = sharedPre.getString("accessToken")??"";
  //   getExchangeRat();
  //
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // getExchangeRat() async {
  //
  //   var params = {
  //     "action":"exchange_rate",
  //   };
  //
  //   await buySellProvider.getExRate(params,context);
  // }


  getSelectedAccount()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DbNetwork.dbNetwork.getNetwork();
    setState(() {});
  }



  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    buySellProvider.accessToken = "";
    buySellProvider.loginButtonText = "Get Otp";
    buySellProvider.showOtpText = false;
    super.initState();

    getSelectedAccount();
  }

  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    return  Scaffold(
      body: isLoading
          ?
      Helper.dialogCall.showLoader()
          :
      Column(
        children: [

          buySellProvider.accessToken == ""
              ?
          const Expanded(child: InstantLoginScreen())
              :
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 17),

                    // buy text
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Buy",
                        style: MyStyle.tx18BWhite,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 15),

                            // coin drop down
                            DropdownButtonFormField<RatesInfo>(
                              value: selectedCoin,
                              decoration: MyStyle.textInputDecoration.copyWith(
                                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_sharp,
                                color: MyColor.greenColor,
                              ),
                              hint: Text(
                                "Select coin",
                                style:MyStyle.tx22RWhite.copyWith(
                                    fontSize: 18,
                                    color: MyColor.whiteColor.withOpacity(0.7)
                                ),
                              ),
                              dropdownColor: MyColor.backgroundColor,
                              isExpanded: true,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                              items: buySellProvider.loginModel!.ratesInfo.map((RatesInfo category) {
                                return DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category.name,
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 16
                                      ),
                                    )
                                );
                              }).toList(),
                              onChanged: (RatesInfo? value) async {

                                var index = DbNetwork.dbNetwork.networkList.indexWhere((element) => element.name == value!.name);
                                networkFees = null;

                                if(index != -1){
                                  await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, DbNetwork.dbNetwork.networkList[index].id);
                                  setState(() {
                                    currencyAcController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                                    networkFees = selectedCoin!.networkFees[0];
                                  });
                                }
                                else if(value!.name == "Tether - USDT TRC20"){
                                  await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, 9);
                                  setState(() {
                                    currencyAcController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                                    selectedCoin = value;
                                    networkFees = selectedCoin!.networkFees[0];

                                  });
                                }
                                else if(value.name == "Tether BEP20"){
                                  await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, 2);
                                  setState(() {
                                    currencyAcController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                                    selectedCoin = value;

                                    networkFees = selectedCoin!.networkFees[0];

                                  });
                                }
                                else if(value.name == "Binance Coin BSC"){
                                  await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, 2);
                                  setState(() {
                                    currencyAcController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                                    selectedCoin = value;
                                    networkFees = "${selectedCoin!.networkFees[0]}";
                                  });
                                }
                                else{
                                  currencyAcController.clear();
                                  // ignore: use_build_context_synchronously
                                  Helper.dialogCall.showToast(context, "Selected Network is not implemented");
                                }

                              },
                            ),
                            const SizedBox(height: 20),

                            // Buy amount
                            TextFormField(
                              keyboardType: TextInputType.number,
                              controller: priceController,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                              onChanged: (value){
                                if(double.parse(value) < selectedCoin!.minBuyAmount){
                                  usdError = "Amount more then ${selectedCoin!.minBuyAmount}";
                                }else{
                                  usdError = "";
                                }
                                setState(() {});
                              },
                              decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText: "Withdraw amount",
                                  isDense: false,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                                  suffixIcon: SizedBox(
                                    width: 80,
                                    child: Center(
                                      child: Text(
                                        "USD",
                                        style: MyStyle.tx18BWhite.copyWith(
                                            fontSize: 16
                                        ),
                                      ),
                                    ),
                                  )
                              ),

                            ),
                            Visibility(
                                visible: usdError.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12.0,left: 10),
                                  child: Text(
                                    usdError,
                                    style: MyStyle.tx18BWhite.copyWith(
                                        color: MyColor.redColor,
                                        fontSize: 14
                                    ),
                                  ),
                                )
                            ),
                            const SizedBox(height: 20),


                            // network fees drop down
                            selectedCoin  == null
                                ?
                            const SizedBox():
                            DropdownButtonFormField<String>(
                             value:  networkFees,
                             // value:"${selectedCoin!.networkFees[0]}",
                              isExpanded: true,
                              decoration: MyStyle.textInputDecoration.copyWith(
                                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_sharp,
                                color: MyColor.greenColor,
                              ),
                              hint: Text(
                                "Select Network Fee",
                                style:MyStyle.tx22RWhite.copyWith(
                                    fontSize: 18,
                                    color: MyColor.whiteColor.withOpacity(0.7)
                                ),
                              ),
                              dropdownColor: MyColor.backgroundColor,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),

                              items: selectedCoin!.networkFees.map((String category) {
                                var symbol = "";
                                //

                                if(selectedCoin!.name.contains("-")){
                                  symbol =  selectedCoin!.name.split("-").last.split(" ").join(" ");
                                }else {
                                  if (selectedCoin!.name == "Tether - USDT TRC20") {
                                    symbol = "USDTTRC20";
                                  } else
                                  if (selectedCoin!.name == "Tether BEP20") {
                                    symbol = "USDTBEP20";
                                  } else {
                                    symbol = DbNetwork.dbNetwork.networkList
                                        .firstWhere((element) {
                                      return element.name.toLowerCase() ==
                                          (selectedCoin!.name.toLowerCase() ==
                                              "binance coin bsc"
                                              ? "binance smart chain"
                                              : selectedCoin!.name
                                              .toLowerCase());
                                    }).symbol;
                                  }
                                }
                                return DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      // "Network Fee: $category",

                                      "Network Fee: $category $symbol",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 16
                                      ),
                                    )
                                );
                              }).toList(),
                              onChanged: (String? value) async {
                                setState(() {
                                  networkFees = value;
                                });
                              },
                            ),
                            SizedBox(height: selectedCoin  == null ? 0: 20),


                            // bank DropDown
                            DropdownButtonFormField<String>(
                              value: bankName,
                              isExpanded: true,
                              decoration: MyStyle.textInputDecoration.copyWith(
                                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_sharp,
                                color: MyColor.greenColor,
                              ),
                              hint: Text(
                                "Select Bank",
                                style:MyStyle.tx22RWhite.copyWith(
                                    fontSize: 18,
                                    color: MyColor.whiteColor.withOpacity(0.7)
                                ),
                              ),
                              dropdownColor: MyColor.backgroundColor,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),

                              items: buySellProvider.loginModel!.banks.map((String category) {

                                return DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 16
                                      ),
                                    )
                                );
                              }).toList(),
                              onChanged: (String? value) async {
                                setState(() {
                                  bankName = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            // Currency account
                            TextFormField(
                              controller: currencyAcController,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                              decoration: MyStyle.textInputDecoration.copyWith(
                                hintText: selectedCoin == null ? "Currency account" : "${selectedCoin!.name} account",
                                isDense: false,
                                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                              ),

                            ),
                            const SizedBox(height: 20),



                            // Memo text
                            selectedCoin == null || selectedCoin!.memoLabel != ""
                                ?
                            const SizedBox()
                                :
                            TextFormField(
                              controller: memoController,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                              decoration: MyStyle.textInputDecoration.copyWith(
                                hintText: "Memo",
                                isDense: false,
                                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                              ),

                            ),
                            const SizedBox(height: 40),

                            // process button
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => BuyValidationPage(
                                  amount: priceController.text.trim(),
                                  bank: bankName!,
                                  itemCode: selectedCoin!.itemCode,
                                  receivingAddress: currencyAcController.text.trim(),
                                  selectedCoin: selectedCoin,
                                ),));
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 45,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration:
                                MyStyle.buttonDecoration,

                                child: const Text(
                                    "Continue",
                                    style:  MyStyle.tx18BWhite
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          )
          
        ],
      )
    );
  }

}
