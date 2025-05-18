import 'package:final_year_project/Resources/constant.dart';
import 'package:final_year_project/Resources/item_widget.dart';
import 'package:final_year_project/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {

  

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

// Fetch cart items from Firestore
@override
void initState() {
  super.initState();
  Future.delayed(Duration.zero, () {
    Provider.of<CartProvider>(context, listen: false).fetchCartFromFirestore();
  });
}


  @override
  Widget build(BuildContext context) {
     

    return Scaffold(
      backgroundColor: PrimaryColor,
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: SecondaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Cart',
          style: TextStyle(color: SecondaryColor),
        ),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: provider.cartItems.isEmpty
                    ? Center(
                        child: Text(
                          "Your cart is empty",
                          style: TextStyle(
                            color: SecondaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.cartItems.length,
                        itemBuilder: (context, index) {
                          return ItemWidget(
                            isCartItems: true,
                            item: provider.cartItems[index], // Display cart items in a list
                          );
                        },
                      ),
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text(
                  'Total',
                  style: TextStyle(color: SecondaryColor, fontSize: 25),
                ),
                trailing: Text(
                  'RM ${provider.price.toStringAsFixed(2)}',// Display total price
                  style: TextStyle(color: SecondaryColor, fontSize: 25),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(SecondaryColor),
                ),
                onPressed: provider.cartItems.isEmpty
                    ? null // Disable checkout if cart is empty
                    : ()  {
                        
                        Navigator.pushNamed(context, 'payment');
                      },
                child: Text(
                  'Checkout',
                  style: TextStyle(color: PrimaryColor),
                ),
              ),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
