import 'package:clipboard/clipboard.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Sell_History_address.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SellStatusPage extends StatefulWidget {
  final String invoiceNo,tokenName;
  const SellStatusPage({
    super.key,
    required this.invoiceNo,
    required this.tokenName
  });

  @override
  State<SellStatusPage> createState() => _SellStatusPageState();
}

class _SellStatusPageState extends State<SellStatusPage> {

  late BuySellProvider buySellProvider;
  late TokenProvider tokenProvider;

  var selectedAccountId = "";
  bool isLoading = true;


  getTxsStatus()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DbSellHistory.dbSellHistory.getTrxStatus(selectedAccountId,widget.invoiceNo);

    var data = {
      "search_term": "",
    };

    await tokenProvider.getSearchToken(data,'/getTokens');

    setState(() {
      isLoading = false;
      _showRefresh = false;
    });

  }

  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);

    super.initState();

    Future.delayed(Duration.zero,(){
      checkOrderStatus(context);
    });

  }

  checkOrderStatus(context)async{
    setState(() {
      isLoading = true;
    });
    var params = {
      "action":"check_order_status",
      "invoice":widget.invoiceNo,
      "auth":"p1~\$*)Ze(@",
    };

    await buySellProvider.checkOrderStatus(
      params,
      selectedAccountId,
      context,
      widget.tokenName
    );
    getTxsStatus();

  }

  bool _showRefresh = false;
  Future<void> _getData() async {

    setState(() {
      _showRefresh = true;
    });

    checkOrderStatus(context);

  }


  @override
  Widget build(BuildContext context) {
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    buySellProvider = Provider.of<BuySellProvider>(context, listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: isLoading || DbSellHistory.dbSellHistory.getTrxStatusData == null
          ?
      const SizedBox()
          :
      Visibility(
        visible: DbSellHistory.dbSellHistory.getTrxStatusData!.orderStatus == "Pending"
            &&
            DbSellHistory.dbSellHistory.getTrxStatusData!.payinUrl != "",
        child: InkWell(
          onTap: () {
            launchUrl(
              Uri.parse(DbSellHistory.dbSellHistory.getTrxStatusData!.payinUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            alignment: Alignment.center,
            height: 45,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: MyStyle.buttonDecoration,

            child: const Text(
              "Make Payment",
              style:  MyStyle.tx18BWhite
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
            "Sell Transaction Status"
        ),
      ),

      body: isLoading
          ?
      Helper.dialogCall.showLoader()
          :
      DeclarativeRefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        color: MyColor.greenColor,
        backgroundColor: MyColor.mainWhiteColor,
        onRefresh: _getData,
        refreshing: _showRefresh,
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                 // coin details
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                    decoration: BoxDecoration(
                        color: MyColor.darkGrey01Color,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DbSellHistory.dbSellHistory.getTrxStatusData!.tokenName,
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 16
                            ),
                          ),
                        ),
                        Text(
                          "~${DbSellHistory.dbSellHistory.getTrxStatusData!.payinAmount}",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // invoice id and date time
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                    decoration: BoxDecoration(
                        color: MyColor.darkGrey01Color,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        //We Pay:
                        Row(
                          children: [

                            Expanded(
                              child: Text(
                                "We Pay: ",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),
                            Text(
                              "${DbSellHistory.dbSellHistory.getTrxStatusData!.amountPayableNgn} NGN",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 10),

                        //Trxn Status:
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Trxn Status: ",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),
                            Text(
                              DbSellHistory.dbSellHistory.getTrxStatusData!.orderStatus,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 10),

                        // invoice id
                        InkWell(
                          onTap: () {
                            FlutterClipboard.copy(DbSellHistory.dbSellHistory.getTrxStatusData!.invoice).then((value) {
                              Helper.dialogCall.showToast(context, "Invoice No Copied");
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Invoice No: ",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  DbSellHistory.dbSellHistory.getTrxStatusData!.invoice,
                                  textAlign: TextAlign.end,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.copy,
                                size: 20,
                                color: MyColor.whiteColor,
                              ),

                            ],
                          ),
                        ),
                        const SizedBox(height: 10),


                        //  validity time
                        Row(
                          children: [

                            Text(
                              "Date: ",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),
                            Expanded(
                              child: Text(
                                DateFormat("dd MMM yyyy hh:mm a").format(DateTime.fromMillisecondsSinceEpoch(DbSellHistory.dbSellHistory.getTrxStatusData!.time * 1000)),
                                textAlign: TextAlign.end,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 10),

                        //  Invoice url
                        Row(
                          children: [

                            Text(
                              "Invoice url: ",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),
                            const SizedBox(height: 20),

                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  launchUrl(
                                    Uri.parse(DbSellHistory.dbSellHistory.getTrxStatusData!.invoiceUrl),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                child: Text(
                                  DbSellHistory.dbSellHistory.getTrxStatusData!.invoiceUrl,
                                  textAlign: TextAlign.end,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 15,
                                      color: MyColor.greenColor
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 5),

                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // warning message
                  Visibility(
                    visible: DbSellHistory.dbSellHistory.getTrxStatusData!.orderStatus == "Pending",
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Note: Your order has been submitted. Your transaction invoice no. is"
                            " ${DbSellHistory.dbSellHistory.getTrxStatusData!.invoice} "
                            " To complete this transaction, please send exactly"
                            " ${DbSellHistory.dbSellHistory.getTrxStatusData!.payinAmount} To",
                        textAlign: TextAlign.center,
                        style:MyStyle.tx18RWhite.copyWith(
                            fontSize: 12,
                            color: MyColor.dotBoarderColor
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Visibility(
                    visible: DbSellHistory.dbSellHistory.getTrxStatusData!.payinUrl == "",
                      child: Column(
                        children: [
                          // qr and token name
                          Container(
                            width: width * 0.8,
                            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 22),
                            decoration: BoxDecoration(
                                color: MyColor.darkGrey01Color,
                                borderRadius: BorderRadius.circular(12)
                            ),
                            child: Column(
                              children: [

                                Container(
                                  height: height * 0.26,
                                  width: width * 0.55,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: MyColor.mainWhiteColor,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: QrImageView(
                                      data: DbSellHistory.dbSellHistory.getTrxStatusData!.payin_address,
                                      eyeStyle: const QrEyeStyle(
                                          color: MyColor.backgroundColor,
                                          eyeShape: QrEyeShape.square
                                      ),
                                      dataModuleStyle: const QrDataModuleStyle(
                                          color: MyColor.backgroundColor,
                                          dataModuleShape:  QrDataModuleShape.square
                                      ),
                                      //embeddedImage: AssetImage('assets/icons/logo.png'),
                                      version: QrVersions.auto,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                Text(
                                  DbSellHistory.dbSellHistory.getTrxStatusData!.payin_address,
                                  textAlign: TextAlign.center,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),

                          // copy and shared
                          SizedBox(
                            width: width * 0.8,
                            child: Row(
                              children: [

                                InkWell(
                                  onTap: () {
                                    Share.share(DbSellHistory.dbSellHistory.getTrxStatusData!.payin_address);
                                  },
                                  child: Container(
                                    height: 55,
                                    width: 60,
                                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 16),
                                    decoration: BoxDecoration(
                                      color: MyColor.darkGrey01Color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Image.asset(
                                      "assets/images/dashboard/share.png",
                                      fit: BoxFit.contain,
                                      color: MyColor.whiteColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),

                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      FlutterClipboard.copy(DbSellHistory.dbSellHistory.getTrxStatusData!.payin_address).then((value) {
                                        Helper.dialogCall.showToast(context, "Copied");
                                      });
                                    },
                                    child: Container(
                                      height: 55,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: MyColor.darkGrey01Color,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child:  Row(
                                        children: [
                                          const Icon(
                                            Icons.copy,
                                            color: MyColor.whiteColor,
                                          ),
                                          const SizedBox(width: 15),

                                          Text(
                                            "Copy address",
                                            textAlign: TextAlign.center,
                                            style: MyStyle.tx18RWhite.copyWith(
                                                fontSize: 16
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      )
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
