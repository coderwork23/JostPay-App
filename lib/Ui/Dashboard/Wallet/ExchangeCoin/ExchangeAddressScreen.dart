import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class ExchangeAddressScreen extends StatefulWidget {
  const ExchangeAddressScreen({super.key});

  @override
  State<ExchangeAddressScreen> createState() => _ExchangeAddressScreenState();
}

class _ExchangeAddressScreenState extends State<ExchangeAddressScreen> {


  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: Container(
          alignment: Alignment.center,
          height: 45,
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: MyStyle.buttonDecoration.copyWith(
            color: MyColor.greenColor,
          ),
          child:Text(
            "Start Exchange",
            style: MyStyle.tx18BWhite.copyWith(
              color:  MyColor.mainWhiteColor,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: MyColor.darkGreyColor,
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
          "Enter ETH address",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),

      ),
      body: SizedBox(
        height: height,
        width: width,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.17,
              width: width,
              child: Stack(
                children: [
                  
                  // background color container
                  Container(
                    color: MyColor.darkGreyColor,
                    height: height * 0.12,
                    width: width,
                  ),

                  // text filed
                  Positioned(
                    bottom: 0,
                    left: 15,
                    right: 15,
                    child: TextFormField(
                      controller: addressController,
                      cursorColor: MyColor.greenColor,
                      style: MyStyle.tx18RWhite,
                      decoration: InputDecoration(
                          filled: true,
                          hintText: "Add ETH Address or FIO name",
                          fillColor: MyColor.blackColor,
                          border: InputBorder.none,
                          hintStyle:MyStyle.tx22RWhite.copyWith(
                              fontSize: 18,
                              color: MyColor.whiteColor.withOpacity(0.7)
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: MyColor.blackColor,
                              )
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: MyColor.blackColor,
                              )
                          ),
                          suffixIcon: SizedBox(
                            width: 80,
                            child: Center(
                              child: Text(
                                "Past",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16,
                                    color: MyColor.greenColor
                                ),
                              ),
                            ),
                          )

                      )
                    ),
                  ),

                  // add wallet text and icon
                  Positioned(
                    bottom: 75,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColor.greenColor
                          ),
                          child: Image.asset(
                            "assets/images/dashboard/wallet.png",
                            height: 20,
                            width: 20,
                            color: MyColor.whiteColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Add Wallet",
                          style: MyStyle.tx18RWhite.copyWith(
                              color: MyColor.greenColor,
                            fontSize: 12
                          ),
                        )
                      ],
                    ),
                  )

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
