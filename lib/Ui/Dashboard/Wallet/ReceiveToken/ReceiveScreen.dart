import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ReceiveScreen extends StatefulWidget {
  int networkId;
  var tokenName;
  var tokenSymbol;
  ReceiveScreen({
    super.key,
    required this.networkId,
    required this.tokenName,
    required this.tokenSymbol
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
          "Receive ${widget.tokenSymbol}",
          style: MyStyle.tx28RGreen.copyWith(
              color: MyColor.mainWhiteColor,
              fontFamily: "NimbusSanLBol",
              fontSize: 22
          ),
        ),
        const SizedBox(height: 25),

        // warning message
        Text(
          "Send only ${widget.tokenName} (${widget.tokenSymbol}) to this address. "
              "Sending any other coins may result in permanent loss.",
          textAlign: TextAlign.center,
          style:MyStyle.tx18RWhite.copyWith(
              fontSize: 18,
              color: MyColor.grey01Color
          ),
        ),
        const SizedBox(height: 25),

        // qr image
        Container(
          padding: const EdgeInsets.all(15),
          width: 160,
          height: 160,
          decoration: BoxDecoration(
              color: MyColor.backgroundColor,
              borderRadius: BorderRadius.circular(10)
          ),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
            child: QrImageView(
              data: selectedAccountAddress,
              eyeStyle: const QrEyeStyle(
                color: MyColor.mainWhiteColor,
                eyeShape: QrEyeShape.square
              ),
              dataModuleStyle: const QrDataModuleStyle(
                  color: MyColor.mainWhiteColor,
                  dataModuleShape:  QrDataModuleShape.square
              ),
              //embeddedImage: AssetImage('assets/icons/logo.png'),
              version: QrVersions.auto,
            ),
          ),
        ),
        const SizedBox(height: 25),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                decoration: BoxDecoration(
                  color: MyColor.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedAccountAddress,
                        textAlign: TextAlign.center,
                        style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        FlutterClipboard.copy(selectedAccountAddress).then((value) {
                          Helper.dialogCall.showToast(context, "Copied");
                        });
                      },
                      child : const Icon(
                        Icons.copy,
                        color: MyColor.greenColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            InkWell(
              onTap: () {
                Share.share('${widget.tokenSymbol} Address $selectedAccountAddress');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                decoration: const BoxDecoration(
                  color: MyColor.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.share_outlined,
                  color: MyColor.greenColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

      ],
    );
  }
}
