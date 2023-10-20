import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1),(){
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen(),
          ), (route) => false
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child:  RichText(
          text: const TextSpan(
              children: [
                TextSpan(
                    text: "Jost",
                    style:MyStyle.tx28BYellow
                ),
                TextSpan(
                    text: "Pay",
                    style:MyStyle.tx28RGreen
                ),
              ]
          )
      ),
          )
      ),
    );
  }
}
