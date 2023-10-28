import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Default_Token_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ignore: must_be_immutable
class AddAssetsScreen extends StatefulWidget {
  String selectedAccountId;
  AddAssetsScreen({
    super.key,
    required this.selectedAccountId
  });

  @override
  State<AddAssetsScreen> createState() => _AddAssetsScreenState();
}

class _AddAssetsScreenState extends State<AddAssetsScreen> {

  TextEditingController searchController = TextEditingController();
  List toggleList = [];
  bool isLoading = true;

  var selectedAccountId = "";
  // get token list
  getCoin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);
    await DBDefaultTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);
    toggleList = List.filled(DBTokenProvider.dbTokenProvider.tokenList.length, false);

    for(int i = 0; i< DBTokenProvider.dbTokenProvider.tokenList.length; i++){
      var list = DBTokenProvider.dbTokenProvider.tokenList[i];
      // print(list.name);
      int index = DBDefaultTokenProvider.dbTokenProvider.tokenDefaultList.indexWhere((element) => element.id == list.id);
      if(index != -1){
        print(list.name);
        toggleList[i] = true;
      }
    }

    isLoading = false;
    setState(() {});
  }

  // upload wallet token list (add or remove token from list)
  toggleButton(id,changeBool,index,list)async{
    await DBDefaultTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);


      SharedPreferences sharedPre = await SharedPreferences.getInstance();
      var listCoin = sharedPre.getString("default")!.split(",");
      if (changeBool) {
        await DBDefaultTokenProvider.dbTokenProvider.createToken(list);
        listCoin.add("$id");
        sharedPre.setString("default", listCoin.join(","));
        setState(() {
          toggleList[index] = changeBool;
        });
      } else {
        if (DBDefaultTokenProvider.dbTokenProvider.tokenDefaultList.length >
            1) {
          await DBDefaultTokenProvider.dbTokenProvider.deleteToken(
              id, widget.selectedAccountId
          );
          listCoin.remove("$id");
          sharedPre.setString("default", listCoin.join(","));

          setState(() {
            toggleList[index] = changeBool;
          });
        }else{
          // ignore: use_build_context_synchronously
          Helper.dialogCall.showToast(context, "You can't remove all coin");
        }
      }
    }


  @override
  void initState() {
    super.initState();
    getCoin();
  }


  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.fromLTRB(20,22,20,10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
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
            "Add Asset",
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
              fillColor: MyColor.darkGrey01Color,
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
            child : isLoading
                ?
            const Center(
                child: CircularProgressIndicator(
                  color: MyColor.greenColor,
                )
            )
                :
            ListView.builder(
              itemCount: DBTokenProvider.dbTokenProvider.tokenList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {

                var list = DBTokenProvider.dbTokenProvider.tokenList[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
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

                      FlutterSwitch(
                        width: 50.0,
                        height: 24.0,
                        toggleSize: 15.0,
                        valueFontSize: 0.0,
                        borderRadius: 30.0,
                        inactiveColor: MyColor.boarderColor,
                        activeColor: MyColor.greenColor,
                        value: toggleList[index],
                        showOnOff: false,
                        onToggle: (val) async{
                          toggleButton(list.id,val,index,list);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
