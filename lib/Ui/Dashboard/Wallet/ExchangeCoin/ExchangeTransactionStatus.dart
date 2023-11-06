import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Ex_Transaction_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/ExchangeProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ExchangeTransactionStatus extends StatefulWidget {
  final String statusId;

  const ExchangeTransactionStatus({
    super.key,
    required this.statusId
  });

  @override
  State<ExchangeTransactionStatus> createState() => _ExchangeTransactionStatusState();
}

class _ExchangeTransactionStatusState extends State<ExchangeTransactionStatus> {


  late ExchangeProvider exchangeProvider;
  var selectedAccountId = "";
  bool isLoading = false;

  NetworkList? sendNetwork, receiveNetwork ;

  getTxsStatus()async{
    setState(() {
      isLoading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DbExTransaction.dbExTransaction.getTrxStatus(selectedAccountId,widget.statusId);

    setState(() {

     sendNetwork = DbNetwork.dbNetwork.networkList.where((element) {
       return element.symbol.toLowerCase() == DbExTransaction.dbExTransaction.getTrxStatusData!.fromCurrency;
     }).toList().first;
     receiveNetwork = DbNetwork.dbNetwork.networkList.where((element) {
       return element.symbol.toLowerCase() == DbExTransaction.dbExTransaction.getTrxStatusData!.toCurrency;
     }).toList().first;
     isLoading = false;

    });

  }

  @override
  void initState() {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: false);
    super.initState();
    getTxsStatus();
  }


  getTrxStatusApi()async{

    await exchangeProvider.transactionStatus(
        "/v1/transactions/${DbExTransaction.dbExTransaction.getTrxStatusData!.id}/${Utils.apiKey}",
        selectedAccountId
    );

    setState(() {
      _showRefresh = false;
    });
  }

  bool _showRefresh = false;
  Future<void> _getData() async {

    setState(() {
      _showRefresh = true;
    });

    getTrxStatusApi();
    getTxsStatus();
  }

  @override
  Widget build(BuildContext context) {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: true);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

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
        title: const Text(
          "Transaction Status"
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // from coin details
                        Row(
                          children: [
                            sendNetwork!.symbol == "usdtbsc" || sendNetwork!.symbol == "usdttrc20"
                                ?
                            Image.asset(
                              sendNetwork!.symbol == "usdtbsc"
                                  ?
                              "assets/images/bsc_usdt.png"
                                  :
                              sendNetwork!.symbol == "usdttrc20"
                                  ?
                              "assets/images/trx_usdt.png"
                                  :
                              "assets/images/bitcoin.png",
                              height: 25,
                              width: 25,
                            )
                                :
                            CachedNetworkImage(
                              height: 25,
                              width: 25,
                              fit: BoxFit.fill,
                              imageUrl: sendNetwork!.logo,
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: MyColor.greenColor
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  height: 25,
                                  width: 25,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: MyColor.whiteColor,
                                  ),
                                  child: Image.asset(
                                    "assets/images/bitcoin.png",
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                sendNetwork!.name,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),
                            Text(
                              "~${ApiHandler.calculateLength3("${DbExTransaction.dbExTransaction.getTrxStatusData!.expectedSendAmount}")} "
                                  "${sendNetwork!.symbol}",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 10),

                        // swap icon
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          decoration:  BoxDecoration(
                            color:MyColor.blackColor,
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Image.asset(
                            "assets/images/dashboard/up_down_arrow.png",
                            height: 25,
                            width: 25,
                            color: MyColor.mainWhiteColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // to coin details
                        Row(
                          children: [
                            receiveNetwork!.symbol == "usdtbsc" || receiveNetwork!.symbol == "usdttrc20"
                                ?
                            Image.asset(
                              receiveNetwork!.symbol == "usdtbsc"
                                  ?
                              "assets/images/bsc_usdt.png"
                                  :
                              receiveNetwork!.symbol == "usdttrc20"
                                  ?
                              "assets/images/trx_usdt.png"
                                  :
                              "assets/images/bitcoin.png",
                              height: 25,
                              width: 25,
                            )
                                :
                            CachedNetworkImage(
                              height: 25,
                              width: 25,
                              fit: BoxFit.fill,
                              imageUrl: exchangeProvider.receiveCoin.logo,
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: MyColor.greenColor
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  height: 25,
                                  width: 25,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: MyColor.whiteColor,
                                  ),
                                  child: Image.asset(
                                    "assets/images/bitcoin.png",
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                receiveNetwork!.name,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),
                            Text(
                              "~${ApiHandler.calculateLength3("${DbExTransaction.dbExTransaction.getTrxStatusData!.expectedReceiveAmount}")} "
                                  "${receiveNetwork!.symbol}",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 5),

                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // transaction id and validity time
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
                              DbExTransaction.dbExTransaction.getTrxStatusData!.status,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 10),

                        // transaction id
                        InkWell(
                          onTap: () {
                            FlutterClipboard.copy(DbExTransaction.dbExTransaction.getTrxStatusData!.payinAddress).then((value) {
                              Helper.dialogCall.showToast(context, "Transaction ID Copied");
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  "Transaction ID: ",
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                              ),
                              Text(
                                DbExTransaction.dbExTransaction.getTrxStatusData!.id,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
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

                            Expanded(
                              child: Text(
                                "Valid Until: ",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),
                            Text(
                              DateFormat("dd MMM yyyy h:mma").format(DbExTransaction.dbExTransaction.getTrxStatusData!.validUntil.toLocal()),
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Note: Please send "
                          "${ApiHandler.calculateLength3("${DbExTransaction.dbExTransaction.getTrxStatusData?.expectedSendAmount}")} "
                          "(${sendNetwork!.symbol}) with in valid time period.If you send after that result is permanent loss of your token.",
                      textAlign: TextAlign.center,
                      style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 12,
                          color: MyColor.dotBoarderColor
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

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
                              data: DbExTransaction.dbExTransaction.getTrxStatusData!.payinAddress,
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
                          DbExTransaction.dbExTransaction.getTrxStatusData!.payinAddress,
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
                            Share.share(DbExTransaction.dbExTransaction.getTrxStatusData!.payinAddress);
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
                              FlutterClipboard.copy(DbExTransaction.dbExTransaction.getTrxStatusData!.payinAddress).then((value) {
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
