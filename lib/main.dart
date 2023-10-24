import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/Ui/Authentication/SplashScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:provider/provider.dart';

import 'Provider/DashboardProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ]
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MaterialColor kPrimaryColor = const MaterialColor(
    0xFF232325,
    <int, Color>{
      50: Color(0xFF232325),
      100: Color(0xFF232325),
      200: Color(0xFF232325),
      300: Color(0xFF232325),
      400: Color(0xFF232325),
      500: Color(0xFF232325),
      600: Color(0xFF232325),
      700: Color(0xFF232325),
      800: Color(0xFF232325),
      900: Color(0xFF232325),
    },
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JostPayWallet',
        theme: ThemeData(
          primarySwatch: kPrimaryColor,
          scaffoldBackgroundColor: MyColor.backgroundColor,
          fontFamily: "NimbusSanLRegular",
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            elevation: 0,
          )
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
