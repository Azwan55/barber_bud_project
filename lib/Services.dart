
//no longer used its was good time to learn how to use it
//this is the code for the services page
import 'package:flutter/material.dart';

class CategoriesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: SizedBox(
                  width: 150.0,
                  height: 170.0,
                  child: Card(
                    color: Colors.white,
                    elevation: 10,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Image.asset('asset/image/1.png'),
                        ),
                        Text(
                          ' Haircut',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap:(){},
              ), //Center
              //Card
              InkWell(
                child: SizedBox(
                  width: 150.0,
                  height: 170.0,
                  child: Card(
                    color: Colors.white,
                    elevation: 10,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Image.asset('asset/image/2.png'),
                        ),
                        Text(
                          'Details Cut',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap :(){},
              ),

              //
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: SizedBox(
                  width: 150.0,
                  height: 170.0,
                  child: Card(
                    color: Colors.white,
                    elevation: 10,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Image.asset('asset/image/3.png'),
                        ),
                        Text(
                          'Kids Haircut',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: (){},
              ), //Center
              //Card
              InkWell(
                child: SizedBox(
                  width: 150.0,
                  height: 170.0,
                  child: Card(
                    color: Colors.white,
                    elevation: 10,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Image.asset('asset/image/4.png'),
                        ),
                        Text(
                          'Shaving',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap:() {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
