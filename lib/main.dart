import 'package:final_year_project/Screens/aboutBarberBud.dart';
import 'package:final_year_project/Screens/orders.dart';
import 'package:final_year_project/Screens/paymentPage.dart';
import 'package:final_year_project/Screens/qrCodeScreen.dart';
import 'package:final_year_project/Screens/transactionHistory.dart';
import 'package:final_year_project/home.dart';
import 'package:final_year_project/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/Screens/SplashScreenMain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //initialize the app
  await Firebase.initializeApp(); //initialize firebase
  runApp(MyApp()); //run the app
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CartProvider(), //provide the cart provider to the app
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          "/": (context) => SplashScreenMain(),
          "splash": (context) => SplashScreenMain(),
          "home": (context) => HomePage(),     
          "payment": (context) => PaymentPage(),
          "qrcode": (context) => QrCodeScreen(),
          "transactionHistory": (context) => Transactionhistory(),
          "aboutBarberBud": (context) => Aboutbarberbud(),
          "order": (context) => OrdersPage(),
         
        },
      ),
    );
  }
}
