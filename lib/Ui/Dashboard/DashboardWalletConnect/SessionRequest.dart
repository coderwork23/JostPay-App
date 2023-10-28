import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:wallet_connect_dart_v2/core/models/app_metadata.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/jsonrpc/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';

class SessionRequest extends StatefulWidget {

  final String account1;
  final RequestSessionPropose proposal;
  final void Function(SessionNamespaces,List<String>) onApprove;
  final void Function() onReject;

  SessionRequest({
    Key? key,
    required this.account1,
    required this.proposal,
    required this.onApprove,
    required this.onReject,
  }): super(key: key);

  @override
  State<SessionRequest> createState() => _SessionRequestState();
}

class _SessionRequestState extends State<SessionRequest> {
  late AppMetadata _metadata;
  late List<String> _selectedAccountIds;
  late TokenProvider tokenProvider;



  @override
  void initState() {
    tokenProvider = Provider.of<TokenProvider>(context,listen: false);
    _metadata = widget.proposal.proposer.metadata;
    super.initState();
  }

  var chinId = "0";

  @override
  Widget build(BuildContext context) {

    tokenProvider = Provider.of<TokenProvider>(context,listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
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
          "Sign Authentication",
          //"Add Token",
        ),
      ),
      body: Container(
        width: width,
        height: height,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    Container(
                      height: 50.0,
                      width: 50.0,
                      padding: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                        image: _metadata.icons.isNotEmpty
                            ? DecorationImage(
                            image: NetworkImage(_metadata.icons.first))
                            : null,
                      ),
                      child: _metadata.icons.isNotEmpty
                          ? null
                          :
                      Center(
                        child: Text(
                          _metadata.name.substring(0, 1),
                          style:  MyStyle.tx18RWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metadata.name,
                            style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                            ),
                            maxLines: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              _metadata.url,
                              maxLines: 1,
                              style:  MyStyle.tx18RWhite.copyWith(
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (_, idx) {
                  final item = widget.proposal.requiredNamespaces.entries.elementAt(idx);
                  print(item.value.toJson());
                  print(item.key);
                  print(item.value.chains);
                  print("check ---> ");
                  print(DbNetwork.dbNetwork.networkList.length);



                  int value = DbNetwork.dbNetwork.networkList.indexWhere((element) {
                    print("element.chain -----> ${element.chain}");
                    return "${element.chain}" == item.value.chains.first.split(":").last && element.isEVM == 1;
                  });

                  print("value ---->  $value");
                  print("chain name ---> ${item.value.chains.first.split(":").last}");

                  if(value != -1){
                    // print("test val"+value.toString());
                    chinId = item.value.chains.first.split(":").last;
                    // print("test chain id"+chinId);
                  }else{
                    // print("check 2 ---> ");
                   Helper.dialogCall.showToast(context, "Network not implemented!!");
                    Navigator.pop(context);
                  }

                  return NamespaceView(
                    type: item.key,
                    accountAddress: widget.account1,
                    namespace: item.value,
                  );
                },
                separatorBuilder: (_, __) =>
                const Divider(height: 1.5, thickness: 1.5),
                itemCount: widget.proposal.requiredNamespaces.entries.length,
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: MyColor.greenColor,
                        ),
                        onPressed: () {
                          final SessionNamespaces params = {};
                          for (final entry
                          in widget.proposal.requiredNamespaces.entries) {
                            final List<String> accounts = [];

                            accounts.add("eip155:$chinId:"+widget.account1);
                            // print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"+accounts.toString());
                            params[entry.key] = SessionNamespace(
                              accounts: accounts,
                              methods: entry.value.methods,
                              events: entry.value.events,
                            );
                            // log('SESSION: ${params[entry.key]!.toJson()}');
                          }
                          // widget.onApprove(params);
                          widget.onApprove(params,widget.proposal.requiredNamespaces.entries.first.value.chains);

                        },
                        child: Text(
                          'Approve',
                          style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: MyColor.redColor,
                        ),
                        onPressed: widget.onReject,
                        child: Text(
                          "Reject",
                          style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

class NamespaceView extends StatefulWidget {
  final String type;
  final String accountAddress;
  final ProposalRequiredNamespace namespace;

  const NamespaceView({
    key,
    required this.type,
    required this.accountAddress,
    required this.namespace,
  });

  @override
  State<NamespaceView> createState() => _NamespaceViewState();
}

class _NamespaceViewState extends State<NamespaceView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
             "Review Permissions",
            style:  MyStyle.tx18RWhite.copyWith(
                fontSize: 16
            ),
          ),
          const SizedBox(height: 8.0),
          ...widget.namespace.chains
              .map((chain) => Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color:  MyColor.darkGrey01Color,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chain,
                  style:  MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Text(
                    "Methods",
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                ),
                Text(
                  widget.namespace.methods.isEmpty
                      ? '-'
                      :
                  widget.namespace.methods.join(', '),
                  style:  MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Text(
                    "Events",
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                ),
                Text(
                  widget.namespace.events.isEmpty
                      ? '-'
                      : widget.namespace.events.join(', '),
                  style:  MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
              ],
            ),
          )).toList(),

          Padding(
            padding: EdgeInsets.only(top: 8.0,bottom: 8),
            child: Text(
              "Selected Account",
              style:  MyStyle.tx18RWhite.copyWith(
                  fontSize: 16
              ),
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: MyColor.darkGrey01Color,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              '${widget.accountAddress.substring(0, 6)}...${widget.accountAddress.substring(widget.accountAddress.length - 6)}',
              style:  MyStyle.tx18RWhite.copyWith(
                  fontSize: 14
              ),
            ),
          )
        ],
      ),
    );
  }
}
