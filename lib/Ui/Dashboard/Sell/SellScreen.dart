import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/InstantLoginScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellHistory.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellValidationPage.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {

  TextEditingController priceController = TextEditingController(text: "0");
  TextEditingController bankNoController = TextEditingController();
  TextEditingController acNameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? selectedBank,selectedAccountId = "",networkFees,sellBank;
  bool isLoading = false;
  var usdError = "";

  RatesInfo? selectedCoin;

  late BuySellProvider buySellProvider;

  getAccessToken()async{

    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    selectedAccountId = sharedPre.getString('accountId') ?? "";
    var email = sharedPre.getString("email")??"";

    await DbNetwork.dbNetwork.getNetwork();
    setState(() {
      emailController.text = email;
      isLoading = false;
    });
  }

  sellValidateOrder()async{
    var params = {
      "action":"validate_sell_order",
      "email":emailController.text.trim(),
      "token":buySellProvider.loginModel!.accessToken,
      "item_code":selectedCoin!.itemCode,
      "amount":priceController.text.trim(),
      "bank":sellBank,
      "account_no":bankNoController.text.trim(),
      "account_name":acNameController.text.trim(),
      "phone":phoneNoController.text,
      "auth":"p1~\$*)Ze(@"
    };


    await buySellProvider.validateSellOrder(params);

    if(buySellProvider.getSellValidation != null && buySellProvider.isValidSuccess){
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SellValidationPage(),)
      );
    }

  }

  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    buySellProvider.accessToken = "";
    super.initState();
    getAccessToken();

  }

  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);
    return Scaffold(
        appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Text(
            "Withdraw",
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SellHistory(),
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

        body:isLoading
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

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
                        setState(() {
                          networkFees = null;
                          selectedCoin = null;
                          selectedCoin = value;
                          priceController.clear();
                        });

                      },
                    ),
                    const SizedBox(height: 20),

                    // Withdraw amount
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: priceController,
                      cursorColor: MyColor.greenColor,
                       style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      onChanged: (value){
                        print(selectedCoin!.minSellAmount);
                        if(double.parse(value) < selectedCoin!.minSellAmount){
                          usdError = "Amount more then ${selectedCoin!.minSellAmount}";
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

                    // Bank Account No.
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: bankNoController,
                      cursorColor: MyColor.greenColor,
                       style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Bank Account No.",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                      ),

                    ),
                    const SizedBox(height: 20),

                    // Account Name
                    TextFormField(
                      controller: acNameController,
                      cursorColor: MyColor.greenColor,
                       style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Account Name",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // bank DropDown
                    DropdownButtonFormField<String>(
                      value: sellBank,
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
                          sellBank = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),


                    // Your Phone No
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: phoneNoController,
                      cursorColor: MyColor.greenColor,
                       style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Your Phone No",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                      ),

                    ),
                    const SizedBox(height: 20),

                    // Your Email Address
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      cursorColor: MyColor.greenColor,
                       style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Your Email Address",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                      ),

                    ),
                    const SizedBox(height: 40),

                    // Proceed button

                    buySellProvider.sellValidOrder
                        ?
                        Helper.dialogCall.showLoader()
                        :
                    selectedCoin == null || priceController.text.isEmpty || sellBank == null
                        || acNameController.text.isEmpty || bankNoController.text.isEmpty || emailController.text.isEmpty
                        ?
                    Container(
                      alignment: Alignment.center,
                      height: 45,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration:
                      selectedCoin == null || priceController.text.isEmpty || sellBank == null
                          || acNameController.text.isEmpty || bankNoController.text.isEmpty || emailController.text.isEmpty
                          ?
                      MyStyle.invalidDecoration
                          :
                      MyStyle.buttonDecoration,

                      child: Text(
                          "Continue",
                          style:  MyStyle.tx18BWhite.copyWith(
                              color:  selectedCoin == null || priceController.text.isEmpty || sellBank == null
                                  || acNameController.text.isEmpty || bankNoController.text.isEmpty || emailController.text.isEmpty
                                  ?
                              MyColor.mainWhiteColor.withOpacity(0.4)
                                  :
                              MyColor.mainWhiteColor
                          )
                      ),
                    )
                        :
                    InkWell(
                      onTap: () {
                        sellValidateOrder();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: MyStyle.buttonDecoration,
                        child: const Text(
                          "Proceed",
                          style: MyStyle.tx18BWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),


                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}
