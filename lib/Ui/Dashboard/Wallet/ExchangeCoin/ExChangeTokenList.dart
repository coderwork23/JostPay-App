import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Provider/ExchangeProvider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExChangeTokenList extends StatefulWidget {
  final String pageType;
  const ExChangeTokenList({
    super.key,
    required this.pageType
  });

  @override
  State<ExChangeTokenList> createState() => _ExChangeTokenListState();
}

class _ExChangeTokenListState extends State<ExChangeTokenList> {


  late ExchangeProvider exchangeProvider;
  var selectedAccountId ="";

  getAcID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
  }


  @override
  void initState() {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: false);
    super.initState();
    getAcID();
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: true);

    return Scaffold(
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
          "Select ${widget.pageType} token",
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
        itemCount: DBTokenProvider.dbTokenProvider.tokenList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var list = DBTokenProvider.dbTokenProvider.tokenList[index];
          return InkWell(
            onTap: () async {
              if(widget.pageType == "send"){
                exchangeProvider.changeSendToken(list,context,selectedAccountId);
              }else{
                exchangeProvider.changeReceiveToken(list,context,selectedAccountId);
              }
              Navigator.pop(context);

              await exchangeProvider.getMinMax(
                  "v1/exchange-range/fixed-rate/${exchangeProvider.sendCoin.symbol.toLowerCase()}_${exchangeProvider.receiveCoin.symbol.toLowerCase()}",
                  {"api_key":Utils.apiKey}
              );


            },
            child : Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child:
                    CachedNetworkImage(
                      height: 35,
                      width: 35,
                      fit: BoxFit.fill,
                      imageUrl: list.logo,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style: MyStyle.tx18RWhite,
                        ),
                        Visibility(
                          visible: list.type.isNotEmpty,
                          child: Text(
                            "type: ${list.type}",
                            style:MyStyle.tx18RWhite.copyWith(
                                fontSize: 13,
                                color: MyColor.grey01Color
                            ),
                          ),
                        ),
                      ],
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
    );
  }
}
