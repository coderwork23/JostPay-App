import 'dart:io';
import 'package:eth_sig_util/util/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Walletv2_provider.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Provider/InternetProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Buy/BuyScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/SettingScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/WalletConnect/walletv2_models/ethereum/wc_ethereum_sign_message.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/WalletConnect/widgets/eip155_data_1.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Support/SupportScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WalletScreen.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_connect_dart_v2/core/models/app_metadata.dart';
import 'package:wallet_connect_dart_v2/core/pairing/models.dart';
import 'package:wallet_connect_dart_v2/sign/engine/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/client/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/client/sign_client.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/jsonrpc/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';
import 'package:wallet_connect_dart_v2/utils/error.dart';
import 'package:wallet_connect_dart_v2/wc_utils/jsonrpc/models/models.dart';
import 'package:web3dart/web3dart.dart';

import '../../Values/utils.dart';
import 'DashboardWalletConnect/SessionRequest.dart';
import 'DashboardWalletConnect/SignTransaction.dart';
import 'DashboardWalletConnect/WalletSign.dart';
import 'DashboardWalletConnect/WalletTransaction.dart';
import 'Settings/WalletConnect/walletv2_models/ethereum/wc_ethereum_transaction.dart';

SignClient? signClient;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  List body = [
    const WalletScreen(),
    const BuyScreen(),
    const SellScreen(),
    const SupportScreen(),
    const SettingScreen()
  ];

  _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(20,10,20,0),
        actionsPadding: const EdgeInsets.fromLTRB(20,5,20,0),
        backgroundColor: MyColor.darkGrey01Color,
     
        content: Text(
          'Do you want to exit an App ?',
          style:  MyStyle.tx18RWhite.copyWith(
              fontSize: 14
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style:  MyStyle.tx18RWhite.copyWith(
                  fontSize: 14
              ),            ),
          ),
          TextButton(
            onPressed: () {
              exit(0);
            },
            child: Text(
              'Yes',
              style: MyStyle.tx18RWhite.copyWith(
                  fontSize: 14
              ),
            ),
          ),
        ],
      ),
    );
  }


  late InternetProvider _internetProvider;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  checkForWc2Url(){
    Future.delayed(const Duration(milliseconds: 1100), () {
      getAccount();
      _initialize();
    });
  }

  String selectedAccountAddress = "";
  String selectedAccountPrivateAddress = "";
  String selectedAccountId = "";
  ValueNotifier <List<SessionStruct>?> sessions = ValueNotifier([]);

  getAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId =  sharedPreferences.getString('accountId')??"";
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,"2");

    setState((){
      selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
    });
  }
  

  checkInternet() async {
    await _internetProvider.checkInternet();
  }

  Web3Client _web3client = Web3Client('', http.Client());

  List<PairingStruct> pairings = [];
  void _initialize() async {
    signClient = await SignClient.init(
      projectId: "73801621aec60dfaa2197c7640c15858",
      relayUrl: "wss://relay.walletconnect.com",
      metadata: const AppMetadata(
        name: 'CatenaWallet',
        description: 'Wallet for WalletConnect',
        url: 'https://walletconnect.com/',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
      database: 'cateCoinWallet_test.db',
    );

    signClient!.on(SignClientEvent.SESSION_PROPOSAL.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionPropose>;
      // log('SESSION_PROPOSAL: $eventData');
      getAccount();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionRequest(
              account1: selectedAccountAddress,
              proposal: eventData.params!,
              onApprove: (namespaces,chain) async {
                // print("then check _onSessionRequest ${chain.first.split(":").last}");
                var index =  DbNetwork.dbNetwork.networkList.indexWhere((element) {
                  return "${element.chain}" == chain.first.split(":").last;
                });
                // print(tokenProvider.networkList[index].toJson());
                final params = SessionApproveParams(
                  id: eventData.id!,
                  namespaces: namespaces,
                );
                //  final approved = await
                signClient!.approve(params).then((value){
                  // setState(() {
                  //   sessions.value = signClient?.session.getAll();
                  // });
                });
                // await approved.acknowledged;
                _web3client = Web3Client(DbNetwork.dbNetwork.networkList[index].url, http.Client());
                Navigator.pop(context);
              },
              onReject: () {
                signClient!.reject(SessionRejectParams(
                  id: eventData.id!,
                  reason: getSdkError(SdkErrorKey.USER_DISCONNECTED),
                ));
                Navigator.pop(context);
              },
            ),
          )
      );
      signClient?.session.getAll();

      // _onSessionRequest(eventData.id!, eventData.params!);

    });

    signClient!.on(SignClientEvent.SESSION_REQUEST.value, (data) async {

      final eventData = data as SignClientEventParams<RequestSessionRequest>;

      // log('SESSION_REQUEST:'+ eventData.id.toString());
      // print("object my check session");
      final session = signClient!.session.get(eventData.topic!);

      switch (eventData.params!.request.method.toEip155Method()) {

        case Eip155Methods.PERSONAL_SIGN:
        // print("PERSONAL_SIGN");
          final requestParams = (eventData.params!.request.params as List).cast<String>();

          final dataToSign = requestParams[0];
          final address = requestParams[1];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.PERSONAL_MESSAGE,
          );

          await DbAccountAddress.dbAccountAddress.getDataByAddress(address);

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletSign(
                  id: eventData.id!,
                  topic: eventData.topic!,
                  session: session,
                  message: message,
                  selectedAccountPrivateAddress: DbAccountAddress.dbAccountAddress.selectPrivateAdd != "" ? DbAccountAddress.dbAccountAddress.selectPrivateAdd : selectedAccountPrivateAddress,
                  signClient: signClient!,
                ),
              )
          );
      // return _onSign(eventData.id!, eventData.topic!, session, message,context);

        case Eip155Methods.ETH_SIGN:
        // print("ETH_SIGN");
          final requestParams =
          (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.MESSAGE,
          );

          await DbAccountAddress.dbAccountAddress.getDataByAddress(address);

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletSign(
                  id: eventData.id!,
                  topic: eventData.topic!,
                  session: session,
                  message: message,
                  selectedAccountPrivateAddress: DbAccountAddress.dbAccountAddress.selectPrivateAdd != "" ? DbAccountAddress.dbAccountAddress.selectPrivateAdd : selectedAccountPrivateAddress,
                  signClient: signClient!,
                ),
              )
          );
      // return _onSign(eventData.id!, eventData.topic!, session, message,context);

        case Eip155Methods.ETH_SIGN_TYPED_DATA:
        // print("ETH_SIGN_TYPED_DATA");
          final requestParams = (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V4,
          );

          await DbAccountAddress.dbAccountAddress.getDataByAddress(address);

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletSign(
                  id: eventData.id!,
                  topic: eventData.topic!,
                  session: session,
                  message: message,
                  selectedAccountPrivateAddress: DbAccountAddress.dbAccountAddress.selectPrivateAdd != "" ? DbAccountAddress.dbAccountAddress.selectPrivateAdd : selectedAccountPrivateAddress,
                  signClient: signClient!,
                ),
              )
          );
      // return _onSign(eventData.id!, eventData.topic!, session, message,context);

        case Eip155Methods.ETH_SIGN_TYPED_DATA_V3:
        // print("ETH_SIGN_TYPED_DATA_V3");
          final requestParams =
          (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V3,
          );

          await DbAccountAddress.dbAccountAddress.getDataByAddress(address);

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletSign(
                  id: eventData.id!,
                  topic: eventData.topic!,
                  session: session,
                  message: message,
                  selectedAccountPrivateAddress: DbAccountAddress.dbAccountAddress.selectPrivateAdd != "" ? DbAccountAddress.dbAccountAddress.selectPrivateAdd : selectedAccountPrivateAddress,
                  signClient: signClient!,
                ),
              )
          );
      // return _onSign(eventData.id!, eventData.topic!, session, message,context);

        case Eip155Methods.ETH_SIGN_TYPED_DATA_V4:
        // print("ETH_SIGN_TYPED_DATA_V4");
          final requestParams = (eventData.params!.request.params as List).cast<String>();
          final dataToSign = requestParams[1];
          final address = requestParams[0];
          final message = WCEthereumSignMessage(
            data: dataToSign,
            address: address,
            type: WCSignType.TYPED_MESSAGE_V4,
          );

          await DbAccountAddress.dbAccountAddress.getDataByAddress(address);

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletSign(
                  id: eventData.id!,
                  topic: eventData.topic!,
                  session: session,
                  message: message,
                  selectedAccountPrivateAddress: DbAccountAddress.dbAccountAddress.selectPrivateAdd != "" ? DbAccountAddress.dbAccountAddress.selectPrivateAdd : selectedAccountPrivateAddress,
                  signClient: signClient!,
                ),
              )
          );
      // return _onSign(eventData.id!, eventData.topic!, session, message,context);

        case Eip155Methods.ETH_SIGN_TRANSACTION:
        // print("ETH_SIGN_TRANSACTION");
          final ethereumTransaction = WCEthereumTransaction.fromJson(
              eventData.params!.request.params.first);
          // return _onSignTransaction(
          //   eventData.id!,
          //   int.parse(eventData.params!.chainId.split(':').last),
          //   session,
          //   ethereumTransaction,
          // );


          var index =  DbNetwork.dbNetwork.networkList.indexWhere((element) {
            return "${element.chain}" == "${int.parse(eventData.params!.chainId.split(':').last)}";
          });

          _web3client = Web3Client(DbNetwork.dbNetwork.networkList[index].url, http.Client());
          final gasPrice = await _web3client.getGasPrice();

          await DbAccountAddress.dbAccountAddress.getDataByAddress(ethereumTransaction.from!);

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignTransaction(
                  web3client: _web3client,
                  id: eventData.id!,
                  gasPrice: gasPrice,
                  chainId:int.parse(eventData.params!.chainId.split(':').last),
                  session: session,
                  ethereumTransaction: ethereumTransaction,
                  title: 'Sign Transaction',
                  onConfirm: () async {
                    final privateKey =  DbAccountAddress.dbAccountAddress.selectPrivateAdd != "" ? DbAccountAddress.dbAccountAddress.selectPrivateAdd : selectedAccountPrivateAddress;
                    final creds = EthPrivateKey.fromHex(privateKey);

                    try {
                      final signedTx = await _web3client.signTransaction(
                        creds,
                        _wcEthTxToWeb3Tx(ethereumTransaction),
                        chainId: int.parse(eventData.params!
                            .chainId
                            .split(':')
                            .last),
                      );
                      final signedTxHex = bytesToHex(signedTx, include0x: true);


                      // print("ETH_SIGN_TRANSACTION object ---> $signedTxHex");
                      signClient!.respond(
                        SessionRespondParams(
                          topic: session.topic,
                          response: JsonRpcResult<String>(
                            id: eventData.id!,
                            result: signedTxHex,
                          ),
                        ),
                      ).then((value) {
                        createSignT(ethereumTransaction.toString(), "Approved",
                            session.topic);
                        setState(() {
                          Utils.wcUrlVal = "";
                        });
                        Navigator.pop(context);
                      });
                    } catch(e){

                      // ignore: use_build_context_synchronously
                      Helper.dialogCall.showToast(_scaffoldKey.currentState!.context, "Some Thing wrong please reconnect your wallet!");

                    }
                  },
                  onReject: () {
                    signClient!.respond(SessionRespondParams(
                      topic: session.topic,
                      response: JsonRpcError(id: eventData.id!),
                    ))
                        .then((value) {
                      createSignT(ethereumTransaction.toString(),"Rejected",session.topic);
                      setState(() {
                        Utils.wcUrlVal = "";
                      });
                      Navigator.pop(context);
                    });
                  },
                ),
              )
          );


        case Eip155Methods.ETH_SEND_TRANSACTION:
        // print("ETH_SEND_TRANSACTION");
        // print(eventData.params!.request.params.first['value']);
          final ethereumTransaction = WCEthereumTransaction.fromJson(
              eventData.params!.request.params.first);


          var index =  DbNetwork.dbNetwork.networkList.indexWhere((element) {
            return "${element.chain}" == "${int.parse(eventData.params!.chainId.split(':').last)}";
          });

          _web3client = Web3Client(DbNetwork.dbNetwork.networkList[index].url, http.Client());
          final gasPrice = await _web3client.getGasPrice();

          await DbAccountAddress.dbAccountAddress.getDataByAddress(ethereumTransaction.from!);

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletTransaction(
                  web3client: _web3client,
                  id: eventData.id!,
                  chainId: int.parse(eventData.params!.chainId.split(':').last),
                  session: session,
                  gasPrice: gasPrice,
                  ethereumTransaction: ethereumTransaction,
                  title: 'Send Transaction',
                  onConfirm: () async {

                    final privateKey = DbAccountAddress.dbAccountAddress.selectPrivateAdd != "" ? DbAccountAddress.dbAccountAddress.selectPrivateAdd : selectedAccountPrivateAddress;
                    final creds = EthPrivateKey.fromHex(privateKey);


                    try {
                      final txHash = await _web3client.sendTransaction(
                        creds,
                        _wcEthTxToWeb3Tx(ethereumTransaction),
                        chainId: int.parse(eventData.params!
                            .chainId.split(':').last),
                      );

                      signClient!.respond(
                        SessionRespondParams(
                          topic: session.topic,
                          response: JsonRpcResult<String>(
                            id: eventData.id!,
                            result: txHash,
                          ),
                        ),
                      ).then((value) {
                        createSignT(ethereumTransaction.toString(), "Approved",
                            session.topic);
                        setState(() {
                          Utils.wcUrlVal = "";
                        });
                        Navigator.pop(context);
                      });
                    }catch(e){
                      // print("checkk error ----> $e");

                      // ignore: use_build_context_synchronously
                      Helper.dialogCall.showToast(_scaffoldKey.currentState!.context, "Some Thing wrong please reconnect your wallet!");
                    }
                  },
                  onReject: () {
                    signClient!
                        .respond(SessionRespondParams(
                      topic: session.topic,
                      response: JsonRpcError(id: eventData.id!),
                    ))
                        .then((value) {
                      createSignT(ethereumTransaction.toString(),"Rejected",session.topic);
                      setState(() {
                        Utils.wcUrlVal = "";
                      });
                      Navigator.pop(context);
                    });
                  },
                ),
              )
          );
        case Eip155Methods.ETH_SEND_RAW_TRANSACTION:
        // print("ETH_SEND_RAW_TRANSACTION");
          break;
        default:
        // debugPrint('Unsupported request.');
      }
    });

    signClient!.on(SignClientEvent.SESSION_EVENT.value, (data) async {
      final eventData = data as SignClientEventParams<RequestSessionEvent>;
      // log('SESSION_EVENT: $eventData');
    });

    signClient!.on(SignClientEvent.SESSION_PING.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      // log('SESSION_PING: $eventData');
    });

    signClient!.on(SignClientEvent.SESSION_DELETE.value, (data) async {
      final eventData = data as SignClientEventParams<void>;
      // log('SESSION_DELETE: $eventData');
      _onSessionClosed(9999, 'Ended.');
    });

    signClient!.on(SignClientEvent.SESSION_UPDATE.value, (data) async{

    });

    if(signClient != null) {
      if (Utils.wcUrlVal != "") {
        if (Utils.wcUrlVal.split('?').last.substring(0, 9) != "requestId") {
          signClient!.pair(Utils.wcUrlVal);
        }
        Utils.wcUrlVal = "";
      }
    }

  }



  createSignT(String value,String type,session) async {

    String date = DateFormat('MMM dd, hh:mm a').format(DateTime.now());

    await DBWalletConnectV2.dbWalletConnectV2.createSignt(
        "$date",
        "$value",
        "$type",
        "$session"
    );

  }

  _onSessionClosed(int? code, String? reason) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          backgroundColor: MyColor.backgroundColor,
          title: Text(
            "Session Ended",
            style:MyStyle.tx18RWhite.copyWith(
                fontSize: 16
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                  'Some Error Occurred. ERROR CODE: $code',
                style:MyStyle.tx18RWhite.copyWith(
                    fontSize: 14
                ),
              ),
            ),
            if (reason != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                    'Failure Reason: $reason',
                  style:MyStyle.tx18RWhite.copyWith(
                      fontSize: 14
                  ),
                ),
              ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: MyColor.blueColor,
                  ),
                  onPressed: () {
                    setState(() {

                      Utils.wcUrlVal = "";
                      sessions.value = signClient?.session.getAll();
                      deleteWalletDB();
                    });
                    //sessions = signClient?.session?.getAll();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Close',
                    style:MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Transaction _wcEthTxToWeb3Tx(WCEthereumTransaction ethereumTransaction) {
    return Transaction(
      from: EthereumAddress.fromHex(ethereumTransaction.from!),
      to: EthereumAddress.fromHex(ethereumTransaction.to!),
      maxGas: ethereumTransaction.gasLimit != null
          ? int.tryParse(ethereumTransaction.gasLimit!)
          : null,
      gasPrice: ethereumTransaction.gasPrice != null
          ? EtherAmount.inWei(BigInt.parse(ethereumTransaction.gasPrice!))
          : null,
      value: EtherAmount.inWei(BigInt.parse(ethereumTransaction.value ?? '0')),
      data: hexToBytes(ethereumTransaction.data!),
      nonce: ethereumTransaction.nonce != null
          ? int.tryParse(ethereumTransaction.nonce!)
          : null,
      maxFeePerGas: ethereumTransaction.maxFeePerGas != null
          ? EtherAmount.inWei(BigInt.parse(ethereumTransaction.maxFeePerGas!))
          : null,
      maxPriorityFeePerGas: ethereumTransaction.maxPriorityFeePerGas != null
          ? EtherAmount.inWei(
          BigInt.parse(ethereumTransaction.maxPriorityFeePerGas!))
          : null,
    );
  }

  deleteWalletDB() async {

    await DBWalletConnectV2.dbWalletConnectV2.getAllSignT();
    List deleteList = [];
    for(var topic in sessions.value!){
      for(var dbTopic in DBWalletConnectV2.dbWalletConnectV2.signTListAll){
        if(dbTopic['publicKey'] != topic.topic){
          deleteList.add(dbTopic['publicKey']);
        }
      }
    }
    await DBWalletConnectV2.dbWalletConnectV2.deleteSignTByKey(deleteList);
  }
  
  @override
  void initState() {
    _internetProvider = Provider.of<InternetProvider>(context, listen: false);
    super.initState();
    checkInternet();
    checkForWc2Url();
  }

  @override
  Widget build(BuildContext context) {

    _internetProvider = Provider.of<InternetProvider>(context, listen: true);
    final dashProvider = Provider.of<DashboardProvider>(context,listen: true);

    return  Scaffold(
    key: _scaffoldKey,
      extendBody: true,
      bottomNavigationBar: Container(
        height: 60,
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color:  MyColor.backgroundColor,
          border: Border.all(
            color: MyColor.boarderColor
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
        ),
        child: Row(
          children: [

            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(0);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/wallet.png",
                      height: 20,
                      width: 20,
                      fit: BoxFit.contain,
                      color: dashProvider.currentIndex == 0 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Wallet",
                      style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 13,
                        color: dashProvider.currentIndex == 0 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(1);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/card.png",
                      height: 26,
                      width: 26,
                      fit: BoxFit.contain,
                      color: dashProvider.currentIndex == 1 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Buy",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 13,
                        color: dashProvider.currentIndex == 1 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(2);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/card.png",
                      height: 26,
                      width: 26,
                      fit: BoxFit.contain,
                          color: dashProvider.currentIndex == 2 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Sell",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 13,
                          color: dashProvider.currentIndex == 2 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(3);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/support.png",
                      height: 22,
                      width: 22 ,
                      fit: BoxFit.contain,
                          color: dashProvider.currentIndex == 3 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Support",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 13,
                          color: dashProvider.currentIndex == 3 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  dashProvider.changeBottomIndex(4);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/images/dashboard/setting.png",
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                          color: dashProvider.currentIndex == 4 ? MyColor.greenColor : MyColor.textGreyColor,
                    ),
                    Text(
                      "Setting",
                      style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 13,
                          color: dashProvider.currentIndex == 4 ? MyColor.greenColor : MyColor.textGreyColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: (){
          return _onWillPop();
        },
        child: Stack(
          children:[
            _internetProvider.isOnline == false
                ?
            Positioned(
              bottom: 95,
              left: 0,
              right: 0,
              child: Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                    color: MyColor.redColor
                ),
                child: Center(
                  child: Text(
                    'No connection',
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                ),
              ),
            )
                :
            const SizedBox(),

            body[dashProvider.currentIndex]
          ],
        ),
      )
    );
  }
}


