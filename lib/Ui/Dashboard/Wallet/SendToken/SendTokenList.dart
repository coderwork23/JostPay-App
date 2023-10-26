import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SendCoinScreen.dart';

class SendTokenList extends StatefulWidget {
  const SendTokenList({super.key});

  @override
  State<SendTokenList> createState() => _SendTokenListState();
}

class _SendTokenListState extends State<SendTokenList> {

  TextEditingController searchController = TextEditingController();


  getCoin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);
      setState(() {});
  }


  @override
  void initState() {
    super.initState();
    getCoin();
  }


  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // dos icon
        Container(
          width: 45,
          height: 5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MyColor.lightGreyColor
          ),
        ),
        const SizedBox(height: 25),

        // add assets text
        Text(
          "Send",
          style: MyStyle.tx28RGreen.copyWith(
              color: MyColor.mainWhiteColor,
              fontFamily: "NimbusSanLBol",
              fontSize: 22
          ),
        ),
        const SizedBox(height: 25),

        //search filed
        TextFormField(
          controller: searchController,
          cursorColor: MyColor.greenColor,
          style: MyStyle.tx18RWhite,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: MyColor.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: MyColor.darkGrey01Color,
                )
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: MyColor.darkGrey01Color,
                )
            ),
            hintText: "Search",
            hintStyle:MyStyle.tx22RWhite.copyWith(
                fontSize: 14,
                color: MyColor.grey01Color
            ),

          ),
        ),
        const SizedBox(height: 25),

        // coin list
        Expanded(
          child : ListView.builder(
            itemCount: DBTokenProvider.dbTokenProvider.tokenList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {

              var list = DBTokenProvider.dbTokenProvider.tokenList[index];

              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendCoinScreen(
                          sendTokenAddress: list.address,
                          sendTokenNetworkId: "${list.networkId}",
                          sendTokenName: list.name,
                          sendTokenSymbol: list.symbol,
                          selectTokenMarketId: "${list.marketId}",
                          sendTokenImage : list.logo,
                          sendTokenBalance : list.balance,
                          sendTokenId : "${list.token_id}",
                          sendTokenUsd : "${list.price}",
                          sendTokenDecimals:list.decimals
                      ),
                    )
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          height: 35,
                          width: 35,
                          fit: BoxFit.fill,
                          imageUrl: "https://s2.coinmarketcap.com/static/img/coins/64x64/${list.marketId}.png",
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: MyColor.greenColor),
                          ),
                          errorWidget: (context, url, error) =>
                              Container(
                                height: 35,
                                width: 35,
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
                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          list.name,
                          style: MyStyle.tx18RWhite,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Text(
                        list.symbol,
                        style: MyStyle.tx18RWhite,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );
  }
}
