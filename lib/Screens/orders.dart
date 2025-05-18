import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Screens/order_Tracking_Page.dart';
import 'package:final_year_project/Screens/pendingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Orders',
              style: TextStyle(fontSize: 27, color: Colors.white),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser.email)
                  .collection('orders')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: Colors.cyanAccent));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading orders',
                          style: TextStyle(color: Colors.white)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('No orders found',
                          style: TextStyle(color: Colors.white)));
                }

                final userOrders = snapshot.data!
                    .docs; /*List of user's orders that act as 
                                                          pointers to the global orders collection    
                                                        */

                return ListView.builder(
                  itemCount: userOrders.length,
                  itemBuilder: (context, index) {
                    final orderId = userOrders[index]
                        .id; // Fetching order ID from user's orders collection

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .doc(
                              orderId) /*Fetching order details from global orders collection
                                          making sure to use the order ID from user's orders collection*/
                          .snapshots(),
                      builder: (context, orderSnapshot) {
                        if (orderSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.cyanAccent),
                            ),
                          );
                        }
                        if (!orderSnapshot
                                .hasData || // Check if order exists in global orders collection
                            !orderSnapshot.data!.exists) {
                          return SizedBox
                              .shrink(); // Don't show anything if order not found in global orders
                        }

                        final orderData =
                            orderSnapshot.data!.data() as Map<String, dynamic>;
                        final items =
                            orderData['items'] as List<dynamic>? ?? [];
                        final status = orderData['status'] ?? 'Unknown';
                        final paymentMethod =
                            orderData['paymentMethod'] ?? 'Unknown';
                        final total = orderData['total'] ?? 0.0;

                        String itemDetails = items.isNotEmpty
                            ? items
                                .map((item) =>
                                    "${item['name']} (x${item['qty']})")
                                .join(", ")
                            : "No items";

                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text("Order ID: $orderId",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(itemDetails),
                                if (paymentMethod == 'Cash')
                                  Text(
                                    "Total Amount: RM$total",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(status,
                                style: TextStyle(
                                  color: status == 'Completed'
                                      ? Colors.green
                                      : (status == 'Ongoing'
                                          ? Colors.blue
                                          : Colors.orange),
                                  fontWeight: FontWeight.bold,
                                )),
                            onTap: () {
                              if (status == "Pending") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Pendingpage(orderId: orderId),
                                  ),
                                );
                              } else if (status == "Ongoing") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OrderTrackingPage(orderId: orderId),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
