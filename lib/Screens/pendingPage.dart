import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/Resources/constant.dart';

class Pendingpage extends StatelessWidget {
  final String orderId;

  const Pendingpage({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryColor,
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: SecondaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pending',
          style: TextStyle(color: SecondaryColor),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),
            Icon(Icons.pending_actions, size: 100, color: SecondaryColor),
            SizedBox(height: 70),
            CircularProgressIndicator(color: Colors.cyanAccent),
            SizedBox(height: 20),
            Text(
              'Waiting for Barber to accept order',
              style: TextStyle(color: SecondaryColor, fontSize: 30),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 100),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _cancelOrder(context);
              },
              child: Text(
                'Cancel Order',
                style: TextStyle(color: SecondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Future<void> _cancelOrder(BuildContext context) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    try {
      final orderRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .collection('orders')
          .doc(orderId);

      final orderSnapshot = await orderRef.get();

      if (orderSnapshot.exists) {
        String paymentMethod = orderSnapshot['paymentMethod']; // Retrieve payment method
        double totalAmount = (orderSnapshot['total'] as num).toDouble(); // Retrieve totalAmount

        if (paymentMethod == 'eWallet') {
          final eWalletSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.email)
              .collection('ewallet')
              .limit(1)
              .get();

          if (eWalletSnapshot.docs.isNotEmpty) {
            DocumentSnapshot eWalletDoc = eWalletSnapshot.docs.first;
            double currentBalance = (eWalletDoc['balance'] as num).toDouble(); // Retrieve balance
            double updatedBalance = currentBalance + totalAmount; // Add refunded amount

            // Update the balance in Firestore
            await eWalletDoc.reference.update({'balance': updatedBalance});
          }

          // Show refund message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order canceled and amount refunded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Show message if payment is not eWallet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order canceled, but no refund was issued'),
              backgroundColor: Colors.orange,
            ),
          );
        }

        // Store transaction details with paymentMethod
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.email)
            .collection('transactions')
            .add({
          'orderId': orderId,
          'details': 'cancel',
          'amount': totalAmount,
          'paymentMethod': paymentMethod, // Save the payment method
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Delete the order after processing
        await orderRef.delete();

        Navigator.pop(context); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order not found!')),
        );
      }
    } catch (e) {
      print('Error canceling order: $e'); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling order: $e')),
      );
    }
  }
}


}
