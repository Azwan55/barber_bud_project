import 'package:final_year_project/Resources/constant.dart';
import 'package:final_year_project/model/item_model.dart';
import 'package:final_year_project/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.item,
    this.isCartItems = false,
  });

  final bool isCartItems;
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        width: 380,
        height: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [

                if (isCartItems) ...[
                  Image.asset(item.image, width: 70, height: 70),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: PrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "RM ${item.price}",
                  style: TextStyle(
                    color: PrimaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                  SizedBox(width: 10),

                  // Minus Button
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.red),
                    onPressed: () {
                      provider.removeItem(item,);
                    },
                  ),

                  // Quantity Display
                  Text(
                    item.qty.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  // Plus Button
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      provider.addItem(item,);
                    },
                  ),
                ] else ...[
                  Image.asset(item.image, width: 70, height: 70),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: PrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "RM ${item.price}",
                  style: TextStyle(
                    color: PrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                  // Add Button for normal item list (not cart)
                  IconButton(
                    icon: Icon(Icons.add_shopping_cart, color: Colors.green),
                    onPressed: () {
                      provider.addItem(item, );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
