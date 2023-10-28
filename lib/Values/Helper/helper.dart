import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';

class Helper {
  static final Helper dialogCall = Helper._();

  Helper._();

  showToast(context,String messages){
    Fluttertoast.showToast(
        msg: messages,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: MyColor.darkGrey01Color,
        textColor: MyColor.whiteColor,
        fontSize: 15.0
    );
  }

  showAlertDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      backgroundColor:MyColor.backgroundColor,
      content: Row(
        children: [
          const CircularProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(MyColor.blueColor),
          ),
          Container(
              margin: const EdgeInsets.only(left: 5),
              child: const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text("Loading...",
                  style: TextStyle(
                    fontSize: 18,
                    color: MyColor.whiteColor,
                  ),
                ),
              )
          ),
        ],
      ),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }


}