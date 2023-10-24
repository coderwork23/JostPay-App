import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellHistory.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {

  TextEditingController priceController = TextEditingController();
  TextEditingController bankNoController = TextEditingController();
  TextEditingController acNameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? selectedCoin,selectedBank;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Withdraw",
            style:MyStyle.tx22RWhite.copyWith(
                fontSize: 24,
                color: MyColor.mainWhiteColor
            ),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
        child: Column(
          children: [

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

            // Withdraw amount
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

            // Bank Account No.
            TextFormField(
              keyboardType: TextInputType.number,
              controller: priceController,
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              decoration: MyStyle.textInputDecoration.copyWith(
                  hintText: "Bank Account No.",
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

              ),

            ),
            const SizedBox(height: 20),

            // Account Name
            TextFormField(
              keyboardType: TextInputType.number,
              controller: priceController,
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              decoration: MyStyle.textInputDecoration.copyWith(
                hintText: "Account Name",
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
              ),
            ),
            const SizedBox(height: 20),

            // bank drop down
            DropdownButtonFormField<String>(
              value: selectedBank,
              decoration: MyStyle.textInputDecoration.copyWith(
                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_sharp,
                color: MyColor.greenColor,
              ),
              hint: Text(
                "Select your Bank",
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 18,
                    color: MyColor.whiteColor.withOpacity(0.7)
                ),
              ),
              dropdownColor: MyColor.backgroundColor,
              isExpanded: true,
              items: ["Bank1","bank2"].map((String category) {
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
                  selectedBank = value;
                });
              },
            ),
            const SizedBox(height: 20),


            // Your Phone No
            TextFormField(
              keyboardType: TextInputType.number,
              controller: priceController,
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              decoration: MyStyle.textInputDecoration.copyWith(
                hintText: "Your Phone No",
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

              ),

            ),
            const SizedBox(height: 20),

            // Your Email Address
            TextFormField(
              keyboardType: TextInputType.number,
              controller: priceController,
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              decoration: MyStyle.textInputDecoration.copyWith(
                hintText: "Your Email Address",
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

              ),

            ),
            const SizedBox(height: 40),

            // Proceed button
            InkWell(
              onTap: () {},
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
    );
  }
}
