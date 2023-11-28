import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ReceiveScreen extends StatefulWidget {
  int networkId;
  String tokenName,tokenSymbol,tokenImage,tokenType;


  ReceiveScreen({
    super.key,
    required this.networkId,
    required this.tokenName,
    required this.tokenSymbol,
    required this.tokenImage,
    required this.tokenType,
  });

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {

  late String selectedAccountName = "",
      selectedAccountAddress = "",selectedAccountId;
  bool isLoaded = false;


  @override
  void initState() {
    super.initState();
    selectedAccount();
  }

  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    selectedAccountName = sharedPreferences.getString('accountName') ?? "";


    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,widget.networkId);
    selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;

    // await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,widget.networkId);

    setState(() {
      selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      isLoaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return  Scaffold(
      appBar: AppBar(
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
        title:  Text(
          "Receive ${widget.tokenSymbol}",
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),


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

                Text(
                  "${widget.tokenName}",
                  textAlign: TextAlign.center,
                  style:MyStyle.tx18BWhite.copyWith(
                      fontSize: 18,
                      color: MyColor.whiteColor
                  ),
                ),

                SizedBox(height: widget.tokenType.isNotEmpty ? 0 : 10),

                Visibility(
                  visible: widget.tokenType.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Type: ${widget.tokenType}",
                      textAlign: TextAlign.center,
                      style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 12,
                          color: MyColor.whiteColor
                      ),
                    ),
                  ),
                ),

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
                      data: selectedAccountAddress,
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
                  selectedAccountAddress,
                  textAlign: TextAlign.center,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // copy and shared
          SizedBox(
            width: width * 0.8,
            child: Row(
              children: [

                InkWell(
                  onTap: () {
                    Share.share(selectedAccountAddress);
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
                      FlutterClipboard.copy(selectedAccountAddress).then((value) {
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
          const SizedBox(height: 20),

          // warning message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Send only ${widget.tokenName} (${widget.tokenType != "" ? "" : widget.tokenSymbol} ${widget.tokenType}) to this address. "
                  "Sending any other coins may result in permanent loss of you token.",
              textAlign: TextAlign.center,
              style:MyStyle.tx18RWhite.copyWith(
                  fontSize: 12,
                  color: MyColor.dotBoarderColor
              ),
            ),
          ),
          const SizedBox(height: 25),

        ],
      ),
    );
  }
}
