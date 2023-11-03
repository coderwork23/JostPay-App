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

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {

  TextEditingController priceController = TextEditingController();
  TextEditingController currencyAcController = TextEditingController();
  bool isLoading = false;

  late BuySellProvider buySellProvider;
  RatesInfo? selectedCoin;

  bool showError = false;
  String errorMessage = "",selectedAccountId = "";

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
    super.initState();

    getSelectedAccount();

    // getExchangeRat();
  }

  @override
  Widget build(BuildContext context) {

    final dashProvider = Provider.of<DashboardProvider>(context);
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

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
          SafeArea(
           child: SingleChildScrollView(
               padding: const EdgeInsets.symmetric(horizontal: 15.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const SizedBox(height: 17),

                 // buy text
                 const Text(
                   "Buy",
                   style: MyStyle.tx18BWhite,
                 ),
                 const SizedBox(height: 30),

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


                     if(index != -1){
                       await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, DbNetwork.dbNetwork.networkList[index].id);
                       setState(() {
                         currencyAcController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                         selectedCoin = value;
                       });
                     }else if(value!.name == "Tether - USDT TRC20"){
                       await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, 9);
                       setState(() {
                         currencyAcController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                         selectedCoin = value;
                       });
                     }else if(value.name == "Tether BEP20"){
                       await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, 2);
                       setState(() {
                         currencyAcController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                         selectedCoin = value;
                       });
                     }else if(value.name == "Binance Coin BSC"){
                       await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, 2);
                       setState(() {
                         currencyAcController.text = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                         selectedCoin = value;
                       });
                     }else{
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

                     }
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
                 const SizedBox(height: 20),

                 // Currency account
                 TextFormField(
                   controller: currencyAcController,
                   cursorColor: MyColor.greenColor,
                   style: MyStyle.tx18RWhite.copyWith(
                     fontSize: 16
                   ),
                   readOnly: true,
                   decoration: MyStyle.textInputDecoration.copyWith(
                       hintText: selectedCoin == null ? "Currency account" : "${selectedCoin!.name} account",
                       isDense: false,
                       contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                   ),

                 ),
                 const SizedBox(height: 40),

                 // process button
                 InkWell(
                   onTap: () {},
                   child: Container(
                     alignment: Alignment.center,
                     height: 45,
                     padding: const EdgeInsets.symmetric(vertical: 12),
                     decoration:
                     MyStyle.buttonDecoration,

                     child: const Text(
                         "Process",
                         style:  MyStyle.tx18BWhite
                     ),
                   ),
                 ),

               ],
             ),
           ),
         )
          
        ],
      )
    );
  }

}
