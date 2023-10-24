import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';


class AddAssetsScreen extends StatefulWidget {
  const AddAssetsScreen({super.key});

  @override
  State<AddAssetsScreen> createState() => _AddAssetsScreenState();
}

class _AddAssetsScreenState extends State<AddAssetsScreen> {

  TextEditingController searchController = TextEditingController();
  List toggleList = List.filled(20, false);
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
            child : ListView.builder(
              itemCount: 20,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/bitcoin.png",
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          "Bitcoin",
                          style: MyStyle.tx18RWhite,
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
                        onToggle: (val) {
                          setState(() {
                            toggleList[index] = val;
                          });
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
