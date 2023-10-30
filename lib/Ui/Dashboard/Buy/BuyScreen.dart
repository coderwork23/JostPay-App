import 'package:flutter/material.dart';
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

  getAccessToken()async{

    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    buySellProvider.accessToken = sharedPre.getString("accessToken")??"";

    setState(() {
      isLoading = false;
    });
  }

  getExchangeRat() async {

    var params = {
      "action":"exchange_rate",
      "token":buySellProvider.accessToken
    };

    await buySellProvider.getExRate(params,context);
  }

  String? selectedCoin;


  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);

    super.initState();
    getAccessToken();
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

                 const Text(
                   "Buy",
                   style: MyStyle.tx18BWhite,
                 ),
                 const SizedBox(height: 30),

                 // coin drop down
                 DropdownButtonFormField<String>(
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
                   items: ["Bitcoin","Tron"].map((String category) {
                     return DropdownMenuItem(
                         value: category,
                         child: Text(
                           category,
                           style: MyStyle.tx18RWhite,
                         )
                     );
                   }).toList(),
                   onChanged: (String? value) {
                     setState(() {
                       selectedCoin = value;
                     });
                   },
                 ),
                 const SizedBox(height: 20),


                 // Buy amount
                 TextFormField(
                   keyboardType: TextInputType.number,
                   controller: priceController,
                   cursorColor: MyColor.greenColor,
                   style: MyStyle.tx18RWhite,
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
                   style: MyStyle.tx18RWhite,
                   decoration: MyStyle.textInputDecoration.copyWith(
                       hintText: "Currency account",
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
