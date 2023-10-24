import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dashProvider = Provider.of<DashboardProvider>(context);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return  Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // instantExchangers images
                Center(
                  child: Image.asset(
                    "assets/images/dashboard/instantExchangers.png",
                    width: width * 0.4,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // title for purchase
                Text(
                  "Purchase Perfect Money, Bitcoin, Tron, USDT, and more using "
                      "Naira bank transfers. Powered by InstantExchangers.",
                  textAlign: TextAlign.center,
                  style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 15
                  ),
                ),
                const SizedBox(height: 20),

                // SignIn text
                Text(
                  "SignIn",
                  textAlign: TextAlign.center,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 25
                  ),
                ),
                const SizedBox(height: 20),

                // email filed
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  cursorColor: MyColor.greenColor,
                  style: MyStyle.tx18RWhite,
                  decoration: MyStyle.textInputDecoration.copyWith(
                      hintText: "Email address",
                      isDense: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15)
                  ),
                ),
                const SizedBox(height: 20),

                //password filed
                TextFormField(
                    controller: passController,
                    obscureText:dashProvider.showPassword,
                    cursorColor: MyColor.greenColor,
                    style: MyStyle.tx18RWhite,
                    decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Passwords",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15
                        ),
                      suffixIcon: dashProvider.showPassword
                          ?
                      IconButton(
                          onPressed: (){
                            dashProvider.changeBuyShowPassword(false);
                          },
                          icon: const Icon(
                            Icons.visibility,
                            color: MyColor.mainWhiteColor,
                          )
                      )
                          :
                      IconButton(
                          onPressed: (){
                            dashProvider.changeBuyShowPassword(true);
                          },
                          icon: const Icon(
                            Icons.visibility_off,
                            color: MyColor.mainWhiteColor,
                          )
                      )
                    ),
                ),
                const SizedBox(height: 20),

                // login button
                InkWell(
                  onTap: () {},
                  child: Container(
                    alignment: Alignment.center,
                    height: 45,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: MyStyle.buttonDecoration,
                    child: const Text(
                      "Login",
                      style: MyStyle.tx18BWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                //Forget Your Password?
                Text(
                  "Forget Your Password?",
                  textAlign: TextAlign.center,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
                const SizedBox(height: 8),

                //Register!
                Text(
                  "Register!",
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
    );
  }
}
