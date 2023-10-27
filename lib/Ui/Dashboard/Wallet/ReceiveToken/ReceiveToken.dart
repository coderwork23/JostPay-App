import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/ReceiveToken/ReceiveScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ReceiveToken extends StatefulWidget {
  const ReceiveToken({super.key});

  @override
  State<ReceiveToken> createState() => _ReceiveTokenState();
}

class _ReceiveTokenState extends State<ReceiveToken> {
  TextEditingController searchController = TextEditingController();

  showReceivePage(BuildContext context,tokenNetworkId,tokenName,symbol){
    showModalBottomSheet(
      isScrollControlled: false,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20,22,20,10),
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height/2,
                maxHeight: MediaQuery.of(context).size.height*0.8
            ),
            child: ReceiveScreen(
              networkId: tokenNetworkId,
              tokenName: tokenName,
              tokenSymbol:symbol,
            )
        );
      },
    );
  }


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

        // Select assets text
        Text(
          "Select Assets",
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
                onTap: (){
                  Navigator.pop(context);
                  showReceivePage(
                      context,
                      list.networkId,
                      list.name,
                      list.symbol
                  );
                },
                child : Padding(
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
