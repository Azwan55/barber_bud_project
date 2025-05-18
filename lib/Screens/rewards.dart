import 'package:final_year_project/model/voucherList.dart';
import 'package:final_year_project/model/voucherModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardPage extends StatelessWidget {
  final VoucherList voucherList = VoucherList();

  // Function to add vouchers to Firestore
  Future<void> addVouchersToFirestore(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to save vouchers"),backgroundColor: Colors.red),
      );
      return;
    }

    final userEmail = user.email!;

    for (var voucher in voucherCatalog) {
      await voucherList.addVoucher(userEmail, voucher);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Vouchers added successfully!"),backgroundColor: Colors.green),
    );
  }

  // Function to remove all vouchers from Firestore
  Future<void> removeVouchersFromFirestore(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to remove vouchers"),backgroundColor: Colors.red),
      );
      return;
    }

    final userEmail = user.email!;

    try {
      QuerySnapshot snapshot = await voucherList.getVoucherCollection(userEmail).get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All vouchers removed successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing vouchers: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Please log in to view rewards",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final userEmail = user.email!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<VoucherModel>>(
        stream: voucherList.getVouchers(userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              color: Colors.cyanAccent,
            ));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No vouchers available",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final vouchers = snapshot.data!;

          // Filter vouchers to show only those with isUsed = false
          final unusedVouchers = vouchers.where((voucher) => !voucher.isUsed).toList();

          return Wrap(
            direction: Axis.horizontal,
            runSpacing: 20,
            children: [
              // Title
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Rewards',
                  style: TextStyle(
                    fontSize: 27,
                    color: Colors.white,
                  ),
                ),
              ),

              // Display filtered vouchers dynamically from Firestore
              for (var voucher in unusedVouchers)
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: InkWell(
                    child: SizedBox(
                      width: 415,
                      height: 100,
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 10,
                          children: [
                            Image.asset(
                              voucher.image,
                              fit: BoxFit.fill,
                            ),
                            Text(
                              voucher.name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      // Future enhancement: Add voucher redemption logic
                    },
                  ),
                ),
            ],
          );
        },
      ),

      // Floating Buttons (Add and Remove)
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => addVouchersToFirestore(context),
            backgroundColor: Colors.white,
            child: Icon(Icons.add, color: Colors.black),
          ),
          SizedBox(height: 15), // Space between buttons
          FloatingActionButton(
            onPressed: () => removeVouchersFromFirestore(context),
            backgroundColor: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
