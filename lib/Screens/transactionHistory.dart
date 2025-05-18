import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Resources/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Transactionhistory extends StatefulWidget {
  const Transactionhistory({super.key});

  @override
  State<Transactionhistory> createState() => _TransactionhistoryState();
}

class _TransactionhistoryState extends State<Transactionhistory> {
  final currentUser = FirebaseAuth.instance.currentUser!;
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
        title: Text('Transaction History',
            style: TextStyle(color: SecondaryColor)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.email)
            .collection('transactions')
            .orderBy('timestamp', descending: true) // Sort by latest
            .snapshots(),
        builder: (context, transactionSnapshot) {
          if (transactionSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (transactionSnapshot.hasError) {
            return Center(
              child: Text(
                'Error loading transactions',
                style: TextStyle(color: SecondaryColor, fontSize: 20),
              ),
            );
          }

          if (!transactionSnapshot.hasData ||
              transactionSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No recent transactions',
                style: TextStyle(color: SecondaryColor, fontSize: 20),
              ),
            );
          }

          return ListView(
            children: transactionSnapshot.data!.docs.map((doc) {
              final transactionData = doc.data() as Map<String, dynamic>;

              String details = transactionData['details'] ?? '';
              String paymentMethod = transactionData['paymentMethod'] ?? '';
              String amount = transactionData['amount'].toString();
              bool isTopUp = details == 'Top-up';
              bool isQRTransfer = details == 'QR Transfer';
              bool isCancelled = details == 'cancel';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    isCancelled
                        ? "Cancelled"
                        : isTopUp
                            ? "Top-Up"
                            : isQRTransfer
                                ? "QR Transfer"
                                : "Order ID: ${transactionData['orderId'] ?? 'N/A'}",
                    style: TextStyle(color: PrimaryColor),
                  ),
                  subtitle: (paymentMethod.isNotEmpty)
                      ? Text("Payment: $paymentMethod")
                      : null,
                  trailing: Text(
                    isCancelled
                        ? "RM $amount"
                        : (isTopUp ? "+ " : "- ") + "RM $amount",
                    style: TextStyle(
                      color: isCancelled
                          ? Colors.grey
                          : (isTopUp ? Colors.green : Colors.red),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
