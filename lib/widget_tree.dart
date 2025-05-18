import 'package:final_year_project/auth/auth.dart';
import'package:final_year_project/home.dart';
import 'package:final_year_project/auth/login_Register_Page.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges, // check if user is logged in or not
      builder: (context,snapshot){
        if (snapshot.hasData){
          return HomePage();

        } else{
          return  LoginPage();
        }
      },
      );
  }
}