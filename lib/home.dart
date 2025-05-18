import 'package:final_year_project/Screens/cart_Screen.dart';
import 'package:final_year_project/Screens/homePageBody.dart';
import 'package:final_year_project/Screens/ewallet.dart';
import 'package:final_year_project/Screens/rewards.dart';
import 'package:final_year_project/Screens/orders.dart';
import 'package:final_year_project/Screens/profile.dart';
import 'package:final_year_project/Resources/constant.dart';
import 'package:final_year_project/provider/cart_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_year_project/auth/auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? get user => Auth().currentUser;

  int index = 0;
  final screens = [
    /* 
                        screens will show which page to go base on index on tapped
                        bottom navigation bar that link to body screen[index] 
                           */
    HomePageBody(),
    OrdersPage(),
    EwalletPage(),
    RewardPage(),
    ProfilePage(),
  ];

  final items = <Widget>[
    //Icon widget for bottom navigation bar
    Icon(Icons.home, size: 40),
    Icon(Icons.list_alt, size: 40),
    Icon(Icons.account_balance_wallet, size: 40),
    Icon(Icons.stars, size: 40),
    Icon(Icons.person, size: 40),
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider = Provider.of<CartProvider>(context);
    int totalItems = provider.cartItems
        .fold(0, (sum, item) => sum + item.qty); //get total items in cart
    return Scaffold(
      backgroundColor: PrimaryColor,
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        actions: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(top: 5, right: 10),
            child: badges.Badge(
              showBadge:
                  totalItems > 0, //show badge if cart item is more than 0

              badgeContent: Text(
                totalItems.toString(),//show total items in cart
                style: TextStyle(color: SecondaryColor),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(),
                    ),
                  );
                },
                child: Icon(
                  CupertinoIcons.cart,
                  size: 30,
                  color: SecondaryColor,
                ),
              ),
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          'Barber Bud',
          style: TextStyle(
            color: SecondaryColor,
            fontSize: 20,
          ),
        ),
      ),
      body: screens[index],
      /*
                              the screen will take index that been put by set state
                              in bottom navigation bar and dispaly the screen[] base
                              on its index.
                            */
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Theme(
          //bottom navigation bar
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(color: Colors.black),
          ),
          child: CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            buttonBackgroundColor: Colors.blueAccent,
            color: const Color.fromARGB(255, 240, 239, 239),
            items: items,
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 300),
            height: 60,
            index: index,
            onTap: (index) {
              setState(() {
                //set current index as index for screens[] to use.
                this.index = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
